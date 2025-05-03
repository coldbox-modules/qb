/**
 * Schema Builder for creating database objects (tables, fields, indexes, etc.)
 */
component accessors="true" {

    /**
     * The specific grammar that will compile the builder statements.
     * e.g. MySQLGrammar, OracleGrammar, etc.
     */
    property name="grammar";

    /**
     * The schema to execute the generated statements against, if any.
     */
    property name="defaultSchema";

    /**
     * A struct of default options for the query builder.
     * These options will be merged with any options passed.
     */
    property name="defaultOptions";

    /**
     * Default length for strings used by the Blueprint.
     * Can be overridden with `setDefaultStringLength( length )`
     */
    property name="defaultStringLength" default="255";

    /**
     * The query log for this builder.
     */
    property name="queryLog" type="array";

    /**
     * Create a new schema builder.
     *
     * @grammar The specific grammar that will compile the builder statements.
     * @defaultOptions  The default queryExecute options to use for this
     *                  builder. This will be merged in each execution.
     *
     * @returns The schema builder instance.
     */
    public SchemaBuilder function init(
        required any grammar = new qb.models.Grammars.BaseGrammar(),
        struct defaultOptions = {},
        string defaultSchema = ""
    ) {
        variables.grammar = arguments.grammar;
        variables.defaultOptions = arguments.defaultOptions;
        variables.defaultSchema = arguments.defaultSchema;
        variables.pretending = false;
        variables.queryLog = [];
        variables.shouldWrapValues = javacast( "null", "" );
        return this;
    }

    public SchemaBuilder function pretend() {
        variables.pretending = true;
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
    public Blueprint function create(
        required string table,
        required function callback,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "create" );
        blueprint.setCreating( true );
        blueprint.setTable( arguments.table );
        arguments.callback( blueprint );
        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        [],
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
                } );
        }
        return blueprint;
    }

    public Blueprint function createView(
        required string view,
        required function callback,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var query = new models.Query.QueryBuilder( getGrammar() );
        arguments.callback( query );

        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "createView", { query: query } );
        blueprint.setCreating( true );
        blueprint.setTable( arguments.view );

        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        query.getBindings(),
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
                } );
        }

        return blueprint;
    }

    public Blueprint function createAs(
        required string newTableName,
        required function callback,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var query = new models.Query.QueryBuilder( getGrammar() );
        arguments.callback( query );

        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "createAs", { query: query } );
        blueprint.setCreating( true );
        blueprint.setTable( arguments.newTableName );

        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        query.getBindings(),
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
                } );
        }

        return blueprint;
    }

    public Blueprint function alterView(
        required string view,
        required function callback,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var query = new models.Query.QueryBuilder( getGrammar() );
        arguments.callback( query );

        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "alterView", { query: query } );
        blueprint.setCreating( true );
        blueprint.setTable( arguments.view );

        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        query.getBindings(),
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
                } );
        }

        return blueprint;
    }

    public Blueprint function dropView( required string view, struct options = {}, boolean execute = true ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "dropView" );
        blueprint.setTable( arguments.view );

        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        query.getBindings(),
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
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
    public Blueprint function drop( required string table, struct options = {}, boolean execute = true ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "drop" );
        blueprint.setTable( arguments.table );
        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        [],
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
                } );
        }
        return blueprint;
    }

    /**
     * Truncate an existing table in the database.
     *
     * @table    The name of the table to truncate.
     * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
     * @execute  Flag to immediately execute the statement.  Default: `true`.
     *
     * @returns  The blueprint instance
     */
    public Blueprint function truncate( required string table, struct options = {}, boolean execute = true ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "truncate" );
        blueprint.setTable( arguments.table );
        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        [],
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
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
    public Blueprint function dropIfExists( required string table, struct options = {}, boolean execute = true ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.addCommand( "drop" );
        blueprint.setTable( arguments.table );
        blueprint.setIfExists( true );
        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        [],
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
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
    public Blueprint function alter(
        required string table,
        required function callback,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.setTable( arguments.table );
        arguments.callback( blueprint );
        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        [],
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
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
    public Blueprint function rename(
        required string from,
        required string to,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var blueprint = new Blueprint(
            this,
            getGrammar(),
            arguments.options,
            getDefaultSchema()
        );
        blueprint.setTable( arguments.from );
        blueprint.addCommand( "renameTable", { to: arguments.to } );
        if ( arguments.execute ) {
            blueprint
                .toSql()
                .each( function( statement ) {
                    getGrammar().runQuery(
                        statement,
                        [],
                        options,
                        "result",
                        variables.pretending,
                        function( data ) {
                            variables.queryLog.append( duplicate( data ) );
                        }
                    );
                } );
        }
        return blueprint;
    }

    /**
     * Rename an existing table in the database.
     * Alias for `rename`
     *
     * @from     The current name of the table.
     * @to       The new name of the table.
     * @options  A struct of options to forward to the `queryExecute` call. Default: `{}`.
     * @execute  Flag to immediately execute the statement.  Default: `true`.
     *
     * @returns  The blueprint instance
     */
    public Blueprint function renameTable(
        required string from,
        required string to,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        return rename( argumentCollection = arguments );
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
    public any function hasTable(
        required string name,
        string schema = variables.defaultSchema,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var args = [ listLast( arguments.name, "." ) ];
        if ( arguments.schema != "" ) {
            arrayAppend( args, arguments.schema );
        }
        var sql = getGrammar().compileTableExists( arguments.name, arguments.schema );
        if ( arguments.execute ) {
            var q = getGrammar().runQuery(
                sql,
                args,
                arguments.options,
                "query",
                variables.pretending
            );
            return isDefined( "q.RecordCount" ) ? q.RecordCount > 0 : false;
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
    public any function hasColumn(
        required string table,
        required string column,
        string schema = variables.defaultSchema,
        struct options = {},
        boolean execute = true
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var args = [ listLast( arguments.table, "." ), arguments.column ];
        if ( arguments.schema != "" ) {
            arrayAppend( args, arguments.schema );
        }
        var sql = getGrammar().compileColumnExists( arguments.table, arguments.column, arguments.schema );
        if ( arguments.execute ) {
            var q = getGrammar().runQuery(
                sql,
                args,
                arguments.options,
                "query",
                variables.pretending,
                function( data ) {
                    variables.queryLog.append( duplicate( data ) );
                }
            );
            return isDefined( "q.RecordCount" ) ? q.RecordCount > 0 : false;
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
    public array function dropAllObjects(
        struct options = {},
        boolean execute = true,
        string schema = variables.defaultSchema
    ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var statements = getGrammar().compileDropAllObjects( arguments.options, arguments.schema, this );
        if ( arguments.execute ) {
            statements.each( function( statement ) {
                getGrammar().runQuery(
                    statement,
                    [],
                    options,
                    "result",
                    variables.pretending,
                    function( data ) {
                        variables.queryLog.append( duplicate( data ) );
                    }
                );
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
    public string function enableForeignKeyConstraints( struct options = {}, boolean execute = true ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var statement = getGrammar().compileEnableForeignKeyConstraints( arguments.options );
        if ( arguments.execute ) {
            getGrammar().runQuery(
                statement,
                [],
                arguments.options,
                "result",
                variables.pretending,
                function( data ) {
                    variables.queryLog.append( duplicate( data ) );
                }
            );
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
    public string function disableForeignKeyConstraints( struct options = {}, boolean execute = true ) {
        structAppend( arguments.options, variables.defaultOptions, false );
        var statement = getGrammar().compileDisableForeignKeyConstraints( arguments.options );
        if ( arguments.execute ) {
            getGrammar().runQuery(
                statement,
                [],
                arguments.options,
                "result",
                variables.pretending,
                function( data ) {
                    variables.queryLog.append( duplicate( data ) );
                }
            );
        }
        return statement;
    }

    public SchemaBuilder function withoutWrappingValues() {
        variables.shouldWrapValues = false;
        return this;
    }

    public SchemaBuilder function withWrappingValues() {
        variables.shouldWrapValues = true;
        return this;
    }

    public any function getShouldWrapValues() {
        if ( isNull( variables.shouldWrapValues ) ) {
            return javacast( "null", "" );
        }
        return variables.shouldWrapValues;
    }

}
