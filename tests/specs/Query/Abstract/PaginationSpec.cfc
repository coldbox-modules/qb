component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "pagination", function() {
            it( "returns the default pagination object", function() {
                var builder = getBuilder();
                var expectedResults = [];
                for ( var i = 1; i <= 25; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$( "count", 45 );
                builder.$( "runQuery", expectedQuery );

                var results = builder.from( "users" ).paginate();

                expect( results ).toBe( {
                    "pagination": {
                        "maxRows": 25,
                        "offset": 0,
                        "page": 1,
                        "totalPages": 2,
                        "totalRecords": 45
                    },
                    "results": expectedResults
                } );
            } );

            it( "can get results for subsequent pages", function() {
                var builder = getBuilder();
                var expectedResults = [];
                for ( var i = 26; i <= 45; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$( "count", 45 );
                builder.$( "runQuery", expectedQuery );

                var results = builder.from( "users" ).paginate( page = 2 );

                expect( results ).toBe( {
                    "pagination": {
                        "maxRows": 25,
                        "offset": 25,
                        "page": 2,
                        "totalPages": 2,
                        "totalRecords": 45
                    },
                    "results": expectedResults
                } );
            } );

            it( "can provide a custom amount per page", function() {
                var builder = getBuilder();
                var expectedResults = [];
                for ( var i = 1; i <= 10; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$( "count", 45 );
                builder.$( "runQuery", expectedQuery );

                var results = builder.from( "users" ).paginate( page = 1, maxRows = 10 );

                expect( results ).toBe( {
                    "pagination": {
                        "maxRows": 10,
                        "offset": 0,
                        "page": 1,
                        "totalPages": 5,
                        "totalRecords": 45
                    },
                    "results": expectedResults
                } );
            } );

            it( "can provide a custom paginator shell", function() {
                var builder = getBuilder();
                builder.setPaginationCollector( {
                    "generateWithResults": function( totalRecords, results, page, maxRows ) {
                        return {
                            "total": totalRecords,
                            "pageNumber": page,
                            "limit": maxRows,
                            "data": results
                        };
                    }
                } );
                var expectedResults = [];
                for ( var i = 1; i <= 25; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$( "count", 45 );
                builder.$( "runQuery", expectedQuery );

                var results = builder.from( "users" ).paginate();

                expect( results ).toBe( {
                    "total": 45,
                    "pageNumber": 1,
                    "limit": 25,
                    "data": expectedResults
                } );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
        return builder;
    }

    private array function getTestBindings( builder ) {
        return builder
            .getBindings()
            .map( function( binding ) {
                return binding.value;
            } );
    }

}
