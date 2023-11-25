component singleton {

    property name="wirebox" inject="wirebox";
    property name="grammar";

    function autoDiscoverGrammar( any datasource = "" ) {
        if ( arguments.datasource.len() ) {
            cfdbinfo( type = "Version", name = "local.dbInfo", datasource = arguments.datasource );
        } else {
            cfdbinfo( type = "Version", name = "local.dbInfo" );
        }


        switch ( dbInfo.DATABASE_PRODUCTNAME ) {
            case "MySQL":
                return wirebox.getInstance( "MySQLGrammar@qb" );
            case "PostgreSQL":
                return wirebox.getInstance( "PostgresGrammar@qb" );
            case "Microsoft SQL Server":
                return wirebox.getInstance( "SQLServerGrammar@qb" );
            case "Oracle":
                return wirebox.getInstance( "OracleGrammar@qb" );
            case "SQLite":
                return wirebox.getInstance( "SQLiteGrammar@qb" );
            default:
                return wirebox.getInstance( "BaseGrammar@qb" );
        }
    }

    function onMissingMethod( missingMethodName, missingMethodArguments ) {
        if ( !structKeyExists( variables, "grammar" ) ) {
            variables.grammar = autoDiscoverGrammar(
                arguments.missingMethodArguments[ 2 ].keyExists( "datasource" ) ? arguments.missingMethodArguments[ 2 ].datasource : ""
            );
        }
        return invoke( variables.grammar, missingMethodName, missingMethodArguments );
    }

}
