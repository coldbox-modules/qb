component displayname="Expression" accessors="true" {

    property name="sql" type="string" default="";

    function init( required string sql ) {
        variables.sql = arguments.sql;
    }

}