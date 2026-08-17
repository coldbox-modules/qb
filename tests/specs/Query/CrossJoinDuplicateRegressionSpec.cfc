component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Cross join duplicate regression", function() {
            it( "prevents duplicate simple cross joins", function() {
                var builder = new qb.models.Query.QueryBuilder( preventDuplicateJoins = true )
                    .from( "users" )
                    .crossJoin( "roles" )
                    .crossJoin( "roles" );

                expect( builder.getJoins() ).toHaveLength( 1 );
                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" CROSS JOIN ""roles""" );
            } );

            it( "prevents duplicate raw cross joins", function() {
                var builder = new qb.models.Query.QueryBuilder( preventDuplicateJoins = true )
                    .from( "users" )
                    .crossJoinRaw( "generate_series(1, 3) AS n" )
                    .crossJoinRaw( "generate_series(1, 3) AS n" );

                expect( builder.getJoins() ).toHaveLength( 1 );
            } );

            it( "prevents duplicate derived cross joins and their bindings", function() {
                var builder = new qb.models.Query.QueryBuilder( preventDuplicateJoins = true ).from( "users" );
                var source = function( query ) {
                    query.from( "roles" ).where( "active", true );
                };

                builder.crossJoinSub( "active_roles", source );
                builder.crossJoinSub( "active_roles", source );

                expect( builder.getJoins() ).toHaveLength( 1 );
                expect( builder.getBindings() ).toHaveLength( 1 );
            } );
        } );
    }

}
