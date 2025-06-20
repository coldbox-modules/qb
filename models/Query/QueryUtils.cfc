/**
 * A collection of query utilities shared across multiple models
 */
component singleton displayname="QueryUtils" accessors="true" {

    /**
     * LogBox logging instance
     */
    property name="log" inject="logbox:logger:{this}";

    /**
     * If true, empty strings are converted to nulls.
     */
    property name="convertEmptyStringsToNull" default="false";

    /**
     * Allow overriding default integer numeric SQL type inferral.
     */
    property name="integerSQLType" default="INTEGER";

    /**
     * Allow overriding default decimal numeric SQL type inferral.
     */
    property name="decimalSQLType" default="DECIMAL";

    /**
     * Creates a new QueryUtils helper.
     * @return               qb.models.Query.QueryUtils
     */
    public QueryUtils function init(
        boolean convertEmptyStringsToNull = false,
        string integerSqlType = "INTEGER",
        string decimalSqlType = "DECIMAL",
        any log
    ) {
        variables.integerSqlType = arguments.integerSqlType;
        variables.decimalSqlType = arguments.decimalSqlType;
        if ( !isNull( arguments.log ) ) {
            variables.log = arguments.log;
        } else {
            variables.log = {
                "debug": function() {
                }
            };
        }
        return this;
    }

    /**
     * Extract a binding from a value.
     *
     * @value The value from which to extract the binding
     *
     * @return any
     */
    public any function extractBinding( any value, required any grammar ) {
        if (
            isNull( arguments.value ) || (
                variables.convertEmptyStringsToNull && isSimpleValue( arguments.value ) && !len( arguments.value )
            )
        ) {
            return {
                "cfsqltype": "VARCHAR",
                "sqltype": "VARCHAR",
                "value": "",
                "null": true
            };
        }

        if ( isBuilder( arguments.value ) ) {
            return arguments.value.getBindings();
        }

        var binding = {};
        if ( isStruct( value ) ) {
            if ( structKeyExists( value, "isExpression" ) && value.isExpression == true ) {
                return value;
            }

            checkForNonQueryParamStructKeys( value );

            binding = value;
        } else {
            binding = { value: normalizeSqlValue( value ) };
        }

        if ( structKeyExists( binding, "sqltype" ) && !structKeyExists( binding, "cfsqltype" ) ) {
            param binding.cfsqltype = binding.sqltype;
        }

        if ( structKeyExists( binding, "cfsqltype" ) && !structKeyExists( binding, "sqltype" ) ) {
            param binding.sqltype = binding.cfsqltype;
        }

        if ( !structKeyExists( binding, "cfsqltype" ) ) {
            if ( checkIsActuallyBoolean( binding.value ) ) {
                structAppend( binding, arguments.grammar.convertToBooleanType( binding.value ), true );
            } else {
                binding.sqltype = inferSqlType( binding.value, arguments.grammar );
                binding.cfsqltype = binding.sqltype;
            }
        }

        if ( binding.cfsqltype == "TIMESTAMP" ) {
            binding.value = dateTimeFormat( binding.value, "yyyy-mm-dd'T'HH:nn:ss.SSSXXX" );
        } else if ( binding.cfsqltype == "DATE" ) {
            binding.value = dateFormat( binding.value, "yyyy-MM-dd" );
        } else if ( binding.cfsqltype == "TIME" ) {
            binding.value = timeFormat( binding.value, "HH:mm:ss.nZ" );
        }
        structAppend( binding, { list: false, null: false }, false );

        if ( isFloatingPoint( binding ) ) {
            param binding.scale = calculateNumberOfDecimalDigits( binding );
        }

        // binding.sqltype = replace( binding.cfsqltype, "", "" );
        // binding.cfsqltype = binding.sqltype;

        return binding;
    }

    /**
     * Replace the question marks (?) in a sql string with the bindings provided.
     *
     * @sql      The sql string to replace the bindings in.
     * @bindings The bindings to replace the question marks with.
     * @inline   Whether or not to inline the bindings.
     *
     * @return   string
     */
    public string function replaceBindings( required string sql, required array bindings, boolean inline = false ) {
        var index = 1;
        return replace(
            arguments.sql,
            "?",
            function( pattern, position, originalString ) {
                var thisBinding = bindings[ index ];

                index++;

                if ( !isStruct( thisBinding ) ) {
                    return castAsSqlType( value = thisBinding, sqltype = "varchar" );
                }

                if ( inline ) {
                    return castAsSqlType(
                        value = thisBinding.null ? javacast( "null", "" ) : thisBinding.value,
                        sqltype = thisBinding.cfsqltype
                    );
                }

                var orderedBinding = structNew( "ordered" );
                for ( var type in [ "value", "cfsqltype", "null" ] ) {
                    orderedBinding[ type ] = thisBinding[ type ];
                }
                if ( isBinary( orderedBinding.value ) ) {
                    orderedBinding.value = toBase64( orderedBinding.value );
                }
                var stringifiedBinding = serializeJSON( orderedBinding );
                return stringifiedBinding;
            },
            "all"
        );
    }

    /**
     * Infer the correct type from a value.
     *
     * @value The value from which to infer the type.
     *
     * @return string
     */
    public string function inferSqlType( any value, required any grammar ) {
        if ( isNull( arguments.value ) ) {
            return "VARCHAR";
        }

        if ( isArray( value ) ) {
            return arraySame(
                value,
                function( val ) {
                    return inferSqlType( val, grammar );
                },
                "VARCHAR"
            );
        }

        if ( checkIsActuallyNumeric( value ) ) {
            return deriveNumericSqlType( value );
        }

        if ( checkIsActuallyDate( value ) ) {
            return "TIMESTAMP";
        }

        if ( checkIsActuallyBoolean( value ) ) {
            return arguments.grammar.getBooleanSqlType();
        }

        return "VARCHAR";
    }

    public any function castAsSqlType( any value, required string sqltype ) {
        if ( isNull( arguments.value ) ) {
            return "NULL";
        }

        switch ( arguments.sqltype ) {
            case "INTEGER":
            case "NUMERIC":
            case "DECIMAL":
            case "FLOAT":
            case "SMALLINT":
            case "REAL":
            case "DOUBLE":
            case "TINYINT":
            case "MONEY":
            case "MONEY4":
            case "BIGINT":
            case "BIT":
                return ( value * 1 );
            case "DATE":
                return "'#dateFormat( value, "yyyy-mm-dd" )#'";
            case "TIME":
                return "'#timeFormat( value, "HH:mm:ss.lll" )#'";
            case "TIMESTAMP":
                return "'#dateTimeFormat( value, "yyyy-mm-dd HH:nn:ss.lll" )#'";
            case "NULL":
                return "NULL";
            case "BLOB":
            case "CLOB":
                return toBase64( value );
            case "VARCHAR":
            case "NVARCHAR":
            case "CHAR":
            case "NCHAR":
            case "IDSTAMP":
            default:
                return "'" & replace(
                    toString( arguments.value ),
                    "'",
                    "''",
                    "all"
                ) & "'";
        }
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
        if ( isNull( arguments.value ) ) {
            return true;
        }
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
        if ( isNull( arguments.value ) ) {
            return false;
        }
        if ( isClosure( arguments.value ) || isCustomFunction( value ) ) {
            return false;
        }
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
     * Returns true if a value is a subquery.
     *
     * @value The value to check if it is a subquery
     *
     * @return boolean
     */
    public boolean function isSubQuery( required any value ) {
        // Includes quick check for a "(" to avoid the regex to look for the subquery pattern if possible
        return isSimpleValue( arguments.value ) &&
        arguments.value.find( "(" ) &&
        arguments.value.reFindNoCase( "^\s*\(.+\)(\s|\sAS\s){0,1}[^\(\s]*\s*$" );
    }

    /**
     * Returns true if a value is not a subquery.
     *
     * @value The value to check if it is a subquery
     *
     * @return boolean
     */
    public boolean function isNotSubQuery( required any value ) {
        return !isSubQuery( value );
    }

    /**
     * Converts a query object to an array of structs.
     *
     * @q The query to convert.
     *
     * @return array
     */
    public array function queryToArrayOfStructs( required any q ) {
        if ( arguments.q.recordCount == 0 ) {
            return [];
        }

        var queryColumns = [];
        if ( isPureBoxLang() ) {
            queryColumns = arguments.q.getColumnNames();
        } else {
            queryColumns = getMetadata( arguments.q ).map( function( item ) {
                return item.name;
            } );
        }

        var results = [];
        arrayResize( results, arguments.q.recordCount );
        for ( var row in arguments.q ) {
            var rowData = structNew( "ordered" );
            for ( var column in queryColumns ) {
                rowData[ column ] = row[ column ];
            }
            results[ arguments.q.currentRow ] = rowData;
        }
        return results;
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
        var queryColumnInfo = isPureBoxLang() ? q
            .getColumnNames()
            .map( ( name ) => {
                return { "name": name, "TypeName": "varchar" };
            } ) : getMetadata( q );
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
            if ( arrayIsEmpty( foundColumn ) ) {
                return "varchar";
            }
            var foundType = lCase( foundColumn[ 1 ].TypeName );
            switch ( foundType ) {
                case "number":
                    return "double";
                case "varchar2":
                    return "varchar";
                case "char":
                    return "varchar";
                case "clob":
                    return "varchar";
                default:
                    return foundType;
            }
        } );

        return queryNew( newColumns.toList(), newColumnTypes.toList(), queryAsArray );
    }

    /**
     * Normalizes sql values in to a list.
     *
     * @value The value to normalize to a list.
     *
     * @return any
     */
    private any function normalizeSqlValue( required any value ) {
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

    /**
     * Detects if value is numeric based on className
     *
     * @value The value
     *
     * @return boolean
     */
    private boolean function checkIsActuallyNumeric( any value ) {
        if ( isNull( arguments.value ) ) {
            variables.log.debug( "checkIsActuallyNumeric: value is null" );
            return false;
        }
        var type = listLast( toString( getMetadata( arguments.value ) ), ". " );
        variables.log.debug( "checkIsActuallyNumeric: #arguments.value# is #type#" );
        return isSimpleValue( arguments.value ) && arrayContainsNoCase(
            [
                "AtomicInteger",
                "AtomicLong",
                "BigDecimal",
                "BigInteger",
                "CFDouble",
                "Double",
                "DoubleAccumulator",
                "DoubleAdder",
                "Float",
                "Integer",
                "Long",
                "LongAccumulator",
                "LongAdder",
                "Short"
            ],
            type
        );
    }

    private string function deriveNumericSqlType( required numeric value ) {
        var isInteger = reFind( "^\d+$", arguments.value ) > 0;
        return isInteger ? variables.integerSqlType : variables.decimalSqlType;
    }

    /**
     * Detects if value is a Date based on Isdate and/or className
     *
     * @value The value
     *
     * @return boolean
     */
    private boolean function checkIsActuallyDate( any value ) {
        if ( isNull( arguments.value ) ) {
            return false;
        }

        var className = "";
        if ( isPureBoxLang() ) {
            className = listLast( arguments.value.$bx.$class.getName(), "." );
        } else {
            className = listLast( toString( getMetadata( arguments.value ) ), "." )
        }

        return isDate( arguments.value ) && arrayContainsNoCase(
            [ "OleDateTime", "DateTimeImpl", "DateTime" ],
            className
        );
    }

    /**
     * Detects if value is a Boolean based on className
     *
     * @value The value
     *
     * @return boolean
     */
    private boolean function checkIsActuallyBoolean( any value ) {
        if ( isNull( arguments.value ) ) {
            return false;
        }

        return arrayContainsNoCase(
            [ "CFBoolean", "Boolean" ],
            listLast( toString( getMetadata( arguments.value ) ), "." )
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

    public string function serializeBindings( required array bindings, required any grammar ) {
        return serializeJSON(
            arguments.bindings.map( function( binding ) {
                var newBinding = extractBinding( duplicate( binding ), grammar );
                if ( isBinary( newBinding.value ) ) {
                    newBinding.value = toBase64( newBinding.value );
                }
                return newBinding;
            } )
        );
    }

    private boolean function isFloatingPoint( required struct binding ) {
        if ( isNull( arguments.binding.value ) || arguments.binding.null ) {
            return false;
        }

        return arguments.binding.cfsqltype.findNoCase( "decimal" ) > 0 ||
        arguments.binding.cfsqltype.findNoCase( "double" ) > 0 ||
        arguments.binding.cfsqltype.findNoCase( "float" ) > 0 ||
        arguments.binding.cfsqltype.findNoCase( "money" ) > 0 ||
        arguments.binding.cfsqltype.findNoCase( "money4" ) > 0 ||
        (
            arguments.binding.cfsqltype.findNoCase( "numeric" ) > 0 && arguments.binding.value
                .toString()
                .findNoCase( "." ) > 0
        );
    }

    private numeric function calculateNumberOfDecimalDigits( required struct binding ) {
        if ( isNull( arguments.binding.value ) || arguments.binding.null ) {
            return 0;
        }

        var numString = arguments.binding.value.toString();
        var numStringParts = listToArray( numString, "." );
        if ( numStringParts.len() != 2 ) {
            return 0;
        }
        var decimalPortion = numStringParts[ 2 ];
        return len( decimalPortion );
    }

    private boolean function isPureBoxLang() {
        return server.keyExists( "boxlang" ) && !server.boxlang.modules.some( ( moduleName ) => findNoCase( "compat-cfml", moduleName ) > 0 );
    }

    private void function checkForNonQueryParamStructKeys( required struct param ) {
        var validKeys = [
            "cfsqltype",
            "list",
            "maxlength",
            "name",
            "null",
            "nulls",
            "sqltype",
            "separator",
            "scale",
            "value"
        ];
        var extraKeys = param.keyArray().filter( ( key ) => !validKeys.containsNoCase( key ) );
        if ( !extraKeys.isEmpty() ) {
            throw(
                type = "QBInvalidQueryParam",
                message = "Invalid keys detected in your query param struct: [#extraKeys.sort( "textnocase" ).toList( ", " )#]. Usually this happens when you meant to serialize the struct to JSON first."
            );
        }
    }

    public boolean function isValidQueryParamStruct( required any param ) {
        if ( !isStruct( arguments.param ) || isObject( arguments.param ) ) {
            return false;
        }

        var validKeys = [
            "cfsqltype",
            "list",
            "maxlength",
            "name",
            "null",
            "nulls",
            "sqltype",
            "separator",
            "scale",
            "value"
        ];
        return param
            .keyArray()
            .filter( ( key ) => !validKeys.containsNoCase( key ) )
            .isEmpty();
    }

}
