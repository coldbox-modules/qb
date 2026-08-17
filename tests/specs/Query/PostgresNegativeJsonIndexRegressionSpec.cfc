component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "PostgreSQL negative JSON index regression", function() {
            it( "compiles negative arrow path segments as array indexes", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                builder.from( "events" ).select( "payload->items->-1 AS lastItem" );

                expect( builder.toSQL() ).toBe( "SELECT ""payload""->'items'->>-1 AS ""lastItem"" FROM ""events""" );
            } );
        } );
    }

}
