/**
* A collection of query utilities shared across multiple models
*/
component displayname="QueryUtils" {

    /**
    * Extract a binding from a value.
    *
    * @value The value from which to extract the binding
    *
    * @return struct
    */
    public struct function extractBinding( required any value ) {
        var binding = "";
        if ( isStruct( value ) ) {
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

        if ( isNumeric( value ) ) {
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
    * Converts a query object to an array of structs.
    *
    * @q The query to convert.
    *
    * @return array
    */
    public array function queryToArrayOfStructs( required any q ) {
        var results = [];
        for ( var row in arguments.q ) {
            results.append( row );
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
    public query function queryRemoveColumns(
        required query q,
        required string columns
    ) {
        var columnList = q.columnList;
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

}
