component accessors="true" {

    property name="utils";

    public StructFormatter function init( any utils = new qb.models.Query.QueryUtils() ) {
        variables.utils = arguments.utils;
        return this;
    }

    public function toFormatter( struct options = {} ) {
        var formatterOptions = structCopy( arguments.options );
        var formatterUtils = variables.utils;

        return function( q ) {
            if (
                !formatterOptions.keyExists( "columnKey" ) || isNull( formatterOptions.columnKey ) || !len(
                    formatterOptions.columnKey
                )
            ) {
                throw(
                    type = "MissingColumnKey",
                    message = "A columnKey option is required for the [struct] return formatter."
                );
            }

            return formatterUtils.queryToStructOfStructs( arguments.q, formatterOptions.columnKey );
        };
    }

}
