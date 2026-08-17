component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQLite delete row-selection regression", function() {
            it( "preserves RETURNING, ORDER BY, LIMIT, and OFFSET", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() )
                    .from( "jobs" )
                    .where( "queue", "mail" )
                    .returning( "id" )
                    .orderByRaw( "CASE WHEN status = ? THEN 0 ELSE 1 END", [ "stale" ] )
                    .limit( 10 )
                    .offset( 2 );

                var sql = builder.delete( toSql = true );

                expect( sql ).toBe(
                    "DELETE FROM ""jobs"" WHERE ""queue"" = ? RETURNING ""id"" ORDER BY CASE WHEN status = ? THEN 0 ELSE 1 END LIMIT 10 OFFSET 2"
                );
                expect( builder.getBindings() ).toHaveLength( 2 );
                expect( builder.getBindings()[ 1 ].value ).toBe( "mail" );
                expect( builder.getBindings()[ 2 ].value ).toBe( "stale" );
            } );
        } );
    }

}
