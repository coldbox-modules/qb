component accessors="true" {

    property name="scope";
    property name="spans";
    property name="failStart";
    property name="failFinish";

    function init() {
        variables.scope = {};
        variables.spans = [];
        variables.failStart = false;
        variables.failFinish = false;
        return this;
    }

    function scrubSQL( required string sql ) {
        return reReplace(
            arguments.sql,
            "'[^']*'|[0-9]+",
            "?",
            "all"
        );
    }

    function startSpan( required string name, required string operation, struct attributes = {} ) {
        if ( variables.failStart ) throw( type = "TelemetryFailure" );
        var span = new tests.resources.TelemetrySpan(
            arguments.name,
            arguments.operation,
            arguments.attributes,
            variables.failFinish
        );
        variables.spans.append( span );
        return span;
    }

}
