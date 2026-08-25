/**
 * Creates the array return formatter without nested factory closures.
 */
component {

    public ArrayFormatterFactory function init( any utils = new qb.models.Query.QueryUtils() ) {
        variables.utils = arguments.utils;
        return this;
    }

    public function toFormatter( struct options = {} ) {
        return function( q ) {
            return variables.utils.queryToArrayOfStructs( arguments.q );
        };
    }

}
