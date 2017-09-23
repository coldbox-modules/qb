component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "schema builder + basic grammar", function() {
            describe( "create tables", function() {
                it( "can create an empty table", function() {
                    var schema = getBuilder();
                    var blueprint = schema.create( "users", function() {}, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 1 );
                    expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" ()" );
                } );

                it( "can create a simple table", function() {
                    var schema = getBuilder();
                    var blueprint = schema.create( "users", function( table ) {
                        table.string( "username" );
                        table.string( "password" );
                    }, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 1 );
                    expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL, ""password"" VARCHAR(255) NOT NULL)" );
                } );

                it( "create a complicated table", function() {
                    var schema = getBuilder();
                    var blueprint = schema.create( "users", function( table ) {
                        table.increments( "id" );
                        table.string( "username" );
                        table.string( "first_name" );
                        table.string( "last_name" );
                        table.string( "password", 100 );
                        table.unsignedInteger( "country_id" ).references( "id" ).setTable( "countries" ).setOnDelete( "cascade" );
                        table.timestamp( "created_date" ).setDefault( "CURRENT_TIMESTAMP" );
                        table.timestamp( "modified_date" ).setDefault( "CURRENT_TIMESTAMP" );
                    }, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 1 );
                    expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT, ""username"" VARCHAR(255) NOT NULL, ""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL, ""password"" VARCHAR(100) NOT NULL, ""country_id"" INTEGER(10) UNSIGNED NOT NULL, ""created_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modified_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (""id""), CONSTRAINT ""fk_country_id"" FOREIGN KEY (""country_id"") REFERENCES ""countries"" (""id"") ON UPDATE NONE ON DELETE CASCADE)" );
                } );

                describe( "column types", function() {
                    it( "bigIncrements", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.bigIncrements( "id" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (""id""))" );
                    } );

                    it( "bigInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "weather_reports", function( table ) {
                            table.bigInteger( "temperature" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""weather_reports"" (""temperature"" BIGINT NOT NULL)" );
                    } );

                    it( "bit", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.bit( "active" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""active"" BIT(1) NOT NULL)" );
                    } );

                    it( "bit (with length)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.bit( "something", 4 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""something"" BIT(4) NOT NULL)" );
                    } );

                    it( "boolean", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.boolean( "active" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""active"" TINYINT(1) NOT NULL)" );
                    } );

                    it( "char", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "classifications", function( table ) {
                            table.char( "level" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""classifications"" (""level"" CHAR(1) NOT NULL)" );
                    } );

                    it( "char (with length)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "classifications", function( table ) {
                            table.char( "abbreviation", 3 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""classifications"" (""abbreviation"" CHAR(3) NOT NULL)" );
                    } );

                    it( "char (limits length over 255 to 255)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "classifications", function( table ) {
                            table.char( "abbreviation", 300 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""classifications"" (""abbreviation"" CHAR(255) NOT NULL)" );
                    } );

                    it( "date", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.date( "posted_date" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""posts"" (""posted_date"" DATE NOT NULL)" );
                    } );

                    it( "datetime", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.datetime( "posted_date" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""posts"" (""posted_date"" DATETIME NOT NULL)" );
                    } );

                    it( "decimal (with defaults)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.decimal( "salary" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" DECIMAL(10,0) NOT NULL)" );
                    } );

                    it( "decimal (with length)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.decimal( "salary", 3 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" DECIMAL(3,0) NOT NULL)" );
                    } );

                    it( "decimal (with precision)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.decimal( name = "salary", precision = 2 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" DECIMAL(10,2) NOT NULL)" );
                    } );

                    it( "decimal (with length and precision)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.decimal( "salary", 3, 2 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" DECIMAL(3,2) NOT NULL)" );
                    } );

                    it( "enum", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""tshirt_size"" ENUM(""S"",""M"",""L"",""XL"",""XXL"") NOT NULL)" );
                    } );

                    it( "float (with defaults)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.float( "salary" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" FLOAT(10,0) NOT NULL)" );
                    } );

                    it( "float (with length)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.float( "salary", 3 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" FLOAT(3,0) NOT NULL)" );
                    } );

                    it( "float (with precision)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.float( name = "salary", precision = 2 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" FLOAT(10,2) NOT NULL)" );
                    } );

                    it( "float (with length and precision)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.float( "salary", 3, 2 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" FLOAT(3,2) NOT NULL)" );
                    } );

                    it( "increments", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.increments( "id" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (""id""))" );
                    } );

                    it( "integer", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.integer( "age" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) NOT NULL)" );
                    } );

                    it( "integer with length", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.integer( "age", 2 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(2) NOT NULL)" );
                    } );

                    it( "json", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.json( "personalizations" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""personalizations"" TEXT NOT NULL)" );
                    } );

                    it( "longText", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.longText( "body" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" );
                    } );

                    it( "mediumIncrements", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.mediumIncrements( "id" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (""id""))" );
                    } );

                    it( "mediumInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.integer( "age" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) NOT NULL)" );
                    } );

                    it( "mediumText", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.mediumText( "body" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" );
                    } );

                    it( "morphs", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "tags", function( table ) {
                            table.morphs( "taggable" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""tags"" (""taggable_id"" INTEGER(10) UNSIGNED NOT NULL, ""taggable_type"" VARCHAR(255) NOT NULL, INDEX ""taggable_index"" (""taggable_id"",""taggable_type""))" );
                    } );

                    it( "nullableMorphs", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "tags", function( table ) {
                            table.nullableMorphs( "taggable" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""tags"" (""taggable_id"" INTEGER(10) UNSIGNED, ""taggable_type"" VARCHAR(255), INDEX ""taggable_index"" (""taggable_id"",""taggable_type""))" );
                    } );

                    it( "raw", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.raw( "id BLOB NOT NULL" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (id BLOB NOT NULL)" );
                    } );

                    it( "smallIncrements", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.smallIncrements( "id" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (""id""))" );
                    } );

                    it( "smallInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.smallInteger( "age" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) NOT NULL)" );
                    } );

                    it( "string", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.string( "username" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL)" );
                    } );

                    it( "string (with length)", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.string( "password", 50 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""password"" VARCHAR(50) NOT NULL)" );
                    } );

                    it( "text", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.text( "body" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" );
                    } );

                    it( "time", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "recurring_tasks", function( table ) {
                            table.time( "fire_time" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""recurring_tasks"" (""fire_time"" TIME NOT NULL)" );
                    } );

                    it( "timestamp", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "posts", function( table ) {
                            table.timestamp( "posted_date" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP NOT NULL)" );
                    } );

                    it( "tinyIncrements", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.tinyIncrements( "id" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (""id""))" );
                    } );

                    it( "tinyInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.tinyInteger( "active" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""active"" INTEGER(10) NOT NULL)" );
                    } );

                    it( "tinyInteger with length", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.tinyInteger( "active", 3 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""active"" INTEGER(3) NOT NULL)" );
                    } );

                    it( "unsignedBigInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "employees", function( table ) {
                            table.unsignedBigInteger( "salary" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""employees"" (""salary"" BIGINT UNSIGNED NOT NULL)" );
                    } );

                    it( "unsignedInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.unsignedInteger( "age" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) UNSIGNED NOT NULL)" );
                    } );

                    it( "unsignedMediumInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.unsignedMediumInteger( "age" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) UNSIGNED NOT NULL)" );
                    } );

                    it( "unsignedSmallInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.unsignedSmallInteger( "age" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) UNSIGNED NOT NULL)" );
                    } );

                    it( "unsignedTinyInteger", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.unsignedTinyInteger( "age" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) UNSIGNED NOT NULL)" );
                    } );

                    it( "uuid", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.uuid( "id" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" CHAR(35) NOT NULL)" );
                    } );
                } );

                describe( "column modifiers", function() {
                    it( "comment", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.boolean( "active" ).comment( "This is a comment" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""active"" TINYINT(1) NOT NULL COMMENT ""This is a comment"")" );
                    } );

                    it( "default", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.boolean( "active" ).default( 1 );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""active"" TINYINT(1) NOT NULL DEFAULT 1)" );
                    } );

                    it( "nullable", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.uuid( "id" ).nullable();
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""id"" CHAR(35))" );
                    } );

                    it( "unsigned", function() {
                        var schema = getBuilder();
                        var blueprint = schema.create( "users", function( table ) {
                            table.integer( "age" ).unsigned();
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "CREATE TABLE ""users"" (""age"" INTEGER(10) UNSIGNED NOT NULL)" );
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

                describe( "rename tables", function() {
                    it( "rename table", function() {
                        var schema = getBuilder();
                        var blueprint = schema.rename( "workers", "employees", {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""workers"" RENAME TO ""employees""" );
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
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""name"" ""username"" VARCHAR(255) NOT NULL" );
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
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""name"" ""username"" VARCHAR(255) NOT NULL" );
                        expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""purchase_date"" ""purchased_at"" TIMESTAMP" );
                    } );
                } );

                describe( "modify columns", function() {
                    it( "modifies a column", function() {
                        var schema = getBuilder();
                        var blueprint = schema.alter( "users", function( table ) {
                            table.modifyColumn( "name", table.string( "username" ) );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""name"" ""username"" VARCHAR(255) NOT NULL" );
                    } );

                    it( "modifies multiple columns", function() {
                        var schema = getBuilder();
                        var blueprint = schema.alter( "users", function( table ) {
                            table.modifyColumn( "name", table.string( "username" ) );
                            table.modifyColumn( "purchase_date", table.timestamp( "purchased_at" ).nullable() );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 2 );
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""name"" ""username"" VARCHAR(255) NOT NULL" );
                        expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""purchase_date"" ""purchased_at"" TIMESTAMP" );
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
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" ADD ""tshirt_size"" ENUM(""S"",""M"",""L"",""XL"",""XXL"") NOT NULL" );
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
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" ADD ""tshirt_size"" ENUM(""S"",""M"",""L"",""XL"",""XXL"") NOT NULL" );
                        expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE ""users"" ADD ""is_active"" TINYINT(1) NOT NULL" );
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
                    expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" DROP COLUMN ""is_active""" );
                    expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE ""users"" ADD ""tshirt_size"" ENUM(""S"",""M"",""L"",""XL"",""XXL"") NOT NULL" );
                    expect( statements[ 3 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""name"" ""username"" VARCHAR(255) NOT NULL" );
                    expect( statements[ 4 ] ).toBeWithCase( "ALTER TABLE ""users"" CHANGE ""purchase_date"" ""purchase_date"" TIMESTAMP" );
                } );

                describe( "drop", function() {
                    it( "drop table", function() {
                        var schema = getBuilder();
                        var blueprint = schema.drop( "users", {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "DROP TABLE ""users""" );
                    } );

                    it( "dropIfExists", function() {
                        var schema = getBuilder();
                        var blueprint = schema.dropIfExists( "users", {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "DROP TABLE IF EXISTS ""users""" );
                    } );

                    it( "drop column", function() {
                        var schema = getBuilder();
                        var blueprint = schema.alter( "users", function( table ) {
                            table.dropColumn( "username" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 1 );
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" DROP COLUMN ""username""" );
                    } );

                    it( "drops multiple columns", function() {
                        var schema = getBuilder();
                        var blueprint = schema.alter( "users", function( table ) {
                            table.dropColumn( "username" );
                            table.dropColumn( "password" );
                        }, {}, false );
                        var statements = blueprint.toSql();
                        expect( statements ).toBeArray();
                        expect( statements ).toHaveLength( 2 );
                        expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""users"" DROP COLUMN ""username""" );
                        expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE ""users"" DROP COLUMN ""password""" );
                    } );
                } );
            } );
        } );
    }

    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ?
            getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init( utils ) :
            arguments.mockGrammar;
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" )
            .init( arguments.mockGrammar );
        return builder;
    }

}
