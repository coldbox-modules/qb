component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "module settings", function() {
            it( "does not expose the removed numericSQLType setting", function() {
                var moduleConfig = prepareMock( new qb.ModuleConfig() );

                moduleConfig.configure();

                expect( moduleConfig.$getProperty( "settings", "variables" ) ).notToHaveKey( "numericSQLType" );
            } );
        } );
    }

}
