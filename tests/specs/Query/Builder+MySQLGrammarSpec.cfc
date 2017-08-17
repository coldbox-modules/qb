import qb.models.Query.Builder;

component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "MySQL Grammar", function() {
            it( "correctly wraps values for MySQL", function() {
                var builder = getBuilder();
                builder.select( "name" ).from( "users" );
                expect( builder.toSql() ).toBe( "SELECT `name` FROM `users`" );
            } );

            describe( "updateOrInsert statements", function() {
                it( "inserts a new record when the where clause does not bring back any records", function() {
                    var builder = getBuilder();
                    builder.$( "exists", false );
                    var sql = builder.from( "users" )
                        .whereID( 10 )
                        .updateOrInsert(
                            values = {  "name" = "Andrew", "email" = "andrew@test.com", "age" = 35 },
                            toSql = true
                        );
                    expect( sql ).toBe( "INSERT INTO `users` (`age`, `email`, `name`) VALUES (?, ?, ?)" );

                    var bindings = builder.getRawBindings();
                    expect( bindings.insert ).toBeArray();
                    expect( bindings.insert ).toHaveLength( 3 );
                    expect( bindings.insert[ 1 ].value ).toBe( 35 );
                    expect( bindings.insert[ 2 ].value ).toBe( "andrew@test.com" );
                    expect( bindings.insert[ 3 ].value ).toBe( "Andrew" );
                } );

                it( "updates an existing record when the where clause brings back at least one record", function() {
                    var builder = getBuilder();
                    builder.$( "exists", true );
                    var sql = builder.from( "users" )
                        .whereID( 10 )
                        .updateOrInsert(
                            values = {  "name" = "Andrew", "email" = "andrew@test.com", "age" = 35 },
                            toSql = true
                        );
                    expect( sql ).toBe( "UPDATE `users` SET `age` = ?, `email` = ?, `name` = ? WHERE `ID` = ? LIMIT 1" );

                    var bindings = builder.getRawBindings();
                    expect( bindings.update ).toBeArray();
                    expect( bindings.update ).toHaveLength( 3 );
                    expect( bindings.update[ 1 ].value ).toBe( 35 );
                    expect( bindings.update[ 2 ].value ).toBe( "andrew@test.com" );
                    expect( bindings.update[ 3 ].value ).toBe( "Andrew" );

                    expect( bindings.where ).toBeArray();
                    expect( bindings.where ).toHaveLength( 1 );
                    expect( bindings.where[ 1 ].value ).toBe( 10 );
                } );
            } );
        } );
    }

    private Builder function getBuilder() {
        var grammar = getMockBox()
            .createMock( "qb.models.Query.Grammars.MySQLGrammar" );
        var queryUtils = getMockBox()
            .createMock( "qb.models.Query.QueryUtils" );
        var builder = getMockBox().createMock( "qb.models.Query.Builder" )
            .init( grammar, queryUtils );
        return builder;
    }

    private array function getTestBindings( required Builder builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}
