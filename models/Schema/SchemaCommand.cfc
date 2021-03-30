component accessors="true" {

    property name="type";
    property name="parameters";

    function init( required string type, struct parameters = {} ) {
        setType( type );
        setParameters( parameters );
        return this;
    }

}
