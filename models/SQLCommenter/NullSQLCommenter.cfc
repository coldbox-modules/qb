component extends="SQLCommenter" singleton {

    /**
     * Returns the SQL unchanged for the NullSQLCommenter.
     *
     * @sql         The SQL string to add the comment to.
     * @datasource  The datasource that will execute the query.
     *              If null, the default datasource is going to be used.
     *
     * @return      Commented SQL string
     */
    public string function appendSqlComments( required string sql, string datasource, array bindings = [] ) {
        return arguments.sql;
    }

}
