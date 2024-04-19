component singleton accessors="true" {

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
        return { "bindings": serializeBindings( bindings = bindings, delimiter = ";" ) };
    }

    private string function serializeBindings( required array bindings, string delimiter = ";" ) {
        return bindings
            .map( function( binding ) {
                return limitString(
                    str = castAsSqlType(
                        value = binding.null ? javacast( "null", "" ) : binding.value,
                        sqltype = binding.cfsqltype
                    ),
                    limit = 100
                );
            } )
            .toList( delimiter );
    }

    private string function limitString( required string str, required numeric limit, string end = "..." ) {
        if ( len( arguments.str ) <= arguments.limit ) {
            return arguments.str;
        }

        return left( arguments.str, arguments.limit ) & arguments.end;
    }

}
