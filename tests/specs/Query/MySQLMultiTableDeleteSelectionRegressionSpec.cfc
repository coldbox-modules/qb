component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "MySQL multi-table delete row-selection regression", function() {
            it( "rejects ORDER BY and LIMIT instead of silently ignoring them", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() )
                    .from( "jobs" )
                    .join(
                        "queues",
                        "queues.id",
                        "=",
                        "jobs.queueId"
                    )
                    .orderBy( "jobs.id" )
                    .limit( 1 );

                expect( function() {
                    builder.delete( toSql = true );
                } ).toThrow( type = "UnsupportedOperation" );
            } );
        } );
    }

}
