component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "MySQL DML offset regression", function() {
            it( "rejects offsets on updates instead of silently updating the wrong rows", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() )
                    .from( "jobs" )
                    .limit( 1 )
                    .offset( 2 );

                expect( function() {
                    builder.update( values = { status: "archived" }, toSql = true );
                } ).toThrow( type = "UnsupportedOperation" );
            } );

            it( "rejects offsets on deletes instead of silently deleting the wrong rows", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() )
                    .from( "jobs" )
                    .limit( 1 )
                    .offset( 2 );

                expect( function() {
                    builder.delete( toSql = true );
                } ).toThrow( type = "UnsupportedOperation" );
            } );
        } );
    }

}
