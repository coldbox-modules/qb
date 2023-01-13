component {

    this.enableNullSupport = shouldEnableFullNullSupport();
    this.timezone = "UTC";

    this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
    this.mappings[ "/qb" ] = expandPath( "/" );
    this.mappings[ "/cbpaginator" ] = expandPath( "/modules/cbpaginator" );
    this.mappings[ "/testbox" ] = this.mappings[ "/qb" ] & "/testbox";

    function shouldEnableFullNullSupport() {
        var system = createObject( "java", "java.lang.System" );
        var value = system.getEnv( "FULL_NULL" );
        return isNull( value ) ? false : !!value;
    }
}
