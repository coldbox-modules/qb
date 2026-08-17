component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQL Server unsupported DML row-selection regression", function() {
            for ( var operation in [ "update", "delete" ] ) {
                it( "rejects direct ordering on #operation# statements", function() {
                    var builder = new qb.models.Query.QueryBuilder(
                        grammar = new qb.models.Grammars.SqlServerGrammar()
                    ).from( "jobs" )
                        .orderBy( "createdDate" )
                        .limit( 1 );

                    expect( function() {
                        if ( operation == "update" ) {
                            builder.update( values = { status: "archived" }, toSql = true );
                        } else {
                            builder.delete( toSql = true );
                        }
                    } ).toThrow( type = "UnsupportedOperation" );
                } );

                it( "rejects offsets on #operation# statements", function() {
                    var builder = new qb.models.Query.QueryBuilder(
                        grammar = new qb.models.Grammars.SqlServerGrammar()
                    ).from( "jobs" )
                        .limit( 1 )
                        .offset( 2 );

                    expect( function() {
                        if ( operation == "update" ) {
                            builder.update( values = { status: "archived" }, toSql = true );
                        } else {
                            builder.delete( toSql = true );
                        }
                    } ).toThrow( type = "UnsupportedOperation" );
                } );
            }
        } );
    }

}
