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
                    expect( blueprint.toSql() ).toBeWithCase( "CREATE TABLE ""users"" (""id"" INT NOT NULL AUTO_INCREMENT, ""username"" VARCHAR(255) NOT NULL, ""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL, ""password"" VARCHAR(100) NOT NULL, ""country_id"" INT NOT NULL, ""created_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modified_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (""id""), CONSTRAINT ""fk_country_id"" FOREIGN KEY (""country_id"") REFERENCES ""countries"" (""id"") ON UPDATE NONE ON DELETE CASCADE)" );
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