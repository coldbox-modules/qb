component displayname="PretendSpec" extends="testbox.system.BaseSpec" {

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
        } );
    }

}
