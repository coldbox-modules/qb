component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQLite alter auto-increment regression", function() {
            it( "rejects adding auto-incrementing primary-key columns", function() {
                var schema = new qb.models.Schema.SchemaBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() );

                expect( function() {
                    schema
                        .alter(
                            table = "users",
                            callback = function( table ) {
                                table.addColumn( table.increments( "id" ) );
                            },
                            execute = false
                        )
                        .toSQL();
                } ).toThrow( type = "UnsupportedOperation" );
            } );
        } );
    }

}
