/**
 * Represents a Join clause in a sql statement
 */
component displayname="JoinClause" accessors="true" extends="qb.models.Query.QueryBuilder" {

    /**
     * A reference to the parent query to which this join clause belongs.
     */
    property name="parentQuery" type="qb.models.Query.QueryBuilder";

    /**
     * The join type of the join clause.
     */
    property name="type" type="string";

    /**
     * The table to join.
     */
    property name="table" type="any";

    /**
     * Valid join types for join clauses.
     */
    variables.types = [
        "inner",
        "full",
        "cross",
        "left",
        "left outer",
        "right",
        "right outer"
    ];

    /**
     * Creates a basic join clause.
     *
     * @parentQuery A reference to the query to which this join clause belongs.
     * @type The join type of this join clause.
     * @table The table to join.
     *
     * @return qb.models.Query.JoinClause
     */
    public JoinClause function init( required QueryBuilder parentQuery, required string type, required any table ) {
        var typeIsValid = false;
        for ( var validType in variables.types ) {
            if ( validType == arguments.type ) {
                typeIsValid = true;
            }
        }
        if ( !typeIsValid ) {
            throw( type = "InvalidSQLType", message = "[#type#] is not a valid sql join type" );
        }

        variables.parentQuery = arguments.parentQuery;
        variables.type = arguments.type;
        variables.table = arguments.table;

        super.init( parentQuery.getGrammar(), parentQuery.getUtils() );

        return this;
    }

    /**
     * Add a column condition to the join statement.
     *
     * @first The name of the first column with which to join. A closure can be passed to create nested join statements.
     * @operator The join operator to use.
     * @second The name of the second column with which to join.
     * @combinator The combinator to use between joins.
     *
     * @return qb.models.Query.JoinClause
     */
    public JoinClause function on(
        required first,
        operator,
        second,
        combinator = "and"
    ) {
        if ( isClosure( first ) || isCustomFunction( first ) ) {
            return whereNested( first, combinator );
        }

        return whereColumn( argumentCollection = arguments );
    }

    /**
     * Add an or column condition to the join statement.
     *
     * @first The name of the first column with which to join. A closure can be passed to create nested join statements.
     * @operator The join operator to use.
     * @second The name of the second column with which to join.
     *
     * @return qb.models.Query.JoinClause
     */
    public JoinClause function orOn( required first, operator, second ) {
        arguments.combinator = "or";
        return on( argumentCollection = arguments );
    }

    /**
     * Returns a new Join Clause based off of the current join clause.
     *
     * @return qb.models.Builder.JoinClause
     */
    public QueryBuilder function newQuery() {
        return new qb.models.Query.JoinClause( parentQuery = getParentQuery(), type = getType(), table = getTable() );
    }

    /**
     * Returns whether the object is a JoinClause.
     * This exists because isInstanceOf is super slow!
     *
     * @returns boolean
     */
    public boolean function isJoin() {
        return true;
    }

}
