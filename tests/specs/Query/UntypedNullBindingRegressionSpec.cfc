component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "untyped null binding regression", function() {
            it( "normalizes null parameter structs that omit a value", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.BaseGrammar( utils );

                expect( utils.extractBinding( { null: true }, grammar ) ).toBe( {
                    cfsqltype: "VARCHAR",
                    sqltype: "VARCHAR",
                    value: "",
                    list: false,
                    null: true
                } );
            } );
        } );
    }

}
