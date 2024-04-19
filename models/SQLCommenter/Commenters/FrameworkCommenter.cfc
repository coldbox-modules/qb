component singleton accessors="true" {

    property name="wirebox" inject="wirebox";
    property name="properties";

    /**
     * Returns a struct of key/value comment pairs to append to the SQL.
     *
     * @sql         The SQL to append the comments to. This is provided if you need to
     *              inspect the SQL to make any decisions about what comments to return.
     * @datasource  The datasource that will execute the query. If null, the default datasource will be used.
     *              This can be used to make decisions about what comments to return.
     */
    public struct function getComments( required string sql, string datasource, array bindings = [] ) {
        param variables.coldboxVersion = variables.wirebox.getInstance( "coldbox:coldboxSetting:version" );
        return { "version": "coldbox-#variables.coldboxVersion#" };
    }

}
