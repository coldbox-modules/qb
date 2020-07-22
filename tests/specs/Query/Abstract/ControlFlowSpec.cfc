component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "control flow", function() {
            describe( "when", function() {
                it( "executes the callback when the condition is true", function() {
                    testCase( function( builder ) {
                        builder
                            .from( "users" )
                            .when( true, function( query ) {
                                query.where( "id", "=", 1 );
                            } )
                            .where( "email", "foo" );
                    }, { sql: "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?", bindings: [ 1, "foo" ] } );
                } );

                it( "does not execute the callback when the condition is false", function() {
                    testCase( function( builder ) {
                        builder
                            .from( "users" )
                            .when( false, function( query ) {
                                query.where( "id", "=", 1 );
                            } )
                            .where( "email", "foo" );
                    }, { sql: "SELECT * FROM ""users"" WHERE ""email"" = ?", bindings: [ "foo" ] } );
                } );

                it( "executes the default callback when the condition is false", function() {
                    testCase( function( builder ) {
                        builder
                            .select( "*" )
                            .from( "users" )
                            .when(
                                false,
                                function( query ) {
                                    query.where( "id", "=", 1 );
                                },
                                function( query ) {
                                    query.where( "id", "=", 2 );
                                }
                            )
                            .where( "email", "foo" );
                    }, { sql: "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?", bindings: [ 2, "foo" ] } );
                } );

                it( "does not execute the default callback when the condition is true", function() {
                    testCase( function( builder ) {
                        builder
                            .select( "*" )
                            .from( "users" )
                            .when(
                                true,
                                function( query ) {
                                    query.where( "id", "=", 1 );
                                },
                                function( query ) {
                                    query.where( "id", "=", 2 );
                                }
                            )
                            .where( "email", "foo" );
                    }, { sql: "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?", bindings: [ 1, "foo" ] } );
                } );

                it( "wraps the wheres if an OR combinator is used inside the callback", function() {
                    testCase(
                        function( builder ) {
                            builder
                                .select( "*" )
                                .from( "users" )
                                .where( "email", "foo" )
                                .when( true, function( query ) {
                                    query.where( "id", "=", 1 ).orWhere( "id", "=", 2 );
                                } );
                        },
                        {
                            sql: "SELECT * FROM ""users"" WHERE ""email"" = ? AND (""id"" = ? OR ""id"" = ?)",
                            bindings: [ "foo", 1, 2 ]
                        }
                    );
                } );

                it( "can skip the wrapping of wheres if an OR combinator is used inside the callback", function() {
                    testCase(
                        function( builder ) {
                            builder
                                .select( "*" )
                                .from( "users" )
                                .where( "email", "foo" )
                                .when(
                                    condition = true,
                                    onTrue = function( query ) {
                                        query.where( "id", "=", 1 ).orWhere( "id", "=", 2 );
                                    },
                                    withoutScoping = true
                                );
                        },
                        {
                            sql: "SELECT * FROM ""users"" WHERE ""email"" = ? AND ""id"" = ? OR ""id"" = ?",
                            bindings: [ "foo", 1, 2 ]
                        }
                    );
                } );

                it( "does not double wrap the wheres if an the wheres are already wrapped inside the callback", function() {
                    testCase(
                        function( builder ) {
                            builder
                                .select( "*" )
                                .from( "users" )
                                .where( "email", "foo" )
                                .when( true, function( query ) {
                                    query.where( function( q2 ) {
                                        q2.where( "id", "=", 1 ).orWhere( "id", "=", 2 );
                                    } );
                                } );
                        },
                        {
                            sql: "SELECT * FROM ""users"" WHERE ""email"" = ? AND (""id"" = ? OR ""id"" = ?)",
                            bindings: [ "foo", 1, 2 ]
                        }
                    );
                } );
            } );

            describe( "tap", function() {
                it( "runs a callback that gets passed the query. without modifying the query", function() {
                    variables.count = 0;
                    testCase( function( builder ) {
                        builder
                            .from( "users" )
                            .tap( function( q ) {
                                count++;
                            } )
                            .where( "id", 1 )
                            .tap( function( q ) {
                                count++;
                            } )
                            .tap( function( q ) {
                                count++;
                                // attempts to modify the query should not work
                                return q.where( "foo", "bar" );
                            } );
                    }, { sql: "SELECT * FROM ""users"" WHERE ""id"" = ?", bindings: [ 1 ] } );

                    expect( count ).toBe( 3, "Three different tap functions should have been called." );
                } );
            } );
        } );
    }

    private function testCase( callback, expected ) {
        var builder = getBuilder();
        var sql = callback( builder );
        if ( !isNull( sql ) ) {
            if ( !isSimpleValue( sql ) ) {
                sql = sql.toSQL();
            }
        } else {
            sql = builder.toSQL();
        }
        if ( isSimpleValue( expected ) ) {
            expected = { sql: expected, bindings: [] };
        }
        expect( sql ).toBeWithCase( expected.sql );
        expect( getTestBindings( builder ) ).toBe( expected.bindings );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
        return builder;
    }

    private array function getTestBindings( builder ) {
        return builder
            .getBindings()
            .map( function( binding ) {
                return binding.value;
            } );
    }

}
