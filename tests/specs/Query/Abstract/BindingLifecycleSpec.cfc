component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "binding lifecycle", function() {
            it( "replaces derived-table bindings when replacing the FROM source", function() {
                var builder = new qb.models.Query.QueryBuilder();

                builder.fromSub( "source", function( query ) {
                    query.from( "orders" ).where( "kind", "retail" );
                } );
                builder.fromSub( "source", function( query ) {
                    query.from( "payments" ).where( "status", "settled" );
                } );

                expect( builder.toSql() ).toBe(
                    "SELECT * FROM (SELECT * FROM ""payments"" WHERE ""status"" = ?) AS ""source"""
                );
                expect( builder.getBindings() ).toHaveLength( 1 );
                expect( builder.getBindings()[ 1 ].value ).toBe( "settled" );
            } );

            it( "clears the previous alias when replacing the FROM source", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users AS old_source" ).from( "payments" );

                expect( builder.toSql() ).toBe( "SELECT * FROM ""payments""" );
            } );

            it( "removes HAVING bindings that are not part of an INSERT", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).having( "age", ">", 21 );

                expect( builder.insert( { name: "new user" }, {}, true ) ).toBe(
                    "INSERT INTO ""users"" (""name"") VALUES (?)"
                );

                expect( builder.getBindings() ).toHaveLength( 1 );
                expect( builder.getBindings()[ 1 ].value ).toBe( "new user" );
            } );

            it( "preserves an explicit null HAVING value", function() {
                var builder = new qb.models.Query.QueryBuilder()
                    .from( "users" )
                    .having( "score", "=", javacast( "null", "" ) );

                expect( builder.getHavings()[ 1 ].operator ).toBe( "=" );
                expect( builder.getRawBindings().having[ 1 ].null ).toBeTrue();
                expect( builder.getRawBindings().having[ 1 ].value ).toBe( "" );
                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" HAVING ""score"" = ?" );
            } );
        } );
    }

}
