component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQLite update row-limit regression", function() {
            it( "places LIMIT after UPDATE FROM predicates", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() )
                    .from( "employees" )
                    .join(
                        "departments",
                        "departments.id",
                        "=",
                        "employees.departmentId"
                    )
                    .limit( 1 );

                var sql = builder.update( values = { name: "Operations" }, toSql = true );

                expect( sql ).toBe(
                    "UPDATE ""employees"" SET ""NAME"" = ? FROM ""departments"" WHERE ""departments"".""id"" = ""employees"".""departmentId"" LIMIT 1"
                );
            } );

            it( "places LIMIT after RETURNING", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() )
                    .from( "employees" )
                    .where( "active", true )
                    .returning( "id" )
                    .limit( 1 );

                var sql = builder.update( values = { name: "Operations" }, toSql = true );

                expect( sql ).toBe(
                    "UPDATE ""employees"" SET ""NAME"" = ? WHERE ""active"" = ? RETURNING ""id"" LIMIT 1"
                );
            } );

            it( "includes UPDATE offsets after the limit", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() )
                    .from( "employees" )
                    .where( "active", true )
                    .limit( 1 )
                    .offset( 2 );

                var sql = builder.update( values = { name: "Operations" }, toSql = true );

                expect( sql ).toBe( "UPDATE ""employees"" SET ""NAME"" = ? WHERE ""active"" = ? LIMIT 1 OFFSET 2" );
            } );
        } );
    }

}
