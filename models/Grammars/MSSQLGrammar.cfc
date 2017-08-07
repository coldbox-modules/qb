component extends="qb.models.Grammars.Grammar" {

    /**
    * The different components of a select statement in the order of compilation.
    */
    variables.selectComponents = [
        "aggregate", "columns", "from", "joins", "wheres",
        "groups", "havings", "orders", "offsetValue", "limitValue"
    ];

    /**
    * Compiles the offset portion of a sql statement.
    *
    * @query The Builder instance.
    * @offsetValue The offset value.
    *
    * @return string
    */
    private string function compileOffsetValue( required qb.models.Query.QueryBuilder query, offsetValue ) {
        if ( isNull( query.getOffsetValue() ) && isNull( query.getLimitValue() ) ) {
            return "";
        }

        if ( isNull( query.getOffsetValue() ) && ! isNull( query.getLimitValue() ) ) {
            offsetValue = 0;
        }

        return "OFFSET #offsetValue# ROWS";
    }

    /**
    * Compiles the limit portion of a sql statement.
    *
    * @query The Builder instance.
    * @limitValue The limit clauses.
    *
    * @return string
    */
    private string function compileLimitValue( required qb.models.Query.QueryBuilder query, limitValue ) {
        if ( isNull( arguments.limitValue ) ) {
            return "";
        }
        return "FETCH NEXT #limitValue# ROWS ONLY";
    }

}
