component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "prefixed inferred SQL type regression", function() {
            it( "normalizes declared query parameter SQL types", function() {
                var utils = new qb.models.Query.QueryUtils();
                var grammar = new qb.models.Grammars.BaseGrammar( utils );

                expect(
                    utils.inferSqlType(
                        [ { value: 18, cfsqltype: "cf_sql_integer" }, { value: 21, sqltype: "INTEGER" } ],
                        grammar
                    )
                ).toBe( "INTEGER" );
            } );

            it( "normalizes configured numeric SQL types", function() {
                var utils = new qb.models.Query.QueryUtils(
                    integerSqlType = "cf_sql_bigint",
                    decimalSqlType = "cf_sql_numeric"
                );
                var grammar = new qb.models.Grammars.BaseGrammar( utils );

                expect( utils.inferSqlType( 18, grammar ) ).toBe( "BIGINT" );
                expect( utils.inferSqlType( 18.5, grammar ) ).toBe( "NUMERIC" );
            } );

            it( "casts PostgreSQL JSON scalars using prefixed query parameter types", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                var sql = builder
                    .from( "users" )
                    .where( "profile->age", ">=", { value: 18, cfsqltype: "cf_sql_integer" } )
                    .toSQL();

                expect( sql ).toBe( "SELECT * FROM ""users"" WHERE CAST(""profile""->>'age' AS NUMERIC) >= ?" );
            } );
        } );
    }

}
