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

}
