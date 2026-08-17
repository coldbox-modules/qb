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

            it( "isolates per-query wrapping overrides during concurrent compilation", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();
                var unwrappedBuilder = new qb.models.Query.QueryBuilder( grammar )
                    .withoutWrappingValues()
                    .select( "unwrapped_column" )
                    .from( "users" );
                var wrappedBuilder = new qb.models.Query.QueryBuilder( grammar )
                    .withWrappingValues()
                    .select( "wrapped_column" )
                    .from( "users" );
                var unwrappedThreadName = "unwrappedCompilation#replace( createUUID(), "-", "", "all" )#";
                var wrappedThreadName = "wrappedCompilation#replace( createUUID(), "-", "", "all" )#";
                var unwrappedResultKey = "qb_#unwrappedThreadName#";
                var wrappedResultKey = "qb_#wrappedThreadName#";
                var unwrappedBuilderKey = "#unwrappedResultKey#_builder";
                var wrappedBuilderKey = "#wrappedResultKey#_builder";
                var grammarKey = "#unwrappedResultKey#_grammar";
                var unwrappedEnteredKey = "#unwrappedResultKey#_entered";
                var wrappedEnteredKey = "#wrappedResultKey#_entered";
                server[ unwrappedBuilderKey ] = unwrappedBuilder;
                server[ wrappedBuilderKey ] = wrappedBuilder;
                server[ grammarKey ] = grammar;
                server[ unwrappedEnteredKey ] = createObject( "java", "java.util.concurrent.CountDownLatch" ).init( 1 );
                server[ wrappedEnteredKey ] = createObject( "java", "java.util.concurrent.CountDownLatch" ).init( 1 );

                try {
                    thread
                        name=unwrappedThreadName
                        action="run"
                        grammarKey=grammarKey
                        builderKey=unwrappedBuilderKey
                        resultKey=unwrappedResultKey
                        enteredKey=unwrappedEnteredKey
                        otherEnteredKey=wrappedEnteredKey {
                        server[ attributes.grammarKey ].pushShouldWrapValuesContext( false );
                        try {
                            server[ attributes.enteredKey ].countDown();
                            server[ attributes.otherEnteredKey ].await();
                            server[ attributes.resultKey ] = server[ attributes.builderKey ].toSQL();
                        } finally {
                            server[ attributes.grammarKey ].popShouldWrapValuesContext();
                        }
                    }
                    thread
                        name=wrappedThreadName
                        action="run"
                        grammarKey=grammarKey
                        builderKey=wrappedBuilderKey
                        resultKey=wrappedResultKey
                        enteredKey=wrappedEnteredKey
                        otherEnteredKey=unwrappedEnteredKey {
                        server[ attributes.grammarKey ].pushShouldWrapValuesContext( true );
                        try {
                            server[ attributes.otherEnteredKey ].await();
                            server[ attributes.enteredKey ].countDown();
                            server[ attributes.resultKey ] = server[ attributes.builderKey ].toSQL();
                        } finally {
                            server[ attributes.grammarKey ].popShouldWrapValuesContext();
                        }
                    }
                    thread action="join" name="#unwrappedThreadName#,#wrappedThreadName#" timeout="10000";

                    if (
                        cfthread[ unwrappedThreadName ].status != "COMPLETED" ||
                        cfthread[ wrappedThreadName ].status != "COMPLETED"
                    ) {
                        throw(
                            message = "Concurrent compilation did not complete",
                            detail = serializeJSON( { "unwrapped": cfthread[ unwrappedThreadName ], "wrapped": cfthread[ wrappedThreadName ] } )
                        );
                    }
                    expect( server[ unwrappedResultKey ] ).toBe( "SELECT unwrapped_column FROM users" );
                    expect( server[ wrappedResultKey ] ).toBe( "SELECT ""wrapped_column"" FROM ""users""" );
                } finally {
                    structDelete( server, unwrappedResultKey );
                    structDelete( server, wrappedResultKey );
                    structDelete( server, unwrappedBuilderKey );
                    structDelete( server, wrappedBuilderKey );
                    structDelete( server, grammarKey );
                    structDelete( server, unwrappedEnteredKey );
                    structDelete( server, wrappedEnteredKey );
                }
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
                expect( new qb.models.Grammars.MySQLGrammar().wrapValue( "odd""name" ) ).toBe(
                    "#chr( 96 )#odd""name#chr( 96 )#"
                );
                expect( new qb.models.Grammars.SqlServerGrammar().wrapValue( "odd]name" ) ).toBe( "[odd]]name]" );
                expect( new qb.models.Grammars.SqlServerGrammar().wrapValue( "odd""name" ) ).toBe( "[odd""name]" );
            } );

            it( "escapes backslashes in JSON path segments", function() {
                var slash = chr( 92 );
                var grammar = new qb.models.Grammars.BaseGrammar();

                expect( grammar.buildJsonPath( [ "folder#slash#name" ] ) ).toBe( "$.""folder#slash##slash#name""" );
            } );
        } );
    }

}
