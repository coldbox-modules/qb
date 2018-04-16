component {

    this.title         = "qb";
    this.author        = "Eric Peterson";
    this.webURL        = "https://github.com/elpete/qb";
    this.description   = "Query builder for the rest of us";
    this.version       = "5.0.0";
    this.autoMapModels = false;
    this.cfmapping     = "qb";

    function configure() {
        settings = {
            defaultGrammar = "AutoDiscover",
            returnFormat = "array"
        };

        interceptorSettings = {
            customInterceptionPoints = "preQBExecute,postQBExecute"
        };

        binder.map( "QueryUtils@qb" )
            .to( "qb.models.Query.QueryUtils" )
            .asSingleton();
    }

    function onLoad() {
        var interceptorService = ( structKeyExists( application, "cbController" ) ) ?
            binder.getInjector().getInstance( dsl = "coldbox:interceptorService" ) :
            binder.getInjector().getInstance( "shell" ).getInterceptorService();

        binder.map( "AutoDiscover@qb" )
            .to( "qb.models.Grammars.AutoDiscover" )
            .asSingleton();

        binder.map( "BaseGrammar@qb" )
            .to( "qb.models.Grammars.BaseGrammar" )
            .property( name = "interceptorService", value = interceptorService )
            .asSingleton();

        binder.map( "MySQLGrammar@qb" )
            .to( "qb.models.Grammars.MySQLGrammar" )
            .property( name = "interceptorService", value = interceptorService )
            .asSingleton();

        binder.map( "PostgresGrammar@qb" )
            .to( "qb.models.Grammars.PostgresGrammar" )
            .property( name = "interceptorService", value = interceptorService )
            .asSingleton();

        binder.map( "OracleGrammar@qb" )
            .to( "qb.models.Grammars.OracleGrammar" )
            .property( name = "interceptorService", value = interceptorService )
            .asSingleton();

        binder.map( "MSSQLGrammar@qb" )
            .to( "qb.models.Grammars.MSSQLGrammar" )
            .property( name = "interceptorService", value = interceptorService )
            .asSingleton();

        var defaultGrammar = settings.defaultGrammar;
        if ( settings.defaultGrammar == "AutoDiscover") {
            defaultGrammar = autoDiscoverGrammar();
        }

        binder.map( "QueryBuilder@qb" )
            .to( "qb.models.Query.QueryBuilder" )
            .initArg( name = "grammar", ref = "#defaultGrammar#@qb" )
            .initArg( name = "utils", ref = "QueryUtils@qb" )
            .initArg( name = "returnFormat", value = settings.returnFormat );

        binder.map( "SchemaBuilder@qb" )
            .to( "qb.models.Schema.SchemaBuilder" )
            .initArg( name = "grammar", ref = "#defaultGrammar#@qb" );
    }

    private function autoDiscoverGrammar() {
        try {
            cfdbinfo( type = "Version", name = "local.dbInfo" );

            switch( dbInfo.DATABASE_PRODUCTNAME ) {
                case "MySQL":
                    return "MySQLGrammar";
                case "PostgreSQL":
                    return "PostgresGrammar";
                case "Microsoft SQL Server":
                    return "MSSQLGrammar";
                case "Oracle":
                    return "OracleGrammar";
                default:
                    return "BaseGrammar";
            }
        }
        catch ( any e ) {
            return "BaseGrammar";
        }
    }

}
