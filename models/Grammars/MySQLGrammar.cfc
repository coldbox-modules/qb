component extends="qb.models.Grammars.BaseGrammar" {

    /**
    * Parses and wraps a value from the Builder for use in a sql statement.
    *
    * @table The value to parse and wrap.
    *
    * @return string
    */
    private string function wrapValue( required any value ) {
        if ( value == "*" ) {
            return value;
        }
        return "`#value#`";
    }

    function compileRenameTable( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "RENAME TABLE",
            wrapTable( blueprint.getTable() ),
            "TO",
            wrapTable( commandParameters.to )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileTableExists( tableName ) {
        return "SELECT 1 FROM `information_schema`.`tables` WHERE `table_name` = ?";
    }

    function compileColumnExists( table, column ) {
        return "SELECT 1 FROM `information_schema`.`columns` WHERE `table_name` = ? AND `column_name` = ?";
    }

}
