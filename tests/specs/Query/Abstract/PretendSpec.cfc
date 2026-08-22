component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "pretend", function() {
            it( "can pretend to run queries instead of actually running them", function() {
                var qb = new qb.models.Query.QueryBuilder();
                expect( function() {
                    qb.newQuery()
                        .select( "*" )
                        .from( "users" )
                        .get();
                } ).toThrow();

                expect( function() {
                    qb.newQuery()
                        .pretend()
                        .select( "*" )
                        .from( "users" )
                        .get();
                } ).notToThrow();
            } );

            it( "can pretend to run schema commands instead of actually running them", function() {
                var sb = new qb.models.Schema.SchemaBuilder();
                expect( function() {
                    sb.create( "users", function( t ) {
                        t.increments( "id" );
                        t.string( "name" );
                        t.datetime( "createdDate" );
                    } );
                } ).toThrow();

                expect( function() {
                    sb.pretend()
                        .create( "users", function( t ) {
                            t.increments( "id" );
                            t.string( "name" );
                            t.datetime( "createdDate" );
                        } );
                } ).notToThrow();
            } );

            it( "keeps internally-created execution builders in pretend mode", function() {
                expect( function() {
                    new qb.models.Query.QueryBuilder()
                        .from( "users" )
                        .pretend()
                        .exists();
                } ).notToThrow();

                expect( function() {
                    new qb.models.Query.QueryBuilder()
                        .from( "users" )
                        .pretend()
                        .insertBulk( [ { "id": 1 } ] );
                } ).notToThrow();

                expect( function() {
                    new qb.models.Query.QueryBuilder()
                        .from( "users" )
                        .select( "status" )
                        .groupBy( "status" )
                        .pretend()
                        .paginate();
                } ).notToThrow();
            } );

            it( "does not query database catalogs when pretending to drop all objects", function() {
                var schema = new qb.models.Schema.SchemaBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                expect( function() {
                    schema.pretend().dropAllObjects();
                } ).notToThrow();
            } );
        } );
    }

}
