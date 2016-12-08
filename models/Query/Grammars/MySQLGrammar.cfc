component extends="qb.models.Query.Grammars.Grammar" {

    private string function wrapValue( required any value ) {
        if ( value == "*" ) {
            return value;
        }
        return "`#value#`";
    }    

}