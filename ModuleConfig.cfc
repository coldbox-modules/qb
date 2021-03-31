component {

    this.title = "qb";
    this.author = "Eric Peterson";
    this.webURL = "https://github.com/coldbox-modules/qb";
    this.description = "A query builder for the rest of us";
    this.cfmapping = "qb";

    function configure() {
        settings = {
            "defaultGrammar": "AutoDiscover@qb",
            "defaultReturnFormat": "array",
            "preventDuplicateJoins": false,
            "strictDateDetection": false,
            "numericSQLType": "CF_SQL_NUMERIC",
            "autoAddScale": true
        };

        interceptorSettings = { "customInterceptionPoints": "preQBExecute,postQBExecute" };
    }

    function onLoad() {
        binder
            .map( alias = "QueryUtils@qb", force = true )
            .to( "qb.models.Query.QueryUtils" )
            .initArg( name = "strictDateDetection", value = settings.strictDateDetection )
            .initArg( name = "numericSQLType", value = settings.numericSQLType );

        binder
            .map( alias = "QueryBuilder@qb", force = true )
            .to( "qb.models.Query.QueryBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar )
            .initArg( name = "utils", ref = "QueryUtils@qb" )
            .initArg( name = "preventDuplicateJoins", value = settings.preventDuplicateJoins )
            .initArg( name = "returnFormat", value = settings.defaultReturnFormat );

        binder
            .map( alias = "SchemaBuilder@qb", force = true )
            .to( "qb.models.Schema.SchemaBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar );
    }

}
