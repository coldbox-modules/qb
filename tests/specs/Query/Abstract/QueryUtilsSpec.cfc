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
        describe( "null type predicates", function() {
            it( "classifies null values without throwing", function() {
                expect( utils.isExpression( javacast( "null", "" ) ) ).toBeFalse();
                expect( utils.isNotExpression( javacast( "null", "" ) ) ).toBeTrue();
                expect( utils.isBuilder( javacast( "null", "" ) ) ).toBeFalse();
                expect( utils.isNotBuilder( javacast( "null", "" ) ) ).toBeTrue();
            } );
        } );

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
                it( "recognizes byte values as integers", function() {
                    expect( utils.inferSqlType( javacast( "byte", 7 ), variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "integers", function() {
                    expect( utils.inferSqlType( 100, variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "negative integers", function() {
                    expect( utils.inferSqlType( -100, variables.mockGrammar ) ).toBe( "INTEGER" );
                } );

                it( "uses integers through the signed 32-bit boundaries", function() {
                    expect( utils.inferSqlType( javacast( "long", "2147483647" ), variables.mockGrammar ) ).toBe(
                        "INTEGER"
                    );
                    expect( utils.inferSqlType( javacast( "long", "-2147483648" ), variables.mockGrammar ) ).toBe(
                        "INTEGER"
                    );
                } );

                it( "uses big integers outside the signed 32-bit boundaries", function() {
                    expect( utils.inferSqlType( javacast( "long", "2147483648" ), variables.mockGrammar ) ).toBe(
                        "BIGINT"
                    );
                    expect( utils.inferSqlType( javacast( "long", "-2147483649" ), variables.mockGrammar ) ).toBe(
                        "BIGINT"
                    );
                    expect( utils.inferSqlType( javacast( "long", "348060777867223040" ), variables.mockGrammar ) ).toBe( "BIGINT" );
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

            it( "recognizes Java date values as timestamps", function() {
                var javaDate = createObject( "java", "java.util.Date" ).init();

                expect( isDate( javaDate ) ).toBeTrue();
                expect( utils.inferSqlType( javaDate, variables.mockGrammar ) ).toBe( "TIMESTAMP" );
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

            it( "does not format null temporal query parameters", function() {
                var temporalTypes = [ "DATE", "TIME", "TIMESTAMP" ];
                temporalTypes.each( function( sqlType ) {
                    var queryParam = { "value": javacast( "null", "" ), "cfsqltype": sqlType, "null": true };
                    var binding = utils.extractBinding( queryParam, variables.mockGrammar );

                    expect( binding.null ).toBeTrue();
                    expect( binding.cfsqltype ).toBe( sqlType );
                    expect( utils.replaceBindings( "SELECT ?", [ binding ] ) ).toInclude( """null"":true" );
                } );
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

            describe( "unsafe numeric inference setting", function() {
                it( "defaults to VARCHAR for unsafe numeric combinations", function() {
                    var defaultUtils = new qb.models.Query.QueryUtils();
                    expect( defaultUtils.getThrowOnUnsafeNumericInference() ).toBeFalse();
                    expect(
                        defaultUtils.extractBinding(
                            {
                                value: [ { value: 1, cfsqltype: "BIGINT" }, { value: 1.5, cfsqltype: "DOUBLE" } ],
                                list: true
                            },
                            variables.mockGrammar
                        ).cfsqltype
                    ).toBe( "VARCHAR" );
                } );

                it( "throws a descriptive error for unsafe numeric list bindings when enabled", function() {
                    var strictUtils = new qb.models.Query.QueryUtils( throwOnUnsafeNumericInference = true );
                    expect( function() {
                        strictUtils.extractBinding(
                            {
                                value: [ { value: 1, cfsqltype: "BIGINT" }, { value: 1.5, cfsqltype: "DOUBLE" } ],
                                list: true
                            },
                            variables.mockGrammar
                        );
                    } ).toThrow( "QBUnsafeNumericInference" );
                    expect( function() {
                        strictUtils.inferSqlType(
                            [ { value: 1.5, cfsqltype: "cf_sql_float" }, { value: 0.1, sqltype: "cf_sql_decimal" } ],
                            variables.mockGrammar
                        );
                    } ).toThrow( "QBUnsafeNumericInference" );
                } );

                it( "still widens safe numeric combinations when enabled", function() {
                    var strictUtils = new qb.models.Query.QueryUtils( throwOnUnsafeNumericInference = true );
                    expect( strictUtils.inferSqlType( [ 1, javacast( "long", "3000000000" ) ], variables.mockGrammar ) ).toBe( "BIGINT" );
                    expect( strictUtils.inferSqlType( [ 1, 1.25 ], variables.mockGrammar ) ).toBe( "DECIMAL" );
                } );

                it( "keeps ordinary mixed text arrays as VARCHAR when enabled regardless of order", function() {
                    var strictUtils = new qb.models.Query.QueryUtils( throwOnUnsafeNumericInference = true );
                    expect(
                        strictUtils.inferSqlType(
                            [ { value: 1, cfsqltype: "BIGINT" }, { value: 1.5, cfsqltype: "DOUBLE" }, "text" ],
                            variables.mockGrammar
                        )
                    ).toBe( "VARCHAR" );
                    expect(
                        strictUtils.inferSqlType(
                            [ "text", { value: 1.5, cfsqltype: "DOUBLE" }, { value: 1, cfsqltype: "BIGINT" } ],
                            variables.mockGrammar
                        )
                    ).toBe( "VARCHAR" );
                } );

                it( "honors an explicit outer binding type when enabled", function() {
                    var strictUtils = new qb.models.Query.QueryUtils( throwOnUnsafeNumericInference = true );
                    var binding = strictUtils.extractBinding(
                        {
                            value: [ { value: 1, cfsqltype: "BIGINT" }, { value: 1.5, cfsqltype: "DOUBLE" } ],
                            list: true,
                            cfsqltype: "FLOAT"
                        },
                        variables.mockGrammar
                    );
                    expect( binding.cfsqltype ).toBe( "FLOAT" );
                } );

                it( "uses configured numeric types during widening", function() {
                    var configuredUtils = new qb.models.Query.QueryUtils( decimalSqlType = "cf_sql_numeric" );
                    expect( configuredUtils.inferSqlType( [ 1, 1.25 ], variables.mockGrammar ) ).toBe( "NUMERIC" );
                    configuredUtils.setBigIntegerSqlType( "cf_sql_double" );
                    configuredUtils.setThrowOnUnsafeNumericInference( true );
                    expect( function() {
                        configuredUtils.inferSqlType(
                            [ javacast( "long", "3000000000" ), 1.25 ],
                            variables.mockGrammar
                        );
                    } ).toThrow( "QBUnsafeNumericInference" );
                } );

                it( "preserves the greatest fractional scale in a promoted decimal list", function() {
                    var binding = variables.utils.extractBinding(
                        {
                            value: [
                                1,
                                javacast( "long", "3000000000" ),
                                1.125,
                                -2.5
                            ],
                            list: true
                        },
                        variables.mockGrammar
                    );
                    expect( binding.cfsqltype ).toBe( "DECIMAL" );
                    expect( binding.scale ).toBe( 3 );
                    expect( binding.value ).toBe( [
                        1,
                        javacast( "long", "3000000000" ),
                        1.125,
                        -2.5
                    ] );
                } );
            } );

            describe( "explicit numeric array widening", function() {
                var cases = [
                    { leftType: "TINYINT", rightType: "TINYINT", expectedType: "TINYINT" },
                    { leftType: "TINYINT", rightType: "SMALLINT", expectedType: "SMALLINT" },
                    { leftType: "TINYINT", rightType: "INTEGER", expectedType: "INTEGER" },
                    { leftType: "TINYINT", rightType: "BIGINT", expectedType: "BIGINT" },
                    { leftType: "SMALLINT", rightType: "SMALLINT", expectedType: "SMALLINT" },
                    { leftType: "SMALLINT", rightType: "INTEGER", expectedType: "INTEGER" },
                    { leftType: "SMALLINT", rightType: "BIGINT", expectedType: "BIGINT" },
                    { leftType: "INTEGER", rightType: "INTEGER", expectedType: "INTEGER" },
                    { leftType: "INTEGER", rightType: "BIGINT", expectedType: "BIGINT" },
                    { leftType: "BIGINT", rightType: "BIGINT", expectedType: "BIGINT" },
                    { leftType: "TINYINT", rightType: "DECIMAL", expectedType: "DECIMAL" },
                    { leftType: "TINYINT", rightType: "NUMERIC", expectedType: "NUMERIC" },
                    { leftType: "TINYINT", rightType: "REAL", expectedType: "REAL" },
                    { leftType: "TINYINT", rightType: "FLOAT", expectedType: "FLOAT" },
                    { leftType: "TINYINT", rightType: "DOUBLE", expectedType: "DOUBLE" },
                    { leftType: "SMALLINT", rightType: "DECIMAL", expectedType: "DECIMAL" },
                    { leftType: "SMALLINT", rightType: "NUMERIC", expectedType: "NUMERIC" },
                    { leftType: "SMALLINT", rightType: "REAL", expectedType: "REAL" },
                    { leftType: "SMALLINT", rightType: "FLOAT", expectedType: "FLOAT" },
                    { leftType: "SMALLINT", rightType: "DOUBLE", expectedType: "DOUBLE" },
                    { leftType: "INTEGER", rightType: "DECIMAL", expectedType: "DECIMAL" },
                    { leftType: "INTEGER", rightType: "NUMERIC", expectedType: "NUMERIC" },
                    { leftType: "INTEGER", rightType: "REAL", expectedType: "DOUBLE" },
                    { leftType: "INTEGER", rightType: "FLOAT", expectedType: "FLOAT" },
                    { leftType: "INTEGER", rightType: "DOUBLE", expectedType: "DOUBLE" },
                    { leftType: "BIGINT", rightType: "DECIMAL", expectedType: "DECIMAL" },
                    { leftType: "BIGINT", rightType: "NUMERIC", expectedType: "NUMERIC" },
                    { leftType: "BIGINT", rightType: "REAL", expectedType: "VARCHAR" },
                    { leftType: "BIGINT", rightType: "FLOAT", expectedType: "VARCHAR" },
                    { leftType: "BIGINT", rightType: "DOUBLE", expectedType: "VARCHAR" },
                    { leftType: "REAL", rightType: "FLOAT", expectedType: "FLOAT" },
                    { leftType: "REAL", rightType: "DOUBLE", expectedType: "DOUBLE" },
                    { leftType: "FLOAT", rightType: "DOUBLE", expectedType: "DOUBLE" },
                    { leftType: "DECIMAL", rightType: "FLOAT", expectedType: "VARCHAR" },
                    { leftType: "NUMERIC", rightType: "DOUBLE", expectedType: "VARCHAR" },
                    { leftType: "BIT", rightType: "TINYINT", expectedType: "TINYINT" },
                    { leftType: "MONEY4", rightType: "SMALLINT", expectedType: "MONEY4" },
                    { leftType: "MONEY4", rightType: "MONEY", expectedType: "MONEY" },
                    { leftType: "MONEY", rightType: "BIGINT", expectedType: "DECIMAL" }
                ];
                for ( var testCase in cases ) {
                    it(
                        title = "combines #testCase.leftType# and #testCase.rightType# as #testCase.expectedType#",
                        data = testCase,
                        body = function( data ) {
                            // Small values deliberately prove that declared types, not just values, determine promotion.
                            expectNumericArrayType(
                                [ { value: 1, cfsqltype: data.leftType }, { value: 1, sqltype: data.rightType } ],
                                data.expectedType
                            );
                            expectNumericArrayType(
                                [
                                    { value: 1, sqltype: "cf_sql_" & lCase( data.leftType ) },
                                    { value: 1, cfsqltype: "cf_sql_" & lCase( data.rightType ) }
                                ],
                                data.expectedType
                            );
                        }
                    );
                }

                it( "falls back to VARCHAR for explicit FLOAT mixed with inferred big integers and decimals", function() {
                    expectNumericArrayType(
                        [
                            1,
                            javacast( "long", "3000000000" ),
                            1.25,
                            { value: 2, cfsqltype: "FLOAT" }
                        ],
                        "VARCHAR"
                    );
                } );

                it( "widens INTEGER and REAL to DOUBLE to preserve integer precision", function() {
                    expectNumericArrayType(
                        [ { value: 16777217, cfsqltype: "INTEGER" }, { value: 1.5, cfsqltype: "REAL" } ],
                        "DOUBLE"
                    );
                } );

                it( "avoids rounding BIGINT values beyond the exact DOUBLE integer range", function() {
                    expectNumericArrayType(
                        [
                            { value: javacast( "long", "9007199254740993" ), cfsqltype: "BIGINT" },
                            { value: 1.5, cfsqltype: "DOUBLE" }
                        ],
                        "VARCHAR"
                    );
                } );

                it( "avoids rounding exact decimal fractions into FLOAT", function() {
                    expectNumericArrayType(
                        [ { value: 0.1, cfsqltype: "DECIMAL" }, { value: 1.5, cfsqltype: "FLOAT" } ],
                        "VARCHAR"
                    );
                } );

                it( "preserves a manually specified type on the outer list binding", function() {
                    var binding = variables.utils.extractBinding(
                        { value: [ 1, javacast( "long", "3000000000" ), 1.25 ], list: true, cfsqltype: "FLOAT" },
                        variables.mockGrammar
                    );
                    expect( binding.cfsqltype ).toBe( "FLOAT" );
                    expect( binding.sqltype ).toBe( "FLOAT" );
                } );
            } );

            describe( "numeric array widening", function() {
                it( "keeps byte short and int values within INTEGER", function() {
                    var values = [ javacast( "byte", -128 ), javacast( "short", 32767 ), javacast( "int", 2147483647 ) ];
                    expectNumericArrayType( values, "INTEGER" );
                } );

                it( "keeps both signed 32-bit boundaries within INTEGER", function() {
                    var values = [ javacast( "long", "-2147483648" ), 0, javacast( "long", "2147483647" ) ];
                    expectNumericArrayType( values, "INTEGER" );
                } );

                it( "widens the reported mixed integer list to BIGINT", function() {
                    var values = [ 1, javacast( "long", "3000000000" ) ];
                    expectNumericArrayType( values, "BIGINT" );
                } );

                it( "widens below the signed 32-bit minimum to BIGINT", function() {
                    var values = [ 1, javacast( "long", "-2147483649" ) ];
                    expectNumericArrayType( values, "BIGINT" );
                } );

                it( "widens above the signed 32-bit maximum to BIGINT", function() {
                    var values = [ 1, javacast( "long", "2147483648" ) ];
                    expectNumericArrayType( values, "BIGINT" );
                } );

                it( "covers both signed 64-bit boundaries with BIGINT", function() {
                    var values = [
                        javacast( "long", "-9223372036854775808" ),
                        0,
                        javacast( "long", "9223372036854775807" )
                    ];
                    expectNumericArrayType( values, "BIGINT" );
                } );

                it( "widens integers and decimal literals to DECIMAL", function() {
                    var values = [ -1, 0, 4.5 ];
                    expectNumericArrayType( values, "DECIMAL" );
                } );

                it( "widens integers and fractional floats to DECIMAL", function() {
                    var values = [ 1, javacast( "float", -1.25 ) ];
                    expectNumericArrayType( values, "DECIMAL" );
                } );

                it( "widens integers and fractional doubles to DECIMAL", function() {
                    var values = [ -1, javacast( "double", 1.125 ) ];
                    expectNumericArrayType( values, "DECIMAL" );
                } );

                it( "widens big integers and fractional floats to DECIMAL", function() {
                    var values = [ javacast( "long", "3000000000" ), javacast( "float", 1.25 ) ];
                    expectNumericArrayType( values, "DECIMAL" );
                } );

                it( "widens big integers and fractional doubles to DECIMAL", function() {
                    var values = [ javacast( "long", "-3000000000" ), javacast( "double", -1.125 ) ];
                    expectNumericArrayType( values, "DECIMAL" );
                } );

                it( "widens integers big integers floats and doubles to DECIMAL", function() {
                    var values = [
                        1,
                        javacast( "long", "3000000000" ),
                        javacast( "float", 1.25 ),
                        javacast( "double", -1.125 )
                    ];
                    expectNumericArrayType( values, "DECIMAL" );
                } );

                it( "widens untyped numeric parameter structs to BIGINT", function() {
                    var values = [ { value: 1 }, { value: javacast( "long", "3000000000" ) } ];
                    expectNumericArrayType( values, "BIGINT" );
                } );

                it( "widens normalized explicit numeric parameter types to DECIMAL", function() {
                    var values = [
                        { value: 1, cfsqltype: "cf_sql_integer" },
                        { value: javacast( "long", "3000000000" ), sqltype: "cf_sql_bigint" },
                        { value: 1.25, cfsqltype: "cf_sql_decimal" }
                    ];
                    expectNumericArrayType( values, "DECIMAL" );
                } );

                it( "ignores nulls while widening numeric members", function() {
                    var values = [ 1, javacast( "null", "" ), javacast( "long", "3000000000" ) ];
                    expectNumericArrayType( values, "BIGINT" );
                } );

                it( "retains VARCHAR when a widened numeric list also contains text", function() {
                    var values = [ 1, javacast( "long", "3000000000" ), "example" ];
                    expectNumericArrayType( values, "VARCHAR" );
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

                it( "widens INTEGER and BIGINT query parameter structs to BIGINT", function() {
                    expect(
                        utils.inferSqlType(
                            [ { value: 1, cfsqltype: "INTEGER" }, { value: 2, cfsqltype: "BIGINT" } ],
                            variables.mockGrammar
                        )
                    ).toBe( "BIGINT" );
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

        describe( "isSubQuery()", function() {
            it( "recognizes aliases separated by repeated whitespace", function() {
                expect( utils.isSubQuery( "(SELECT id FROM users)   AS   activeUsers" ) ).toBeTrue();
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

            it( "preserves PostgreSQL question mark operators", function() {
                var binding = utils.extractBinding( "name", variables.mockGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT * FROM records WHERE payload ? ?",
                        [ binding ],
                        true,
                        new qb.models.Grammars.PostgresGrammar()
                    )
                ).toBe( "SELECT * FROM records WHERE payload ? 'name'" );
            } );

            it( "uses the resolved grammar when replacing bindings", function() {
                var binding = utils.extractBinding( "name", variables.mockGrammar );
                var postgresGrammar = new qb.models.Grammars.PostgresGrammar();
                var autoDiscover = getMockBox()
                    .createMock( "qb.models.Grammars.AutoDiscover" )
                    .$( "autoDiscoverGrammar", postgresGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT * FROM records WHERE payload ? ?",
                        [ binding ],
                        true,
                        autoDiscover
                    )
                ).toBe( "SELECT * FROM records WHERE payload ? 'name'" );
            } );

            it( "preserves question marks in MySQL hash comments", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT * FROM records WHERE id = ? ## why?#chr( 10 )#",
                        [ binding ],
                        true,
                        new qb.models.Grammars.MySQLGrammar()
                    )
                ).toBe( "SELECT * FROM records WHERE id = 42 ## why?#chr( 10 )#" );
            } );

            it( "replaces question marks after MySQL double minus operators", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT 10--? AS result",
                        [ binding ],
                        true,
                        new qb.models.Grammars.MySQLGrammar()
                    )
                ).toBe( "SELECT 10--42 AS result" );
            } );

            it( "does not treat MySQL dollar-delimited identifiers as PostgreSQL dollar quotes", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT $tag$, ? FROM records",
                        [ binding ],
                        true,
                        new qb.models.Grammars.MySQLGrammar()
                    )
                ).toBe( "SELECT $tag$, 42 FROM records" );
            } );

            it( "requires a closing delimiter before treating generic SQL as dollar quoted", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect( utils.replaceBindings( "SELECT $tag$, ? FROM records", [ binding ], true ) ).toBe(
                    "SELECT $tag$, 42 FROM records"
                );
            } );

            it( "preserves question marks in SQL Server bracketed identifiers", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT [why?] FROM records WHERE id = ?",
                        [ binding ],
                        true,
                        new qb.models.Grammars.SqlServerGrammar()
                    )
                ).toBe( "SELECT [why?] FROM records WHERE id = 42" );
            } );

            it( "preserves question marks in SQLite bracketed identifiers", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT [why?] FROM records WHERE id = ?",
                        [ binding ],
                        true,
                        new qb.models.Grammars.SQLiteGrammar()
                    )
                ).toBe( "SELECT [why?] FROM records WHERE id = 42" );
            } );

            it( "preserves question marks in escaped string literals", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings( "SELECT 'isn''t ?' AS marker FROM users WHERE id = ?", [ binding ], true )
                ).toBe( "SELECT 'isn''t ?' AS marker FROM users WHERE id = 42" );
            } );

            it( "treats backslashes as ordinary characters in PostgreSQL string literals", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );
                var slash = chr( 92 );

                expect(
                    utils.replaceBindings(
                        "SELECT 'C:#slash#' AS path FROM users WHERE id = ?",
                        [ binding ],
                        true,
                        new qb.models.Grammars.PostgresGrammar()
                    )
                ).toBe( "SELECT 'C:#slash#' AS path FROM users WHERE id = 42" );
            } );

            it( "preserves question marks in Oracle alternative quoted literals", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );
                var oracleGrammar = new qb.models.Grammars.OracleGrammar( utils );

                expect(
                    utils.replaceBindings(
                        "SELECT q'[isn't ? -- /* a placeholder */]' AS marker FROM users WHERE id = ?",
                        [ binding ],
                        true,
                        oracleGrammar
                    )
                ).toBe( "SELECT q'[isn't ? -- /* a placeholder */]' AS marker FROM users WHERE id = 42" );
            } );

            it( "preserves question marks in nested PostgreSQL block comments", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect(
                    utils.replaceBindings(
                        "SELECT 1 /* outer ? /* inner ? */ still outer ? */ WHERE id = ?",
                        [ binding ],
                        true,
                        new qb.models.Grammars.PostgresGrammar()
                    )
                ).toBe( "SELECT 1 /* outer ? /* inner ? */ still outer ? */ WHERE id = 42" );
            } );

            it( "rejects bindings without matching placeholders", function() {
                var binding = utils.extractBinding( 42, variables.mockGrammar );

                expect( function() {
                    utils.replaceBindings( "SELECT 1", [ binding ], true );
                } ).toThrow( type = "BindingMismatch" );
            } );
        } );

        describe( "extractBinding()", function() {
            it( "does not mutate query parameter structs supplied by callers", function() {
                var queryParam = { "value": 42, "cfsqltype": "INTEGER" };
                var originalQueryParam = duplicate( queryParam );

                utils.extractBinding( queryParam, variables.mockGrammar );

                expect( queryParam ).toBe( originalQueryParam );
            } );

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

            it( "calculates scale for scientific notation", function() {
                var smallDecimal = createObject( "java", "java.math.BigDecimal" ).init( "1.23E-4" );
                var smallerDecimal = createObject( "java", "java.math.BigDecimal" ).init( "1.0E-7" );

                expect( utils.extractBinding( smallDecimal, variables.mockGrammar ).scale ).toBe( 6 );
                expect( utils.extractBinding( smallerDecimal, variables.mockGrammar ).scale ).toBe( 8 );
            } );

            it( "preserves significant zeroes in scientific notation scale", function() {
                var decimal = createObject( "java", "java.math.BigDecimal" ).init( "1.00E-7" );

                expect( utils.extractBinding( decimal, variables.mockGrammar ).scale ).toBe( 9 );
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

            it( "preserves null predicate types as strings", function() {
                var cloned = new qb.models.Query.QueryBuilder()
                    .from( "users" )
                    .whereNull( "deletedAt" )
                    .clone();

                expect( cloned.getWheres()[ 1 ].type ).toBe( "null" );
                expect( cloned.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""deletedAt"" IS NULL" );
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

        describe( "null-aware comparisons", function() {
            it( "compares null array elements without throwing", function() {
                var left = [ javacast( "null", "" ) ];
                var right = [ javacast( "null", "" ) ];

                expect( utils.arrayCompare( left, right ) ).toBeTrue();
                expect( utils.arrayCompare( left, [ "value" ] ) ).toBeFalse();
                expect( utils.arrayCompare( [ "value" ], right ) ).toBeFalse();
            } );

            it( "compares null struct values symmetrically when full null support is enabled", function() {
                var fullNull = createObject( "java", "java.lang.System" ).getEnv( "FULL_NULL" );
                if ( isNull( fullNull ) || !fullNull ) {
                    return;
                }

                expect(
                    utils.structCompare( { "value": javacast( "null", "" ) }, { "value": javacast( "null", "" ) } )
                ).toBeTrue();
                expect( utils.structCompare( { "value": javacast( "null", "" ) }, { "value": "present" } ) ).toBeFalse();
                expect( utils.structCompare( { "value": "present" }, { "value": javacast( "null", "" ) } ) ).toBeFalse();
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

            it( "distinguishes table aliases", function() {
                var first = new qb.models.Query.QueryBuilder().from( "users AS first_user" );
                var second = new qb.models.Query.QueryBuilder().from( "users AS second_user" );

                expect( first.isEqualTo( second ) ).toBeFalse();
            } );

            it( "distinguishes recursive common table expressions", function() {
                var recursive = new qb.models.Query.QueryBuilder().withRecursive( "numbers", function( q ) {
                    q.select( "id" ).from( "numbers" );
                } );
                var nonRecursive = new qb.models.Query.QueryBuilder().with( "numbers", function( q ) {
                    q.select( "id" ).from( "numbers" );
                } );

                expect( recursive.isEqualTo( nonRecursive ) ).toBeFalse();
            } );

            it( "compares raw expressions without throwing", function() {
                var first = new qb.models.Query.QueryBuilder().selectRaw( "? AS id", [ 1 ] );
                var equivalent = new qb.models.Query.QueryBuilder().selectRaw( "? AS id", [ 1 ] );
                var differentBinding = new qb.models.Query.QueryBuilder().selectRaw( "? AS id", [ 2 ] );
                var differentSql = new qb.models.Query.QueryBuilder().selectRaw( "? AS user_id", [ 1 ] );

                expect( first.isEqualTo( equivalent ) ).toBeTrue();
                expect( first.isEqualTo( differentBinding ) ).toBeFalse();
                expect( first.isEqualTo( differentSql ) ).toBeFalse();
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

    private void function expectNumericArrayType( required array values, required string expectedType ) {
        var reversedValues = [];
        for ( var i = arguments.values.len(); i >= 1; i-- ) {
            if ( !arrayIsDefined( arguments.values, i ) || isNull( arguments.values[ i ] ) ) {
                reversedValues.append( javacast( "null", "" ) );
            } else {
                reversedValues.append( arguments.values[ i ] );
            }
        }
        for ( var orderedValues in [ arguments.values, reversedValues ] ) {
            expect( variables.utils.inferSqlType( orderedValues, variables.mockGrammar ) ).toBe(
                arguments.expectedType
            );
            var binding = variables.utils.extractBinding( { value: orderedValues, list: true }, variables.mockGrammar );
            expect( binding.cfsqltype ).toBe( arguments.expectedType );
            expect( binding.sqltype ).toBe( arguments.expectedType );
            expect( binding.list ).toBeTrue();
        }
    }

}
