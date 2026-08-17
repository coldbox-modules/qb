component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Oracle row number column regression", function() {
            it( "preserves application QB_RN columns outside generated pagination queries", function() {
                var grammar = getMockBox().createMock( "qb.models.Grammars.OracleGrammar" ).init();
                grammar.$property(
                    propertyName = "userRows",
                    mock = queryNew( "QB_RN,name", "integer,varchar", [ { QB_RN: 7, name: "Ada" } ] )
                );

                var result = grammar.runQuery(
                    sql = "SELECT QB_RN, name FROM userRows",
                    bindings = [],
                    options = { dbtype: "query" }
                );

                expect( queryColumnList( result ) ).toInclude( "QB_RN" );
                expect( result.QB_RN[ 1 ] ).toBe( 7 );
            } );

            it( "removes generated QB_RN metadata from empty pagination results", function() {
                var grammar = getMockBox().createMock( "qb.models.Grammars.OracleGrammar" ).init();
                grammar.$property( propertyName = "userRows", mock = queryNew( "QB_RN,name", "integer,varchar" ) );

                var result = grammar.runQuery(
                    sql = "/* SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM ( */ SELECT QB_RN, name FROM userRows",
                    bindings = [],
                    options = { dbtype: "query" }
                );

                expect( result ).toBeQuery();
                expect( result.recordCount ).toBe( 0 );
                expect( queryColumnList( result ) ).notToInclude( "QB_RN" );
                expect( queryColumnList( result ) ).toInclude( "name" );
            } );
        } );
    }

}
