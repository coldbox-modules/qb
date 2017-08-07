import qb.models.Query.QueryBuilder;

component extends="qb.models.Grammars.Grammar" {

    /**
    * Runs a query through `queryExecute`.
    * This function exists so that platform-specific grammars can override it if needed.
    *
    * @sql The sql string to execute.
    * @bindings The bindings to apply to the query.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function runQuery( sql, bindings, options ) {
        var result = super.runQuery( argumentCollection = arguments );
        if ( result.recordCount > 0 ) {
            return utils.queryRemoveColumns( result, "QB_RN" );
        }
        return result;
    }

    /**
    * Compile a Builder's query into a sql string.
    *
    * @query The Builder instance.
    *
    * @return string
    */
    public string function compileSelect( required QueryBuilder query ) {
        var sql = super.compileSelect( argumentCollection = arguments );

        return compileOracleLimitAndOffset( query, sql );
    }

    /**
    * Compile a Builder's query into an insert string.
    *
    * @query The Builder instance.
    * @columns The array of columns into which to insert.
    * @values The array of values to insert.
    *
    * @return string
    */
    public string function compileInsert( required QueryBuilder query, required array columns, required array values ) {
        var columnsString = columns.map( wrapColumn ).toList( ", " );

        var placeholderString = values.map( function( valueArray ) {
            return "INTO #wrapTable( query.getFrom() )# (#columnsString#) VALUES (" & valueArray.map( function() {
                return "?";
            } ).toList( ", " ) & ")";
        } ).toList( " ");
        return trim( "INSERT ALL #placeholderString# SELECT 1 FROM dual" );
    }

    /**
    * Since Oracle doesn't know how to do a simple limit of offset without subquerys
    * add a subquery around the compiled value for the limit and the offset.
    *
    * @query The Builder instance.
    * @sql The generated sql string.
    *
    * @return string
    */
    private string function compileOracleLimitAndOffset(
        required QueryBuilder query,
        required string sql
    ) {
        var limitAndOffset = [];
        if ( ! isNull( query.getOffsetValue() ) ) {
            limitAndOffset.append( """QB_RN"" > #query.getOffsetValue()#" );
        }

        if ( ! isNull( query.getLimitValue() ) ) {
            var offset = query.getOffsetValue() ?: 0;
            limitAndOffset.append( """QB_RN"" <= #offset + query.getLimitValue()#" );
        }

        if ( limitAndOffset.isEmpty() ) {
            return sql;
        }
        
        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (#sql#) results ) WHERE #limitAndOffset.toList( " AND " )#";
    }

    /**
    * Compiles the limit portion of a sql statement.
    * Overridden here because Oracle needs to wrap the entire sql statement instead.
    *
    * @query The Builder instance.
    * @limitValue The limit clauses.
    *
    * @return string
    */
    private string function compileLimitValue( required QueryBuilder query, limitValue ) {
        return "";
    }

    /**
    * Compiles the offset portion of a sql statement.
    * Overridden here because Oracle needs to wrap the entire sql statement instead.
    *
    * @query The Builder instance.
    * @offsetValue The offset value.
    *
    * @return string
    */
    private string function compileOffsetValue( required QueryBuilder query, offsetValue ) {
        return "";
    }

    /**
    * Parses and wraps a table from the Builder for use in a sql statement.
    *
    * @table The table to parse and wrap.
    *
    * @return string
    */
    private string function wrapTable( required any table ) {
        var alias = "";
        if ( table.findNoCase( " as " ) > 0 ) {
            var matches = REFindNoCase( "(.*)(?:\sAS\s)(.*)", table, 1, true );
            if ( matches.pos.len() >= 3 ) {
                alias = mid( table, matches.pos[3], matches.len[3] );
                table = mid( table, matches.pos[2], matches.len[2] );
            }
        }
        table = table.listToArray( "." ).map( function( tablePart, index ) {
            return wrapValue( index == 1 ? getTablePrefix() & tablePart : tablePart );
        } ).toList( "." );
        return alias == "" ? table : table & " " & wrapValue( alias );
    }

    /**
    * Parses and wraps a value from the Builder for use in a sql statement.
    *
    * @table The value to parse and wrap.
    *
    * @return string
    */
    private string function wrapValue( required any value ) {
        return super.wrapValue( uCase( arguments.value ) );
    }

}