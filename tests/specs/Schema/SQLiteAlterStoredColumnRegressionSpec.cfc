component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQLite alter stored-column regression", function() {
            it( "rejects adding stored generated columns", function() {
                var schema = new qb.models.Schema.SchemaBuilder( grammar = new qb.models.Grammars.SQLiteGrammar() );

                expect( function() {
                    schema
                        .alter(
                            table = "orders",
                            callback = function( table ) {
                                table.addColumn( table.decimal( "total" ).storedAs( "quantity * price" ) );
                            },
                            execute = false
                        )
                        .toSQL();
                } ).toThrow( type = "UnsupportedOperation" );
            } );
        } );
    }

}
