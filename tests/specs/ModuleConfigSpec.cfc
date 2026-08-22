component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "module settings", function() {
            it( "does not expose the removed numericSQLType setting", function() {
                var moduleConfig = prepareMock( new qb.ModuleConfig() );

                moduleConfig.configure();

                expect( moduleConfig.$getProperty( "settings", "variables" ) ).notToHaveKey( "numericSQLType" );
            } );

            it( "exposes separate integer SQL type settings", function() {
                var moduleConfig = prepareMock( new qb.ModuleConfig() );

                moduleConfig.configure();

                var settings = moduleConfig.$getProperty( "settings", "variables" );
                expect( settings.integerSQLType ).toBe( "INTEGER" );
                expect( settings.bigIntegerSQLType ).toBe( "BIGINT" );
                expect( settings.decimalSQLType ).toBe( "DECIMAL" );
            } );
        } );
    }

}
