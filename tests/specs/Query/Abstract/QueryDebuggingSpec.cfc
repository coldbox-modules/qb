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

            // TODO: Update with BoxLang specific path
            xit( "can output the configured sql with the bindings substituted in", function() {
                var query = getBuilder()
                    .from( "users" )
                    .join( "logins", function( j ) {
                        j.on( "users.id", "logins.user_id" )
                            .where( "logins.created_date", ">", parseDateTime( "2019-06-01" ) );
                    } )
                    .whereIn( "users.type", [ "admin", "manager" ] )
                    .whereNotNull( "active" )
                    .orderBy( "logins.created_date", "desc" );

                if ( isLucee() ) {
                    expect( query.toSQL( showBindings = true ) ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""logins"" ON ""users"".""id"" = ""logins"".""user_id"" AND ""logins"".""created_date"" > {""value"":""2019-06-01T00:00:00-06:00"",""cfsqltype"":""CF_SQL_TIMESTAMP"",""null"":false} WHERE ""users"".""type"" IN ({""value"":""admin"",""cfsqltype"":""CF_SQL_VARCHAR"",""null"":false}, {""value"":""manager"",""cfsqltype"":""CF_SQL_VARCHAR"",""null"":false}) AND ""active"" IS NOT NULL ORDER BY ""logins"".""created_date"" DESC"
                    );
                } else {
                    expect( query.toSQL( showBindings = true ) ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""logins"" ON ""users"".""id"" = ""logins"".""user_id"" AND ""logins"".""created_date"" > {""value"":""2019-06-01T00:00:00-06:00"",""cfsqltype"":""CF_SQL_TIMESTAMP"",""null"":false} WHERE ""users"".""type"" IN ({""value"":""admin"",""cfsqltype"":""CF_SQL_VARCHAR"",""null"":false}, {""value"":""manager"",""cfsqltype"":""CF_SQL_VARCHAR"",""null"":false}) AND ""active"" IS NOT NULL ORDER BY ""logins"".""created_date"" DESC"
                    );
                }
            } );

            it( "provides a useful error message when calling `from` with a closure", function() {
                expect( function() {
                    getBuilder().from( function( q ) {
                        q.from( "whatever" ).where( "active", 1 );
                    } );
                } ).toThrow( type = "QBInvalidFrom" );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
        return builder;
    }

    private boolean function isLucee() {
        return server.keyExists( "lucee" );
    }

}
