component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query failure observation", function() {
            it( "announces a failed execution once, diagnoses observer failure, and preserves its original exception", function() {
                var observations = [];
                var diagnostics = [];
                var grammar = new qb.models.Grammars.BaseGrammar();
                grammar.setLog( {
                    canDebug: function() {
                        return false;
                    },
                    debug: function( message, extraInfo ) {
                        diagnostics.append( extraInfo );
                    }
                } );
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
                expect( observations[ 1 ].exception ).toBe( failure );
                expect( failure.type ).notToBe( "ObserverFailure" );
                expect( diagnostics.len() ).toBe( 1 );
                expect( diagnostics[ 1 ].type ).toBe( "ObserverFailure" );
            } );
            it( "preserves the query exception even when the observer diagnostic logger fails", function() {
                var original = {};
                var grammar = new qb.models.Grammars.BaseGrammar();
                grammar.setLog( {
                    canDebug: function() {
                        return false;
                    },
                    debug: function( message, extraInfo ) {
                        throw( type = "DiagnosticFailure" );
                    }
                } );
                grammar.setInterceptorService( {
                    announce: function( state, data ) {
                        if ( state == "onQBExecuteException" ) {
                            original = data.exception;
                            throw( type = "ObserverFailure" );
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
                expect( failure ).toBe( original );
                expect( failure.type ).notToBe( "DiagnosticFailure" );
                expect( failure.type ).notToBe( "ObserverFailure" );
            } );
            it( "uses the existing processState compatibility path for failure interception", function() {
                var states = [];
                var grammar = new qb.models.Grammars.BaseGrammar();
                grammar.setInterceptorService( {
                    processState: function( state, data ) {
                        states.append( state );
                    }
                } );
                expect( () => grammar.runQuery(
                    sql = "SELECT nonexistent_column FROM nonexistent_table",
                    options = { dbtype: "query" }
                ) ).toThrow();
                expect( states ).toBe( [ "preQBExecute", "onQBExecuteException" ] );
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
