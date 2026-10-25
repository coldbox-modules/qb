component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "schema callback query builder identity", function() {
            it( "preserves canonical builder identity when createView loads the builder first", function() {
                assertSchemaBuilderIdentity( "createView" );
            } );
            it( "preserves canonical builder identity when createAs loads the builder first", function() {
                assertSchemaBuilderIdentity( "createAs" );
            } );
            it( "preserves canonical builder identity when alterView loads the builder first", function() {
                assertSchemaBuilderIdentity( "alterView" );
            } );
            it( "rejects a non-QueryBuilder argument at the nominal wrapper boundary", function() {
                expect( function() {
                    new tests.resources.querybuilder.RetrievableQueryBuilder( {} );
                } ).toThrow();
            } );
            it( "rejects a non-QueryBuilder return from the nominal wrapper boundary", function() {
                var builder = new qb.models.Query.QueryBuilder();
                var wrapper = new tests.resources.querybuilder.RetrievableQueryBuilder( builder );
                prepareMock( wrapper ).$property( "builder", "variables", {} );
                expect( function() {
                    wrapper.retrieveQuery();
                } ).toThrow();
            } );
        } );
    }

    private function assertSchemaBuilderIdentity( required string method ) {
        var grammar = new qb.models.Grammars.MySQLGrammar();
        var schema = new qb.models.Schema.SchemaBuilder( grammar );
        var received = {};
        var options = {
            callback: function( query ) {
                query
                    .select( "id" )
                    .from( "users" )
                    .where( "active", 1 );
                // Exercise the original nominal checks before metadata calls can warm Adobe's type cache.
                received.wrapper = new tests.resources.querybuilder.RetrievableQueryBuilder( query );
            },
            execute: false
        };
        options[ arguments.method == "createAs" ? "newTableName" : "view" ] = "active_users";
        invoke( schema, arguments.method, options );
        var query = new qb.models.Query.QueryBuilder( grammar = grammar )
            .from( "posts" )
            .whereIn( "userId", received.wrapper );
        expect( query.toSQL() ).toBe(
            "SELECT * FROM `posts` WHERE `userId` IN (SELECT `id` FROM `users` WHERE `active` = ?)"
        );
        expect( query.getBindings() ).toHaveLength( 1 );
        expect( query.getBindings()[ 1 ].value ).toBe( 1 );
        expect( getMetadata( received.wrapper.retrieveQuery() ).name ).toBe( "qb.models.Query.QueryBuilder" );
    }

}
