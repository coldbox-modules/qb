component accessors="true" {

    property name="type";
    property name="name";
    property name="foreignKey";
    property name="columns";
    property name="table";
    property name="onUpdate" default="NONE";
    property name="onDelete" default="NONE";

    function init() {
        variables.columns = [];
        return this;
    }

    function setColumns( columns ) {
        variables.columns = isArray( arguments.columns ) ? arguments.columns : [ arguments.columns ];
        return this;
    }

}
