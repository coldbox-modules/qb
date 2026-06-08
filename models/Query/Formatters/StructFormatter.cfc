component accessors="true" {

    property name="utils";

    public StructFormatter function init( any utils = new qb.models.Query.QueryUtils() ) {
        variables.utils = arguments.utils;
        return this;
    }

    public function toFormatter( struct options = {} ) {
        return new qb.models.Query.Formatters.StructReturnFormatter( variables.utils, arguments.options );
    }

}
