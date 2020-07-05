/**
 * A collection of query utilities shared across multiple models
 */
component displayname="QueryUtils" accessors="true" {

    /**
     * A reference to the owning query builder
     */
    property name="builder";

    /**
     * Extract a binding from a value.
     *
     * @value The value from which to extract the binding
     *
     * @return any
     */
    public any function extractBinding( any value ) {
        if ( isNull( arguments.value ) ) {
            return { "cfsqltype": "CF_SQL_VARCHAR", "value": "", "null": true };
        }

        if ( isBuilder( arguments.value ) ) {
            return arguments.value.getBindings();
        }

        var binding = "";
        if ( isStruct( value ) ) {
            if ( structKeyExists( value, "isExpression" ) && value.isExpression == true ) {
                return value;
            }
            binding = value;
        } else {
            binding = { value: normalizeSqlValue( value ) };
        }

        structAppend( binding, { cfsqltype: inferSqlType( binding.value ), list: false, null: false }, false );

        return binding;
    }

    /**
     * Infer the correct cf_sql_type from a value.
     *
     * @value The value from which to infer the cf_sql_type.
     *
     * @return string
     */
    public string function inferSqlType( required any value ) {
        if ( isArray( value ) ) {
            return arraySame(
                value,
                function( val ) {
                    return inferSqlType( val );
                },
                "CF_SQL_VARCHAR"
            );
        }

        if ( checkIsActuallyNumeric( value ) ) {
            return "CF_SQL_NUMERIC";
        }

        if ( isDate( value ) ) {
            return "CF_SQL_TIMESTAMP";
        }

        return "CF_SQL_VARCHAR";
    }

    /**
     * Returns true if a value is an Expression.
     *
     * @value The value to check if it is an Expression.
     *
     * @return boolean
     */
    public boolean function isExpression( required any value ) {
        return !isSimpleValue( arguments.value ) &&
        !isArray( arguments.value ) &&
        structKeyExists( arguments.value, "isExpression" );
    }

    /**
     * Returns true if a value is not an Expression.
     *
     * @value The value to check if it is not an Expression.
     *
     * @return boolean
     */
    public boolean function isNotExpression( required any value ) {
        return isSimpleValue( arguments.value ) ||
        isArray( arguments.value ) ||
        !structKeyExists( arguments.value, "isExpression" );
    }

    /**
     * Returns true if a value is an Expression.
     *
     * @value The value to check if it is an Expression.
     *
     * @return boolean
     */
    public boolean function isBuilder( required any value ) {
        return !isSimpleValue( arguments.value ) &&
        !isArray( arguments.value ) &&
        structKeyExists( arguments.value, "isBuilder" );
    }

    /**
     * Returns true if a value is not an Expression.
     *
     * @value The value to check if it is not an Expression.
     *
     * @return boolean
     */
    public boolean function isNotBuilder( required any value ) {
        return isSimpleValue( arguments.value ) ||
        isArray( arguments.value ) ||
        !structKeyExists( arguments.value, "isBuilder" );
    }

    /**
     * Converts a query object to an array of structs.
     *
     * @q The query to convert.
     *
     * @return array
     */
    public array function queryToArrayOfStructs( required any q ) {
        var queryColumns = getMetadata( arguments.q ).map( function( item ) {
            return item.name;
        } );

        return queryReduce(
            arguments.q,
            function( results, row ) {
                var rowData = structNew( "ordered" );
                for ( var column in queryColumns ) {
                    rowData[ column ] = row[ column ];
                }
                results.append( rowData );
                return results;
            },
            []
        );
    }

    /**
     * Remove a list of columns from a specified query.
     *
     * @q The query from which to remove the column.
     * @columns A list of columns to remove from the query.
     *
     * @return query
     */
    public query function queryRemoveColumns( required query q, required string columns ) {
        var columnsToRemove = arguments.columns.listToArray();
        var queryColumnInfo = getMetadata( q );
        var queryAsArray = queryToArrayOfStructs( q );
        queryAsArray.each( function( row ) {
            columnsToRemove.each( function( col ) {
                structDelete( row, col );
            } );
        } );

        var newColumns = queryColumnInfo
            .filter( function( column ) {
                return !arrayContainsNoCase( columnsToRemove, column.name );
            } )
            .map( function( column ) {
                return column.name;
            } );

        var newColumnTypes = newColumns.map( function( col ) {
            var foundColumn = queryColumnInfo.filter( function( c ) {
                return c.name == col;
            } );
            return arrayIsEmpty( foundColumn ) ? "varchar" : lCase( foundColumn[ 1 ].TypeName );
        } );

        return queryNew( newColumns.toList(), newColumnTypes.toList(), queryAsArray );
    }

    /**
     * Normalizes sql values in to a list.
     *
     * @value The value to normalize to a list.
     *
     * @return string
     */
    private string function normalizeSqlValue( required any value ) {
        if ( isArray( arguments.value ) ) {
            return arrayToList( arguments.value );
        }

        return arguments.value;
    }

    /**
     * Returns the value of the closure if every element in the array returns the same value.
     * Otherwise, it returns the default value.
     *
     * @args The array of elements.
     * @closure The closure to execute and retrieve the compared value.
     * @defaultValue The default value to return if the array does not return all the same values. Default: "".
     *
     * @return any
     */
    private any function arraySame( required array args, required any closure, any defaultValue = "" ) {
        if ( arrayLen( arguments.args ) == 0 ) {
            return arguments.defaultValue;
        }

        var initial = closure( arguments.args[ 1 ] );

        for ( var arg in arguments.args ) {
            if ( closure( arg ) != initial ) {
                return defaultValue;
            }
        }

        return initial;
    }

    private boolean function checkIsActuallyNumeric( required any value ) {
        return isNull( arguments.value ) || (
        isSimpleValue( arguments.value ) && arrayContainsNoCase(
            [
                "CFDouble",
                "Integer",
                "Double",
                "Float",
                "Long",
                "Short"
            ],
            listLast( getMetadata( arguments.value ), '. ' ) )
        );
    }

    /** Utility functions to assist with preventing duplicate joins. Adapted from cflib.org **/
    /**
     *
     * @param LeftStruct      The first struct. (Required)
     * @param RightStruct      The second structure. (Required)
     * @return Returns a boolean.
     * @author Ja Carter (ja@nuorbit.com).  Fix by Jose Alfonso and tweaks by Samuel Knowlton (sam@inleague.io) for scoping, formatting, and null checks
     * @version 2, October 14, 2005 (updated 11 Feb 2020)
     */

    public boolean function structCompare( LeftStruct, RightStruct ) {
        var result = true;
        var LeftStructKeys = "";
        var RightStructKeys = "";
        var key = "";

        // Make sure both params are structures
        if ( !( isStruct( arguments.LeftStruct ) AND isStruct( arguments.RightStruct ) ) ) return false;

        // Make sure both structures have the same keys
        local.LeftStructKeys = listSort( structKeyList( LeftStruct ), "TextNoCase", "ASC" );
        local.RightStructKeys = listSort( structKeyList( RightStruct ), "TextNoCase", "ASC" );
        if ( LeftStructKeys neq RightStructKeys ) return false;

        // Loop through the keys and compare them one at a time
        for ( var key in arguments.LeftStruct ) {
            // key is null, null check the other side
            if ( isNull( arguments.leftStruct[ key ] ) ) {
                local.result = isNull( arguments.rightStruct[ key ] );
                if ( !local.result ) {
                    return false;
                }
            }
            // Key is a structure, call structCompare()
            else if ( isStruct( arguments.LeftStruct[ key ] ) ) {
                local.result = structCompare( arguments.LeftStruct[ key ], arguments.RightStruct[ key ] );
                if ( !local.result ) {
                    return false;
                }
            }
            // Key is an array, call arrayCompare()
            else if ( isArray( arguments.LeftStruct[ key ] ) ) {
                local.result = arrayCompare( arguments.LeftStruct[ key ], arguments.RightStruct[ key ] );
                if ( !local.result ) {
                    return false;
                }
            }
            // A simple type comparison here
            else {
                if ( arguments.LeftStruct[ key ] != arguments.RightStruct[ key ] ) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     *
     * @param LeftArray      The first array. (Required)
     * @param RightArray      The second array. (Required)
     * @return Returns a boolean.
     * @author Ja Carter (ja@nuorbit.com) with tweaks by Samuel Knowlton (sam@inleague.io) for scoping and formatting
     * @version 1, September 23, 2004 (updated 11 Feb 2020)
     */
    public boolean function arrayCompare( LeftArray, RightArray ) {
        var result = true;
        var i = "";

        // Make sure both params are arrays
        if ( !( isArray( arguments.LeftArray ) AND isArray( arguments.RightArray ) ) ) {
            return false;
        }
        // Make sure both arrays have the same length
        if ( arrayLen( arguments.LeftArray ) != arrayLen( arguments.RightArray ) ) {
            return false;
        }

        // If both arrays are empty, don't bother
        if ( arguments.leftArray.isEmpty() && arguments.rightArray.isEmpty() ) return true;

        // Loop through the elements and compare them one at a time
        for ( var i = 1; local.i lte arrayLen( LeftArray ); local.i = local.i + 1 ) {
            // elements is a structure, call structCompare()
            if ( isStruct( arguments.LeftArray[ i ] ) ) {
                local.result = structCompare( arguments.LeftArray[ i ], arguments.RightArray[ i ] );
                if ( !local.result ) return false;
                // elements is an array, call arrayCompare()
            } else if ( isArray( arguments.LeftArray[ i ] ) ) {
                local.result = arrayCompare( arguments.LeftArray[ i ], arguments.RightArray[ i ] );
                if ( !local.result ) return false;
                // A simple type comparison here
            } else {
                if ( arguments.LeftArray[ i ] != arguments.RightArray[ i ] ) return false;
            }
        }

        return true;
    }

}
