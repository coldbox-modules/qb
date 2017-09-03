component accessors="true" {

    property name="blueprint";

    property name="name";
    property name="type";
    property name="length" default="255";
    property name="precision" default="10";
    property name="nullable" default="false";
    property name="unsigned" default="false";
    property name="autoIncrement" default="false";
    property name="default" default="";
    property name="comment" default="";
    property name="values";

    function init( blueprint ) {
        setBlueprint( blueprint );
        variables.values = [];
        return this;
    }

    function comment( comment ) {
        return setComment( comment );
    }

    function default( value ) {
        return setDefault( value );
    }

    function nullable() {
        return setNullable( true );
    }

    function references( column ) {
        arguments.type = "foreign";
        arguments.foreignKey = getName();
        return getBlueprint().addIndex( argumentCollection = arguments );
    }

    function unsigned() {
        return setUnsigned( true );
    }

}
