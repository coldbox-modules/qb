component extends="testbox.system.BaseSpec" {
    function run() {
        describe( "interaction with collaborators", function() {
            beforeEach( function() {
                variables.mockGrammar = getMockBox().createStub( implements = "Quick.models.Query.Grammars.GrammarInterface" );
                variables.query = new Quick.models.Query.Builder();
                getMockBox().prepareMock( query );
                query.$property( propertyName = "grammar", mock = mockGrammar );
            } );

            describe( "interaction with grammar", function() {
                describe( "toSQL()", function() {
                    xit( "returns the result of sending itself to its grammar", function() {
                        // Expecting the query to be passed in $args() is not working here.
                        // Even stranger is the fact that the callLog shows a call,
                        // isArray() says it's an array, but arrayLen() says 0 and
                        // trying to access it blows up.
                        //
                        // var callLog = mockGrammar.$callLog().compileSelect;
                        // debug(callLog);
                        // debug(isArray(callLog));
                        // debug(arrayLen(callLog));

                        mockGrammar.$( "compileSelect" ).$results( "::compiled SQL::" );
                        expect( query.toSQL() ).toBe( "::compiled SQL::" );
                        expect( mockGrammar.$once( "compileSelect" ) ).toBeTrue( "compileSelect() should have been called once." );
                    } );
                } );
            } );
        } );
    }
}