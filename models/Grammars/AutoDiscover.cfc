component singleton {

    property name="wirebox" inject="wirebox";
    property name="grammar";
    property name="shouldWrapValues";

    function autoDiscoverGrammar() {
        cfdbinfo( type = "Version", name = "local.dbInfo" );

        var discoveredGrammar = "";
        switch ( dbInfo.DATABASE_PRODUCTNAME ) {
            case "MySQL":
            case "MariaDB":
                discoveredGrammar = wirebox.getInstance( "MySQLGrammar@qb" );
                break;
            case "Derby":
                discoveredGrammar = wirebox.getInstance( "DerbyGrammar@qb" );
                break;
            case "PostgreSQL":
                discoveredGrammar = wirebox.getInstance( "PostgresGrammar@qb" );
                break;
            case "Microsoft SQL Server":
                discoveredGrammar = wirebox.getInstance( "SQLServerGrammar@qb" );
                break;
            case "Oracle":
                discoveredGrammar = wirebox.getInstance( "OracleGrammar@qb" );
                break;
            case "SQLite":
                discoveredGrammar = wirebox.getInstance( "SQLiteGrammar@qb" );
                break;
            default:
                discoveredGrammar = wirebox.getInstance( "BaseGrammar@qb" );
        }

        return discoveredGrammar;
    }

    public AutoDiscover function setShouldWrapValues( required boolean shouldWrapValues ) {
        variables.shouldWrapValues = arguments.shouldWrapValues;
        if ( structKeyExists( variables, "grammar" ) && !isNull( variables.grammar ) ) {
            variables.grammar.setShouldWrapValues( arguments.shouldWrapValues );
        }
        return this;
    }

    public any function getResolvedGrammar() {
        if ( !structKeyExists( variables, "grammar" ) || isNull( variables.grammar ) ) {
            variables.grammar = autoDiscoverGrammar();
            if ( structKeyExists( variables, "shouldWrapValues" ) && !isNull( variables.shouldWrapValues ) ) {
                variables.grammar.setShouldWrapValues( variables.shouldWrapValues );
            }
        }
        return variables.grammar;
    }

    function onMissingMethod( missingMethodName, missingMethodArguments ) {
        return invoke( getResolvedGrammar(), missingMethodName, missingMethodArguments );
    }

}
