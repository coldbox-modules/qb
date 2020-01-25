component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query defaults", function() {
            it( "can configure default options", function() {
                var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
                var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
                builder.setDefaultOptions( { "datasource": "foo" } );
                var expectedQuery = queryNew( "id", "integer", [ { id: 1 } ] );
                grammar.$( "runQuery", expectedQuery );
                builder
                    .select( "id" )
                    .from( "users" )
                    .get();
                expect( grammar.$once( "runQuery" ) ).toBeTrue( "runQuery should have been called once." );
                var options = grammar.$callLog().runQuery[ 1 ][ 3 ];
                expect( options ).toBeStruct();
                expect( options ).toHaveKey( "datasource" );
                expect( options.datasource ).toBe( "foo" );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
        return builder;
    }

}
