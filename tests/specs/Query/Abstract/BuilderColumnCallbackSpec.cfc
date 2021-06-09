component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "column callback spec", function() {
            beforeEach( function() {
                variables.query = new qb.models.Query.QueryBuilder();
                getMockBox().prepareMock( query );
                query.$property( propertyName = "utils", mock = new qb.models.Query.QueryUtils() );
            } );

            it( "does nothing by default", function() {
                query.from( "users" ).where( "firstName", "=", "firstName" );
                expect( query.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""firstName"" = ?" );
                expect( query.getBindings()[ 1 ].value ).toBe( "firstName" );
            } );

            it( "can set a column formatter to be called for each column used", function() {
                query.setColumnFormatter( function( column ) {
                    return reverse( column );
                } );
                query.from( "users" ).where( "firstName", "=", "firstName" );
                expect( query.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""emaNtsrif"" = ?" );
                expect( query.getBindings()[ 1 ].value ).toBe( "firstName" );
            } );

            it( "column formatters are not applied until building the query", function() {
                var prefix = "a";
                query.setColumnFormatter( function( column ) {
                    return prefix & "." & column;
                } );
                query.from( "users" ).where( "firstName", "=", "firstName" );
                expect( query.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""a"".""firstName"" = ?" );
                prefix = "b";
                expect( query.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""b"".""firstName"" = ?" );
                expect( query.getBindings()[ 1 ].value ).toBe( "firstName" );
            } );
        } );
    }

}
