component singleton accessors="true" {

    property name="properties";
    property name="driverVersionByDatasource";

    /**
     * Returns a struct of key/value comment pairs to append to the SQL.
     *
     * @sql         The SQL to append the comments to. This is provided if you need to
     *              inspect the SQL to make any decisions about what comments to return.
     * @datasource  The datasource that will execute the query. If null, the default datasource will be used.
     *              This can be used to make decisions about what comments to return.
     */
    public struct function getComments( required string sql, string datasource, array bindings = [] ) {
        param variables.driverVersionByDatasource = {};
        var driverVersion = "UNKNOWN";
        if ( isNull( arguments.datasource ) ) {
            if ( !variables.driverVersionByDatasource.keyExists( "__DEFAULT__" ) ) {
                cfdbinfo( type = "version", name = "local.dbInfo" );
                variables.driverVersionByDatasource[ "__DEFAULT__" ] = local.dbInfo.DRIVER_VERSION;
            }
            driverVersion = variables.driverVersionByDatasource[ "__DEFAULT__" ];
        } else {
            if ( !variables.driverVersionByDatasource.keyExists( arguments.datasource ) ) {
                cfdbinfo( type = "version", name = "local.dbInfo", datasource = arguments.datasource );
                variables.driverVersionByDatasource[ arguments.datasource ] = local.dbInfo.DRIVER_VERSION;
            }
            driverVersion = variables.driverVersionByDatasource[ arguments.datasource ];
        }
        return { "dbDriver": driverVersion };
    }

}
