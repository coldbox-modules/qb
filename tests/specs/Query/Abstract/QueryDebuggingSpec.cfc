component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query debugging", function() {
            it( "can output the configured sql with placeholders for the bindings", function() {
                var query = getBuilder()
                    .from( "users" )
                    .join( "logins", function( j ) {
                        j.on( "users.id", "logins.user_id" ).where( "logins.created_date", ">", "01 Jun 2019" );
                    } )
                    .whereIn( "users.type", [ "admin", "manager" ] )
                    .whereNotNull( "active" )
                    .orderBy( "logins.created_date", "desc" );

                expect( query.toSQL() ).toBe(
                    "SELECT * FROM ""users"" INNER JOIN ""logins"" ON ""users"".""id"" = ""logins"".""user_id"" AND ""logins"".""created_date"" > ? WHERE ""users"".""type"" IN (?, ?) AND ""active"" IS NOT NULL ORDER BY ""logins"".""created_date"" DESC"
                );
            } );

            it( "can output the configured sql with the bindings substituted in", function() {
                var query = getBuilder()
                    .from( "users" )
                    .join( "logins", function( j ) {
                        j.on( "users.id", "logins.user_id" ).where( "logins.created_date", ">", "01 Jun 2019" );
                    } )
                    .whereIn( "users.type", [ "admin", "manager" ] )
                    .whereNotNull( "active" )
                    .orderBy( "logins.created_date", "desc" );

                expect( query.toSQL( showBindings = true ) ).toBe(
                    "SELECT * FROM ""users"" INNER JOIN ""logins"" ON ""users"".""id"" = ""logins"".""user_id"" AND ""logins"".""created_date"" > {""value"":""01 Jun 2019"",""cfsqltype"":""CF_SQL_TIMESTAMP"",""null"":false} WHERE ""users"".""type"" IN ({""value"":""admin"",""cfsqltype"":""CF_SQL_VARCHAR"",""null"":false}, {""value"":""manager"",""cfsqltype"":""CF_SQL_VARCHAR"",""null"":false}) AND ""active"" IS NOT NULL ORDER BY ""logins"".""created_date"" DESC"
                );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
        return builder;
    }

}
