component extends="qb.models.Query.QueryBuilder" {

    variables.whereNestedCalled = false;

    public QueryBuilder function whereNested( required callback, combinator = "and" ) {
        variables.whereNestedCalled = true;
        return super.whereNested( argumentCollection = arguments );
    }

    public boolean function wasWhereNestedCalled() {
        return variables.whereNestedCalled;
    }

}
