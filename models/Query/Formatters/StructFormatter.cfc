component accessors="true" {

    property name="utils";
    property name="options";

    public StructFormatter function init( any utils = new qb.models.Query.QueryUtils(), struct options = {} ) {
        variables.utils = arguments.utils;
        variables.options = arguments.options;
        return this;
    }

    public function toFormatter( struct options = {} ) {
        return new qb.models.Query.Formatters.StructFormatter( utils = variables.utils, options = arguments.options );
    }

    public struct function format( required any q ) {
        if (
            !variables.options.keyExists( "columnKey" ) || isNull( variables.options.columnKey ) || !len(
                variables.options.columnKey
            )
        ) {
            throw(
                type = "MissingColumnKey",
                message = "A columnKey option is required for the [struct] return formatter."
            );
        }

        return variables.utils.queryToStructOfStructs( arguments.q, variables.options.columnKey );
    }

}
