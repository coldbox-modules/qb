component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "shouldWrapValues setting", function() {
            it( "does not eagerly discover a grammar when configured", function() {
                var grammar = getMockBox().createMock( "qb.models.Grammars.PostgresGrammar" ).init();
                var autoDiscover = getMockBox()
                    .createMock( "qb.models.Grammars.AutoDiscover" )
                    .$( "autoDiscoverGrammar", grammar );

                autoDiscover.setShouldWrapValues( false );

                expect( autoDiscover.$count( "autoDiscoverGrammar" ) ).toBe( 0 );
                expect( autoDiscover.onMissingMethod( "wrapValue", { "value": "users" } ) ).toBe( "users" );
                expect( autoDiscover.$count( "autoDiscoverGrammar" ) ).toBe( 1 );
                expect( grammar.getShouldWrapValues() ).toBeFalse();
            } );

            it( "defaults to true in BaseGrammar", function() {
                var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
                var grammar = getMockBox().createMock( "qb.models.Grammars.PostgresGrammar" ).init( utils );

                expect( grammar.getShouldWrapValues() ).toBeTrue( "shouldWrapValues should default to true" );
            } );

            it( "wraps identifiers in double quotes when shouldWrapValues is true", function() {
                var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
                var grammar = getMockBox().createMock( "qb.models.Grammars.PostgresGrammar" ).init( utils );
                grammar.setShouldWrapValues( true );

                var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );

                var sql = builder
                    .from( "users" )
                    .select( "name" )
                    .toSQL();

                expect( sql ).toBe( "SELECT ""name"" FROM ""users""" );

                sql = builder
                    .from( "users" )
                    .select( "id" )
                    .where( "email", "test@test.com" )
                    .toSQL( withBindings = true );

                expect( sql ).toBe( "SELECT ""id"" FROM ""users"" WHERE ""email"" = ?" );
            } );

            it( "does not wrap identifiers when shouldWrapValues is false", function() {
                var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
                var grammar = getMockBox().createMock( "qb.models.Grammars.PostgresGrammar" ).init( utils );
                grammar.setShouldWrapValues( false );

                var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );

                var sql = builder
                    .from( "users" )
                    .select( "name" )
                    .toSQL();

                expect( sql ).toBe( "SELECT name FROM users" );

                sql = builder
                    .from( "users" )
                    .select( "id" )
                    .where( "email", "test@test.com" )
                    .toSQL();

                expect( sql ).toBe( "SELECT id FROM users WHERE email = ?" );
            } );

            it( "per-query withoutWrappingValues overrides grammar default", function() {
                var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
                var grammar = getMockBox().createMock( "qb.models.Grammars.PostgresGrammar" ).init( utils );
                grammar.setShouldWrapValues( true );

                var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );

                // Grammar default is true, but per-query override to false
                var sql = builder
                    .withoutWrappingValues()
                    .from( "users" )
                    .select( "name" )
                    .toSQL();

                expect( sql ).toBe( "SELECT name FROM users" );
            } );

            it( "preserves per-query wrapping overrides in new queries and clones", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();
                var builder = new qb.models.Query.QueryBuilder( grammar )
                    .withoutWrappingValues()
                    .select( "id" )
                    .from( "users" );

                expect( builder.newQuery().getShouldWrapValues() ).toBeFalse();
                expect( builder.clone().toSQL() ).toBe( "SELECT id FROM users" );
            } );
        } );

        describe( "SQL literal escaping", function() {
            it( "escapes each grammar's identifier delimiter", function() {
                expect( new qb.models.Grammars.PostgresGrammar().wrapValue( "odd""name" ) ).toBe( """odd""""name""" );
                expect( new qb.models.Grammars.SQLiteGrammar().wrapValue( "odd""name" ) ).toBe( """odd""""name""" );
                expect( new qb.models.Grammars.DerbyGrammar().wrapValue( "odd""name" ) ).toBe( """odd""""name""" );
                expect( new qb.models.Grammars.OracleGrammar().wrapValue( "odd""name" ) ).toBe( """ODD""""NAME""" );
                expect( new qb.models.Grammars.MySQLGrammar().wrapValue( "odd#chr( 96 )#name" ) ).toBe(
                    "#chr( 96 )#odd#chr( 96 )##chr( 96 )#name#chr( 96 )#"
                );
                expect( new qb.models.Grammars.SqlServerGrammar().wrapValue( "odd]name" ) ).toBe( "[odd]]name]" );
            } );

            it( "escapes backslashes in JSON path segments", function() {
                var slash = chr( 92 );
                var grammar = new qb.models.Grammars.BaseGrammar();

                expect( grammar.buildJsonPath( [ "folder#slash#name" ] ) ).toBe( "$.""folder#slash##slash#name""" );
            } );
        } );
    }

}
