component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "negative limit and offset regression", function() {
            it( "clamps direct row bounds to valid SQL values", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder
                    .from( "users" )
                    .limit( -10 )
                    .offset( -20 );

                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" LIMIT 0 OFFSET 0" );
            } );
        } );
    }

}
