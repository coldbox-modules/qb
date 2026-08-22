component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQLite alter unique-column regression", function() {
            it( "rejects adding columns with inline unique constraints", function() {
                var schema = new qb.models.Schema.SchemaBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() );

                expect( function() {
                    schema
                        .alter(
                            table = "users",
                            callback = function( table ) {
                                table.addColumn( table.string( "email" ).unique() );
                            },
                            execute = false
                        )
                        .toSQL();
                } ).toThrow( type = "UnsupportedOperation" );
            } );
        } );
    }

}
