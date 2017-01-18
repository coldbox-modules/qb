component extends="qb.models.Query.Grammars.Grammar" {

    variables.selectComponents = [
        "aggregate", "columns", "from", "joins", "wheres",
        "groups", "havings", "orders", "offsetValue", "limitValue"
    ];

    private string function compileOffsetValue( required Builder query, offsetValue ) {
        if ( isNull( query.getOffsetValue() ) && isNull( query.getLimitValue() ) ) {
            return "";
        }

        if ( isNull( query.getOffsetValue() ) && ! isNull( query.getLimitValue() ) ) {
            offsetValue = 0;
        }

        return "OFFSET #offsetValue# ROWS";
    }

    private string function compileLimitValue( required Builder query, limitValue ) {
        if ( isNull( arguments.limitValue ) ) {
            return "";
        }
        return "FETCH NEXT #limitValue# ROWS ONLY";
    }

}