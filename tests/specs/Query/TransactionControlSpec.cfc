component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "typed transaction controls", function() {
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
            it( "compiles table locks with explicit modes and NOWAIT", function() {
                var builder = postgres();
                expect( builder.lockTables( tables = [ "public.items", "outbox" ], toSql = true ) ).toBe( "LOCK TABLE ""public"".""items"", ""outbox"" IN SHARE MODE" );
                expect(
                    builder.lockTables(
                        tables = [ "items" ],
                        mode = "access exclusive",
                        nowait = true,
                        toSql = true
                    )
                ).toBe( "LOCK TABLE ""items"" IN ACCESS EXCLUSIVE MODE NOWAIT" );
            } );
            it( "accepts each PostgreSQL table lock mode", function() {
                var builder = postgres();
                var modes = [
                    "ACCESS SHARE",
                    "ROW SHARE",
                    "ROW EXCLUSIVE",
                    "SHARE UPDATE EXCLUSIVE",
                    "SHARE",
                    "SHARE ROW EXCLUSIVE",
                    "EXCLUSIVE",
                    "ACCESS EXCLUSIVE"
                ];
                for ( var mode in modes ) {
                    expect( builder.lockTables( tables = [ "items" ], mode = mode, toSql = true ) ).toBe( "LOCK TABLE ""items"" IN " & mode & " MODE" );
                }
            } );
            it( "compiles controls without executing or changing SELECT state", function() {
                var builder = postgres()
                    .from( "users" )
                    .where( "id", 17 )
                    .pretend();
                var before = builder.toSQL();
                builder.setConstraints( mode = "DEFERRED", toSql = true );
                builder.lockTables( tables = [ "items" ], toSql = true );
                expect( builder.getQueryLog() ).toBeEmpty();
                expect( builder.toSQL() ).toBe( before );
                expect( builder.getBindings()[ 1 ].value ).toBe( 17 );
            } );
            it( "quotes command identifiers even when ordinary wrapping is disabled", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();
                grammar.setShouldWrapValues( false );
                var builder = new qb.models.Query.QueryBuilder( grammar = grammar );
                expect( builder.lockTables( tables = [ "MixedCase" ], toSql = true ) ).toBe( "LOCK TABLE ""MixedCase"" IN SHARE MODE" );
                expect(
                    builder.setConstraints( mode = "IMMEDIATE", constraints = [ "public.MixedCase" ], toSql = true )
                ).toBe( "SET CONSTRAINTS ""public"".""MixedCase"" IMMEDIATE" );
            } );
            it( "rejects raw SQL, aliases, empty lists, and invalid modes", function() {
                var builder = postgres();
                expect( () => builder.lockTables( tables = [], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [ "items AS i" ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [ builder.raw( "items" ) ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [ "items" ], mode = "SHARE; COMMIT", toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [ "items; COMMIT" ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.setConstraints( mode = "IMMEDIATE", constraints = [ builder.raw( "ALL" ) ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.setConstraints( mode = "later", toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.setConstraints( mode = "DEFERRED", constraints = [ "*" ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
            } );
            it( "fails explicitly when a dialect does not implement the operation", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.BaseGrammar() );
                expect( () => builder.setConstraints( mode = "DEFERRED", toSql = true ) ).toThrow( "UnsupportedOperation" );
                expect( () => builder.lockTables( tables = [ "items" ], toSql = true ) ).toThrow( "UnsupportedOperation" );
            } );
            it( "supports pretend execution and logs controls without SELECT bindings", function() {
                var builder = postgres()
                    .from( "users" )
                    .where( "id", 17 )
                    .pretend();
                builder.setConstraints( "DEFERRED" );
                builder.lockTables( [ "users" ] );
                expect( builder.getQueryLog() ).toHaveLength( 2 );
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
                builder.lockTables( tables = [ "items" ] );
                var calls = builder.$callLog().runQuery;
                expect( calls ).toHaveLength( 2 );
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
