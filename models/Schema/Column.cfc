component accessors="true" {

    property name="blueprint";

    property name="name";
    property name="type";
    property name="length" default="255";
    property name="precision";
    property name="nullable" default="false";
    property name="unsigned" default="false";
    property name="autoIncrement" default="false";
    property name="default" default="";
    property name="comment" default="";
    property name="unique" default="false";
    property name="values";

    function init( blueprint ) {
        setBlueprint( blueprint );
        variables.values = [];
        return this;
    }

    function comment( comment ) {
        setComment( comment );
        return this;
    }

    function default( value ) {
        setDefault( value );
        return this;
    }

    function nullable() {
        setNullable( true );
        return this;
    }

    function primaryKey( indexName ) {
        arguments.indexName = isNull( arguments.indexName ) ? "pk_#getBlueprint().getTable()#_#getName()#" : arguments.indexName;
        return getBlueprint().addIndex( type = "primary", columns = getName(), name = arguments.indexName );
    }

    function references( columns ) {
        arguments.columns = isArray( columns ) ? columns : [ columns ];
        return getBlueprint().addIndex(
            type = "foreign",
            columns = columns,
            foreignKey = [ getName() ],
            name = "fk_#getBlueprint().getTable()#_#getName()#"
        );
    }

    function unsigned() {
        setUnsigned( true );
        return this;
    }

    function unique() {
        setUnique( true );
        return this;
    }

    function hasPrecision() {
        return ! isNull( getPrecision() );
    }

}
