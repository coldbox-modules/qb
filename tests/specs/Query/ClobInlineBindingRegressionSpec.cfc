component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "CLOB inline binding regression", function() {
            it( "renders CLOB bindings as escaped text literals", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.BaseGrammar( utils );
                var binding = utils.extractBinding( { "value": "Pete's notes", "cfsqltype": "CLOB" }, grammar );

                expect(
                    utils.replaceBindings(
                        "SELECT ?",
                        [ binding ],
                        true,
                        grammar
                    )
                ).toBe( "SELECT 'Pete''s notes'" );
            } );
        } );
    }

}
