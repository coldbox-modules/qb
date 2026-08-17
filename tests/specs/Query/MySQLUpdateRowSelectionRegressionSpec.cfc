component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "MySQL update row-selection regression", function() {
            it( "preserves ORDER BY before LIMIT on single-table updates", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() )
                    .from( "jobs" )
                    .where( "queue", "mail" )
                    .orderByRaw( "FIELD(status, ?)", [ "stale" ] )
                    .limit( 10 );

                var sql = builder.update( values = { status: "archived" }, toSql = true );

                expect( sql ).toBe(
                    "UPDATE `jobs` SET `STATUS` = ? WHERE `queue` = ? ORDER BY FIELD(status, ?) LIMIT 10"
                );
                expect( builder.getBindings( order = builder.getGrammar().getUpdateBindingOrder( builder ) ) ).toHaveLength(
                    3
                );
            } );

            it( "rejects row selection on multi-table updates", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() )
                    .from( "jobs" )
                    .join(
                        "queues",
                        "queues.id",
                        "=",
                        "jobs.queueId"
                    )
                    .limit( 1 );

                expect( function() {
                    builder.update( values = { status: "archived" }, toSql = true );
                } ).toThrow( type = "UnsupportedOperation" );
            } );
        } );
    }

}
