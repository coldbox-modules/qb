/** Optional execution telemetry. This adapter does not require a telemetry module to be installed. */
component accessors="true" {

    property name="interceptorService" inject="box:interceptorService";

    function init( any interceptorService ) {
        if ( !isNull( arguments.interceptorService ) ) variables.interceptorService = arguments.interceptorService;
        return this;
    }

    struct function configure( required struct context ) {
        var service = variables.interceptorService;
        var name = "qbQueryTelemetry" & replace( createUUID(), "-", "", "all" );
        var whenDrained = function() {
            service.unregister( name );
        };
        var listener = new QueryTelemetryListener(
            telemetry = arguments.context.telemetry,
            executionKey = "_" & name,
            databaseSystem = arguments.context.databaseSystem ?: "other",
            onDrained = whenDrained
        );
        try {
            service.registerInterceptor(
                interceptorObject = listener,
                interceptorName = name,
                customPoints = "preQBExecute,postQBExecute,onQBExecuteException"
            );
        } catch ( any registrationFailure ) {
            try {
                listener.close();
            } catch ( any ignored ) {
            }
            rethrow;
        }
        return {
            mode: "custom",
            shutdown: function() {
                listener.close();
            }
        };
    }

}
