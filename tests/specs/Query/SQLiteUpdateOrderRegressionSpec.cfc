component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQLite update ordering regression", function() {
            it( "preserves ORDER BY between RETURNING and LIMIT", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() )
                    .from( "jobs" )
                    .where( "queue", "mail" )
                    .returning( "id" )
                    .orderByRaw( "CASE WHEN status = ? THEN 0 ELSE 1 END", [ "stale" ] )
                    .limit( 10 );

                var sql = builder.update( values = { status: "archived" }, toSql = true );

                expect( sql ).toBe(
                    "UPDATE ""jobs"" SET ""STATUS"" = ? WHERE ""queue"" = ? RETURNING ""id"" ORDER BY CASE WHEN status = ? THEN 0 ELSE 1 END LIMIT 10"
                );
                expect( builder.getBindings( order = builder.getGrammar().getUpdateBindingOrder( builder ) ) ).toHaveLength(
                    3
                );
            } );
        } );
    }

}
