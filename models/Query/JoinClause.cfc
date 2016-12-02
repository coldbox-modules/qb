component displayname="JoinClause" extends="qb.models.Query.Builder" accessors="true" {

    property name="parentQuery" type="qb.models.Query.Builder";
    property name="type" type="string";
    property name="table" type="string";

    variables.types = [
        "inner", "full", "cross",
        "left", "left outer", "right", "right outer"
    ];

    public JoinClause function init(
        required Builder parentQuery,
        required string type,
        required string table
    ) {
        var typeIsValid = false;
        for ( var validType in variables.types ) {
            if ( validType == arguments.type ) {
                typeIsValid = true;
            }
        }
        if ( ! typeIsValid ) {
            throw( type = "InvalidSQLType", message = "[#type#] is not a valid sql join type" );
        }

        variables.parentQuery = arguments.parentQuery;
        variables.type = arguments.type;
        variables.table = arguments.table;

        super.init( parentQuery.getGrammar(), parentQuery.getUtils() );

        return this;
    }

    public JoinClause function on( required first, operator, second, combinator = "and" ) {
        if ( isClosure( first ) ) {
            return whereNested( first, combinator );
        }

        return whereColumn( argumentCollection = arguments );
    }

    public JoinClause function orOn( required first, operator, second ) {
        arguments.combinator = "or";
        return on( argumentCollection = arguments );
    }

    public Builder function newQuery() {
        return new qb.models.Query.JoinClause(
            parentQuery = getParentQuery(),
            type = getType(),
            table = getTable()
        );
    }

}