component extends="qb.models.Grammars.BaseGrammar" singleton accessors="true" {

    /**
     * The parameter limit for SQL Server grammar.
     */
    this.parameterLimit = 2000;

    /**
     * The different components of a select statement in the order of compilation.
     */
    variables.selectComponents = [
        "commonTables",
        "aggregate",
        "columns",
        "tableName",
        "lockType",
        "joins",
        "wheres",
        "groups",
        "havings",
        "unions",
        "orders",
        "offsetValue",
        "limitValue"
    ];


    /**
     * Creates a new SQL Server Query Grammar.
     *
     * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
     *
     * @return qb.models.Grammars.SqlServerGrammar
     */
    public SqlServerGrammar function init( qb.models.Query.QueryUtils utils ) {
        super.init( argumentCollection = arguments );

        variables.cteColumnsRequireParentheses = true;

        return this;
    }

    /**
     * Compile a Builder's query into an insert string.
     *
     * @query The Builder instance.
     * @columns The array of columns into which to insert.
     * @values The array of values to insert.
     *
     * @return string
     */
    public string function compileInsert( required query, required array columns, required array values ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var columnsString = arguments.columns
                .map( function( column ) {
                    return wrapColumn( column.formatted );
                } )
                .toList( ", " );
            var returningColumns = arguments.query
                .getReturning()
                .map( function( column ) {
                    if ( listLen( column, "." ) > 1 ) {
                        return column;
                    }
                    return "INSERTED." & wrapColumn( column );
                } )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " OUTPUT #returningColumns#" : "";
            var placeholderString = values
                .map( function( valueArray ) {
                    return "(" & valueArray
                        .map( function( item ) {
                            if ( getUtils().isExpression( item ) ) {
                                return item.getSQL();
                            } else {
                                return "?";
                            }
                        } )
                        .toList( ", " ) & ")";
                } )
                .toList( ", " );
            return trim(
                "INSERT INTO #wrapTable( query.getTableName() )# (#columnsString#)#returningClause# VALUES #placeholderString#"
            );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    private string function compileOuterApplyJoin( required QueryBuilder query, required JoinClause join ) {
        // OUTER APPLY ( <some-table-def> ) (AS)? <table-alias>
        var tableName = wrapTable( join.getTable() )
        if ( !reFindNoCase( "^\s*#trim( getTableAliasOperator() )#", tableName ) ) {
            // table alias operator is optional in MSSqlServer, but we'll provide it if it wasn't expanded via wrapTable.
            // Will `wrapTable` ever have emitted a table alias operator here?
            // n.b. `getTableAliasOperator()` is expected to have a leading and trailing space.
            tableName = "#getTableAliasOperator()##tableName#";
        }
        // `tableName` is expected to have at least a leading space.
        return "OUTER APPLY (#join.getLateralRawExpression()#)#tableName#";
    }

    private string function compileCrossApplyJoin( required QueryBuilder query, required JoinClause join ) {
        // CROSS APPLY ( <some-table-def> ) (AS)? <table-alias>
        var tableName = wrapTable( join.getTable() )
        if ( !reFindNoCase( "^\s*#trim( getTableAliasOperator() )#", tableName ) ) {
            // table alias operator is optional in MSSqlServer, but we'll provide it if it wasn't expanded via wrapTable.
            // Will `wrapTable` ever have emitted a table alias operator here?
            // n.b. `getTableAliasOperator()` is expected to have a leading and trailing space.
            tableName = "#getTableAliasOperator()##tableName#";
        }
        // `tableName` is expected to have at least a leading space.
        return "CROSS APPLY (#join.getLateralRawExpression()#)#tableName#";
    }

    private string function compileLateralJoin( required QueryBuilder query, required JoinClause join ) {
        throw(
            type = "UnsupportedOperation",
            message = "This grammar does not support LATERAL joins. Instead, use either OUTER APPLY or CROSS APPLY joins."
        );
    }

    /**
     * Compiles the Common Table Expressions (CTEs).
     *
     * @query The Builder instance.
     * @columns The selected columns.
     *
     * @return string
     */
    private string function compileCommonTables( required query, required array commonTables ) {
        var results = getCommonTableExpressionSQL(
            query = arguments.query,
            commonTables = arguments.commonTables,
            supportsRecursiveKeyword = false
        );

        // the semi-colon can avoid some issues with the JDBC drivers
        return ( results.len() ? ";" : "" ) & results;
    }

    /**
     * Compiles the columns portion of a sql statement.
     *
     * @query The Builder instance.
     * @columns The selected columns.
     *
     * @return string
     */
    private string function compileColumns( required query, required array columns ) {
        if ( !query.getAggregate().isEmpty() ) {
            return "";
        }
        var select = query.getDistinct() ? "SELECT DISTINCT " : "SELECT ";
        if ( !isNull( query.getLimitValue() ) && isNull( query.getOffsetValue() ) ) {
            select &= "TOP (#query.getLimitValue()#) ";
        }
        return select & columns.map( wrapColumn ).toList( ", " );
    }

    /**
     * Compiles the lock portion of a sql statement.
     *
     * @query The Builder instance.
     * @lockType The lock type to compile.
     *
     * @return string
     */
    private string function compileLockType( required query, required string lockType ) {
        switch ( arguments.lockType ) {
            case "nolock":
                return "WITH (NOLOCK)";
            case "shared":
                return "WITH (ROWLOCK,HOLDLOCK)";
            case "update":
                return "WITH (ROWLOCK,UPDLOCK,HOLDLOCK)";
            case "updateSkipLocked":
                return "WITH (ROWLOCK,UPDLOCK,READPAST)";
            case "custom":
                return arguments.query.getLockValue();
            case "none":
            default:
                return "";
        }
    }

    /**
     * Compiles the order by portion of a sql statement.
     *
     * @query The Builder instance.
     * @orders The where clauses.
     *
     * @return string
     */
    private string function compileOrders( required query, required array orders ) {
        if ( orders.isEmpty() ) {
            if ( isNull( query.getOffsetValue() ) ) {
                return "";
            }
            return "ORDER BY 1";
        }

        var orderBys = orders.map( function( orderBy ) {
            if ( orderBy.direction == "raw" ) {
                return orderBy.column.getSQL();
            } else if ( orderBy.keyExists( "query" ) ) {
                return "(#compileSelect( orderBy.query )#) #uCase( orderBy.direction )#";
            } else {
                return "#wrapColumn( orderBy.column )# #uCase( orderBy.direction )#";
            }
        } );

        return "ORDER BY #orderBys.toList( ", " )#";
    }

    /**
     * Compiles the offset portion of a sql statement.
     *
     * @query The Builder instance.
     * @offsetValue The offset value.
     *
     * @return string
     */
    private string function compileOffsetValue( required query, offsetValue ) {
        if ( isNull( query.getOffsetValue() ) ) {
            return "";
        }

        return "OFFSET #offsetValue# ROWS";
    }

    /**
     * Compiles the limit portion of a sql statement.
     *
     * @query The Builder instance.
     * @limitValue The limit clauses.
     *
     * @return string
     */
    private string function compileLimitValue( required query, limitValue ) {
        if ( !isNull( arguments.limitValue ) && !isNull( query.getOffsetValue() ) ) {
            return "FETCH NEXT #limitValue# ROWS ONLY";
        }
        return "";
    }

    /**
     * Parses and wraps a value from the Builder for use in a sql statement.
     *
     * @table The value to parse and wrap.
     *
     * @return string
     */
    function wrapValue( required any value ) {
        if ( !variables.shouldWrapValues ) {
            return arguments.value;
        }

        if ( value == "*" ) {
            return value;
        }

        arguments.value = reReplace( arguments.value, """", "", "all" );

        return "[#value#]";
    }

    /**
     * Compile a Builder's query into an update string.
     *
     * @query The Builder instance.
     * @columns The array of columns into which to insert.
     *
     * @return string
     */
    public string function compileUpdate( required query, required array columns, required struct updateMap ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var updateList = columns
                .map( function( column ) {
                    var value = updateMap[ column.original ];
                    var assignment = "?";
                    if ( utils.isExpression( value ) ) {
                        assignment = value.getSql();
                    } else if ( utils.isBuilder( value ) ) {
                        assignment = "(#value.toSQL()#)";
                    }
                    return "#wrapColumn( column.formatted )# = #assignment#";
                } )
                .toList( ", " );

            var updateTable = "";
            if ( !getUtils().isExpression( query.getTableName() ) ) {
                var parts = explodeTable( query.getTableName() );
                updateTable = parts.alias.len() ? wrapAlias( parts.alias ) : wrapTable( parts.table );
            } else {
                updateTable = query.getTableName().getSql();
            }
            var updateStatement = concatenate( [
                "UPDATE",
                isNull( query.getLimitValue() ) ? "" : "TOP (#query.getLimitValue()#)",
                updateTable,
                "SET",
                updateList
            ] );

            var returningColumns = arguments.query
                .getReturning()
                .map( function( column ) {
                    if ( getUtils().isExpression( column ) ) {
                        return trim( column.getSQL() );
                    }
                    if ( listLen( column, "." ) > 1 ) {
                        return column;
                    }
                    return "INSERTED." & wrapColumn( column );
                } )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " OUTPUT #returningColumns#" : "";

            if ( arguments.query.getJoins().isEmpty() ) {
                return trim( updateStatement & returningClause & " " & compileWheres( query, query.getWheres() ) );
            }

            return trim(
                updateStatement & returningClause & " FROM #wrapTable( query.getTableName() )# " & compileJoins(
                    arguments.query,
                    arguments.query.getJoins()
                ) & " " & compileWheres( query, query.getWheres() )
            );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Compile a Builder's query into a delete string.
     *
     * @query The Builder instance.
     *
     * @return string
     */
    public string function compileDelete( required QueryBuilder query ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var returningColumns = arguments.query
                .getReturning()
                .map( function( column ) {
                    if ( getUtils().isExpression( column ) ) {
                        return trim( column.getSQL() );
                    }
                    if ( listLen( column, "." ) > 1 ) {
                        return column;
                    }
                    return "DELETED." & wrapColumn( column );
                } )
                .toList( ", " );
            var returningClause = returningColumns != "" ? "OUTPUT #returningColumns#" : "";

            var hasJoins = !arguments.query.getJoins().isEmpty();

            return trim(
                arrayToList(
                    arrayFilter(
                        [
                            "DELETE",
                            hasJoins ? wrapTable( query.getTableName() ) : "",
                            "FROM",
                            wrapTable( query.getTableName() ),
                            returningClause,
                            hasJoins ? compileJoins( query, query.getJoins() ) : "",
                            compileWheres( query, query.getWheres() )
                        ],
                        function( sql ) {
                            return sql != "";
                        }
                    ),
                    " "
                )
            );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    public string function compileUpsert(
        required QueryBuilder qb,
        required array insertColumns,
        required array values,
        required array updateColumns,
        required any updates,
        required array target,
        QueryBuilder source,
        any deleteUnmatched = false
    ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.qb.getShouldWrapValues() );
            }

            var sourceString = "";
            var columnsString = arguments.insertColumns
                .map( function( column ) {
                    return wrapColumn( column.formatted );
                } )
                .toList( ", " );

            if ( !isNull( arguments.source ) ) {
                sourceString = "(#compileSelect( arguments.source )#) AS [qb_src]";
            } else {
                var placeholderString = arguments.values
                    .map( function( valueArray ) {
                        return "(" & valueArray
                            .map( function( item ) {
                                if ( getUtils().isExpression( item ) ) {
                                    return item.getSQL();
                                } else {
                                    return "?";
                                }
                            } )
                            .toList( ", " ) & ")";
                    } )
                    .toList( ", " );

                sourceString = "(VALUES #placeholderString#) AS [qb_src] (#columnsString#)";
            }

            var constraintString = arguments.target
                .map( function( column ) {
                    return "#wrapColumn( "qb_target.#column.formatted#" )# = #wrapColumn( "qb_src.#column.formatted#" )#";
                } )
                .toList( " AND " );

            var updateList = "";
            if ( isArray( arguments.updates ) ) {
                updateList = arguments.updates
                    .map( function( column ) {
                        return "#wrapColumn( column.formatted )# = #wrapColumn( "qb_src.#column.formatted#" )#";
                    } )
                    .toList( ", " );
            } else {
                updateList = arguments.updateColumns
                    .map( function( column ) {
                        var value = updates[ column.original ];
                        return "#wrapColumn( column.formatted )# = #utils.isExpression( value ) ? value.getSql() : "?"#";
                    } )
                    .toList( ", " );
            }
            var updateStatement = updateList == "" ? "" : " WHEN MATCHED THEN UPDATE SET #updateList#";

            var deleteStatement = "";
            if ( isBoolean( arguments.deleteUnmatched ) ) {
                if ( arguments.deleteUnmatched ) {
                    deleteStatement = " WHEN NOT MATCHED BY SOURCE THEN DELETE";
                }
            } else if ( utils.isBuilder( arguments.deleteUnmatched ) ) {
                var deleteRestrictionsStatement = replace(
                    compileWheres( arguments.deleteUnmatched, arguments.deleteUnmatched.getWheres() ),
                    "WHERE",
                    "AND",
                    "one"
                ) & " ";
                deleteStatement = " WHEN NOT MATCHED BY SOURCE #deleteRestrictionsStatement#THEN DELETE";
            }

            var returningColumns = arguments.qb
                .getReturning()
                .map( function( column ) {
                    if ( getUtils().isExpression( column ) ) {
                        return trim( column.getSQL() );
                    }
                    if ( listLen( column, "." ) > 1 ) {
                        return column;
                    }
                    return "INSERTED." & wrapColumn( column );
                } )
                .toList( ", " );

            var returningClause = returningColumns != "" ? " OUTPUT #returningColumns#" : "";

            return "MERGE #wrapTable( arguments.qb.getTableName() )# AS [qb_target] USING #sourceString# ON #constraintString##updateStatement# WHEN NOT MATCHED BY TARGET THEN INSERT (#columnsString#) VALUES (#columnsString#)#deleteStatement##returningClause#;";
        } finally {
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function generateType( column, blueprint ) {
        if ( column.getComputedType() != "none" ) {
            return "";
        }
        return super.generateType( argumentCollection = arguments );
    }

    function generateNullConstraint( column ) {
        return ( column.getIsNullable() || column.getComputedType() != "none" ) ? "" : "NOT NULL";
    }

    function modifyUnsigned( column ) {
        return "";
    }

    function generateComputed( column ) {
        if ( column.getComputedType() == "none" ) {
            return "";
        }

        return "AS (#column.getComputedDefinition()#)" & ( column.getComputedType() == "virtual" ? "" : " PERSISTED" );
    }

    function generateAutoIncrement( column ) {
        return column.getAutoIncrement() ? "IDENTITY" : "";
    }

    function generateDefault( column, blueprint ) {
        return column.getDefaultValue() != "" ? "CONSTRAINT #wrapValue( "df_#blueprint.getTable()#_#column.getName()#" )# DEFAULT #wrapDefaultType( column )#" : "";
    }

    function wrapDefaultType( column ) {
        switch ( column.getType() ) {
            case "boolean":
                return column.getDefaultValue() ? 1 : 0;
            case "char":
            case "string":
                return "'#column.getDefaultValue()#'";
            default:
                return column.getDefaultValue();
        }
    }

    function generateComment( column ) {
        return "";
    }

    function compileDropColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            if ( isSimpleValue( commandParameters.name ) ) {
                return concatenate( [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "DROP COLUMN",
                    wrapColumn( commandParameters.name )
                ] );
            } else {
                var statements = [
                    arrayToList(
                        [
                            "ALTER TABLE",
                            wrapTable( blueprint.getTable() ),
                            "DROP COLUMN",
                            wrapColumn( commandParameters.name.getName() )
                        ],
                        " "
                    )
                ];
                if ( commandParameters.name.getDefaultValue() != "" ) {
                    statements.prepend(
                        "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( "df_#blueprint.getTable()#_#commandParameters.name.getName()#" )#"
                    );
                }
                return statements;
            }
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileRenameTable( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "EXEC sp_rename #wrapTable( blueprint.getTable() )#, #wrapTable( commandParameters.to )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileRenameColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "EXEC sp_rename #wrapValue( blueprint.getTable() & "." & commandParameters.from )#, #wrapColumn( commandParameters.to.getName() )#, [COLUMN]";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "EXEC sp_rename #wrapValue( commandParameters.from )#, #wrapValue( commandParameters.to )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropIndex( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "DROP INDEX #wrapTable( blueprint.getTable() )#.#wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileModifyColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "ALTER COLUMN",
                compileCreateColumn( commandParameters.to, blueprint )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function getAllTableNames( options, schema = "" ) {
        var sql = "SELECT #wrapColumn( "table_name" )# FROM #wrapTable( "information_schema.tables" )#";
        var args = [];
        if ( schema != "" ) {
            sql &= " WHERE #wrapColumn( "table_schema" )# = ?";
            args.append( schema );
        }
        var tablesQuery = runQuery( sql, args, options, "query" );
        var tables = [];
        for ( var table in tablesQuery ) {
            arrayAppend( tables, table[ "table_name" ] );
        }
        return tables;
    }

    function compileDropAllObjects( required struct options, string schema = "", SchemaBuilder sb ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.sb.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.sb.getShouldWrapValues() );
            }

            var tables = getAllTableNames( options, schema );
            var tableList = arrayToList(
                arrayMap( tables, function( table ) {
                    return wrapTable( table );
                } ),
                ", "
            );
            return arrayFilter(
                [
                    "DECLARE @sql NVARCHAR(MAX) = N'';
                SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_NAME(parent_object_id))
                    + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
                FROM sys.foreign_keys;

                EXEC sp_executesql @sql;",
                    arrayIsEmpty( tables ) ? "" : "DROP TABLE #tableList#"
                ],
                function( sql ) {
                    return sql != "";
                }
            );
        } finally {
            if ( !isNull( arguments.sb.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function typeBigInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "BIGINT";
    }

    function typeBit( column ) {
        return "BIT";
    }

    function typeBoolean( column ) {
        return "BIT";
    }

    public string function getBooleanSqlType() {
        return "CF_SQL_BIT";
    }

    function typeChar( column ) {
        return "NCHAR(#column.getLength()#)";
    }

    function typeDatetime( column ) {
        return typeTimestamp( column );
    }

    function typeDatetimeTz( column ) {
        return typeTimestampTz( column );
    }

    function typeEnum( column, blueprint ) {
        blueprint.appendIndex(
            type = "check",
            name = "enum_#blueprint.getTable()#_#column.getName()#",
            columns = column
        );
        return "NVARCHAR(255)";
    }

    function typeDecimal( column ) {
        return "DECIMAL(#column.getLength()#,#column.getPrecision()#)";
    }

    function typeFloat( column ) {
        if ( column.getPrecision() != 0 ) {
            return "FLOAT(#column.getPrecision()#)";
        }

        return "FLOAT";
    }

    function typeGUID( column ) {
        return "uniqueidentifier";
    }

    function typeInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "INTEGER";
    }

    function typeJson( column ) {
        return "NVARCHAR(MAX)";
    }

    function typeLongText( column ) {
        return "VARCHAR(MAX)";
    }

    function typeUnicodeLongText( column ) {
        return "NVARCHAR(MAX)";
    }

    function typeMediumInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "INTEGER";
    }

    function typeMediumText( column ) {
        return "VARCHAR(MAX)";
    }

    function typeMoney( column ) {
        return "MONEY";
    }

    function typeSmallMoney( column ) {
        return "SMALLMONEY";
    }

    function typeUnicodeMediumText( column ) {
        return "NVARCHAR(MAX)";
    }

    function typeSmallInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "SMALLINT";
    }

    function typeText( column ) {
        return "VARCHAR(MAX)";
    }

    function typeUnicodeText( column ) {
        return "NVARCHAR(MAX)";
    }

    function typeTimestamp( column ) {
        return "DATETIME2#isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"#";
    }

    function typeTimestampTz( column ) {
        return "DATETIMEOFFSET";
    }

    function typeTinyInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "TINYINT";
    }

}
