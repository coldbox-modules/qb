component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Arrow-containing table aliases", function() {
            it( "preserves an arrow-containing join qualifier", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder
                    .from( "competitions comp" )
                    .join(
                        "seasons comp->currentSeason",
                        "comp->currentSeason.seasonUID",
                        "=",
                        "comp.seasonUID"
                    );
                expect( builder.toSQL() ).toBe( "SELECT * FROM [competitions] AS [comp] INNER JOIN [seasons] AS [comp->currentSeason] ON [comp->currentSeason].[seasonUID] = [comp].[seasonUID]" );
            } );

            it( "preserves an arrow-containing source qualifier", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder.from( "seasons comp->currentSeason" ).select( "comp->currentSeason.seasonUID" );
                expect( builder.toSQL() ).toBe( "SELECT [comp->currentSeason].[seasonUID] FROM [seasons] AS [comp->currentSeason]" );
            } );

            it( "still supports JSON paths in join conditions", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder
                    .from( "users u" )
                    .join(
                        "teams t",
                        "u.profile->teamId",
                        "=",
                        "t.id"
                    );
                expect( builder.toSQL() ).toBe( "SELECT * FROM [users] AS [u] INNER JOIN [teams] AS [t] ON JSON_VALUE([u].[profile], '$.""teamId""') = [t].[id]" );
            } );

            it( "preserves dotted JSON keys", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder.from( "users" ).select( "profile->address.city" );
                expect( builder.toSQL() ).toBe( "SELECT JSON_VALUE([profile], '$.""address.city""') FROM [users]" );
            } );

            it( "supports JSON paths on an arrow-containing qualifier", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder.from( "seasons comp->currentSeason" ).select( "comp->currentSeason.profile->name" );
                expect( builder.toSQL() ).toBe( "SELECT JSON_VALUE([comp->currentSeason].[profile], '$.""name""') FROM [seasons] AS [comp->currentSeason]" );
            } );

            it( "supports explicit JSON paths on an arrow-containing qualifier", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder
                    .from( "seasons comp->currentSeason" )
                    .select( builder.jsonPath( "comp->currentSeason.profile", [ "name" ] ) );
                expect( builder.toSQL() ).toBe( "SELECT JSON_VALUE([comp->currentSeason].[profile], '$.""name""') FROM [seasons] AS [comp->currentSeason]" );
            } );

            it( "recognizes aliases from earlier joins in later join conditions", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder
                    .from( "competitions comp" )
                    .join(
                        "seasons comp->currentSeason",
                        "comp->currentSeason.seasonUID",
                        "=",
                        "comp.seasonUID"
                    )
                    .join(
                        "years y",
                        "y.id",
                        "=",
                        "comp->currentSeason.yearId"
                    )
                    .where( "comp->currentSeason.active", 1 );
                expect( builder.toSQL() ).toBe( "SELECT * FROM [competitions] AS [comp] INNER JOIN [seasons] AS [comp->currentSeason] ON [comp->currentSeason].[seasonUID] = [comp].[seasonUID] INNER JOIN [years] AS [y] ON [y].[id] = [comp->currentSeason].[yearId] WHERE [comp->currentSeason].[active] = ?" );
            } );
        } );
    }

}
