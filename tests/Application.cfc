component {
    this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
    this.mappings[ "/qb" ] = expandPath( "/" );
    this.mappings[ "/cbpaginator" ] = expandPath( "/modules/cbpaginator" );
    this.mappings[ "/testbox" ] = this.mappings[ "/qb" ] & "/testbox";
}
