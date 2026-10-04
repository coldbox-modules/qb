component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query failure observation", function() {
            it( "announces a failed execution once and preserves its original exception", function() {
                var observations = [];
                var grammar = new qb.models.Grammars.BaseGrammar();
                grammar.setInterceptorService( {
                    announce: function( state, data ) {
                        if ( state == "onQBExecuteException" ) {
                            observations.append( data );
                            throw( type = "ObserverFailure", message = "must not replace database error" );
                        }
                    }
                } );
                var failure = {};
                try {
                    grammar.runQuery(
                        sql = "SELECT nonexistent_column FROM nonexistent_table",
                        options = { dbtype: "query" }
                    );
                } catch ( any caught ) {
                    failure = caught;
                }
                expect( observations.len() ).toBe( 1 );
                expect( observations[ 1 ].executionTime ).toBeGTE( 0 );
                expect( observations[ 1 ].exception.message ).toBe( failure.message );
                expect( failure.type ).notToBe( "ObserverFailure" );
            } );
            it( "keeps pretend execution hooks compatible without announcing a failure", function() {
                var states = [];
                var grammar = new qb.models.Grammars.BaseGrammar();
                grammar.setInterceptorService( {
                    announce: function( state, data ) {
                        states.append( state );
                    }
                } );
                grammar.runQuery( sql = "not executable", pretend = true );
                expect( states ).toBe( [ "preQBExecute", "postQBExecute" ] );
            } );
        } );
    }

}
