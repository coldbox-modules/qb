component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "schema builder + oracle grammar", function() {
            describe( "rename columns", function() {
                it( "renames a column", function() {
                    var schema = getBuilder();
                    var blueprint = schema.alter( "users", function( table ) {
                        table.renameColumn( "name", table.string( "username" ) );
                    }, {}, false );
                    var statements = blueprint.toSql();
                    expect( statements ).toBeArray();
                    expect( statements ).toHaveLength( 1 );
                    expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""USERS"" RENAME COLUMN ""NAME"" TO ""USERNAME""" );
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
                    expect( statements[ 1 ] ).toBeWithCase( "ALTER TABLE ""USERS"" RENAME COLUMN ""NAME"" TO ""USERNAME""" );
                    expect( statements[ 2 ] ).toBeWithCase( "ALTER TABLE ""USERS"" RENAME COLUMN ""PURCHASE_DATE"" TO ""PURCHASED_AT""" );
                } );
            } );
        } );
    }

    private function getBuilder() {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        var grammar = getMockBox()
            .createMock( "qb.models.Grammars.OracleGrammar" )
            .init( utils );
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" )
            .init( grammar );
        return builder;
    }

}
