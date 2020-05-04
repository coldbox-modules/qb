component {

    this.title         = "qb";
    this.author        = "Eric Peterson";
    this.webURL        = "https://github.com/coldbox-modules/qb";
    this.description   = "A query builder for the rest of us";
    this.cfmapping     = "qb";

    function configure() {
        settings = {
            defaultGrammar = "AutoDiscover@qb",
            defaultReturnFormat = "array",
            preventDuplicateJoins = false
        };

        interceptorSettings = {
            customInterceptionPoints = "preQBExecute,postQBExecute"
        };
    }

    function onLoad() {
        binder.map( alias = "QueryBuilder@qb", force = true )
            .to( "qb.models.Query.QueryBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar )
            .initArg( name = "utils", ref = "QueryUtils@qb" )
            .initArg( name = "preventDuplicateJoints", value = settings.preventDuplicateJoins )
            .initArg( name = "returnFormat", value = settings.defaultReturnFormat );

        binder.map( alias = "SchemaBuilder@qb", force = true )
            .to( "qb.models.Schema.SchemaBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar );
    }

}
