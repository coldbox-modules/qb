component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQLite multi-join update regression", function() {
            it( "places every joined table before the update predicates", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() )
                    .from( "employees" )
                    .join( "departments", function( join ) {
                        join.on( "departments.id", "=", "employees.departmentId" ).where( "departments.active", true );
                    } )
                    .join( "locations", function( join ) {
                        join.on( "locations.id", "=", "departments.locationId" ).where( "locations.region", "west" );
                    } )
                    .where( "employees.active", true );

                var values = structNew( "ordered" );
                values[ "departmentName" ] = "Operations";
                var sql = builder.update( values = values, toSql = true );

                expect( sql ).toBe(
                    "UPDATE ""employees"" SET ""departmentName"" = ? FROM ""departments"", ""locations"" WHERE ""departments"".""id"" = ""employees"".""departmentId"" AND ""departments"".""active"" = ? AND ""locations"".""id"" = ""departments"".""locationId"" AND ""locations"".""region"" = ? AND ""employees"".""active"" = ?"
                );
                expect( builder.getBindings( order = builder.getGrammar().getUpdateBindingOrder( builder ) ) ).toHaveLength(
                    4
                );
                expect(
                    builder.getBindings( order = builder.getGrammar().getUpdateBindingOrder( builder ) )[ 1 ].value
                ).toBe( "Operations" );
                expect(
                    builder.getBindings( order = builder.getGrammar().getUpdateBindingOrder( builder ) )[ 2 ].value
                ).toBeTrue();
                expect(
                    builder.getBindings( order = builder.getGrammar().getUpdateBindingOrder( builder ) )[ 3 ].value
                ).toBe( "west" );
                expect(
                    builder.getBindings( order = builder.getGrammar().getUpdateBindingOrder( builder ) )[ 4 ].value
                ).toBeTrue();
            } );
        } );
    }

}
