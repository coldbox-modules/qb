component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "performance optimization regressions", function() {
            it( "preserves scalar binding type inference and decimal scale", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.BaseGrammar( utils );

                expect( utils.extractBinding( "42", grammar ).cfsqltype ).toBe( "VARCHAR" );
                expect( utils.extractBinding( 42, grammar ).cfsqltype ).toBe( "INTEGER" );
                expect( utils.extractBinding( true, grammar ).cfsqltype ).toBe( "TINYINT" );
                expect(
                    utils.extractBinding(
                        {
                            value: createObject( "java", "java.math.BigDecimal" ).init( "3.1400" ),
                            cfsqltype: "cf_sql_decimal"
                        },
                        grammar
                    ).scale
                ).toBe( 4 );
            } );

            it( "copies and validates query parameter keys in one pass", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.BaseGrammar( utils );
                var queryParam = {
                    value: 42,
                    cfsqltype: "INTEGER",
                    maxlength: 10,
                    scale: 0,
                    null: false
                };

                var binding = utils.extractBinding( queryParam, grammar );

                expect( binding ).toBe( {
                    value: 42,
                    cfsqltype: "INTEGER",
                    sqltype: "INTEGER",
                    maxlength: 10,
                    scale: 0,
                    list: false,
                    null: false
                } );
                expect( queryParam ).notToHaveKey( "sqltype" );
                expect( function() {
                    utils.extractBinding( { value: 42, zebra: true, alpha: true }, grammar );
                } ).toThrow(
                    type = "QBInvalidQueryParam",
                    regex = "Invalid keys detected in your query param struct: \[alpha, zebra\]"
                );
            } );

            it( "preserves the scalar WHERE fast path representation", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder.from( "users" ).where( "users.id", "=", 42 );

                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""id"" = ?" );
                expect( builder.getWheres() ).toBe( [
                    {
                        column: { type: "simple", value: "users.id" },
                        operator: "=",
                        value: 42,
                        combinator: "and",
                        type: "basic"
                    }
                ] );
                expect( builder.getBindings() ).toBe( [
                    {
                        value: 42,
                        cfsqltype: "INTEGER",
                        sqltype: "INTEGER",
                        list: false,
                        null: false
                    }
                ] );
            } );

            it( "serializes and infers bulk values without retaining per-value bindings", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );
                var values = [];
                arrayResize( values, 3 );
                values[ 1 ] = { value: 1, cfsqltype: "cf_sql_bigint" };
                values[ 3 ] = { value: 3, sqltype: "BIGINT" };

                builder.from( "users" ).whereInBulk( "id", values );

                expect( builder.getWheres()[ 1 ].sqlType ).toBe( "BIGINT" );
                expect( deserializeJSON( builder.getBindings().last().value ) ).toBe( [ 1, javacast( "null", "" ), 3 ] );
                expect( builder.getBindings().len() ).toBe( 1 );
            } );

            it( "preserves sparse, scalar, expression, and query parameter WHERE IN values", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );
                var values = [];
                arrayResize( values, 4 );
                values[ 1 ] = 1;
                values[ 3 ] = builder.raw( "COALESCE(?, 3)", [ 3 ] );
                values[ 4 ] = { value: 4, cfsqltype: "INTEGER" };

                builder.from( "users" ).whereIn( "id", values );

                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""id"" IN (?, ?, COALESCE(?, 3), ?)" );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1, "", 3, 4 ] );
                expect( builder.getBindings()[ 2 ].null ).toBeTrue();
            } );

            it( "converts query results directly to keyed row structs", function() {
                var utils = new qb.models.Query.QueryUtils();
                var rows = queryNew(
                    "id,name",
                    "integer,varchar",
                    [ { id: 1, name: "Ada" }, { id: 2, name: "Grace" }, { id: 1, name: "Augusta" } ]
                );

                var result = utils.queryToStructOfStructs( rows, "id" );

                expect( result ).toHaveKey( "1" );
                expect( result ).toHaveKey( "2" );
                expect( result.count() ).toBe( 2 );
                expect( result[ 1 ].name ).toBe( "Augusta" );
                expect( result[ 2 ].name ).toBe( "Grace" );
                expect( utils.queryToStructOfStructs( queryNew( "name", "varchar" ), "id" ) ).toBe( {} );
            } );

            it( "projects retained query columns without mutating the source query", function() {
                var utils = new qb.models.Query.QueryUtils();
                var source = queryNew(
                    "id,name,age",
                    "integer,varchar,integer",
                    [ { id: 1, name: "Ada", age: 36 }, { id: 2, name: "Grace", age: 85 } ]
                );

                var result = utils.queryRemoveColumns( source, "NaMe" );

                expect( listLen( result.columnList ) ).toBe( 2 );
                expect( listFindNoCase( result.columnList, "id" ) > 0 ).toBeTrue();
                expect( listFindNoCase( result.columnList, "age" ) > 0 ).toBeTrue();
                expect( listFindNoCase( result.columnList, "name" ) ).toBe( 0 );
                expect( result.recordCount ).toBe( 2 );
                expect( result.id[ 1 ] ).toBe( 1 );
                expect( result.id[ 2 ] ).toBe( 2 );
                expect( result.age[ 1 ] ).toBe( 36 );
                expect( result.age[ 2 ] ).toBe( 85 );
                expect( listLen( source.columnList ) ).toBe( 3 );
                expect( listFindNoCase( source.columnList, "name" ) > 0 ).toBeTrue();
                expect( source.name[ 1 ] ).toBe( "Ada" );
                expect( source.name[ 2 ] ).toBe( "Grace" );
            } );

            it( "flattens requested binding groups in order while honoring exclusions", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );
                builder.addBindings( { value: "selected" }, "select" );
                builder.addBindings( { value: "joined" }, "join" );
                builder.addBindings( { value: "filtered" }, "where" );

                var bindings = builder.getBindings( except = [ "SELECT" ], order = [ "select", "join", "where" ] );

                expect( bindings.map( ( binding ) => binding.value ) ).toBe( [ "joined", "filtered" ] );
            } );

            it( "wraps simple identifiers through the fast path and preserves alias parsing", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();

                expect( grammar.wrapColumn( { type: "simple", value: "accounts.users.id" } ) ).toBe(
                    """accounts"".""users"".""id"""
                );
                expect( grammar.wrapColumn( { type: "simple", value: "users.id AS userId" } ) ).toBe(
                    """users"".""id"" AS ""userId"""
                );
                expect( grammar.wrapColumn( { type: "simple", value: "users.id#chr( 9 )#userId" } ) ).toBe(
                    """users"".""id"" AS ""userId"""
                );
            } );

            it( "normalizes prefixed SQL types without changing public results", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.BaseGrammar( utils );

                expect( utils.inferSqlType( { cfsqltype: " cf_sql_bigint " }, grammar ) ).toBe( "BIGINT" );
                expect( utils.inferSqlType( { sqltype: " Decimal " }, grammar ) ).toBe( "DECIMAL" );
                expect( grammar.resolveWhereInBulkSqlType( " cf_sql_varchar " ) ).toBe( "VARCHAR" );
                expect( grammar.resolveWhereInBulkSqlType( " timestamp " ) ).toBe( "TIMESTAMP" );
            } );

            it( "infers array SQL types without retaining per-item type results", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.PostgresGrammar( utils );
                var sparseValues = [];
                arrayResize( sparseValues, 4 );
                sparseValues[ 1 ] = 1;
                sparseValues[ 3 ] = 3;
                sparseValues[ 4 ] = { null: true };

                expect( utils.inferSqlType( sparseValues, grammar ) ).toBe( "INTEGER" );
                expect( utils.inferSqlType( [ 1, "mixed" ], grammar ) ).toBe( "VARCHAR" );
                expect( utils.inferSqlType( [], grammar ) ).toBe( "VARCHAR" );
            } );

            it( "appends scalar and array binding inputs without changing their order", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder.addBindings( { value: "first" }, "where" );
                builder.addBindings( [ { value: "second" }, { value: "third" } ], "where" );

                expect( builder.getBindings( order = [ "where" ] ).map( ( binding ) => binding.value ) ).toBe( [ "first", "second", "third" ] );
            } );

            it( "normalizes a single column without splitting and preserves list behavior", function() {
                var builder = new qb.models.Query.QueryBuilder();

                expect( builder.normalizeToArray( " users.id " ) ).toBe( [ "users.id" ] );
                expect( builder.normalizeToArray( "users.id, users.name" ) ).toBe( [ "users.id", "users.name" ] );
                expect( builder.normalizeToArray( "" ) ).toBe( [ "" ] );
            } );

            it( "wraps simple table names without changing prefix or alias behavior", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();

                expect( grammar.wrapTable( "analytics.users" ) ).toBe( """analytics"".""users""" );
                grammar.setTablePrefix( "qb_" );
                expect( grammar.wrapTable( "analytics.users" ) ).toBe( """analytics"".""qb_users""" );
                grammar.setTablePrefix( "" );
                expect( grammar.wrapTable( "users AS u" ) ).toBe( """users"" AS ""u""" );
            } );

            it( "does not resolve the target grammar when there are no nested common tables", function() {
                var grammar = createMock( "qb.models.Grammars.BaseGrammar" )
                    .init()
                    .$( "getResolvedGrammar" )
                    .$callback( function() {
                        throw( type = "UnexpectedGrammarResolution" );
                    } );
                var source = new qb.models.Query.QueryBuilder( grammar = grammar );
                var target = new qb.models.Query.QueryBuilder( grammar = grammar );

                expect( function() {
                    new qb.models.Query.QueryExecutor().hoistNestedCommonTables( source, target );
                } ).notToThrow();
            } );
        } );
    }

}
