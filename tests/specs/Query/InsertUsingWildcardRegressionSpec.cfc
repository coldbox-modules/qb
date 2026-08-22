component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "insert using wildcard regression", function() {
            it( "omits the target column list for an implicit wildcard source", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "archived_users" );

                var sql = builder.insertUsing( source = builder.newQuery().from( "users" ), toSql = true );

                expect( sql ).toBe( "INSERT INTO ""archived_users"" SELECT * FROM ""users""" );
            } );

            it( "omits the target column list for MySQL wildcard sources", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() ).from( "archived_users" );

                var sql = builder.insertUsing( source = builder.newQuery().from( "users" ), toSql = true );

                expect( sql ).toBe( "INSERT INTO `archived_users` SELECT * FROM `users`" );
            } );
        } );
    }

}
