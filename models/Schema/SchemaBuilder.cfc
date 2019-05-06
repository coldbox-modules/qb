/**
* Schema Builder for creating database objects (tables, fields, indexes, etc.)
*/
component accessors="true" singleton {

    /**
    * The specific grammar that will compile the builder statements.
    * e.g. MySQLGrammar, OracleGrammar, etc.
    */
    property name="grammar";

    /**
    * Default length for strings used by the Blueprint.
    * Can be overridden with `setDefaultStringLength( length )`
    */
    property name="defaultStringLength" default="255";

    /**
    * Create a new schema builder.
    *
    * @grammar The specific grammar that will compile the builder statements.
    *
    * @returns The schema builder instance.
    */
    function init( grammar ) {
        variables.grammar = arguments.grammar;
        return this;
    }

    /**
    * Create a new table in the database.
    *
    * @table    The name of the table to create.
    * @callback A callback to define the structure of the table. The callback is passed an
    *           instance of `Blueprint` as the only argument.
    * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
    * @execute  Flag to immediately execute the statement.  Default: `true`.
    *
    * @returns  The blueprint instance
    */
    function create( table, callback, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.addCommand( "create" );
        blueprint.setCreating( true );
        blueprint.setTable( table );
        callback( blueprint );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    /**
    * Drop an existing table in the database.
    *
    * @table    The name of the table to drop.
    * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
    * @execute  Flag to immediately execute the statement.  Default: `true`.
    *
    * @returns  The blueprint instance
    */
    function drop( table, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.addCommand( "drop" );
        blueprint.setTable( table );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    /**
    * Drop an existing table if it exists in the database.
    *
    * @table    The name of the table to drop.
    * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
    * @execute  Flag to immediately execute the statement.  Default: `true`.
    *
    * @returns  The blueprint instance
    */
    function dropIfExists( table, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.addCommand( "drop" );
        blueprint.setTable( table );
        blueprint.setIfExists( true );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    /**
    * Alter an existing table in the database.
    *
    * @table    The name of the table to alter.
    * @callback A callback to define the changes for the table. The callback is passed an
    *           instance of `Blueprint` as the only argument.
    * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
    * @execute  Flag to immediately execute the statement.  Default: `true`.
    *
    * @returns  The blueprint instance
    */
    function alter( table, callback, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.setTable( table );
        callback( blueprint );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    /**
    * Rename an existing table in the database.
    *
    * @from     The current name of the table.
    * @to       The new name of the table.
    * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
    * @execute  Flag to immediately execute the statement.  Default: `true`.
    *
    * @returns  The blueprint instance
    */
    function rename( from, to, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.setTable( from );
        blueprint.addCommand( "renameTable", { to = to } );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    /**
    * Check if a table exists in the database.
    *
    * @name     The name of the table to check.
    * @schema   The name of the schema to check.  If blank, checks all schemas.
    * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
    * @execute  Flag to immediately execute the statement.  Default: `true`.
    *
    * @returns  The blueprint instance
    */
    function hasTable( name, schema = "", options = {}, execute = true ) {
        var args = [ name ];
        if ( schema != "" ) {
            arrayAppend( args, schema );
        }
        var sql = getGrammar().compileTableExists( name, schema );
        if ( execute ) {
            var q = getGrammar().runQuery( sql, args, options, "query" );
            return q.RecordCount > 0;
        }
        return sql;
    }

    /**
    * Check if a column exists in a provided table in the database.
    *
    * @table    The name of the table to check for the column.
    * @column   The name of the column to check.
    * @schema   The name of the schema to check.  If blank, checks all schemas.
    * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
    * @execute  Flag to immediately execute the statement.  Default: `true`.
    *
    * @returns  The blueprint instance
    */
    function hasColumn( table, column, schema = "", options = {}, execute = true ) {
        var args = [ table, column ];
        if ( schema != "" ) {
            arrayAppend( args, schema );
        }
        var sql = getGrammar().compileColumnExists( table, column, schema );
        if ( execute ) {
            var q = getGrammar().runQuery( sql, args, options, "query" );
            return q.RecordCount > 0;
        }
        return sql;
    }

    /**
     * Drops all objects in a database.
     *
     * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
     * @execute  Flag to immediately execute the statement.  Default: `true`.
     *
     * @returns The array of executed statements.
     */
    function dropAllObjects( options = {}, execute = true, schema = "" ) {
        var statements = getGrammar().compileDropAllObjects( options, schema );
        if ( execute ) {
            statements.each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return statements;
    }

    /**
     * Enables the foreign key constraints for a database.
     *
     * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
     * @execute  Flag to immediately execute the statement.  Default: `true`.
     *
     * @returns The executed sql statement.
     */
    function enableForeignKeyConstraints( options = {}, execute = true ) {
        var statement = getGrammar().compileEnableForeignKeyConstraints( options );
        if ( execute ) {
            getGrammar().runQuery( statement, [], options, "result" );
        }
        return statement;
    }

    /**
     * Disables the foreign key constraints for a database.
     *
     * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
     * @execute  Flag to immediately execute the statement.  Default: `true`.
     *
     * @returns The executed sql statement.
     */
    function disableForeignKeyConstraints( options = {}, execute = true ) {
        var statement = getGrammar().compileDisableForeignKeyConstraints( options );
        if ( execute ) {
            getGrammar().runQuery( statement, [], options, "result" );
        }
        return statement;
    }

}
