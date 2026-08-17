component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "MySQL delete row-selection regression", function() {
            it( "preserves ORDER BY and LIMIT on single-table deletes", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() )
                    .from( "jobs" )
                    .where( "queue", "mail" )
                    .orderByRaw( "FIELD(status, ?)", [ "stale" ] )
                    .limit( 10 );

                var sql = builder.delete( toSql = true );

                expect( sql ).toBe( "DELETE FROM `jobs` WHERE `queue` = ? ORDER BY FIELD(status, ?) LIMIT 10" );
                expect( builder.getBindings() ).toHaveLength( 2 );
                expect( builder.getBindings()[ 1 ].value ).toBe( "mail" );
                expect( builder.getBindings()[ 2 ].value ).toBe( "stale" );
            } );
        } );
    }

}
