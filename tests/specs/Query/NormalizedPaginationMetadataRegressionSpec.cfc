component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "normalized pagination metadata regression", function() {
            it( "passes the normalized page to pagination collectors", function() {
                var builder = getBuilder();
                builder.$( "count", 1 );
                builder.$( "runQuery", queryNew( "id", "integer", [ { id: 1 } ] ) );
                builder.setPaginationCollector( {
                    "generateWithResults": function( totalRecords, results, page, maxRows ) {
                        return { page: page };
                    }
                } );

                var results = builder.from( "users" ).paginate( page = -1 );

                expect( results.page ).toBe( 1 );
            } );

            it( "passes the normalized page to simple pagination collectors", function() {
                var builder = getBuilder();
                builder.$( "runQuery", queryNew( "id", "integer", [ { id: 1 } ] ) );
                builder.setPaginationCollector( {
                    "generateSimpleWithResults": function( results, page, maxRows ) {
                        return { page: page };
                    }
                } );

                var results = builder.from( "users" ).simplePaginate( page = -1 );

                expect( results.page ).toBe( 1 );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        return getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
    }

}
