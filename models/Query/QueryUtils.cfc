component displayname="QueryUtils" {
    
    public struct function extractBinding( required any value ) {
        var binding = isStruct( value ) ? value : { value = normalizeSqlValue( value ) };

        structAppend( binding, {
            cfsqltype = inferSqlType( binding.value ),
            list = isList( binding.value ),
            null = false
        }, false );

        return binding;
    }

    public string function inferSqlType( required any value ) {
        if ( isList( arguments.value ) ) {
            arguments.value = listToArray( arguments.value );
        }

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

    public boolean function isExpression( required any value ) {
        return isInstanceOf( arguments.value, "qb.models.Query.Expression" );
    }

    public boolean function isNotExpression( required any value ) {
        return ! isInstanceOf( arguments.value, "qb.models.Query.Expression" );
    }

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
    * @param theQuery     The query to manipulate. (Required)
    * @param columnsToRemove      A list of columns to remove. (Required)
    * @return Returns a query. 
    * @author Giampaolo Bellavite (giampaolo@bellavite.com) 
    * @version 1, April 14, 2005 
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
        var newQuery = new Query();
        newQuery.setDBType( "query" );
        newQuery.setAttributes( qbOriginalQuery = arguments.q );
        newQuery.setSQL( "SELECT #columnList# FROM qbOriginalQuery" );
        return newQuery.execute().getResult();
    }

    private string function normalizeSqlValue( required any value ) {
        if ( isArray( arguments.value ) ) {
            return arrayToList( arguments.value );
        }

        return arguments.value;
    }

    private boolean function isList( required any value ) {
        if ( isStruct( value ) || isArray( value ) ) {
            return false;
        }
        
        var listAsArray = listToArray( arguments.value );
        return arrayLen( listAsArray ) > 1;
    }

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

}