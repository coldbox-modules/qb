component displayname="Expression" {

    function init( required string sql ) {
        variables.sql = arguments.sql;
    }

    function getSQL() {
        return sql;
    }

}