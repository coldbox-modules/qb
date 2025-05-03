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
            "strictDateDetection": true,
            "convertEmptyStringsToNull": false,
            "numericSQLType": "NUMERIC",
            "integerSQLType": "INTEGER",
            "decimalSQLType": "DECIMAL",
            "autoAddScale": true,
            "defaultOptions": {},
            "sqlCommenter": {
                "enabled": false,
                "commenters": [
                    { "class": "FrameworkCommenter@qb", "properties": {} },
                    { "class": "RouteInfoCommenter@qb", "properties": {} },
                    { "class": "DBInfoCommenter@qb", "properties": {} }
                ]
            },
            "shouldMaxRowsOverrideToAll": function( maxRows ) {
                return maxRows <= 0;
            }
        };

        interceptorSettings = { "customInterceptionPoints": "preQBExecute,postQBExecute" };
    }

    function onLoad() {
        // Fill out the sqlCommenter commenters array in case users
        // forget to define it when overriding in their `config/ColdBox.cfc`
        if ( !settings.sqlCommenter.keyExists( "commenters" ) ) {
            param settings.sqlCommenter.commenters = [
                { "class": "FrameworkCommenter@qb", "properties": {} },
                { "class": "RouteInfoCommenter@qb", "properties": {} },
                { "class": "DBInfoCommenter@qb", "properties": {} }
            ];
        }

        binder
            .map( alias = "QueryUtils@qb", force = true )
            .to( "qb.models.Query.QueryUtils" )
            .initArg( name = "strictDateDetection", value = settings.strictDateDetection )
            .initArg( name = "convertEmptyStringsToNull", value = settings.convertEmptyStringsToNull )
            .initArg( name = "numericSQLType", value = settings.numericSQLType )
            .initArg( name = "autoAddScale", value = settings.autoAddScale )
            .initArg( name = "integerSQLType", value = settings.integerSQLType )
            .initArg( name = "decimalSQLType", value = settings.decimalSQLType );

        binder
            .map( alias = "QueryBuilder@qb", force = true )
            .to( "qb.models.Query.QueryBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar )
            .initArg( name = "utils", ref = "QueryUtils@qb" )
            .initArg( name = "preventDuplicateJoins", value = settings.preventDuplicateJoins )
            .initArg( name = "returnFormat", value = settings.defaultReturnFormat )
            .initArg( name = "defaultOptions", value = settings.defaultOptions )
            .initArg( name = "sqlCommenter", ref = "ColdBoxSQLCommenter@qb" )
            .initArg( name = "shouldMaxRowsOverrideToAll", value = settings.shouldMaxRowsOverrideToAll );

        binder
            .map( alias = "SchemaBuilder@qb", force = true )
            .to( "qb.models.Schema.SchemaBuilder" )
            .initArg( name = "grammar", ref = settings.defaultGrammar );
    }

}
