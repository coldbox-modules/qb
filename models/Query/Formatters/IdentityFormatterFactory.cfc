/**
 * Creates the identity formatter used by query and none return formats.
 */
component {

    public function toFormatter( struct options = {} ) {
        return format;
    }

    public any function format( required any q ) {
        return arguments.q;
    }

}
