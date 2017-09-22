component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "schema builder + mysql grammar", function() {
            describe( "rename", function() {
                it( "rename table", function() {
                    var schema = getBuilder();
                    var blueprint = schema.rename( "workers", "employees", {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 1 );
                    expect( statements[ 1 ] ).toBeWithCase( "RENAME TABLE `workers` TO `employees`" );
                } );
            } );

            describe( "rename columns", function() {
                it( "renames a column", function() {
                    var schema = getBuilder();
                    var blueprint = schema.alter( "users", function( table ) {
                        table.renameColumn( "name", table.string( "username" ) );
                    }, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 1 );
                    expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE `users` CHANGE `name` `username` VARCHAR(255) NOT NULL" );
                } );

                it( "renames multiple columns", function() {
                    var schema = getBuilder();
                    var blueprint = schema.alter( "users", function( table ) {
                        table.renameColumn( "name", table.string( "username" ) );
                        table.renameColumn( "purchase_date", table.timestamp( "purchased_at" ).nullable() );
                    }, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 2 );
                    expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE `users` CHANGE `name` `username` VARCHAR(255) NOT NULL" );
                    expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE `users` CHANGE `purchase_date` `purchased_at` TIMESTAMP" );
                } );
            } );
        } );
    }

    private function getBuilder() {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        var grammar = getMockBox()
            .createMock( "qb.models.Grammars.MySQLGrammar" )
            .init( utils );
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" )
            .init( grammar );
        return builder;
    }

}
