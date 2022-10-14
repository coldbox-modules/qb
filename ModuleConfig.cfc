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
            "integerSQLType": "CF_SQL_INTEGER",
            "decimalSQLType": "CF_SQL_DECIMAL",
            "autoAddScale": true,
            "autoDeriveNumericType": false,
            "defaultOptions": {}
        };

        interceptorSettings = { "customInterceptionPoints": "preQBExecute,postQBExecute" };
    }

    function onLoad() {
        binder
            .map( alias = "QueryUtils@qb", force = true )
            .to( "qb.models.Query.QueryUtils" )
            .initArg( name = "strictDateDetection", value = settings.strictDateDetection )
            .initArg( name = "numericSQLType", value = settings.numericSQLType )
            .initArg( name = "autoAddScale", value = settings.autoAddScale )
            .initArg( name = "autoDeriveNumericType", value = settings.autoDeriveNumericType )
            .initArg( name = "integerSQLType", value = settings.integerSQLType )
            .initArg( name = "decimalSQLType", value = settings.decimalSQLType );

        binder
            .map( alias = "QueryBuilder@qb", force = true )
            .to( "qb.models.Query.QueryBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar )
            .initArg( name = "utils", ref = "QueryUtils@qb" )
            .initArg( name = "preventDuplicateJoins", value = settings.preventDuplicateJoins )
            .initArg( name = "returnFormat", value = settings.defaultReturnFormat )
            .initArg( name = "defaultOptions", value = settings.defaultOptions );

        binder
            .map( alias = "SchemaBuilder@qb", force = true )
            .to( "qb.models.Schema.SchemaBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar );
    }

}
