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

            describe( "has", function() {
                it( "hasTable", function() {
                    var mockGrammar = getMockBox().createMock( "qb.models.Grammars.MySQLGrammar" );
                    mockGrammar.$( "runQuery", queryNew( "result", "CF_SQL_INTEGER", [ { result = 1 } ] ) );
                    var schema = getBuilder( mockGrammar );
                    var result = schema.hasTable( "users" );
                    expect( result ).toBeTrue();
                    var sql = schema.hasTable( "users", {}, false );
                    expect( sql ).toBeWithCase( "SELECT 1 FROM `information_schema`.`tables` WHERE `table_name` = ?" );
                } );

                it( "hasColumn", function() {
                    var mockGrammar = getMockBox().createMock( "qb.models.Grammars.MySQLGrammar" );
                    mockGrammar.$( "runQuery", queryNew( "result", "CF_SQL_INTEGER", [ { result = 1 } ] ) );
                    var schema = getBuilder( mockGrammar );
                    var result = schema.hasColumn( "users", "username" );
                    expect( result ).toBeTrue();
                    var sql = schema.hasColumn( "users", "username", {}, false );
                    expect( sql ).toBeWithCase( "SELECT 1 FROM `information_schema`.`columns` WHERE `table_name` = ? AND `column_name` = ?" );
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

            describe( "adding columns", function() {
                it( "can add a new column", function() {
                    var schema = getBuilder();
                    var blueprint = schema.alter( "users", function( table ) {
                        table.addColumn( table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] ) );
                    }, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 1 );
                    expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE `users` ADD `tshirt_size` ENUM(`S`,`M`,`L`,`XL`,`XXL`) NOT NULL" );
                } );

                it( "can add multiple columns", function() {
                    var schema = getBuilder();
                    var blueprint = schema.alter( "users", function( table ) {
                        table.addColumn( table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] ) );
                        table.addColumn( table.boolean( "is_active" ) );
                    }, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 2 );
                    expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE `users` ADD `tshirt_size` ENUM(`S`,`M`,`L`,`XL`,`XXL`) NOT NULL" );
                    expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE `users` ADD `is_active` TINYINT(1) NOT NULL" );
                } );
            } );

            xdescribe( "indexes", function() {
                describe( "unique", function() {
                    it( "unique (off of column)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.string( "username" ).unique();
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE `users` (`username` VARCHAR(255) NOT NULL, CONSTRAINT unique_username UNIQUE (`username`))" );
                    } );

                    it( "unique (off of table)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.string( "username" );
                            table.unique( "username" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE `users` (`username` VARCHAR(255) NOT NULL, UNIQUE (`username`))" );
                    } );
                } );

                describe( "primary indexes", function() {
                    it( "column primary key", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.string( "uuid" ).primaryKey();
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE `users` (`uuid` VARCHAR(255) NOT NULL, PRIMARY KEY (`uuid`)" );
                    } );
                } );
            } );

            it( "can drop and add and rename and modify columns at the same time", function() {
                var schema = getBuilder();
                var blueprint = schema.alter( "users", function( table ) {
                    table.dropColumn( "is_active" );
                    table.addColumn( table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] ) );
                    table.renameColumn( "name", table.string( "username" ) );
                    table.modifyColumn( "purchase_date", table.timestamp( "purchase_date" ).nullable() );
                }, {}, false );
                var statements = blueprint.toSql();
                expect( statements ).toBeArray();
                expect( statements ).toHaveLength( 4 );
                expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE `users` DROP COLUMN `is_active`" );
                expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE `users` ADD `tshirt_size` ENUM(`S`,`M`,`L`,`XL`,`XXL`) NOT NULL" );
                expect( statements[ 3 ] ).toBeWithCase( "ALTER TABLE `users` CHANGE `name` `username` VARCHAR(255) NOT NULL" );
                expect( statements[ 4 ] ).toBeWithCase( "ALTER TABLE `users` CHANGE `purchase_date` `purchase_date` TIMESTAMP" );
            } );
        } );
    }

    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ?
            getMockBox().createMock( "qb.models.Grammars.MySQLGrammar" ).init( utils ) :
            arguments.mockGrammar;
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" )
            .init( arguments.mockGrammar );
        return builder;
    }

}
