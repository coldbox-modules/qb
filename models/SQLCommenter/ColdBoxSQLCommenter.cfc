component extends="SQLCommenter" singleton {

    /**
     * All the qb module settings so we can inspect the sqlCommenter settings.
     */
    property name="settings" inject="box:moduleSettings:qb";

    /**
     * WireBox Injector
     */
    property name="wirebox" inject="wirebox";

    /**
     * An array of configured Commenter components.
     * These are used to fetch the comments for each SQL query.
     */
    property name="commenters" type="array";

    /**
     * Set up the commenters array with configured Commenter components.
     */
    function onDIComplete() {
        variables.commenters = variables.settings.sqlCommenter.commenters.map( ( commenterInfo ) => {
            param commenterInfo.properties = {};
            if ( !commenterInfo.keyExists( "class" ) ) {
                throw( "A commenter must have a class pointing to a WireBox mapping" );
            }

            return variables.wirebox.getInstance( commenterInfo.class ).setProperties( commenterInfo.properties );
        } );
    }

    /**
     * Gathers comments from the configured commenters and appends it to the SQL query.
     *
     * @sql         The SQL string to add the comment to.
     * @datasource  The datasource that will execute the query.
     *              If null, the default datasource is going to be used.
     *
     * @return      Commented SQL string
     */
    public string function appendSqlComments( required string sql, string datasource ) {
        if ( !settings.sqlCommenter.enabled ) {
            return arguments.sql;
        }

        var comments = variables.commenters.reduce( ( acc, commenter ) => {
            acc.append( commenter.getComments( sql, isNull( datasource ) ? javacast( "null", "" ) : datasource ), true );
        }, {} );

        return appendCommentsToSQL( arguments.sql, comments );
    }

}
