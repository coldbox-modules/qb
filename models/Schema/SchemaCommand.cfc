component accessors="true" {

    property name="type";
    property name="parameters";

    function init( required type , parameters = {} ) {
        setType( type );
        setParameters( parameters );
        return this;
    }

}
