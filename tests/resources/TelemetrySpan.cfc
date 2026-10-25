component accessors="true" {

    property name="name";
    property name="operation";
    property name="attributes";
    property name="statuses";

    function init(
        required string name,
        required string operation,
        required struct attributes,
        boolean failFinish = false
    ) {
        variables.name = arguments.name;
        variables.operation = arguments.operation;
        variables.attributes = arguments.attributes;
        variables.statuses = [];
        variables.failFinish = arguments.failFinish;
        return this;
    }

    function finish( required string status ) {
        variables.statuses.append( arguments.status );
        if ( variables.failFinish ) throw( type = "TelemetryFailure" );
    }

}
