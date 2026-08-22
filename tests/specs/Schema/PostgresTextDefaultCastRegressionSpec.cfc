component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "PostgreSQL text default cast regression", function() {
            it( "preserves double colons inside text defaults", function() {
                var schema = new qb.models.Schema.SchemaBuilder( grammar = new qb.models.Grammars.PostgresGrammar() );

                var statements = schema
                    .create(
                        "hosts",
                        function( table ) {
                            table.string( "address" ).default( "::1" );
                        },
                        {},
                        false
                    )
                    .toSQL();

                expect( statements ).toBe( [ "CREATE TABLE ""hosts"" (""address"" VARCHAR(255) NOT NULL DEFAULT '::1')" ] );
            } );
        } );
    }

}
