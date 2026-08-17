component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Oracle unsupported DML row-selection regression", function() {
            for ( var selection in [ "order", "offset" ] ) {
                it( "rejects #selection# on update statements", function() {
                    var builder = configuredBuilder( selection );

                    expect( function() {
                        builder.update( values = { status: "archived" }, toSql = true );
                    } ).toThrow( type = "UnsupportedOperation" );
                } );
            }

            for ( var selection in [ "order", "limit", "offset" ] ) {
                it( "rejects #selection# on delete statements", function() {
                    var builder = configuredBuilder( selection );

                    expect( function() {
                        builder.delete( toSql = true );
                    } ).toThrow( type = "UnsupportedOperation" );
                } );
            }
        } );
    }

    private any function configuredBuilder( required string selection ) {
        var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.OracleGrammar() ).from( "jobs" );

        switch ( arguments.selection ) {
            case "order":
                return builder.orderBy( "createdDate" );
            case "limit":
                return builder.limit( 1 );
            case "offset":
                return builder.offset( 2 );
        }
    }

}
