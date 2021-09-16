/**
 * Expression is a simple wrapper around text that should not
 * be parsed or evaluated or modified in any way.
 * Expressions are included as-is in a sql statement.
 */
component displayname="Expression" accessors="true" {

    /**
     * The raw sql value
     */
    property name="sql" type="string" default="";
    property name="bindings" type="array";

    this.isExpression = true;

    /**
     * Create a new Expression wrapping up some sql.
     *
     * @sql The sql string to wrap up.
     *
     * @return qb.models.Query.Expression
     */
    public Expression function init( required string sql, array bindings = [] ) {
        variables.sql = arguments.sql;
        variables.bindings = arguments.bindings;
        return this;
    }

}
