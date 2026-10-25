# Optional query telemetry

qb ships `QueryTelemetryAdapter@qb` for applications that explicitly opt in to execution tracing. The adapter observes qb's `preQBExecute`, `postQBExecute`, and `onQBExecuteException` events. qb does not install a telemetry client, choose an exporter, or require Sentry.

With a Sentry version supporting configurable query adapters:

```cfml
// Select the optional execution adapter shipped by qb.
moduleSettings.sentry.queryAdapter = "QueryTelemetryAdapter@qb";

// Supply the technical database system recorded on query spans.
moduleSettings.sentry.databaseSystem = "postgresql";
```

The telemetry client still controls its DSN, sampling, SQL sanitization, and delivery. The adapter only passes scrubbed SQL, the operation `db.query`, and the configured `db.system` attribute to the client. It never exports query bindings, options, results, or exception contents. Pretend executions do not produce spans. Native engine tracing is an alternative to this adapter; qb does not assume it is the application's only query mechanism.

## Adapter contract

`configure(context)` accepts a telemetry object and an optional database-system name:

```cfml
configured = adapter.configure( {
    // The telemetry object owns scopes, SQL scrubbing, spans, and export policy.
    telemetry: telemetry,
    // A technical database-system value; defaults to "other".
    databaseSystem: "postgresql"
} );

// After application work has stopped, remove this registration's query listeners.
configured.shutdown();
```

The object supplies `getScope()`, `setScope(scope)`, `scrubSQL(sql)`, and `startSpan(name,operation,attributes)`. A span supplies `finish(status)`. `configure()` returns `{mode:"custom",shutdown:callback}`. The optional `applicationName` in a consumer's setup context is accepted but is not exported; the injected application's interceptor service already scopes the registration.

Each configuration owns a uniquely named interceptor. Shutdown is idempotent, blocks new observations, and removes only that registration after observed queries complete. Success/error completion hooks remain registered until the in-flight count reaches zero, preserving span completion and scope restoration. No execution registry is retained by the singleton. A failed registration attempts to remove its partial registration before rethrowing. Shutdown does not cancel database calls or wait synchronously for them; a query that never completes can keep its completion hooks registered.

Execution state lives on qb's query event data. Nested qb executions restore their enclosing scopes; repeated completion callbacks cannot finish an execution twice. Observer failures do not replace a query result or database exception. The `manualQuerySpan` scope marker suppresses duplicate manual/native observations; an adapter-owned token permits nested qb spans while an enclosing explicit manual wrapper suppresses them.

Applications using qb outside ColdBox can pass a compatible interceptor service to the adapter constructor. The service must support `registerInterceptor(interceptorObject,interceptorName,customPoints)` and `unregister(name)`, and must be the same service used by the grammar's execution events. No adapter is installed automatically.
