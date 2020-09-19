component displayname="QueryUtilsSpec" extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.utils = new qb.models.Query.QueryUtils();
        variables.mockGrammar = createMock( "qb.models.Grammars.BaseGrammar" );
        variables.mockBuilder = new qb.models.Query.QueryBuilder(
            grammar = variables.mockGrammar,
            utils = variables.utils
        );
    }

    function run() {
        describe( "inferSqlType()", function() {
            it( "strings", function() {
                expect( utils.inferSqlType( "a string" ) ).toBe( "CF_SQL_VARCHAR" );
            } );

            it( "numbers", function() {
                if ( isACF2016() ) {
                    expect( utils.inferSqlType( 100 ) ).toBe( "CF_SQL_VARCHAR" );
                } else {
                    expect( utils.inferSqlType( 100 ) ).toBe( "CF_SQL_NUMERIC" );
                }
            } );

            it( "dates", function() {
                variables.mockBuilder.$("getStrictDateDetection").$results(false,false,true,true);
                expect( utils.inferSqlType( now() ) ).toBe( "CF_SQL_TIMESTAMP" );
                expect( utils.inferSqlType( "06 12345" ) ).toBe( "CF_SQL_TIMESTAMP" );
                //last two with strict dateDetection
                expect( utils.inferSqlType( now() ) ).toBe( "CF_SQL_TIMESTAMP" );
                expect( utils.inferSqlType( "06 12345" ) ).toBe( "CF_SQL_VARCHAR" );
            } );

            describe( "it infers the sql type from the members of an array", function() {
                it( "if all the members of the array are the same", function() {
                    if ( isACF2016() ) {
                        expect( utils.inferSqlType( [ 1, 2 ] ) ).toBe( "CF_SQL_VARCHAR" );
                    } else {
                        expect( utils.inferSqlType( [ 1, 2 ] ) ).toBe( "CF_SQL_NUMERIC" );
                    }
                } );

                it( "but defaults to CF_SQL_VARCHAR if they are different", function() {
                    expect(
                        utils.inferSqlType( [
                            1,
                            2,
                            3,
                            dateFormat( "05/01/2016", "MM/DD/YYYY" )
                        ] )
                    ).toBe( "CF_SQL_VARCHAR" );
                } );
            } );
        } );

        describe( "extractBinding()", function() {
            it( "includes sensible defaults", function() {
                var binding = utils.extractBinding( "05/10/2016" );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( "05/10/2016" );
                expect( binding.cfsqltype ).toBe( "CF_SQL_TIMESTAMP" );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );
        } );

        describe( "queryToArrayOfStructs()", function() {
            it( "converts a query to an array of structs", function() {
                var data = [
                    { id: 1, name: "foo", age: 24 },
                    { id: 2, name: "bar", age: 32 },
                    { id: 3, name: "baz", age: 41 }
                ];
                var q = queryNew( "id,name,age", "integer,varchar,integer", data );
                expect( q ).toBeQuery();
                expect( q.recordCount ).toBe( 3 );

                var result = utils.queryToArrayOfStructs( q );

                expect( result ).toBeArray();
                expect( result ).toHaveLength( 3 );
                expect( result ).toBe( data );
            } );
        } );

        describe( "queryRemoveColumns()", function() {
            it( "returns the query with specified columns removed", function() {
                var data = [
                    { id: 1, name: "foo", age: 24 },
                    { id: 2, name: "bar", age: 32 },
                    { id: 3, name: "baz", age: 41 }
                ];
                var q = queryNew( "id,name,age", "integer,varchar,integer", data );
                var result = utils.queryRemoveColumns( q, "age,name" );

                expect( result ).toBeQuery();
                expect( result.recordCount ).toBe( 3 );
                expect( result.columnList ).toBe( "id" );
            } );

            it( "returns the query with specified columns removed when no rows exist in query", function() {
                var data = [];
                var q = queryNew( "id,name,age", "integer,varchar,integer", data );
                var result = utils.queryRemoveColumns( q, "age,name" );

                expect( result ).toBeQuery();
                expect( result.recordCount ).toBe( 0 );
                expect( result.columnList ).toBe( "id" );
            } );
        } );

        describe( "clone()", function() {
            it( "clones the query preserving the grammar and avoiding duplicate()", function() {
                var queryOne = new qb.models.Query.QueryBuilder();
                queryOne
                    .from( "foo" )
                    .select( [ "one", "two" ] )
                    .where( "bar", "baz" );
                var queryTwo = queryOne.clone();
                expect( queryTwo.getFrom() ).toBe( "foo" );
                expect( queryTwo.getColumns() ).toBe( [ "one", "two" ] );
                expect( queryTwo.getWheres() ).toBe( [
                    {
                        column: "bar",
                        combinator: "and",
                        operator: "=",
                        value: "baz",
                        type: "basic"
                    }
                ] );
                expect( queryTwo.getRawBindings().where ).toBe( [
                    {
                        value: "baz",
                        cfsqltype: "cf_sql_varchar",
                        null: false,
                        list: false
                    }
                ] );
                queryTwo.from( "another" );
                expect( queryOne.getFrom() ).toBe( "foo" );
            } );
        } );
    }

    private boolean function isACF2016() {
        return server.keyExists( "coldfusion" ) &&
        !server.keyExists( "lucee" ) &&
        left( server.coldfusion.productversion, 4 ) == "2016";
    }

}
