component {

    this.title         = 'qb';
    this.author        = 'Eric Peterson';
    this.webURL        = 'https://github.com/elpete/qb';
    this.description   = 'Query builder for the rest of us';
    this.version       = '1.0.0';
    this.autoMapModels = false;
    this.cfmapping     = 'qb';

    function configure() {
        settings = {
            defaultGrammar = "BaseGrammar",
            returnFormat = "array"
        };

        interceptorSettings = {
            customInterceptionPoints = [ "preQBExecute", "postQBExecute" ]
        };

        binder.map( "BaseGrammar@qb" )
            .to( "qb.models.Grammars.Grammar" )
            .asSingleton();

        binder.map( "MySQLGrammar@qb" )
            .to( "qb.models.Grammars.MySQLGrammar" )
            .asSingleton();

        binder.map( "OracleGrammar@qb" )
            .to( "qb.models.Grammars.OracleGrammar" )
            .asSingleton();

        binder.map( "MSSQLGrammar@qb" )
            .to( "qb.models.Grammars.MSSQLGrammar" )
            .asSingleton();

        binder.map( "QueryUtils@qb" )
            .to( "qb.models.Query.QueryUtils" )
            .asSingleton();
    }

    function onLoad() {
        binder.map( "DefaultGrammar@qb" )
            .to( "qb.models.Grammars.#settings.defaultGrammar#" );

        binder.map( "QueryBuilder@qb" )
            .to( "qb.models.Query.QueryBuilder" )
            .initArg( name = "grammar", ref = "#settings.defaultGrammar#@qb" )
            .initArg( name = "utils", ref = "QueryUtils@qb" )
            .initArg( name = "returnFormat", value = settings.returnFormat );
    }

}
