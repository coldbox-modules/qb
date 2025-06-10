component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "queryLog", function() {
            it( "tracks the queries it executes", function() {
                var qb = new qb.models.Query.QueryBuilder();
                qb.pretend()
                    .select( "*" )
                    .from( "users" )
                    .get();

                expect( qb.getQueryLog() ).toBeArray();
                expect( qb.getQueryLog() ).toHaveLength( 1 );
                expect( qb.getQueryLog()[ 1 ] ).toBeStruct();

                expect( qb.getQueryLog()[ 1 ] ).toHaveKey( "sql" );
                expect( qb.getQueryLog()[ 1 ].sql ).toBeString().toBe( "SELECT * FROM ""users""" );

                expect( qb.getQueryLog()[ 1 ] ).toHaveKey( "bindings" );
                expect( qb.getQueryLog()[ 1 ].bindings ).toBeArray().toBeEmpty();

                expect( qb.getQueryLog()[ 1 ] ).toHaveKey( "options" );
                expect( qb.getQueryLog()[ 1 ].options ).toBeStruct();

                expect( qb.getQueryLog()[ 1 ] ).toHaveKey( "returnObject" );
                expect( qb.getQueryLog()[ 1 ].returnObject ).toBeString().toBe( "query" );

                expect( qb.getQueryLog()[ 1 ] ).toHaveKey( "pretend" );
                expect( qb.getQueryLog()[ 1 ].pretend ).toBeBoolean().toBeTrue();

                expect( qb.getQueryLog()[ 1 ] ).toHaveKey( "result" );
                expect( qb.getQueryLog()[ 1 ].result ).toBeStruct().toBeEmpty();

                expect( qb.getQueryLog()[ 1 ] ).toHaveKey( "executionTime" );
                expect( qb.getQueryLog()[ 1 ].executionTime ).toBeNumeric().toBe( 0 );
            } );

            it( "tracks the queries it executes for schema builder", function() {
                var schema = new qb.models.Schema.SchemaBuilder();
                schema
                    .pretend()
                    .create( "users", function( t ) {
                        t.increments( "id" );
                        t.string( "name" );
                        t.datetime( "createdDate" );
                    } );

                expect( schema.getQueryLog() ).toBeArray();
                expect( schema.getQueryLog() ).toHaveLength( 1 );
                expect( schema.getQueryLog()[ 1 ] ).toBeStruct();

                expect( schema.getQueryLog()[ 1 ] ).toHaveKey( "sql" );
                expect( schema.getQueryLog()[ 1 ].sql )
                    .toBeString()
                    .toBe( "CREATE TABLE ""users"" (""id"" INTEGER UNSIGNED NOT NULL AUTO_INCREMENT, ""name"" VARCHAR(255) NOT NULL, ""createdDate"" DATETIME NOT NULL, CONSTRAINT ""pk_users_id"" PRIMARY KEY (""id""))" );

                expect( schema.getQueryLog()[ 1 ] ).toHaveKey( "bindings" );
                expect( schema.getQueryLog()[ 1 ].bindings ).toBeArray().toBeEmpty();

                expect( schema.getQueryLog()[ 1 ] ).toHaveKey( "options" );
                expect( schema.getQueryLog()[ 1 ].options ).toBeStruct();

                expect( schema.getQueryLog()[ 1 ] ).toHaveKey( "returnObject" );
                expect( schema.getQueryLog()[ 1 ].returnObject ).toBeString().toBe( "result" );

                expect( schema.getQueryLog()[ 1 ] ).toHaveKey( "pretend" );
                expect( schema.getQueryLog()[ 1 ].pretend ).toBeBoolean().toBeTrue();

                expect( schema.getQueryLog()[ 1 ] ).toHaveKey( "result" );
                expect( schema.getQueryLog()[ 1 ].result ).toBeStruct().toBeEmpty();

                expect( schema.getQueryLog()[ 1 ] ).toHaveKey( "executionTime" );
                expect( schema.getQueryLog()[ 1 ].executionTime ).toBeNumeric().toBe( 0 );
            } );
        } );
    }

}
