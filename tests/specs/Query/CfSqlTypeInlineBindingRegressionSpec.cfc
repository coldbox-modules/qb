component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "cf_sql inline binding regression", function() {
            it( "renders prefixed numeric SQL types without string quotes", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.BaseGrammar( utils );
                var binding = utils.extractBinding( { "value": 42, "cfsqltype": "cf_sql_integer" }, grammar );

                expect(
                    utils.replaceBindings(
                        "SELECT ?",
                        [ binding ],
                        true,
                        grammar
                    )
                ).toBe( "SELECT 42" );
            } );
        } );
    }

}
