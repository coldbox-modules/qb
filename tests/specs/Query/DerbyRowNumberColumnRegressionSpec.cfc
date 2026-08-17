component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Derby row number column regression", function() {
            it( "preserves application QB_RN columns", function() {
                var grammar = getMockBox().createMock( "qb.models.Grammars.DerbyGrammar" ).init();
                grammar.$property(
                    propertyName = "userRows",
                    mock = queryNew( "QB_RN,name", "integer,varchar", [ { QB_RN: 7, name: "Ada" } ] )
                );

                var result = grammar.runQuery(
                    sql = "SELECT QB_RN, name FROM userRows",
                    bindings = [],
                    options = { dbtype: "query" }
                );

                expect( listToArray( lCase( result.columnList ) ) ).toInclude( "qb_rn" );
                expect( result.QB_RN[ 1 ] ).toBe( 7 );
            } );
        } );
    }

}
