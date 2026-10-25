/** Keeps each query's span on that execution's event data, never on the shared listener. */
component {

    function init(
        required any telemetry,
        required string executionKey,
        required function onDrained,
        string databaseSystem = "other"
    ) {
        variables.telemetry = arguments.telemetry;
        variables.executionKey = arguments.executionKey;
        variables.databaseSystem = arguments.databaseSystem;
        variables.closed = createObject( "java", "java.util.concurrent.atomic.AtomicBoolean" ).init( false );
        variables.unregistered = createObject( "java", "java.util.concurrent.atomic.AtomicBoolean" ).init( false );
        variables.inFlight = createObject( "java", "java.util.concurrent.atomic.AtomicInteger" ).init( 0 );
        variables.onDrained = arguments.onDrained;
        return this;
    }

    function close() {
        variables.closed.set( true );
        unregisterWhenDrained();
    }

    function preQBExecute( event, interceptData ) {
        if ( ( arguments.interceptData.pretend ?: false ) || !acquireExecution() ) return;
        var observed = false;
        try {
            var current = variables.telemetry.getScope();
            // Native listeners skip an already observed query. Our token still permits nested qb executions.
            if (
                current.keyExists( "manualQuerySpan" ) &&
                ( !isSimpleValue( current.manualQuerySpan ) || current.manualQuerySpan != variables.executionKey )
            )
                return;
            if ( arguments.interceptData.keyExists( variables.executionKey ) ) return;
            var span = variables.telemetry.startSpan(
                variables.telemetry.scrubSQL( arguments.interceptData.sql ),
                "db.query",
                { "db.system": variables.databaseSystem }
            );
            arguments.interceptData[ variables.executionKey ] = {
                span: span,
                previous: current,
                completed: createObject( "java", "java.util.concurrent.atomic.AtomicBoolean" ).init( false )
            };
            observed = true;
            var next = {};
            for ( var key in current ) next[ key ] = current[ key ];
            next.span = span;
            next.manualQuerySpan = variables.executionKey;
            variables.telemetry.setScope( next );
        } catch ( any ignored ) {
            // Observability must not prevent a query from executing.
        } finally {
            if ( !observed ) releaseExecution();
        }
    }

    function postQBExecute( event, interceptData ) {
        complete( arguments.interceptData, "ok" );
    }

    function onQBExecuteException( event, interceptData ) {
        complete( arguments.interceptData, "internal_error" );
    }

    private function complete( required struct data, required string status ) {
        try {
            if ( !arguments.data.keyExists( variables.executionKey ) ) return;
            var execution = arguments.data[ variables.executionKey ];
            if ( !execution.completed.compareAndSet( false, true ) ) return;
            arguments.data.delete( variables.executionKey );
            try {
                execution.span.finish( arguments.status );
            } finally {
                restoreExecution( execution );
            }
        } catch ( any ignored ) {
            // Preserve the result or original database error, including when telemetry fails.
        }
    }

    private function restoreExecution( required struct execution ) {
        try {
            variables.telemetry.setScope( arguments.execution.previous );
        } finally {
            releaseExecution();
        }
    }

    private boolean function acquireExecution() {
        if ( variables.closed.get() ) return false;
        variables.inFlight.incrementAndGet();
        if ( variables.closed.get() ) {
            releaseExecution();
            return false;
        }
        return true;
    }

    private function releaseExecution() {
        variables.inFlight.decrementAndGet();
        try {
            unregisterWhenDrained();
        } catch ( any ignored ) {
            // An unregister failure during completion must not replace a query result or exception.
        }
    }

    private function unregisterWhenDrained() {
        if (
            variables.closed.get() && variables.inFlight.get() == 0 && variables.unregistered.compareAndSet(
                false,
                true
            )
        ) {
            try {
                variables.onDrained();
            } catch ( any failure ) {
                variables.unregistered.set( false );
                rethrow;
            }
        }
    }

}
