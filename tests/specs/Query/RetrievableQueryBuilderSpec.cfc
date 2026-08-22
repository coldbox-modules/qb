component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "retrievable query builder compatibility", function() {
            it( "accepts a retrievable builder in a whereIn subquery", function() {
                var grammar = new qb.models.Grammars.MySQLGrammar();
                var inner = new qb.models.Query.QueryBuilder( grammar = grammar )
                    .select( "id" )
                    .from( "users" )
                    .where( "active", true );
                var retrievableBuilder = new tests.resources.querybuilder.RetrievableQueryBuilder( inner );

                var query = new qb.models.Query.QueryBuilder( grammar = grammar )
                    .from( "posts" )
                    .whereIn( "userId", retrievableBuilder );

                expect( query.toSQL() ).toBe(
                    "SELECT * FROM `posts` WHERE `userId` IN (SELECT `id` FROM `users` WHERE `active` = ?)"
                );
                expect( query.getBindings() ).toHaveLength( 1 );
            } );
        } );
    }

}
