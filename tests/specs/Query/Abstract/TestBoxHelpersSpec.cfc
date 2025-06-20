component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "testbox helpers", () => {
            beforeEach( () => {
                variables.qb = new qb.models.Query.QueryBuilder();
                getMockBox().prepareMock( qb );

                var utils = new qb.models.Query.QueryUtils();
                qb.$property( propertyName = "utils", mock = utils );
            } );

            afterEach( () => structDelete( variables, "qb" ) );

            it( "can expect a record to exist", () => {
                variables.qb.$( "exists", true );
                expect( () => {
                    variables.qb.expectToExist();
                } ).notToThrow( type = "TestBox.AssertionFailed" );

                expect( () => {
                    variables.qb.expectNotToExist();
                } ).toThrow( type = "TestBox.AssertionFailed" );

                variables.qb.$( "exists", false );
                expect( () => {
                    variables.qb.expectToExist();
                } ).toThrow( type = "TestBox.AssertionFailed" );

                expect( () => {
                    variables.qb.expectNotToExist();
                } ).notToThrow( type = "TestBox.AssertionFailed" );
            } );

            it( "can expect to find a certain number of records", () => {
                variables.qb.$( "count", 1 );
                expect( () => {
                    variables.qb.expectToHaveCount( 1 );
                } ).notToThrow( type = "TestBox.AssertionFailed" );

                expect( () => {
                    variables.qb.expectNotToHaveCount( 1 );
                } ).toThrow( type = "TestBox.AssertionFailed" );

                variables.qb.$( "count", 2 );
                expect( () => {
                    variables.qb.expectToHaveCount( 1 );
                } ).toThrow( type = "TestBox.AssertionFailed" );

                expect( () => {
                    variables.qb.expectNotToHaveCount( 1 );
                } ).notToThrow( type = "TestBox.AssertionFailed" );
            } );
        } );
    }

}
