component {

    this.isBuilder = true;

    function init( required qb.models.Query.QueryBuilder builder ) {
        variables.builder = arguments.builder;
        return this;
    }

    qb.models.Query.QueryBuilder function retrieveQuery() {
        return variables.builder;
    }

}
