component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "JSON support", function() {
            var supportedGrammars = [
                {
                    name: "MySQL",
                    component: "qb.models.Grammars.MySQLGrammar",
                    selectSql: "SELECT json_unquote(json_extract(`profile`, '$.""contacts""[0].""email""')) AS `explicitName`, json_unquote(json_extract(`profile`, '$.""contacts""[0].""email""')) AS `shortcutName` FROM `users`",
                    whereSql: "SELECT * FROM `users` WHERE json_unquote(json_extract(`profile`, '$.""age""')) >= ? AND json_unquote(json_extract(`profile`, '$.""age""')) < ?",
                    containsSql: "SELECT * FROM `users` WHERE json_contains(`profile`, ?, '$.""languages""') AND json_contains(`profile`, ?, '$.""languages""')",
                    existsSql: "SELECT * FROM `users` WHERE ifnull(json_contains_path(`profile`, 'one', '$.""name""'), 0) AND ifnull(json_contains_path(`profile`, 'one', '$.""name""'), 0)",
                    lengthSql: "SELECT * FROM `users` WHERE json_length(`profile`, '$.""languages""') > ? AND json_length(`profile`, '$.""languages""') > ? ORDER BY json_unquote(json_extract(`profile`, '$.""name""')) ASC, json_unquote(json_extract(`profile`, '$.""name""')) DESC",
                    containsBindings: [ """en""", """en""" ]
                },
                {
                    name: "PostgreSQL",
                    component: "qb.models.Grammars.PostgresGrammar",
                    selectSql: "SELECT ""profile""->'contacts'->0->>'email' AS ""explicitName"", ""profile""->'contacts'->0->>'email' AS ""shortcutName"" FROM ""users""",
                    whereSql: "SELECT * FROM ""users"" WHERE ""profile""->>'age' >= ? AND ""profile""->>'age' < ?",
                    containsSql: "SELECT * FROM ""users"" WHERE (""profile""->'languages')::jsonb @> ?::jsonb AND (""profile""->'languages')::jsonb @> ?::jsonb",
                    existsSql: "SELECT * FROM ""users"" WHERE ""profile""->'name' IS NOT NULL AND ""profile""->'name' IS NOT NULL",
                    lengthSql: "SELECT * FROM ""users"" WHERE jsonb_array_length((""profile""->'languages')::jsonb) > ? AND jsonb_array_length((""profile""->'languages')::jsonb) > ? ORDER BY ""profile""->>'name' ASC, ""profile""->>'name' DESC",
                    containsBindings: [ """en""", """en""" ]
                },
                {
                    name: "SQL Server",
                    component: "qb.models.Grammars.SqlServerGrammar",
                    selectSql: "SELECT json_value([profile], '$.""contacts""[0].""email""') AS [explicitName], json_value([profile], '$.""contacts""[0].""email""') AS [shortcutName] FROM [users]",
                    whereSql: "SELECT * FROM [users] WHERE json_value([profile], '$.""age""') >= ? AND json_value([profile], '$.""age""') < ?",
                    containsSql: "SELECT * FROM [users] WHERE ? IN (SELECT [value] FROM openjson([profile], '$.""languages""')) AND ? IN (SELECT [value] FROM openjson([profile], '$.""languages""'))",
                    existsSql: "SELECT * FROM [users] WHERE 'name' IN (SELECT [key] FROM openjson([profile])) AND 'name' IN (SELECT [key] FROM openjson([profile]))",
                    lengthSql: "SELECT * FROM [users] WHERE (SELECT count(*) FROM openjson([profile], '$.""languages""')) > ? AND (SELECT count(*) FROM openjson([profile], '$.""languages""')) > ? ORDER BY json_value([profile], '$.""name""') ASC, json_value([profile], '$.""name""') DESC",
                    containsBindings: [ "en", "en" ]
                },
                {
                    name: "SQLite",
                    component: "qb.models.Grammars.SQLiteGrammar",
                    selectSql: "SELECT json_extract(""profile"", '$.""contacts""[0].""email""') AS ""explicitName"", json_extract(""profile"", '$.""contacts""[0].""email""') AS ""shortcutName"" FROM ""users""",
                    whereSql: "SELECT * FROM ""users"" WHERE json_extract(""profile"", '$.""age""') >= ? AND json_extract(""profile"", '$.""age""') < ?",
                    containsSql: "SELECT * FROM ""users"" WHERE EXISTS (SELECT 1 FROM json_each(""profile"", '$.""languages""') WHERE ""json_each"".""value"" IS ?) AND EXISTS (SELECT 1 FROM json_each(""profile"", '$.""languages""') WHERE ""json_each"".""value"" IS ?)",
                    existsSql: "SELECT * FROM ""users"" WHERE json_type(""profile"", '$.""name""') IS NOT NULL AND json_type(""profile"", '$.""name""') IS NOT NULL",
                    lengthSql: "SELECT * FROM ""users"" WHERE json_array_length(""profile"", '$.""languages""') > ? AND json_array_length(""profile"", '$.""languages""') > ? ORDER BY json_extract(""profile"", '$.""name""') ASC, json_extract(""profile"", '$.""name""') DESC",
                    containsBindings: [ "en", "en" ]
                },
                {
                    name: "Oracle",
                    component: "qb.models.Grammars.OracleGrammar",
                    selectSql: "SELECT json_value(""PROFILE"", '$.""contacts""[0].""email""') AS ""EXPLICITNAME"", json_value(""PROFILE"", '$.""contacts""[0].""email""') AS ""SHORTCUTNAME"" FROM ""USERS""",
                    whereSql: "SELECT * FROM ""USERS"" WHERE json_value(""PROFILE"", '$.""age""') >= ? AND json_value(""PROFILE"", '$.""age""') < ?",
                    containsSql: "SELECT * FROM ""USERS"" WHERE json_exists(""PROFILE"", '$.""languages""[*]?(@ == $value)' PASSING ? AS ""value"") AND json_exists(""PROFILE"", '$.""languages""[*]?(@ == $value)' PASSING ? AS ""value"")",
                    existsSql: "SELECT * FROM ""USERS"" WHERE json_exists(""PROFILE"", '$.""name""') AND json_exists(""PROFILE"", '$.""name""')",
                    lengthSql: "SELECT * FROM ""USERS"" WHERE json_value(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) > ? AND json_value(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) > ? ORDER BY json_value(""PROFILE"", '$.""name""') ASC, json_value(""PROFILE"", '$.""name""') DESC",
                    containsBindings: [ "en", "en" ]
                }
            ];

            supportedGrammars.each( function( grammarCase ) {
                describe( grammarCase.name, function() {
                    it( "selects scalar values with explicit and arrow syntax", function() {
                        var builder = getBuilder( grammarCase.component );
                        builder
                            .select( [
                                builder.jsonPath(
                                    column = "profile",
                                    path = [ "contacts", 0, "email" ],
                                    alias = "explicitName"
                                ),
                                "profile->contacts->0->email AS shortcutName"
                            ] )
                            .from( "users" );
                        expect( builder.toSQL() ).toBeWithCase( grammarCase.selectSql );
                    } );

                    it( "uses scalar values in predicates with explicit and arrow syntax", function() {
                        var builder = getBuilder( grammarCase.component );
                        builder
                            .from( "users" )
                            .where( builder.jsonPath( column = "profile", path = [ "age" ] ), ">=", 21 )
                            .where( "profile->age", "<", 65 );
                        assertQuery( builder, grammarCase.whereSql, [ 21, 65 ] );
                    } );

                    it( "checks containment with explicit and arrow syntax", function() {
                        var builder = getBuilder( grammarCase.component );
                        builder
                            .from( "users" )
                            .whereJsonContains( column = "profile", path = [ "languages" ], value = "en" )
                            .whereJsonContains( "profile->languages", "en" );
                        assertQuery( builder, grammarCase.containsSql, grammarCase.containsBindings );
                    } );

                    it( "checks path existence with explicit and arrow syntax", function() {
                        var builder = getBuilder( grammarCase.component );
                        builder
                            .from( "users" )
                            .whereJsonExists( column = "profile", path = [ "name" ] )
                            .whereJsonExists( "profile->name" );
                        assertQuery( builder, grammarCase.existsSql, [] );
                    } );

                    it( "checks array length and orders scalar values with both syntaxes", function() {
                        var builder = getBuilder( grammarCase.component );
                        builder
                            .from( "users" )
                            .whereJsonLength(
                                column = "profile",
                                path = [ "languages" ],
                                operator = ">",
                                value = 1
                            )
                            .whereJsonLength( "profile->languages", ">", 1 )
                            .orderBy( builder.jsonPath( "profile", [ "name" ] ) )
                            .orderByDesc( "profile->name" );
                        assertQuery( builder, grammarCase.lengthSql, [ 1, 1 ] );
                    } );
                } );
            } );

            supportedGrammars
                .filter( ( grammarCase ) => listFindNoCase( "MySQL,PostgreSQL", grammarCase.name ) )
                .each( function( grammarCase ) {
                    it( "supports compound containment values in #grammarCase.name# with both syntaxes", function() {
                        var builder = getBuilder( grammarCase.component );
                        builder
                            .from( "users" )
                            .whereJsonContains( column = "profile", path = [ "languages" ], value = [ "en", "de" ] )
                            .whereJsonContains( "profile->languages", [ "en", "de" ] );
                        assertQuery(
                            builder,
                            grammarCase.containsSql,
                            [ serializeJSON( [ "en", "de" ] ), serializeJSON( [ "en", "de" ] ) ]
                        );
                    } );
                } );

            it( "supports JSON boolean and negative convenience methods", function() {
                var builder = getBuilder( "qb.models.Grammars.MySQLGrammar" );
                builder
                    .from( "users" )
                    .whereJsonDoesntContain( column = "profile", path = [ "languages" ], value = "en" )
                    .orWhereJsonDoesntContain( "profile->languages", "fr" )
                    .orWhereJsonContains( column = "profile", path = [ "languages" ], value = "de" )
                    .whereJsonDoesntExist( column = "profile", path = [ "nickname" ] )
                    .orWhereJsonExists( "profile->name" )
                    .orWhereJsonDoesntExist( "profile->timezone" )
                    .orWhereJsonLength(
                        column = "profile",
                        path = [ "languages" ],
                        operator = ">",
                        value = 1
                    );
                assertQuery(
                    builder,
                    "SELECT * FROM `users` WHERE NOT (json_contains(`profile`, ?, '$.""languages""')) OR NOT (json_contains(`profile`, ?, '$.""languages""')) OR json_contains(`profile`, ?, '$.""languages""') AND NOT (ifnull(json_contains_path(`profile`, 'one', '$.""nickname""'), 0)) OR ifnull(json_contains_path(`profile`, 'one', '$.""name""'), 0) OR NOT (ifnull(json_contains_path(`profile`, 'one', '$.""timezone""'), 0)) OR json_length(`profile`, '$.""languages""') > ?",
                    [ """en""", """fr""", """de""", 1 ]
                );
            } );

            it( "throws for JSON operations in unsupported grammars", function() {
                var builder = getBuilder( "qb.models.Grammars.DerbyGrammar" );
                builder.select( builder.jsonPath( "profile", [ "name" ] ) ).from( "users" );
                expect( function() {
                    builder.toSQL();
                } ).toThrow( "UnsupportedOperation" );
            } );
        } );
    }

    private QueryBuilder function getBuilder( required string grammarComponent ) {
        var utils = new qb.models.Query.QueryUtils();
        var grammar = createObject( "component", arguments.grammarComponent ).init( utils );
        return new qb.models.Query.QueryBuilder( grammar = grammar, utils = utils );
    }

    private void function assertQuery( required QueryBuilder builder, required string sql, required array bindings ) {
        expect( arguments.builder.toSQL() ).toBeWithCase( arguments.sql );
        var values = arguments.builder
            .getBindings()
            .map( function( binding ) {
                return isStruct( binding ) && binding.keyExists( "value" ) ? binding.value : binding;
            } );
        expect( values ).toBe( arguments.bindings );
    }

}
