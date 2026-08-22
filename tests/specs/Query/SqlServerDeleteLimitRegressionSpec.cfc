component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQL Server delete limit regression", function() {
            it( "compiles TOP for single-table deletes", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() )
                    .from( "jobs" )
                    .where( "queue", "mail" )
                    .limit( 1 );

                expect( builder.delete( toSql = true ) ).toBe( "DELETE TOP (1) FROM [jobs] WHERE [queue] = ?" );
            } );

            it( "compiles TOP for joined deletes", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() )
                    .from( "jobs AS j" )
                    .join(
                        "queues AS q",
                        "q.id",
                        "=",
                        "j.queueId"
                    )
                    .where( "q.name", "mail" )
                    .limit( 1 );

                expect( builder.delete( toSql = true ) ).toBe(
                    "DELETE TOP (1) [j] FROM [jobs] AS [j] INNER JOIN [queues] AS [q] ON [q].[id] = [j].[queueId] WHERE [q].[name] = ?"
                );
            } );
        } );
    }

}
