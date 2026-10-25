component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "optional query telemetry adapter", function() {
            it( "registers independent listeners and unregisters only its own registration once", function() {
                var environment = makeEnvironment();
                environment.configured.shutdown();
                environment.unregistered.names.clear();
                var adapter = new qb.models.Telemetry.QueryTelemetryAdapter( environment.service );
                var first = adapter.configure( { telemetry: environment.telemetry, applicationName: "app" } );
                var second = adapter.configure( { telemetry: environment.telemetry, applicationName: "app" } );
                expect( first.mode ).toBe( "custom" );
                expect( environment.listeners.count() ).toBe( 2 );
                first.shutdown();
                first.shutdown();
                expect( environment.listeners.count() ).toBe( 1 );
                expect( environment.unregistered.names.len() ).toBe( 1 );
                second.shutdown();
                expect( environment.listeners ).toBeEmpty();
            } );
            it( "scrubs SQL, emits configured database metadata, and restores the enclosing scope", function() {
                var environment = makeEnvironment( "postgresql" );
                environment.telemetry.setScope( { request: "enclosing" } );
                var data = { sql: "SELECT 'PRIVATE', 42", bindings: [ "SECRET" ], options: { password: "SECRET" } };
                environment.listener.preQBExecute( interceptData = data );
                expect( environment.telemetry.getScope().manualQuerySpan ).toBeString();
                expect( environment.telemetry.getSpans().len() ).toBe( 1 );
                var span = environment.telemetry.getSpans()[ 1 ];
                expect( span.getName() ).toBe( "SELECT ?, ?" );
                expect( span.getAttributes() ).toBe( { "db.system": "postgresql" } );
                environment.listener.postQBExecute( interceptData = data );
                expect( span.getStatuses() ).toBe( [ "ok" ] );
                expect( environment.telemetry.getScope() ).toBe( { request: "enclosing" } );
                expect( data.count() ).toBe( 3 );
                environment.configured.shutdown();
            } );
            it( "preserves nested execution scopes and completes each query only once", function() {
                var environment = makeEnvironment();
                var outer = { sql: "SELECT 1" };
                var inner = { sql: "SELECT 2" };
                environment.listener.preQBExecute( interceptData = outer );
                environment.listener.preQBExecute( interceptData = inner );
                expect( environment.telemetry.getSpans().len() ).toBe( 2 );
                environment.listener.onQBExecuteException( interceptData = inner );
                environment.listener.postQBExecute( interceptData = inner );
                expect( environment.telemetry.getSpans()[ 2 ].getStatuses() ).toBe( [ "internal_error" ] );
                expect( environment.telemetry.getScope().span ).toBe( environment.telemetry.getSpans()[ 1 ] );
                environment.listener.postQBExecute( interceptData = outer );
                expect( environment.telemetry.getSpans()[ 1 ].getStatuses() ).toBe( [ "ok" ] );
                expect( environment.telemetry.getScope() ).toBeEmpty();
                environment.configured.shutdown();
            } );
            it( "skips pretend and manually observed queries without changing their scope", function() {
                var environment = makeEnvironment();
                environment.listener.preQBExecute( interceptData = { sql: "SELECT 1", pretend: true } );
                environment.telemetry.setScope( { manualQuerySpan: true, request: "manual" } );
                var data = { sql: "SELECT 2" };
                environment.listener.preQBExecute( interceptData = data );
                environment.listener.postQBExecute( interceptData = data );
                expect( environment.telemetry.getSpans() ).toBeEmpty();
                expect( environment.telemetry.getScope() ).toBe( { manualQuerySpan: true, request: "manual" } );
                environment.configured.shutdown();
            } );
            it( "does not duplicate another installed adapter's observation", function() {
                var environment = makeEnvironment();
                var second = new qb.models.Telemetry.QueryTelemetryAdapter( environment.service ).configure( { telemetry: environment.telemetry } );
                var data = { sql: "SELECT 1" };
                environment.service.announce( "preQBExecute", data );
                environment.service.announce( "postQBExecute", data );
                expect( environment.telemetry.getSpans().len() ).toBe( 1 );
                expect( environment.telemetry.getScope() ).toBeEmpty();
                second.shutdown();
                environment.configured.shutdown();
            } );
            it( "restores scope even when finishing telemetry throws", function() {
                var environment = makeEnvironment();
                environment.telemetry.setFailFinish( true );
                var data = { sql: "SELECT 1" };
                environment.listener.preQBExecute( interceptData = data );
                environment.listener.onQBExecuteException( interceptData = data );
                expect( environment.telemetry.getScope() ).toBeEmpty();
                expect( environment.telemetry.getSpans()[ 1 ].getStatuses() ).toBe( [ "internal_error" ] );
                environment.configured.shutdown();
            } );
            it( "does not let telemetry startup failures prevent query observation callbacks", function() {
                var environment = makeEnvironment();
                environment.telemetry.setFailStart( true );
                var data = { sql: "SELECT 1" };
                environment.listener.preQBExecute( interceptData = data );
                environment.listener.postQBExecute( interceptData = data );
                expect( environment.telemetry.getScope() ).toBeEmpty();
                expect( environment.telemetry.getSpans() ).toBeEmpty();
                environment.configured.shutdown();
            } );
            it( "blocks new executions after shutdown even through a retained listener reference", function() {
                var environment = makeEnvironment();
                environment.configured.shutdown();
                environment.listener.preQBExecute( interceptData = { sql: "SELECT 1" } );
                expect( environment.telemetry.getSpans() ).toBeEmpty();
            } );
            it( "drains successful in-flight queries before removing completion hooks", function() {
                var environment = makeEnvironment();
                var data = { sql: "SELECT 1" };
                environment.service.announce( "preQBExecute", data );
                environment.configured.shutdown();
                environment.configured.shutdown();
                expect( environment.listeners.count() ).toBe( 1 );
                environment.service.announce( "preQBExecute", { sql: "SELECT 2" } );
                expect( environment.telemetry.getSpans().len() ).toBe( 1 );
                environment.service.announce( "postQBExecute", data );
                expect( environment.telemetry.getSpans()[ 1 ].getStatuses() ).toBe( [ "ok" ] );
                expect( environment.telemetry.getScope() ).toBeEmpty();
                expect( environment.listeners ).toBeEmpty();
                environment.configured.shutdown();
                expect( environment.unregistered.names.len() ).toBe( 1 );
            } );
            it( "drains failed nested queries before unregistering the adapter", function() {
                var environment = makeEnvironment();
                var outer = { sql: "SELECT 1" };
                var inner = { sql: "SELECT 2" };
                environment.service.announce( "preQBExecute", outer );
                environment.service.announce( "preQBExecute", inner );
                environment.configured.shutdown();
                environment.service.announce( "onQBExecuteException", inner );
                expect( environment.listeners.count() ).toBe( 1 );
                expect( environment.telemetry.getScope().span ).toBe( environment.telemetry.getSpans()[ 1 ] );
                environment.service.announce( "onQBExecuteException", outer );
                environment.listener.postQBExecute( interceptData = outer );
                expect( environment.telemetry.getSpans()[ 1 ].getStatuses() ).toBe( [ "internal_error" ] );
                expect( environment.telemetry.getSpans()[ 2 ].getStatuses() ).toBe( [ "internal_error" ] );
                expect( environment.telemetry.getScope() ).toBeEmpty();
                expect( environment.listeners ).toBeEmpty();
                expect( environment.unregistered.names.len() ).toBe( 1 );
            } );
            it( "removes a partially installed listener when registration fails", function() {
                var removed = [];
                var listener = {};
                var adapter = new qb.models.Telemetry.QueryTelemetryAdapter( {
                    registerInterceptor: function( interceptorObject, interceptorName, customPoints ) {
                        listener = interceptorObject;
                        throw( type = "RegistrationFailure" );
                    },
                    unregister: function( name ) {
                        removed.append( name );
                    }
                } );
                var telemetry = new tests.resources.TelemetryRecorder();
                expect( function() {
                    adapter.configure( { telemetry: telemetry } );
                } ).toThrow( "RegistrationFailure" );
                expect( removed.len() ).toBe( 1 );
                listener.preQBExecute( interceptData = { sql: "SELECT 1" } );
                expect( telemetry.getSpans() ).toBeEmpty();
            } );
            it( "observes real successful and failed grammar executions without replacing database results or errors", function() {
                var environment = makeEnvironment();
                var grammar = new qb.models.Grammars.BaseGrammar();
                grammar.setInterceptorService( environment.service );
                var source = queryNew( "numberValue", "integer", [ { numberValue: 7 } ] );
                prepareMock( grammar ).$property( "telemetrySource", "variables", source );
                var result = grammar.runQuery(
                    sql = "SELECT numberValue FROM telemetrySource",
                    options = { dbtype: "query" }
                );
                expect( result.numberValue[ 1 ] ).toBe( 7 );
                var caught = {};
                var didThrow = false;
                try {
                    grammar.runQuery( sql = "SELECT missing FROM missing_table", options = { dbtype: "query" } );
                } catch ( any failure ) {
                    caught = failure;
                    didThrow = true;
                }
                expect( didThrow ).toBeTrue();
                if ( isObject( environment.failure.original ) ) {
                    expect( caught ).toBeSameInstanceAs( environment.failure.original );
                } else {
                    expect( caught ).toBe( environment.failure.original );
                }
                expect( environment.telemetry.getSpans()[ 1 ].getStatuses() ).toBe( [ "ok" ] );
                expect( environment.telemetry.getSpans()[ 2 ].getStatuses() ).toBe( [ "internal_error" ] );
                expect( environment.telemetry.getScope() ).toBeEmpty();
                environment.configured.shutdown();
            } );
        } );
    }

    private struct function makeEnvironment( string databaseSystem = "other" ) {
        var telemetry = new tests.resources.TelemetryRecorder();
        var listeners = structNew( "ordered" );
        var unregistered = { names: [] };
        var failure = {};
        var service = {
            registerInterceptor: function( interceptorObject, interceptorName, customPoints ) {
                listeners[ interceptorName ] = interceptorObject;
            },
            unregister: function( name ) {
                unregistered.names.append( name );
                listeners.delete( name );
            },
            announce: function( state, data ) {
                if ( state == "onQBExecuteException" && data.keyExists( "exception" ) ) failure.original = data.exception;
                for ( var name in listeners ) invoke( listeners[ name ], state, { interceptData: data } );
            }
        };
        var configured = new qb.models.Telemetry.QueryTelemetryAdapter( service ).configure( { telemetry: telemetry, databaseSystem: arguments.databaseSystem } );
        return {
            telemetry: telemetry,
            service: service,
            listeners: listeners,
            listener: listeners[ listeners.keyArray()[ 1 ] ],
            unregistered: unregistered,
            failure: failure,
            configured: configured
        };
    }

}
