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
                expect( utils.inferSqlType( "a string", variables.mockGrammar ) ).toBe( "CF_SQL_VARCHAR" );
            } );

            describe( "numbers", function() {
                it( "integers", function() {
                    expect( utils.inferSqlType( 100, variables.mockGrammar ) ).toBe( "CF_SQL_INTEGER" );
                    variables.utils.setAutoDeriveNumericType( false );
                    expect( utils.inferSqlType( 100, variables.mockGrammar ) ).toBe( "CF_SQL_NUMERIC" );
                    variables.utils.setAutoDeriveNumericType( true );
                } );

                it( "decimals", function() {
                    expect( utils.inferSqlType( 4.50, variables.mockGrammar ) ).toBe( "CF_SQL_DECIMAL" );
                    variables.utils.setAutoDeriveNumericType( false );
                    expect( utils.inferSqlType( 4.50, variables.mockGrammar ) ).toBe( "CF_SQL_NUMERIC" );
                    variables.utils.setAutoDeriveNumericType( true );
                } );

                it( "really long decimals", function() {
                    variables.utils.setAutoDeriveNumericType( true );
                    expect( utils.inferSqlType( 19482.279999997998, variables.mockGrammar ) ).toBe( "CF_SQL_DECIMAL" );
                } );
            } );

            it( "dates", function() {
                expect( utils.inferSqlType( now(), variables.mockGrammar ) ).toBe( "CF_SQL_TIMESTAMP" );
                variables.utils.setStrictDateDetection( true );
                // expect( utils.inferSqlType( now(), variables.mockGrammar ) ).toBe( "CF_SQL_TIMESTAMP" );
                // expect( utils.inferSqlType( "06 12345" ), variables.mockGrammar ).toBe( "CF_SQL_VARCHAR" );
                variables.utils.setStrictDateDetection( false );
            } );

            it( "null", function() {
                expect( utils.inferSqlType( javacast( "null", "" ), variables.mockGrammar ) ).toBe( "CF_SQL_VARCHAR" );
                expect( utils.extractBinding( javacast( "null", "" ), variables.mockGrammar ) ).toBe( { "null": true, "cfsqltype": "CF_SQL_VARCHAR", "value": "" } );
                makePublic( utils, "checkIsActuallyNumeric", "publicCheckIsActuallyNumeric" );
                expect( utils.publicCheckIsActuallyNumeric( javacast( "null", "" ) ) ).toBe( false );
                makePublic( utils, "isFloatingPoint", "publicIsFloatingPoint" );
                expect(
                    utils.publicIsFloatingPoint( { "value": javacast( "null", "" ), "cfsqltype": "CF_SQL_DECIMAL", "null": true } )
                ).toBe( false );
                makePublic( utils, "checkIsActuallyDate", "publicCheckIsActuallyDate" );
                expect( utils.publicCheckIsActuallyDate( javacast( "null", "" ) ) ).toBe( false );
                makePublic( utils, "calculateNumberOfDecimalDigits", "publicCalculateNumberOfDecimalDigits" );
                expect(
                    utils.publicCalculateNumberOfDecimalDigits( { "value": javacast( "null", "" ), "cfsqltype": "CF_SQL_DECIMAL", "null": true } )
                ).toBe( 0 );
            } );

            describe( "boolean", () => {
                it( "infers boolean types correctly", () => {
                    makePublic( utils, "checkIsActuallyBoolean", "publicCheckIsActuallyBoolean" );
                    expect( utils.publicCheckIsActuallyBoolean( true ) ).toBeTrue();
                    expect( utils.publicCheckIsActuallyBoolean( "true" ) ).toBeFalse();
                    expect( utils.publicCheckIsActuallyBoolean( false ) ).toBeTrue();
                    expect( utils.publicCheckIsActuallyBoolean( "false" ) ).toBeFalse();
                } );

                describe( "extracting boolean params", () => {
                    afterEach( () => variables.mockGrammar.$reset() );

                    it( "without boolean support in the grammar", () => {
                        expect( utils.inferSqlType( true, variables.mockGrammar ) ).toBe( "CF_SQL_TINYINT" );
                        expect( utils.inferSqlType( "true", variables.mockGrammar ) ).toBe( "CF_SQL_VARCHAR" );
                        expect( utils.inferSqlType( false, variables.mockGrammar ) ).toBe( "CF_SQL_TINYINT" );
                        expect( utils.inferSqlType( "false", variables.mockGrammar ) ).toBe( "CF_SQL_VARCHAR" );

                        expect( utils.extractBinding( true, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_TINYINT",
                            "value": 1
                        } );
                        expect( utils.extractBinding( "true", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_VARCHAR",
                            "value": "true"
                        } );
                        expect( utils.extractBinding( false, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_TINYINT",
                            "value": 0
                        } );
                        expect( utils.extractBinding( "false", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_VARCHAR",
                            "value": "false"
                        } );
                    } );

                    it( "with boolean support in the grammar", () => {
                        variables.mockGrammar.$( "getBooleanSqlType", "CF_SQL_OTHER" );
                        variables.mockGrammar
                            .$( "convertToBooleanType" )
                            .$callback( ( any value ) => {
                                return {
                                    "value": isNull( value ) ? javacast( "null", "" ) : !!value,
                                    "cfsqltype": "CF_SQL_OTHER"
                                };
                            } );

                        expect( utils.extractBinding( true, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_OTHER",
                            "value": true
                        } );
                        expect( utils.extractBinding( "true", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_VARCHAR",
                            "value": "true"
                        } );
                        expect( utils.extractBinding( false, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_OTHER",
                            "value": false
                        } );
                        expect( utils.extractBinding( "false", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "CF_SQL_VARCHAR",
                            "value": "false"
                        } );
                    } );
                } );
            } );

            describe( "it infers the sql type from the members of an array", function() {
                it( "if all the members of the array are the same", function() {
                    expect( utils.inferSqlType( [ 1, 2 ], variables.mockGrammar ) ).toBe( "CF_SQL_INTEGER" );
                } );

                it( "but defaults to CF_SQL_VARCHAR if they are different", function() {
                    expect(
                        utils.inferSqlType(
                            [
                                1,
                                2,
                                3,
                                dateFormat( "05/01/2016", "MM/DD/YYYY" )
                            ],
                            variables.mockGrammar
                        )
                    ).toBe( "CF_SQL_VARCHAR" );
                } );
            } );
        } );

        describe( "extractBinding()", function() {
            it( "includes sensible defaults", function() {
                var datetime = parseDateTime( "05/10/2016" );
                var binding = utils.extractBinding( datetime, variables.mockGrammar );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( dateTimeFormat( datetime, "yyyy-mm-dd'T'HH:nn:ss.SSSXXX" ) );
                expect( binding.cfsqltype ).toBe( "CF_SQL_TIMESTAMP" );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );

            it( "automatically sets a scale if needed", function() {
                var binding = utils.extractBinding(
                    { "value": 3.14159, "cfsqltype": "CF_SQL_DECIMAL" },
                    variables.mockGrammar
                );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( 3.14159 );
                expect( binding.cfsqltype ).toBe( "CF_SQL_DECIMAL" );
                expect( binding ).toHaveKey( "scale" );
                expect( binding.scale ).toBe( 5 );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );

            it( "does not set a scale for integers", function() {
                var binding = utils.extractBinding(
                    { "value": 3.14159, "cfsqltype": "CF_SQL_INTEGER" },
                    variables.mockGrammar
                );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( 3.14159 );
                expect( binding.cfsqltype ).toBe( "CF_SQL_INTEGER" );
                expect( binding ).notToHaveKey( "scale" );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );

            it( "does not set a scale when autoSetScale is set to false", function() {
                try {
                    utils.setAutoAddScale( false );
                    var binding = utils.extractBinding(
                        { "value": 3.14159, "cfsqltype": "CF_SQL_DECIMAL" },
                        variables.mockGrammar
                    );

                    expect( binding ).toBeStruct();
                    expect( binding.value ).toBe( 3.14159 );
                    expect( binding.cfsqltype ).toBe( "CF_SQL_DECIMAL" );
                    expect( binding ).notToHaveKey( "scale" );
                    expect( binding.list ).toBe( false );
                    expect( binding.null ).toBe( false );
                } finally {
                    utils.setAutoAddScale( true );
                }
            } );

            it( "uses a passed in scale if provided", function() {
                var binding = utils.extractBinding(
                    { "value": 3.14159, "cfsqltype": "CF_SQL_DECIMAL", "scale": 2 },
                    variables.mockGrammar
                );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( 3.14159 );
                expect( binding.cfsqltype ).toBe( "CF_SQL_DECIMAL" );
                expect( binding ).toHaveKey( "scale" );
                expect( binding.scale ).toBe( 2 );
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
                expect( queryTwo.getTableName() ).toBe( "foo" );
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
                expect( queryOne.getTableName() ).toBe( "foo" );
            } );

            it( "has the exact same sql as the original query", function() {
                var queryOne = new qb.models.Query.QueryBuilder();
                queryOne
                    .from( "foo" )
                    .select( [ "one", "two" ] )
                    .where( "bar", "baz" )
                    .join( "qux", "qux.fooId", "=", "foo.id" )
                    .groupBy( [ "foo.one", "foo.two", "foo.bar" ] )
                    .having( "foo.one", ">", 1 )
                    .withAlias( "f" )
                    .orderByDesc( "qux.blah" );
                var queryTwo = queryOne.clone();
                expect( queryTwo.toSql( showBindings = "inline" ) ).toBe( queryOne.toSql( showBindings = "inline" ) );
            } );
        } );
    }

}
