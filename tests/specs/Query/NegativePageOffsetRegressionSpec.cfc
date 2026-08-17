component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "negative page offset regression", function() {
            it( "clamps non-positive pages before calculating the offset", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder.from( "users" ).forPage( -1, 10 );

                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" LIMIT 10 OFFSET 0" );
            } );
        } );
    }

}
