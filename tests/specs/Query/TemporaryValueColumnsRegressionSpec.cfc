component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "value column restoration regression", function() {
            it( "restores selected columns after retrieving one value", function() {
                var builder = getBuilder();
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 1", options = {} )
                    .$results( queryNew( "name", "varchar", [ { name: "foo" } ] ) );

                builder.select( "id" ).from( "users" );

                expect( builder.value( "name" ) ).toBe( "foo" );
                expect( builder.getColumns().map( ( column ) => column.value ) ).toBe( [ "id" ] );
            } );

            it( "restores selected columns after retrieving a value list", function() {
                var builder = getBuilder();
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""name"" FROM ""users""", options = {} )
                    .$results( queryNew( "name", "varchar", [ { name: "foo" }, { name: "bar" } ] ) );

                builder.select( "id" ).from( "users" );

                expect( builder.values( "name" ) ).toBe( [ "foo", "bar" ] );
                expect( builder.getColumns().map( ( column ) => column.value ) ).toBe( [ "id" ] );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        return getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
    }

}
