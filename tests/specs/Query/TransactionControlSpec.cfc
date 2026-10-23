component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "typed transaction controls", function() {
            it( "compiles PostgreSQL savepoint operations", function() {
                var builder = postgres();
                expect( builder.createSavepoint( name = "batch_1", toSql = true ) ).toBe( "SAVEPOINT ""batch_1""" );
                expect( builder.rollbackToSavepoint( name = "batch_1", toSql = true ) ).toBe( "ROLLBACK TO SAVEPOINT ""batch_1""" );
                expect( builder.releaseSavepoint( name = "batch_1", toSql = true ) ).toBe( "RELEASE SAVEPOINT ""batch_1""" );
            } );
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
            it( "quotes command identifiers even when ordinary wrapping is disabled", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();
                grammar.setShouldWrapValues( false );
                var builder = new qb.models.Query.QueryBuilder( grammar = grammar );
                expect( builder.createSavepoint( name = "MixedCase", toSql = true ) ).toBe( "SAVEPOINT ""MixedCase""" );
            } );
            it( "rejects raw SQL, aliases, empty lists, and invalid modes", function() {
                var builder = postgres();
                expect( () => builder.createSavepoint( name = "x; COMMIT", toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.releaseSavepoint( name = "", toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [ "items AS i" ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [ builder.raw( "items" ) ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.lockTables( tables = [ "items" ], mode = "SHARE; COMMIT", toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.setConstraints( mode = "later", toSql = true ) ).toThrow( "InvalidTransactionControl" );
                expect( () => builder.setConstraints( mode = "DEFERRED", constraints = [ "*" ], toSql = true ) ).toThrow( "InvalidTransactionControl" );
            } );
            it( "fails explicitly when a dialect does not implement the operation", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.BaseGrammar() );
                expect( () => builder.createSavepoint( name = "batch", toSql = true ) ).toThrow( "UnsupportedOperation" );
                expect( () => builder.rollbackToSavepoint( name = "batch", toSql = true ) ).toThrow( "UnsupportedOperation" );
                expect( () => builder.releaseSavepoint( name = "batch", toSql = true ) ).toThrow( "UnsupportedOperation" );
                expect( () => builder.setConstraints( mode = "DEFERRED", toSql = true ) ).toThrow( "UnsupportedOperation" );
                expect( () => builder.lockTables( tables = [ "items" ], toSql = true ) ).toThrow( "UnsupportedOperation" );
            } );
            it( "supports pretend execution and logs controls without SELECT bindings", function() {
                var builder = postgres()
                    .from( "users" )
                    .where( "id", 17 )
                    .pretend();
                builder.createSavepoint( "batch" );
                builder.rollbackToSavepoint( "batch" );
                builder.releaseSavepoint( "batch" );
                builder.setConstraints( "DEFERRED" );
                builder.lockTables( [ "users" ] );
                expect( builder.getQueryLog() ).toHaveLength( 5 );
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
                builder.createSavepoint( name = "batch", options = { "datasource": "special" } );
                builder.rollbackToSavepoint( name = "batch" );
                builder.releaseSavepoint( name = "batch" );
                builder.setConstraints( mode = "IMMEDIATE" );
                builder.lockTables( tables = [ "items" ] );
                var calls = builder.$callLog().runQuery;
                expect( calls ).toHaveLength( 5 );
                for ( var call in calls ) {
                    expect( call.bindings ).toBeEmpty();
                    expect( call.returnObject ).toBe( "result" );
                }
                expect( calls[ 1 ].options ).toBe( { "datasource": "special" } );
                expect( calls[ 1 ].sql ).toBe( "SAVEPOINT ""batch""" );
                expect( builder.toSQL() ).toBe( before );
                expect( builder.getBindings()[ 1 ].value ).toBe( 17 );
            } );
        } );
    }
    private any function postgres() {
        return new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );
    }

}
