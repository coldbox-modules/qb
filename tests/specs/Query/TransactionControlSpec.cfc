component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "typed constraint timing controls", function() {
            it( "compiles all or explicitly named constraint modes", function() {
                var builder = postgres();
                expect( builder.setConstraints( mode = "deferred", toSql = true ) ).toBe( "SET CONSTRAINTS ALL DEFERRED" );
                expect(
                    builder.setConstraints(
                        mode = "IMMEDIATE",
                        constraints = [ "public.parent_fk", "child_fk" ],
                        toSql = true
                    )
                ).toBe( "SET CONSTRAINTS ""public"".""parent_fk"", ""child_fk"" IMMEDIATE" );
            } );
            it( "compiles controls without executing or changing SELECT state", function() {
                var builder = postgres()
                    .from( "users" )
                    .where( "id", 17 )
                    .pretend();
                var before = builder.toSQL();
                builder.setConstraints( mode = "DEFERRED", toSql = true );
                expect( builder.getQueryLog() ).toBeEmpty();
                expect( builder.toSQL() ).toBe( before );
                expect( builder.getBindings()[ 1 ].value ).toBe( 17 );
            } );
            it( "quotes command identifiers even when ordinary wrapping is disabled", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();
                grammar.setShouldWrapValues( false );
                var builder = new qb.models.Query.QueryBuilder( grammar = grammar );
                expect(
                    builder.setConstraints( mode = "IMMEDIATE", constraints = [ "public.MixedCase" ], toSql = true )
                ).toBe( "SET CONSTRAINTS ""public"".""MixedCase"" IMMEDIATE" );
            } );
            it( "rejects raw SQL, invalid identifiers, and invalid modes", function() {
                var builder = postgres();
                expect( () => builder.setConstraints( mode = "IMMEDIATE", constraints = [ builder.raw( "ALL" ) ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.setConstraints( mode = "later", toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.setConstraints( mode = "DEFERRED", constraints = [ "*" ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
            } );
            it( "fails explicitly when a dialect does not implement the operation", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.BaseGrammar() );
                expect( () => builder.setConstraints( mode = "DEFERRED", toSql = true ) ).toThrow( "UnsupportedOperation" );
            } );
            it( "supports pretend execution and logs controls without SELECT bindings", function() {
                var builder = postgres()
                    .from( "users" )
                    .where( "id", 17 )
                    .pretend();
                builder.setConstraints( "DEFERRED" );
                expect( builder.getQueryLog() ).toHaveLength( 1 );
                for ( var entry in builder.getQueryLog() ) {
                    expect( entry.bindings ).toBeEmpty();
                    expect( entry.pretend ).toBeTrue();
                    expect( entry.returnObject ).toBe( "result" );
                }
                expect( builder.getBindings()[ 1 ].value ).toBe( 17 );
            } );
            it( "executes through runQuery with no inherited SELECT bindings or state changes", function() {
                var builder = getMockBox()
                    .createMock( "qb.models.Query.QueryBuilder" )
                    .init( grammar = new qb.models.Grammars.PostgresGrammar() );
                builder.$( "runQuery", { "ok": true } );
                builder.from( "users" ).where( "id", 17 );
                var before = builder.toSQL();
                builder.setConstraints( mode = "IMMEDIATE", options = { "datasource": "special" } );
                var calls = builder.$callLog().runQuery;
                expect( calls ).toHaveLength( 1 );
                for ( var call in calls ) {
                    expect( call.bindings ).toBeEmpty();
                    expect( call.returnObject ).toBe( "result" );
                }
                expect( calls[ 1 ].options ).toBe( { "datasource": "special" } );
                expect( calls[ 1 ].sql ).toBe( "SET CONSTRAINTS ALL IMMEDIATE" );
                expect( builder.toSQL() ).toBe( before );
                expect( builder.getBindings()[ 1 ].value ).toBe( 17 );
            } );
        } );
    }
    private any function postgres() {
        return new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );
    }

}
