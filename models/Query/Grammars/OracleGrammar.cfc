import qb.models.Query.Builder;

component extends="qb.models.Query.Grammars.Grammar" {

    public any function runQuery( sql, bindings, options ) {
        var result = super.runQuery( argumentCollection = arguments );
        if ( ! isNull( result ) ) {
            return utils.queryRemoveColumns( result, "QB_RN" );
        }
        return;
    }

    public string function compileSelect( required Builder query ) {
        var sql = super.compileSelect( argumentCollection = arguments );

        return compileOracleLimitAndOffset( query, sql );
    }

    public string function compileInsert( required Builder query, required array columns, required array values ) {
        var columnsString = columns.map( wrapColumn ).toList( ", " );

        var placeholderString = values.map( function( valueArray ) {
            return "INTO #wrapTable( query.getFrom() )# (#columnsString#) VALUES (" & valueArray.map( function() {
                return "?";
            } ).toList( ", " ) & ")";
        } ).toList( " ");
        return trim( "INSERT ALL #placeholderString# SELECT 1 FROM dual" );
    }

    private string function compileOracleLimitAndOffset( required Builder query, required string sql ) {
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

    private string function compileLimitValue( required Builder query, limitValue ) {
        return "";
    }

    private string function compileOffsetValue( required Builder query, offsetValue ) {
        return "";
    }

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

    private string function wrapValue( required any value ) {
        return super.wrapValue( uCase( arguments.value ) );
    }

}