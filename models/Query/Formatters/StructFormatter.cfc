component accessors="true" {

    property name="utils";
    property name="columnKey";

    public StructFormatter function init( any utils = new qb.models.Query.QueryUtils(), struct options = {} ) {
        variables.utils = arguments.utils;
        variables.columnKey = arguments.options.keyExists( "columnKey" ) && !isNull( arguments.options.columnKey )
         ? arguments.options.columnKey
         : javacast( "null", "" );
        return this;
    }

    public function toFormatter( struct options = {} ) {
        return new qb.models.Query.Formatters.StructFormatter( utils = variables.utils, options = arguments.options );
    }

    public struct function format( required any q ) {
        if ( isNull( variables.columnKey ) || !len( variables.columnKey ) ) {
            throw(
                type = "MissingColumnKey",
                message = "A columnKey option is required for the [struct] return formatter."
            );
        }

        return variables.utils.queryToStructOfStructs( arguments.q, variables.columnKey );
    }

}
