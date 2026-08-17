component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "WHERE IN null binding regression", function() {
            it( "preserves null array positions as null bindings", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder.from( "users" ).whereIn( "id", [ 1, javacast( "null", "" ), 2 ] );

                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""id"" IN (?, ?, ?)" );
                expect( builder.getBindings() ).toHaveLength( 3 );
                expect( builder.getBindings()[ 2 ].null ).toBeTrue();
            } );

            it( "preserves null array positions in NOT IN predicates", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder.from( "users" ).whereNotIn( "id", [ 1, javacast( "null", "" ), 2 ] );

                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""id"" NOT IN (?, ?, ?)" );
                expect( builder.getBindings() ).toHaveLength( 3 );
                expect( builder.getBindings()[ 2 ].null ).toBeTrue();
            } );
        } );
    }

}
