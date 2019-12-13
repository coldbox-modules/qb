/**
* A collection of query utilities shared across multiple models
*/
component displayname="QueryUtils" singleton {

    /**
    * Extract a binding from a value.
    *
    * @value The value from which to extract the binding
    *
    * @return any
    */
    public any function extractBinding( required any value ) {
        if ( isBuilder( arguments.value ) ) {
            return arguments.value.getBindings();
        }

        var binding = "";
        if ( isStruct( value ) ) {
            if ( structKeyExists( value, "isExpression" ) && value.isExpression == true ) {
                return value;
            }
            binding = value;
        }
        else {
            binding = { value = normalizeSqlValue( value ) };
        }

        structAppend( binding, {
            cfsqltype = inferSqlType( binding.value ),
            list = false,
            null = false
        }, false );

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
            return arraySame( value, function( val ) {
                return inferSqlType( val );
            }, "CF_SQL_VARCHAR" );
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
        return ! isSimpleValue( arguments.value ) &&
            ! isArray( arguments.value ) &&
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
            ! structKeyExists( arguments.value, "isExpression" );
    }

    /**
    * Returns true if a value is an Expression.
    *
    * @value The value to check if it is an Expression.
    *
    * @return boolean
    */
    public boolean function isBuilder( required any value ) {
        return ! isSimpleValue( arguments.value ) &&
            ! isArray( arguments.value ) &&
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
            ! structKeyExists( arguments.value, "isBuilder" );
    }

    /**
    * Converts a query object to an array of structs.
    *
    * @q The query to convert.
    *
    * @return array
    */
    public array function queryToArrayOfStructs( required any q ) {
        var queryColumns = getMetadata( arguments.q )
            .map( function( item ) {
                return item.name;
            } );

        return queryReduce( arguments.q, function( results, row ) {
            var rowData = structNew( "ordered" );
            for ( var column in queryColumns ) {
                rowData[ column ] = row[ column ];
            }
            results.append( rowData );
            return results;
        }, [] );
    }

    /**
    * Remove a list of columns from a specified query.
    *
    * @q The query from which to remove the column.
    * @columns A list of columns to remove from the query.
    *
    * @return query
    */
    public query function queryRemoveColumns(
        required query q,
        required string columns
    ) {
        var columnList = getMetadata( q ).map( function( column ) {
            return column.name;
        } ).toList( "," );
        for ( var c in arguments.columns.listToArray() ) {
            var columnPosition = listFindNoCase( columnList, c );
            if ( columnPosition != 0 ) {
                columnList = ListDeleteAt( columnList, columnPosition );
            }
        }
        return queryExecute(
            "SELECT #columnList# FROM arguments.q",
            {},
            { dbtype = "query" }
        );
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
    private any function arraySame(
        required array args,
        required any closure,
        any defaultValue = ""
    ) {
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
        return arrayContainsNoCase( [
            "CFDouble",
            "Integer",
            "Double",
            "Float",
            "Long",
            "Short"
        ], value.getClass().getSimpleName() );
    }

}
