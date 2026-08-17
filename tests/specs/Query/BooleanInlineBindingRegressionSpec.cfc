component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "boolean inline binding regression", function() {
            it( "renders PostgreSQL Boolean bindings as SQL literals", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.PostgresGrammar( utils );
                var binding = utils.extractBinding( true, grammar );

                expect( binding.cfsqltype ).toBe( "OTHER" );
                expect(
                    utils.replaceBindings(
                        "SELECT ?",
                        [ binding ],
                        true,
                        grammar
                    )
                ).toBe( "SELECT TRUE" );
            } );
        } );
    }

}
