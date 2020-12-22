component singleton {

    property name="wirebox" inject="wirebox";
    property name="grammar";

    function autoDiscoverGrammar() {
        cfdbinfo( type = "Version", name = "local.dbInfo" );

        switch ( dbInfo.DATABASE_PRODUCTNAME ) {
            case "MySQL":
                return wirebox.getInstance( "MySQLGrammar@qb" );
            case "PostgreSQL":
                return wirebox.getInstance( "PostgresGrammar@qb" );
            case "Microsoft SQL Server":
                return wirebox.getInstance( "SQLServerGrammar@qb" );
            case "Oracle":
                return wirebox.getInstance( "OracleGrammar@qb" );
            default:
                return wirebox.getInstance( "BaseGrammar@qb" );
        }
    }

    function onMissingMethod( missingMethodName, missingMethodArguments ) {
        if ( !structKeyExists( variables, "grammar" ) ) {
            variables.grammar = autoDiscoverGrammar();
        }
        return invoke( variables.grammar, missingMethodName, missingMethodArguments );
    }

}
