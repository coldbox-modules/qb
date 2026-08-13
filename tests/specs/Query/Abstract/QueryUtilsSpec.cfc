component extends="testbox.system.BaseSpec" {

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
            it( "maintains the passed in cfsqltype if provided", () => {
                var binding = utils.extractBinding( { "value": 1, "cfsqltype": "BIT" }, variables.mockGrammar );
                expect( binding.cfsqltype ).toBe( "BIT" );
                expect( binding.sqltype ).toBe( "BIT" );
            } );

            it( "maintains the passed in sqltype if provided", () => {
                var binding = utils.extractBinding( { "value": 1, "sqltype": "BIT" }, variables.mockGrammar );
                expect( binding.cfsqltype ).toBe( "BIT" );
                expect( binding.sqltype ).toBe( "BIT" );
            } );

            it( "strings", function() {
                expect( utils.inferSqlType( "a string", variables.mockGrammar ) ).toBe( "VARCHAR" );
            } );

            describe( "numbers", function() {
                it( "integers", function() {
                    expect( utils.inferSqlType( 100, variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "negative integers", function() {
                    expect( utils.inferSqlType( -100, variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "decimals", function() {
                    expect( utils.inferSqlType( 4.50, variables.mockGrammar ) ).toBe( "DECIMAL" );
                } );

                it( "really long decimals", function() {
                    expect( utils.inferSqlType( 19482.279999997998, variables.mockGrammar ) ).toBe( "DECIMAL" );
                } );
            } );

            it( "dates", function() {
                expect( utils.inferSqlType( now(), variables.mockGrammar ) ).toBe( "TIMESTAMP" );
            } );

            it( "empty strings as null", () => {
                var bindingA = utils.extractBinding( "", variables.mockGrammar );
                expect( bindingA.null ).toBeFalse();
                variables.utils.setConvertEmptyStringsToNull( true );
                var bindingB = utils.extractBinding( "", variables.mockGrammar );
                expect( bindingB.null ).toBeTrue();
            } );

            it( "null", function() {
                expect( utils.inferSqlType( javacast( "null", "" ), variables.mockGrammar ) ).toBe( "VARCHAR" );
                expect( utils.extractBinding( javacast( "null", "" ), variables.mockGrammar ) ).toBe( {
                    "null": true,
                    "cfsqltype": "VARCHAR",
                    "sqltype": "VARCHAR",
                    "value": ""
                } );
                makePublic( utils, "checkIsActuallyNumeric", "publicCheckIsActuallyNumeric" );
                expect( utils.publicCheckIsActuallyNumeric( javacast( "null", "" ) ) ).toBe( false );
                makePublic( utils, "isFloatingPoint", "publicIsFloatingPoint" );
                expect(
                    utils.publicIsFloatingPoint( { "value": javacast( "null", "" ), "cfsqltype": "DECIMAL", "null": true } )
                ).toBe( false );
                makePublic( utils, "checkIsActuallyDate", "publicCheckIsActuallyDate" );
                expect( utils.publicCheckIsActuallyDate( javacast( "null", "" ) ) ).toBe( false );
                makePublic( utils, "calculateNumberOfDecimalDigits", "publicCalculateNumberOfDecimalDigits" );
                expect(
                    utils.publicCalculateNumberOfDecimalDigits( { "value": javacast( "null", "" ), "cfsqltype": "DECIMAL", "null": true } )
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
                        expect( utils.inferSqlType( true, variables.mockGrammar ) ).toBe( "TINYINT" );
                        expect( utils.inferSqlType( "true", variables.mockGrammar ) ).toBe( "VARCHAR" );
                        expect( utils.inferSqlType( false, variables.mockGrammar ) ).toBe( "TINYINT" );
                        expect( utils.inferSqlType( "false", variables.mockGrammar ) ).toBe( "VARCHAR" );

                        expect( utils.extractBinding( true, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "TINYINT",
                            "sqltype": "TINYINT",
                            "value": 1
                        } );
                        expect( utils.extractBinding( "true", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "VARCHAR",
                            "sqltype": "VARCHAR",
                            "value": "true"
                        } );
                        expect( utils.extractBinding( false, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "TINYINT",
                            "sqltype": "TINYINT",
                            "value": 0
                        } );
                        expect( utils.extractBinding( "false", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "VARCHAR",
                            "sqltype": "VARCHAR",
                            "value": "false"
                        } );
                    } );

                    it( "with boolean support in the grammar", () => {
                        variables.mockGrammar.$( "getBooleanSqlType", "OTHER" );
                        variables.mockGrammar
                            .$( "convertToBooleanType" )
                            .$callback( ( any value ) => {
                                return {
                                    "value": isNull( value ) ? javacast( "null", "" ) : !!value,
                                    "cfsqltype": "OTHER",
                                    "sqltype": "OTHER"
                                };
                            } );

                        expect( utils.extractBinding( true, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "OTHER",
                            "sqltype": "OTHER",
                            "value": true
                        } );
                        expect( utils.extractBinding( "true", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "VARCHAR",
                            "sqltype": "VARCHAR",
                            "value": "true"
                        } );
                        expect( utils.extractBinding( false, variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "OTHER",
                            "sqltype": "OTHER",
                            "value": false
                        } );
                        expect( utils.extractBinding( "false", variables.mockGrammar ) ).toBe( {
                            "list": false,
                            "null": false,
                            "cfsqltype": "VARCHAR",
                            "sqltype": "VARCHAR",
                            "value": "false"
                        } );
                    } );
                } );
            } );

            describe( "it infers the sql type from the members of an array", function() {
                it( "if all the members of the array are the same", function() {
                    expect( utils.inferSqlType( [ 1, 2 ], variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "infers matching negative and positive integers as integers", function() {
                    expect( utils.inferSqlType( [ -1, 2 ], variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "ignores null members when inferring an array type", function() {
                    expect( utils.inferSqlType( [ 1, javacast( "null", "" ) ], variables.mockGrammar ) ).toBe( "INTEGER" );
                    expect(
                        utils.inferSqlType(
                            [
                                utils.extractBinding( 1, variables.mockGrammar ),
                                utils.extractBinding( javacast( "null", "" ), variables.mockGrammar )
                            ],
                            variables.mockGrammar
                        )
                    ).toBe( "INTEGER" );
                } );

                it( "defaults all-null arrays to VARCHAR", function() {
                    expect(
                        utils.inferSqlType( [ javacast( "null", "" ), javacast( "null", "" ) ], variables.mockGrammar )
                    ).toBe( "VARCHAR" );
                } );

                it( "uses matching cfsqltypes from query parameter structs", function() {
                    expect(
                        utils.inferSqlType(
                            [ { value: 1, cfsqltype: "BIGINT" }, { value: 2, cfsqltype: "BIGINT" } ],
                            variables.mockGrammar
                        )
                    ).toBe( "BIGINT" );
                } );

                it( "uses matching sqltypes from query parameter structs", function() {
                    expect(
                        utils.inferSqlType(
                            [ { value: 1, sqltype: "BIGINT" }, { value: 2, sqltype: "BIGINT" } ],
                            variables.mockGrammar
                        )
                    ).toBe( "BIGINT" );
                } );

                it( "infers values from untyped query parameter structs", function() {
                    expect( utils.inferSqlType( [ { value: 1 }, { value: 2 } ], variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "defaults to VARCHAR when query parameter struct types differ", function() {
                    expect(
                        utils.inferSqlType(
                            [ { value: 1, cfsqltype: "INTEGER" }, { value: 2, cfsqltype: "BIGINT" } ],
                            variables.mockGrammar
                        )
                    ).toBe( "VARCHAR" );
                } );

                it( "but defaults to VARCHAR if they are different", function() {
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
                    ).toBe( "VARCHAR" );
                } );
            } );
        } );

        describe( "replaceBindings()", function() {
            it( "only replaces parameter placeholders in executable SQL", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );
                var sql = "SELECT '?' AS single_quoted, ""why?"" AS double_quoted, #chr( 96 )#why?#chr( 96 )# AS backticked, $$?$$ AS dollar_quoted -- ?#chr( 10 )#FROM users WHERE id = ? /* ? */";

                expect( utils.replaceBindings( sql, [ binding ], true ) ).toBe(
                    "SELECT '?' AS single_quoted, ""why?"" AS double_quoted, #chr( 96 )#why?#chr( 96 )# AS backticked, $$?$$ AS dollar_quoted -- ?#chr( 10 )#FROM users WHERE id = 42 /* ? */"
                );
            } );

            it( "replaces placeholders inside PostgreSQL array constructors", function() {
                var binding = utils.extractBinding( "name", variables.mockGrammar );

                expect( utils.replaceBindings( "SELECT ARRAY[?]", [ binding ], true ) ).toBe( "SELECT ARRAY['name']" );
            } );

            it( "preserves question marks in escaped string literals", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings( "SELECT 'isn''t ?' AS marker FROM users WHERE id = ?", [ binding ], true )
                ).toBe( "SELECT 'isn''t ?' AS marker FROM users WHERE id = 42" );
            } );
        } );

        describe( "extractBinding()", function() {
            it( "includes sensible defaults", function() {
                var datetime = parseDateTime( "05/10/2016" );
                var binding = utils.extractBinding( datetime, variables.mockGrammar );

                expect( binding ).toBeStruct();
                var formattedExpectedDate = isBoxLang() ? dateTimeFormat( datetime, "yyyy-MM-dd'T'HH:mm:ss.SSSXXX" ) : dateTimeFormat(
                    datetime,
                    "yyyy-mm-dd'T'HH:nn:ss.lllXXX"
                );
                expect( binding.value ).toBe( formattedExpectedDate );
                expect( binding.cfsqltype ).toBe( "TIMESTAMP" );
                expect( binding.sqltype ).toBe( "TIMESTAMP" );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );

            it( "automatically sets a scale if needed", function() {
                var binding = utils.extractBinding(
                    { "value": 3.14159, "cfsqltype": "DECIMAL" },
                    variables.mockGrammar
                );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( 3.14159 );
                expect( binding.cfsqltype ).toBe( "DECIMAL" );
                expect( binding.sqltype ).toBe( "DECIMAL" );
                expect( binding ).toHaveKey( "scale" );
                expect( binding.scale ).toBe( 5 );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );

            it( "does not set a scale for integers", function() {
                var binding = utils.extractBinding(
                    { "value": 3.14159, "cfsqltype": "INTEGER" },
                    variables.mockGrammar
                );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( 3.14159 );
                expect( binding.cfsqltype ).toBe( "INTEGER" );
                expect( binding.sqltype ).toBe( "INTEGER" );
                expect( binding ).notToHaveKey( "scale" );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );

            it( "uses a passed in scale if provided", function() {
                var binding = utils.extractBinding(
                    { "value": 3.14159, "cfsqltype": "DECIMAL", "scale": 2 },
                    variables.mockGrammar
                );

                expect( binding ).toBeStruct();
                expect( binding.value ).toBe( 3.14159 );
                expect( binding.cfsqltype ).toBe( "DECIMAL" );
                expect( binding.sqltype ).toBe( "DECIMAL" );
                expect( binding ).toHaveKey( "scale" );
                expect( binding.scale ).toBe( 2 );
                expect( binding.list ).toBe( false );
                expect( binding.null ).toBe( false );
            } );

            it( "checks that structs that are passed look like query param structs", () => {
                expect( () => {
                    var binding = utils.extractBinding(
                        {
                            "foo": "bar",
                            "value": "something",
                            "null": true,
                            "enabled": true
                        },
                        variables.mockGrammar
                    );
                } ).toThrow(
                    type = "QBInvalidQueryParam",
                    regex = "Invalid keys detected in your query param struct: \[enabled, foo\]\. Usually this happens when you meant to serialize the struct to JSON first\."
                );
            } );

            it( "can skip query param struct key validation when configured", () => {
                var relaxedUtils = new qb.models.Query.QueryUtils( validateQueryParamStructKeys = false );

                var binding = relaxedUtils.extractBinding(
                    {
                        "foo": "bar",
                        "value": "something",
                        "null": true,
                        "enabled": true
                    },
                    variables.mockGrammar
                );

                expect( binding.foo ).toBe( "bar" );
                expect( binding.enabled ).toBeTrue();
                expect( binding.null ).toBeTrue();
                expect( binding.list ).toBeFalse();
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
                expect( queryTwo.getColumns().map( ( c ) => c.value ) ).toBe( [ "one", "two" ] );
                expect( queryTwo.getWheres() ).toBe( [
                    {
                        column: { "type": "simple", "value": "bar" },
                        combinator: "and",
                        operator: "=",
                        value: "baz",
                        type: "basic"
                    }
                ] );
                expect( queryTwo.getRawBindings().where ).toBe( [
                    {
                        value: "baz",
                        cfsqltype: "varchar",
                        sqltype: "varchar",
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

            it( "does not share mutable query clauses with the original", function() {
                var original = new qb.models.Query.QueryBuilder()
                    .from( "users AS u" )
                    .select( "u.id" )
                    .where( "u.active", 1 )
                    .where( function( q ) {
                        q.where( "u.status", "active" );
                    } )
                    .join( "profiles AS p", "p.userId", "u.id" )
                    .groupBy( "u.id" )
                    .orderBy( "u.name" );
                var originalSql = original.toSQL();

                original.clone().withAlias( "member" );

                expect( original.toSQL() ).toBe( originalSql );
            } );

            it( "preserves all query state in a clone", function() {
                var original = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() )
                    .from( "users" )
                    .forRaw( "JSON PATH" )
                    .noLock()
                    .addUpdate( { "active": 1 } );
                var cloned = original.clone();

                expect( cloned.toSQL() ).toBe( original.toSQL() );
                expect( cloned.getUpdates() ).toBe( original.getUpdates() );
            } );
        } );

        describe( "reset()", function() {
            it( "clears a SQL Server FOR clause", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() )
                    .from( "users" )
                    .forRaw( "JSON PATH" )
                    .reset()
                    .from( "accounts" );

                expect( builder.toSQL() ).toBe( "SELECT * FROM [accounts]" );
            } );
        } );

        describe( "isEqualTo()", function() {
            it( "compares equivalent common table expressions", function() {
                var first = new qb.models.Query.QueryBuilder().with( "active_users", function( q ) {
                    q.from( "users" ).where( "active", 1 );
                } );
                var second = new qb.models.Query.QueryBuilder().with( "active_users", function( q ) {
                    q.from( "users" ).where( "active", 1 );
                } );

                expect( first.isEqualTo( second ) ).toBeTrue();
            } );
        } );

        describe( "aggregate state", function() {
            it( "does not mutate a union query while compiling an aggregate", function() {
                var builder = new qb.models.Query.QueryBuilder()
                    .select( "name" )
                    .from( "users" )
                    .where( "id", 1 )
                    .union( function( q ) {
                        q.select( "name" )
                            .from( "users" )
                            .where( "id", 2 );
                    } );
                var originalSql = builder.toSQL();

                builder.count( toSQL = true );

                expect( builder.toSQL() ).toBe( originalSql );
            } );
        } );
    }

}
