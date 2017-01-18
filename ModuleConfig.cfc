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
            returningArrays = true,
            returnFormat = ""
        };

        binder.map( "BaseGrammar@qb" )
            .to( "qb.models.Query.Grammars.Grammar" )
            .asSingleton();

        binder.map( "MySQLGrammar@qb" )
            .to( "qb.models.Query.Grammars.MySQLGrammar" )
            .asSingleton();

        binder.map( "OracleGrammar@qb" )
            .to( "qb.models.Query.Grammars.OracleGrammar" )
            .asSingleton();

        binder.map( "MSSQLGrammar@qb" )
            .to( "qb.models.Query.Grammars.MSSQLGrammar" )
            .asSingleton();

        binder.map( "QueryUtils@qb" )
            .to( "qb.models.Query.QueryUtils" )
            .asSingleton();
    }

    function onLoad() {
        binder.map( "builder@qb" )
            .to( "qb.models.Query.Builder" )
            .initArg( name = "grammar", ref = "#settings.defaultGrammar#@qb" )
            .initArg( name = "utils", ref = "QueryUtils@qb" );
    }

}