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
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

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

            it( "can paginate a group by query", function() {
                var builder = getBuilder();
                var expectedResults = [];
                for ( var i = 1; i <= 25; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

                var nestedBuilder = getBuilder();
                nestedBuilder.$( "count", 15 );
                builder.$( "newQuery", nestedBuilder );

                var results = builder
                    .from( "users" )
                    .groupBy( "lastName" )
                    .paginate();

                expect( results ).toBe( {
                    "pagination": {
                        "maxRows": 25,
                        "offset": 0,
                        "page": 1,
                        "totalPages": 1,
                        "totalRecords": 15
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
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

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
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

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

            it( "can does not limit the query when the maxrows passes the override check", function() {
                var builder = getBuilder();
                builder.setShouldMaxRowsOverrideToAll( function( maxrows ) {
                    return maxrows <= 0;
                } );

                var expectedResults = [];
                for ( var i = 1; i <= 45; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$( "count", 45 );
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

                var results = builder.from( "users" ).paginate( page = 1, maxRows = 0 );

                expect( results.pagination ).toBe( {
                    "maxRows": 0,
                    "offset": 0,
                    "page": 1,
                    "totalPages": 0,
                    "totalRecords": 45
                } );
                expect( results.results ).toBe( expectedResults );
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
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

                var results = builder.from( "users" ).paginate();

                expect( results ).toBe( {
                    "total": 45,
                    "pageNumber": 1,
                    "limit": 25,
                    "data": expectedResults
                } );
            } );
        } );

        describe( "simple pagination", function() {
            it( "returns the default pagination object", function() {
                var builder = getBuilder();
                var expectedResults = [];
                for ( var i = 1; i <= 26; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

                var results = builder.from( "users" ).simplePaginate();

                expect( results ).toBe( {
                    "pagination": {
                        "maxRows": 25,
                        "offset": 0,
                        "page": 1,
                        "hasMore": true
                    },
                    "results": expectedResults.slice( 1, 25 )
                } );
            } );

            it( "can get results for subsequent pages", function() {
                var builder = getBuilder();
                var expectedResults = [];
                for ( var i = 26; i <= 45; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

                var results = builder.from( "users" ).simplePaginate( page = 2 );

                expect( results ).toBe( {
                    "pagination": {
                        "maxRows": 25,
                        "offset": 25,
                        "page": 2,
                        "hasMore": false
                    },
                    "results": expectedResults
                } );
            } );

            it( "can provide a custom amount per page", function() {
                var builder = getBuilder();
                var expectedResults = [];
                for ( var i = 1; i <= 11; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

                var results = builder.from( "users" ).simplePaginate( page = 1, maxRows = 10 );

                expect( results ).toBe( {
                    "pagination": {
                        "maxRows": 10,
                        "offset": 0,
                        "page": 1,
                        "hasMore": true
                    },
                    "results": expectedResults.slice( 1, 10 )
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
                    },
                    "generateSimpleWithResults": function( results, page, maxRows ) {
                        return {
                            "next": results.len() > maxRows,
                            "pageNumber": page,
                            "limit": maxRows,
                            "data": results
                        };
                    }
                } );
                var expectedResults = [];
                for ( var i = 1; i <= 20; i++ ) {
                    expectedResults.append( { "id": i } );
                }
                var expectedQuery = queryNew( "id", "integer", expectedResults );
                builder.$(
                    "runQuery",
                    supportsNativeReturnType() ? builder.getUtils().queryToArrayOfStructs( expectedQuery ) : expectedQuery
                );

                var results = builder.from( "users" ).simplePaginate();

                expect( results ).toBe( {
                    "next": false,
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

    private boolean function supportsNativeReturnType() {
        return server.keyExists( "lucee" ) || listFirst( server.coldfusion.productversion ) >= 2021;
    }

}
