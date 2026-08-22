component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "raw expression null binding regression", function() {
            it( "preserves null positions in raw expression bindings", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder.from( "users" ).selectRaw( "COALESCE(?, 0) AS score", [ javacast( "null", "" ) ] );

                expect( builder.toSQL() ).toBe( "SELECT COALESCE(?, 0) AS score FROM ""users""" );
                expect( builder.getBindings() ).toHaveLength( 1 );
                expect( builder.getBindings()[ 1 ].null ).toBeTrue();
            } );
        } );
    }

}
