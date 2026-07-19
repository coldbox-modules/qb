component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "shouldWrapValues setting", function() {

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

                var sql = builder.from( "users" ).select( "name" ).toSQL();

                expect( sql ).toBe( 'SELECT "name" FROM "users"' );

                sql = builder.from( "users" ).select( "id" ).where( "email", "test@test.com" ).toSQL( withBindings = true );

                expect( sql ).toBe( 'SELECT "id" FROM "users" WHERE "email" = ?' );
            } );

            it( "does not wrap identifiers when shouldWrapValues is false", function() {
                var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
                var grammar = getMockBox().createMock( "qb.models.Grammars.PostgresGrammar" ).init( utils );
                grammar.setShouldWrapValues( false );

                var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );

                var sql = builder.from( "users" ).select( "name" ).toSQL();

                expect( sql ).toBe( "SELECT name FROM users" );

                sql = builder.from( "users" ).select( "id" ).where( "email", "test@test.com" ).toSQL();

                expect( sql ).toBe( "SELECT id FROM users WHERE email = ?" );
            } );

            it( "per-query withoutWrappingValues overrides grammar default", function() {
                var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
                var grammar = getMockBox().createMock( "qb.models.Grammars.PostgresGrammar" ).init( utils );
                grammar.setShouldWrapValues( true );

                var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );

                // Grammar default is true, but per-query override to false
                var sql = builder.withoutWrappingValues().from( "users" ).select( "name" ).toSQL();

                expect( sql ).toBe( "SELECT name FROM users" );
            } );

        } );
    }

}
