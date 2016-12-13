import qb.models.Query.Builder;

component extends="qb.models.Query.Grammars.Grammar" {

    public string function compileSelect( required Builder query ) {
        var sql = super.compileSelect( argumentCollection = arguments );

        return compileOracleLimitAndOffset( query, sql );
    }

    private string function compileOracleLimitAndOffset( required Builder query, required string sql ) {
        var limitAndOffset = [];
        if ( ! isNull( query.getOffsetValue() ) ) {
            limitAndOffset.append( "ROWNUM > #query.getOffsetValue()#" );
        }

        if ( ! isNull( query.getLimitValue() ) ) {
            var offset = query.getOffsetValue() ?: 0;
            limitAndOffset.append( "ROWNUM <= #offset + query.getLimitValue()#" );
        }

        if ( limitAndOffset.isEmpty() ) {
            return sql;
        }
        
        return "SELECT * FROM (#sql#) WHERE #limitAndOffset.toList( " AND " )#";
    }

    private string function compileLimitValue( required Builder query, limitValue ) {
        return "";
    }

    private string function compileOffsetValue( required Builder query, offsetValue ) {
        return "";
    }


}