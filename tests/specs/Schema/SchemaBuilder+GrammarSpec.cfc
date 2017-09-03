component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "schema builder + basic grammar", function() {
            describe( "create tables", function() {
                it( "can create an empty table", function() {
                    var schema = getBuilder();
                    var blueprint = schema.create( "users", function() {}, false );
                    expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" ()" );
                } );

                it( "can create a simple table", function() {
                    var schema = getBuilder();
                    var blueprint = schema.create( "users", function( table ) {
                        table.string( "username" );
                        table.string( "password" );
                    }, false );
                    expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL, ""password"" VARCHAR(255) NOT NULL)" );
                } );

                it( "create a complicated table", function() {
                    var schema = getBuilder();
                    var blueprint = schema.create( "users", function( table ) {
                        table.increments( "id" );
                        table.string( "username" );
                        table.string( "first_name" );
                        table.string( "last_name" );
                        table.string( "password", 100 );
                        table.unsignedInt( "country_id" ).references( "id" ).setTable( "countries" ).setOnDelete( "cascade" );
                        table.timestamp( "created_date" ).setDefault( "CURRENT_TIMESTAMP" );
                        table.timestamp( "modified_date" ).setDefault( "CURRENT_TIMESTAMP" );
                    }, false );
                    expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT, ""username"" VARCHAR(255) NOT NULL, ""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL, ""password"" VARCHAR(100) NOT NULL, ""country_id"" INTEGER(10) UNSIGNED NOT NULL, ""created_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modified_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (""id""), CONSTRAINT ""fk_country_id"" FOREIGN KEY (""country_id"") REFERENCES ""countries"" (""id"") ON UPDATE NONE ON DELETE CASCADE)" );
                } );

                describe( "column types", function() {
                    it( "bigIncrements", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.bigIncrements( "id" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""id"" BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (""id""))" );
                    } );

                    it( "bigInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "weather_reports", function( table ) {
                            table.bigInteger( "temperature" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""weather_reports"" (""temperature"" BIGINT NOT NULL)" );
                    } );

                    it( "bit", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.bit( "active" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""active"" BIT(1) NOT NULL)" );
                    } );

                    it( "bit (with length)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.bit( "something", 4 );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""something"" BIT(4) NOT NULL)" );
                    } );

                    it( "boolean", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.boolean( "active" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""active"" TINYINT(1) NOT NULL)" );
                    } );

                    it( "char", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "classifications", function( table ) {
                            table.char( "level" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""classifications"" (""level"" CHAR(1) NOT NULL)" );
                    } );

                    it( "char (with length)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "classifications", function( table ) {
                            table.char( "abbreviation", 3 );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""classifications"" (""abbreviation"" CHAR(3) NOT NULL)" );
                    } );

                    it( "char (limits length over 255 to 255)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "classifications", function( table ) {
                            table.char( "abbreviation", 300 );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""classifications"" (""abbreviation"" CHAR(255) NOT NULL)" );
                    } );

                    it( "date", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.date( "posted_date" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""posts"" (""posted_date"" DATE NOT NULL)" );
                    } );

                    it( "datetime", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.datetime( "posted_date" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""posts"" (""posted_date"" DATETIME NOT NULL)" );
                    } );

                    xit( "decimal", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "enum", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "float", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "increments", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.increments( "id" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (""id""))" );
                    } );

                    it( "integer", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.integer( "age" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) NOT NULL)" );
                    } );

                    it( "integer with precision", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.integer( "age", 2 );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(2) NOT NULL)" );
                    } );

                    xit( "json", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "longText", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "mediumIncrements", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "mediumInteger", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "mediumText", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "morphs", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "nullableMorphs", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "raw", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "smallIncrements", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "smallInteger", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "string", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.string( "username" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL)" );
                    } );

                    it( "string (with length)", function() {
                        var schema = getBuilder();
                    var blueprint = schema.create( "users", function( table ) {
                        table.string( "password", 50 );
                    }, false );
                    expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""password"" VARCHAR(50) NOT NULL)" );
                    } );

                    it( "text", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.text( "body" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" );
                    } );

                    it( "time", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "recurring_tasks", function( table ) {
                            table.time( "fire_time" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""recurring_tasks"" (""fire_time"" TIME NOT NULL)" );
                    } );

                    it( "tinyInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.tinyInteger( "active" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""active"" TINYINT NOT NULL)" );
                    } );

                    it( "tinyInteger with length", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.tinyInteger( "active", 3 );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""active"" TINYINT(3) NOT NULL)" );
                    } );

                    it( "timestamp", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.timestamp( "posted_date" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP NOT NULL)" );
                    } );

                    it( "unsignedBigInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.unsignedBigInteger( "salary" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" BIGINT UNSIGNED NOT NULL)" );
                    } );

                    it( "unsignedInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.unsignedInteger( "age" );
                        }, false );
                        expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) UNSIGNED NOT NULL)" );
                    } );

                    xit( "unsignedMediumInteger", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "unsignedSmallInteger", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "unsignedTinyInteger", function() {
                        fail( "test not implemented yet" );
                    } );

                    xit( "uuid", function() {
                        fail( "test not implemented yet" );
                    } );
                } );

                xdescribe( "column modifiers", function() {
                    it( "comment", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "default", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "nullable", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "unsigned", function() {
                        fail( "test not implemented yet" );
                    } );
                } );

                xdescribe( "indexes", function() {
                    it( "unique", function() {
                        fail( "off of column" );
                        fail( "off of table" );
                    } );

                    it( "index", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "composite index", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "override index name", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "primary", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "composite primary key", function() {
                        fail( "test not implemented yet" );
                    } );
                } );

                xdescribe( "has", function() {
                    it( "hasTable", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "hasColumn", function() {
                        fail( "test not implemented yet" );
                    } );
                } );

                xdescribe( "rename", function() {
                    it( "rename table", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "rename column", function() {
                        fail( "test not implemented yet" );
                    } );
                } );

                xdescribe( "drop", function() {
                    it( "drop table", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "dropIfExists", function() {
                        fail( "test not implemented yet" );
                    } );

                    it( "drop column", function() {
                        fail( "test not implemented yet" );
                    } );
                } );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox()
            .createMock( "qb.models.Grammars.Grammar" );
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" )
            .init( grammar );
        return builder;
    }

}
