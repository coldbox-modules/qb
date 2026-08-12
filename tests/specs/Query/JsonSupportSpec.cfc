component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "JSON support", function() {
            var supportedGrammars = [
                {
                    name: "MySQL",
                    component: "qb.models.Grammars.MySQLGrammar",
                    selectSql: "SELECT JSON_UNQUOTE(JSON_EXTRACT(`profile`, '$.""contacts""[0].""email""')) AS `explicitName`, JSON_UNQUOTE(JSON_EXTRACT(`profile`, '$.""contacts""[0].""email""')) AS `shortcutName` FROM `users`",
                    whereSql: "SELECT * FROM `users` WHERE JSON_UNQUOTE(JSON_EXTRACT(`profile`, '$.""age""')) >= ? AND JSON_UNQUOTE(JSON_EXTRACT(`profile`, '$.""age""')) < ?",
                    containsSql: "SELECT * FROM `users` WHERE JSON_CONTAINS(`profile`, ?, '$.""languages""') AND JSON_CONTAINS(`profile`, ?, '$.""languages""')",
                    existsSql: "SELECT * FROM `users` WHERE IFNULL(JSON_CONTAINS_PATH(`profile`, 'one', '$.""name""'), 0) AND IFNULL(JSON_CONTAINS_PATH(`profile`, 'one', '$.""name""'), 0)",
                    lengthSql: "SELECT * FROM `users` WHERE JSON_LENGTH(`profile`, '$.""languages""') > ? AND JSON_LENGTH(`profile`, '$.""languages""') > ? ORDER BY JSON_UNQUOTE(JSON_EXTRACT(`profile`, '$.""name""')) ASC, JSON_UNQUOTE(JSON_EXTRACT(`profile`, '$.""name""')) DESC",
                    lengthEqualitySql: "SELECT * FROM `users` WHERE JSON_LENGTH(`profile`, '$.""languages""') = ? AND JSON_LENGTH(`profile`, '$.""languages""') = ? OR JSON_LENGTH(`profile`, '$.""languages""') = ? OR JSON_LENGTH(`profile`, '$.""languages""') = ?",
                    containsBindings: [ """en""", """en""" ]
                },
                {
                    name: "PostgreSQL",
                    component: "qb.models.Grammars.PostgresGrammar",
                    selectSql: "SELECT ""profile""->'contacts'->0->>'email' AS ""explicitName"", ""profile""->'contacts'->0->>'email' AS ""shortcutName"" FROM ""users""",
                    whereSql: "SELECT * FROM ""users"" WHERE ""profile""->>'age' >= ? AND ""profile""->>'age' < ?",
                    containsSql: "SELECT * FROM ""users"" WHERE (""profile""->'languages')::jsonb @> ?::jsonb AND (""profile""->'languages')::jsonb @> ?::jsonb",
                    existsSql: "SELECT * FROM ""users"" WHERE ""profile""->'name' IS NOT NULL AND ""profile""->'name' IS NOT NULL",
                    lengthSql: "SELECT * FROM ""users"" WHERE JSONB_ARRAY_LENGTH((""profile""->'languages')::jsonb) > ? AND JSONB_ARRAY_LENGTH((""profile""->'languages')::jsonb) > ? ORDER BY ""profile""->>'name' ASC, ""profile""->>'name' DESC",
                    lengthEqualitySql: "SELECT * FROM ""users"" WHERE JSONB_ARRAY_LENGTH((""profile""->'languages')::jsonb) = ? AND JSONB_ARRAY_LENGTH((""profile""->'languages')::jsonb) = ? OR JSONB_ARRAY_LENGTH((""profile""->'languages')::jsonb) = ? OR JSONB_ARRAY_LENGTH((""profile""->'languages')::jsonb) = ?",
                    containsBindings: [ """en""", """en""" ]
                },
                {
                    name: "SQL Server",
                    component: "qb.models.Grammars.SqlServerGrammar",
                    selectSql: "SELECT JSON_VALUE([profile], '$.""contacts""[0].""email""') AS [explicitName], JSON_VALUE([profile], '$.""contacts""[0].""email""') AS [shortcutName] FROM [users]",
                    whereSql: "SELECT * FROM [users] WHERE JSON_VALUE([profile], '$.""age""') >= ? AND JSON_VALUE([profile], '$.""age""') < ?",
                    containsSql: "SELECT * FROM [users] WHERE ? IN (SELECT [value] FROM OPENJSON([profile], '$.""languages""')) AND ? IN (SELECT [value] FROM OPENJSON([profile], '$.""languages""'))",
                    existsSql: "SELECT * FROM [users] WHERE 'name' IN (SELECT [key] FROM OPENJSON([profile])) AND 'name' IN (SELECT [key] FROM OPENJSON([profile]))",
                    lengthSql: "SELECT * FROM [users] WHERE (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) > ? AND (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) > ? ORDER BY JSON_VALUE([profile], '$.""name""') ASC, JSON_VALUE([profile], '$.""name""') DESC",
                    lengthEqualitySql: "SELECT * FROM [users] WHERE (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ? AND (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ? OR (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ? OR (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ?",
                    containsBindings: [ "en", "en" ]
                },
                {
                    name: "SQLite",
                    component: "qb.models.Grammars.SQLiteGrammar",
                    selectSql: "SELECT JSON_EXTRACT(""profile"", '$.""contacts""[0].""email""') AS ""explicitName"", JSON_EXTRACT(""profile"", '$.""contacts""[0].""email""') AS ""shortcutName"" FROM ""users""",
                    whereSql: "SELECT * FROM ""users"" WHERE JSON_EXTRACT(""profile"", '$.""age""') >= ? AND JSON_EXTRACT(""profile"", '$.""age""') < ?",
                    containsSql: "SELECT * FROM ""users"" WHERE EXISTS (SELECT 1 FROM JSON_EACH(""profile"", '$.""languages""') WHERE ""json_each"".""value"" IS ?) AND EXISTS (SELECT 1 FROM JSON_EACH(""profile"", '$.""languages""') WHERE ""json_each"".""value"" IS ?)",
                    existsSql: "SELECT * FROM ""users"" WHERE JSON_TYPE(""profile"", '$.""name""') IS NOT NULL AND JSON_TYPE(""profile"", '$.""name""') IS NOT NULL",
                    lengthSql: "SELECT * FROM ""users"" WHERE JSON_ARRAY_LENGTH(""profile"", '$.""languages""') > ? AND JSON_ARRAY_LENGTH(""profile"", '$.""languages""') > ? ORDER BY JSON_EXTRACT(""profile"", '$.""name""') ASC, JSON_EXTRACT(""profile"", '$.""name""') DESC",
                    lengthEqualitySql: "SELECT * FROM ""users"" WHERE JSON_ARRAY_LENGTH(""profile"", '$.""languages""') = ? AND JSON_ARRAY_LENGTH(""profile"", '$.""languages""') = ? OR JSON_ARRAY_LENGTH(""profile"", '$.""languages""') = ? OR JSON_ARRAY_LENGTH(""profile"", '$.""languages""') = ?",
                    containsBindings: [ "en", "en" ]
                },
                {
                    name: "Oracle",
                    component: "qb.models.Grammars.OracleGrammar",
                    selectSql: "SELECT JSON_VALUE(""PROFILE"", '$.""contacts""[0].""email""') AS ""EXPLICITNAME"", JSON_VALUE(""PROFILE"", '$.""contacts""[0].""email""') AS ""SHORTCUTNAME"" FROM ""USERS""",
                    whereSql: "SELECT * FROM ""USERS"" WHERE JSON_VALUE(""PROFILE"", '$.""age""') >= ? AND JSON_VALUE(""PROFILE"", '$.""age""') < ?",
                    containsSql: "SELECT * FROM ""USERS"" WHERE JSON_EXISTS(""PROFILE"", '$.""languages""[*]?(@ == $value)' PASSING ? AS ""value"") AND JSON_EXISTS(""PROFILE"", '$.""languages""[*]?(@ == $value)' PASSING ? AS ""value"")",
                    existsSql: "SELECT * FROM ""USERS"" WHERE JSON_EXISTS(""PROFILE"", '$.""name""') AND JSON_EXISTS(""PROFILE"", '$.""name""')",
                    lengthSql: "SELECT * FROM ""USERS"" WHERE JSON_VALUE(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) > ? AND JSON_VALUE(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) > ? ORDER BY JSON_VALUE(""PROFILE"", '$.""name""') ASC, JSON_VALUE(""PROFILE"", '$.""name""') DESC",
                    lengthEqualitySql: "SELECT * FROM ""USERS"" WHERE JSON_VALUE(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) = ? AND JSON_VALUE(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) = ? OR JSON_VALUE(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) = ? OR JSON_VALUE(""PROFILE"", '$.""languages"".size()' RETURNING NUMBER) = ?",
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

                    it( "defaults JSON length comparisons to equality with both syntaxes", function() {
                        var builder = getBuilder( grammarCase.component );
                        builder
                            .from( "users" )
                            .whereJsonLength( column = "profile", path = [ "languages" ], value = 1 )
                            .whereJsonLength( "profile->languages", 1 )
                            .orWhereJsonLength( column = "profile", path = [ "languages" ], value = 2 )
                            .orWhereJsonLength( "profile->languages", 2 );
                        assertQuery( builder, grammarCase.lengthEqualitySql, [ 1, 1, 2, 2 ] );
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
                    "SELECT * FROM `users` WHERE NOT (JSON_CONTAINS(`profile`, ?, '$.""languages""')) OR NOT (JSON_CONTAINS(`profile`, ?, '$.""languages""')) OR JSON_CONTAINS(`profile`, ?, '$.""languages""') AND NOT (IFNULL(JSON_CONTAINS_PATH(`profile`, 'one', '$.""nickname""'), 0)) OR IFNULL(JSON_CONTAINS_PATH(`profile`, 'one', '$.""name""'), 0) OR NOT (IFNULL(JSON_CONTAINS_PATH(`profile`, 'one', '$.""timezone""'), 0)) OR JSON_LENGTH(`profile`, '$.""languages""') > ?",
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
