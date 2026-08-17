component extends="qb.models.Grammars.BaseGrammar" singleton accessors="true" {

    public boolean function supportsBulkInsert() {
        return true;
    }

    public struct function prepareBulkInsertValues(
        required array values,
        required array columns,
        required struct sqlTypes
    ) {
        var grammar = this;
        var normalizedColumns = arguments.columns;
        var serializedValues = arguments.values.map( function( row ) {
            var serializedRow = {};
            normalizedColumns.each( function( column ) {
                if ( !row.keyExists( column.original ) || isNull( row[ column.original ] ) ) {
                    serializedRow[ column.original ] = javacast( "null", "" );
                    return;
                }
                var binding = getUtils().extractBinding( row[ column.original ], grammar );
                serializedRow[ column.original ] = binding.null ? javacast( "null", "" ) : binding.value;
            } );
            return serializedRow;
        } );

        var bulkValues = arguments.values;
        var explicitSqlTypes = arguments.sqlTypes;
        normalizedColumns.each( function( column ) {
            var columnValues = bulkValues.map( function( row ) {
                return row.keyExists( column.original ) ? row[ column.original ] : javacast( "null", "" );
            } );
            var sqlType = explicitSqlTypes.keyExists( column.original )
             ? explicitSqlTypes[ column.original ]
             : resolveWhereInBulkSqlType( getUtils().inferSqlType( columnValues, grammar ) );
            sqlType = trim( sqlType );
            if (
                sqlType == "" ||
                !reFindNoCase(
                    "^[a-z][a-z0-9_]*(?:\s+[a-z][a-z0-9_]*)*(?:\s*\(\s*(?:max|\d+)(?:\s*,\s*\d+)?\s*\))?$",
                    sqlType
                )
            ) {
                throw( type = "InvalidSQLType", message = "Invalid SQL type [#sqlType#] for a bulk insert." );
            }
            column.bulkSqlType = sqlType;
        } );

        return {
            "columns": normalizedColumns,
            "binding": getUtils().extractBinding(
                { value: serializeJSON( serializedValues ), cfsqltype: "LONGVARCHAR" },
                grammar
            )
        };
    }

    public string function compileBulkInsert( required any query, required array columns ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var columnsString = arguments.columns.map( ( column ) => wrapColumn( column.formatted ) ).toList( ", " );
            var returningColumns = arguments.query
                .getReturning()
                .map( function( column ) {
                    if ( column.type == "raw" ) {
                        return trim( column.value.getSQL() );
                    }
                    if ( listLen( column.value, "." ) > 1 ) {
                        return column.value;
                    }
                    return "INSERTED." & wrapColumn( column );
                } )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " OUTPUT #returningColumns#" : "";
            var withColumns = arguments.columns
                .map( function( column ) {
                    var escapedPath = replace(
                        replace( column.original, "\", "\\", "all" ),
                        """",
                        "\""",
                        "all"
                    );
                    escapedPath = replace( escapedPath, "'", "''", "all" );
                    return "#wrapColumn( column.formatted )# #column.bulkSqlType# '$.""#escapedPath#""'";
                } )
                .toList( ", " );

            return "INSERT INTO #wrapTable( query.getTableName() )# (#columnsString#)#returningClause# SELECT #columnsString# FROM OPENJSON(?) WITH (#withColumns#)";
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    public string function compileWhereInBulkValues( required string sqlType ) {
        return "SELECT [value] FROM OPENJSON(?) WITH ([value] #arguments.sqlType# '$')";
    }

    public string function resolveWhereInBulkSqlType( required string sqlType ) {
        var normalizedType = super.resolveWhereInBulkSqlType( arguments.sqlType );
        switch ( normalizedType ) {
            case "CHAR":
            case "NCHAR":
            case "VARCHAR":
            case "NVARCHAR":
            case "LONGVARCHAR":
            case "LONGNVARCHAR":
            case "CLOB":
            case "NCLOB":
                return "NVARCHAR(MAX)";
            case "TIMESTAMP":
                return "DATETIME2";
            case "BOOLEAN":
                return "BIT";
            default:
                return normalizedType;
        }
    }

    public string function compileJsonScalar( required struct jsonPath ) {
        return "JSON_VALUE(#wrapJsonColumn( arguments.jsonPath )#, '#buildJsonPath( arguments.jsonPath.path )#')";
    }

    public string function compileJsonContains( required struct jsonPath ) {
        if ( arguments.jsonPath.keyExists( "nullValue" ) && arguments.jsonPath.nullValue ) {
            return "EXISTS (SELECT 1 FROM OPENJSON(#wrapJsonColumn( arguments.jsonPath )#, '#buildJsonPath( arguments.jsonPath.path )#') WHERE [type] = 0 AND ? IS NULL)";
        }
        return "? IN (SELECT [value] FROM OPENJSON(#wrapJsonColumn( arguments.jsonPath )#, '#buildJsonPath( arguments.jsonPath.path )#'))";
    }

    public string function compileJsonExists( required struct jsonPath ) {
        if ( arguments.jsonPath.path.isEmpty() ) {
            return "#wrapJsonColumn( arguments.jsonPath )# IS NOT NULL";
        }
        var path = duplicate( arguments.jsonPath.path );
        var key = path.pop();
        var openJson = path.isEmpty()
         ? "OPENJSON(#wrapJsonColumn( arguments.jsonPath )#)"
         : "OPENJSON(#wrapJsonColumn( arguments.jsonPath )#, '#buildJsonPath( path )#')";
        return "'#replace( key, "'", "''", "all" )#' IN (SELECT [key] FROM #openJson#)";
    }

    public string function compileJsonLength( required struct jsonPath ) {
        return "(SELECT COUNT(*) FROM OPENJSON(#wrapJsonColumn( arguments.jsonPath )#, '#buildJsonPath( arguments.jsonPath.path )#'))";
    }

    /**
     * Compile independently ordered and limited UNION branches as derived queries.
     * SQL Server requires this shape for ORDER BY to determine each branch's TOP rows.
     */
    public string function compileSelect( required QueryBuilder query ) {
        if ( !shouldCompileOrderedUnionBranches( arguments.query ) ) {
            return super.compileSelect( arguments.query );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var commonTables = arguments.query.getCommonTables();
            var rootQuery = arguments.query.clone();
            var unions = rootQuery.getUnions();
            rootQuery.setUnions( [] );
            rootQuery.setCommonTables( [] );

            var sql = [
                commonTables.isEmpty() ? "" : compileCommonTables( arguments.query, commonTables ),
                "SELECT * FROM (#super.compileSelect( rootQuery )#) AS #wrapValue( "qb_union_0" )#"
            ];

            unions.each( function( union, index ) {
                if ( union.query.getOrders().len() && !isLimitedQuery( union.query ) ) {
                    throw(
                        type = "OrderByNotAllowed",
                        message = "The ORDER BY clause is not allowed in a UNION statement.",
                        detail = "SQL Server only allows an ORDER BY clause in a UNION branch when TOP, OFFSET, or FETCH limits that branch."
                    );
                }

                var unionOperator = union.all ? "UNION ALL" : "UNION";
                sql.append(
                    "#unionOperator# SELECT * FROM (#compileSelect( union.query )#) AS #wrapValue( "qb_union_#index#" )#"
                );
            } );

            return trim( concatenate( sql ) );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    private boolean function shouldCompileOrderedUnionBranches( required QueryBuilder query ) {
        if ( arguments.query.getUnions().isEmpty() ) {
            return false;
        }

        return arguments.query.getUnions().some( ( union ) => union.query.getOrders().len() );
    }

    public array function getSelectBindingOrder( required QueryBuilder query ) {
        if ( !shouldCompileOrderedUnionBranches( arguments.query ) ) {
            return super.getSelectBindingOrder( arguments.query );
        }

        return [
            "commonTables",
            "update",
            "insert",
            "aggregate",
            "select",
            "from",
            "join",
            "where",
            "groupBy",
            "having",
            "orderBy",
            "union"
        ];
    }

    public array function getUpdateBindingOrder( required QueryBuilder query ) {
        return [
            "commonTables",
            "from",
            "update",
            "join",
            "where",
            "groupBy",
            "having",
            "orderBy",
            "union"
        ];
    }

    private boolean function isOrderedLimitedQuery( required QueryBuilder query ) {
        return arguments.query.getOrders().len() && isLimitedQuery( arguments.query );
    }

    private boolean function isLimitedQuery( required QueryBuilder query ) {
        return !isNull( arguments.query.getLimitValue() ) || !isNull( arguments.query.getOffsetValue() );
    }

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
        "limitValue",
        "forClause"
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

    private string function compileForClause( required QueryBuilder query, any forClause ) {
        if ( isNull( arguments.forClause ) ) {
            return "";
        }

        return "FOR #forClause.getSQL()#";
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
                    if ( column.type == "raw" ) {
                        return trim( column.value.getSQL() );
                    }
                    if ( listLen( column.value, "." ) > 1 ) {
                        return column.value;
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
            } else if ( orderBy.direction == "random" ) {
                return orderByRandom();
            } else if ( orderBy.keyExists( "query" ) ) {
                return "(#compileSelect( orderBy.query )#) #uCase( orderBy.direction )#";
            } else {
                return "#wrapColumn( orderBy.column )# #uCase( orderBy.direction )#";
            }
        } );

        return "ORDER BY #orderBys.toList( ", " )#";
    }

    private string function orderByRandom() {
        return "NEWID()";
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
        if ( !getShouldWrapValues() ) {
            return arguments.value;
        }

        if ( value == "*" ) {
            return value;
        }

        if ( len( arguments.value ) >= 2 && left( arguments.value, 1 ) == """" && right( arguments.value, 1 ) == """" ) {
            arguments.value = mid( arguments.value, 2, len( arguments.value ) - 2 );
        }
        arguments.value = replace( arguments.value, "]", "]]", "all" );

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
        if ( !arguments.query.getOrders().isEmpty() || !isNull( arguments.query.getOffsetValue() ) ) {
            throw(
                type = "UnsupportedOperation",
                message = "SQL Server does not support direct ORDER BY or OFFSET clauses on UPDATE statements."
            );
        }
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
            if ( arguments.query.getAlias() != "" ) {
                updateTable = wrapAlias( getTablePrefix() & arguments.query.getAlias() );
            } else if ( !getUtils().isExpression( query.getTableName() ) ) {
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
                    if ( column.type == "raw" ) {
                        return trim( column.value.getSQL() );
                    }
                    if ( listLen( column.value, "." ) > 1 ) {
                        return column.value;
                    }
                    return "INSERTED." & wrapColumn( column );
                } )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " OUTPUT #returningColumns#" : "";

            if ( arguments.query.getJoins().isEmpty() && arguments.query.getAlias() == "" ) {
                return trim(
                    compileCommonTables( query, query.getCommonTables() ) & " " & updateStatement & returningClause & " " & compileWheres(
                        query,
                        query.getWheres()
                    )
                );
            }

            return trim(
                concatenate( [
                    compileCommonTables( query, query.getCommonTables() ),
                    updateStatement & returningClause,
                    "FROM #wrapQueryTable( query )#",
                    compileJoins( arguments.query, arguments.query.getJoins() ),
                    compileWheres( query, query.getWheres() )
                ] )
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
        if ( !arguments.query.getOrders().isEmpty() || !isNull( arguments.query.getOffsetValue() ) ) {
            throw(
                type = "UnsupportedOperation",
                message = "SQL Server does not support direct ORDER BY or OFFSET clauses on DELETE statements."
            );
        }
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var returningColumns = arguments.query
                .getReturning()
                .map( function( column ) {
                    if ( column.type == "raw" ) {
                        return trim( column.value.getSQL() );
                    }
                    if ( listLen( column.value, "." ) > 1 ) {
                        return column.value;
                    }
                    return "DELETED." & wrapColumn( column );
                } )
                .toList( ", " );
            var returningClause = returningColumns != "" ? "OUTPUT #returningColumns#" : "";

            var hasJoins = !arguments.query.getJoins().isEmpty();
            var hasAlias = arguments.query.getAlias() != "";
            var topClause = isNull( arguments.query.getLimitValue() )
             ? ""
             : "TOP (#arguments.query.getLimitValue()#)";

            if ( !hasJoins && !hasAlias ) {
                return trim(
                    arrayToList(
                        arrayFilter(
                            [
                                compileCommonTables( query, query.getCommonTables() ),
                                "DELETE",
                                topClause,
                                "FROM",
                                wrapQueryTable( query ),
                                returningClause,
                                compileWheres( query, query.getWheres() )
                            ],
                            function( sql ) {
                                return sql != "";
                            }
                        ),
                        " "
                    )
                );
            }

            return trim(
                arrayToList(
                    arrayFilter(
                        [
                            compileCommonTables( query, query.getCommonTables() ),
                            "DELETE",
                            topClause,
                            hasAlias
                             ? wrapAlias( getTablePrefix() & query.getAlias() )
                             : wrapTable( query.getTableName(), false ),
                            returningClause,
                            "FROM",
                            wrapQueryTable( query ),
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
        any deleteUnmatched = false,
        boolean matchNulls = false
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

            var constraintString = compileUpsertTargetConstraint( arguments.target, arguments.matchNulls );

            var updateList = "";
            if ( isArray( arguments.updates ) ) {
                updateList = arguments.updates
                    .map( function( column ) {
                        return "#wrapColumn( column.formatted )# = #wrapColumn( { "type": "simple", "value": "qb_src.#column.formatted.value#" } )#";
                    } )
                    .toList( ", " );
            } else {
                updateList = arguments.updateColumns
                    .map( function( column ) {
                        var equalsClause = "?";
                        if (
                            !isNull( updates[ column.original ] ) && getUtils().isExpression(
                                updates[ column.original ]
                            )
                        ) {
                            equalsClause = updates[ column.original ].getSQL();
                        }
                        return "#wrapColumn( column.formatted )# = #equalsClause#";
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
                    if ( column.type == "raw" ) {
                        return trim( column.value.getSQL() );
                    }
                    if ( listLen( column.value, "." ) > 1 ) {
                        return column.value;
                    }
                    return "INSERTED." & wrapColumn( column );
                } )
                .toList( ", " );

            var returningClause = returningColumns != "" ? " OUTPUT #returningColumns#" : "";
            return trim(
                compileCommonTables( arguments.qb, arguments.qb.getCommonTables() ) &
                " MERGE #wrapTable( arguments.qb.getTableName() )# AS [qb_target] USING #sourceString# ON #constraintString##updateStatement# WHEN NOT MATCHED BY TARGET THEN INSERT (#columnsString#) VALUES (#columnsString#)#deleteStatement##returningClause#;"
            );
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
        return column.getHasDefaultValue() ? "CONSTRAINT #wrapValue( "df_#listLast( blueprint.getTable(), "." )#_#column.getName()#" )# DEFAULT #wrapDefaultType( column )#" : "";
    }

    function wrapDefaultType( column ) {
        if ( shouldQuoteDefaultValue( arguments.column ) ) {
            return quoteStringLiteral( column.getDefaultValue() );
        }
        switch ( column.getType() ) {
            case "boolean":
                return column.getDefaultValue() ? 1 : 0;
            default:
                return column.getDefaultValue();
        }
    }

    function generateComment( column ) {
        return "";
    }

    function compileCreateView( blueprint, commandParameters ) {
        var query = arguments.commandParameters[ "query" ];
        if ( query.getCommonTables().isEmpty() ) {
            return super.compileCreateView( argumentCollection = arguments );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var selectStatement = compileSelect( query );
            if ( selectStatement.left( 1 ) == ";" ) {
                selectStatement = mid( selectStatement, 2, selectStatement.len() - 1 );
            }
            return "CREATE VIEW #wrapTable( blueprint.getTable() )# AS #selectStatement#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileCreateAs( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var query = commandParameters[ "query" ];
            return insertIntoOuterSelect( compileSelect( query ), wrapTable( blueprint.getTable() ) );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Inserts a SQL Server INTO clause after the outer query's select list.
     * Tokens inside CTEs, subqueries, literals, identifiers, and comments are ignored.
     */
    private string function insertIntoOuterSelect( required string sql, required string table ) {
        var position = 1;
        var depth = 0;
        var state = "sql";
        var sqlLength = arguments.sql.len();
        var hasOuterSelect = false;
        var selectListBoundaries = [
            " FROM ",
            " UNION ",
            " ORDER BY ",
            " OFFSET ",
            " FOR ",
            " OPTION "
        ];

        while ( position <= sqlLength ) {
            var character = arguments.sql.mid( position, 1 );
            var nextCharacter = position < sqlLength ? arguments.sql.mid( position + 1, 1 ) : "";

            if ( state == "lineComment" ) {
                if ( character == chr( 10 ) || character == chr( 13 ) ) {
                    state = "sql";
                }
                position++;
                continue;
            }
            if ( state == "blockComment" ) {
                if ( character == "*" && nextCharacter == "/" ) {
                    position += 2;
                    state = "sql";
                } else {
                    position++;
                }
                continue;
            }
            if ( state != "sql" ) {
                var closingCharacter = state == "singleQuote" ? "'" : ( state == "doubleQuote" ? """" : "]" );
                if ( character == closingCharacter ) {
                    if ( nextCharacter == closingCharacter ) {
                        position += 2;
                    } else {
                        position++;
                        state = "sql";
                    }
                } else {
                    position++;
                }
                continue;
            }

            if ( character == "-" && nextCharacter == "-" ) {
                position += 2;
                state = "lineComment";
                continue;
            }
            if ( character == "/" && nextCharacter == "*" ) {
                position += 2;
                state = "blockComment";
                continue;
            }
            if ( character == "'" || character == """" || character == "[" ) {
                state = character == "'" ? "singleQuote" : ( character == """" ? "doubleQuote" : "bracketQuote" );
                position++;
                continue;
            }
            if ( character == "(" ) {
                depth++;
                position++;
                continue;
            }
            if ( character == ")" ) {
                depth = max( 0, depth - 1 );
                position++;
                continue;
            }

            if ( depth == 0 && !hasOuterSelect && position + 5 <= sqlLength ) {
                var previousCharacter = position == 1 ? "" : arguments.sql.mid( position - 1, 1 );
                var characterAfterSelect = position + 6 > sqlLength ? "" : arguments.sql.mid( position + 6, 1 );
                hasOuterSelect = compareNoCase( arguments.sql.mid( position, 6 ), "SELECT" ) == 0 &&
                ( previousCharacter == "" || previousCharacter == ";" || reFind( "\s", previousCharacter ) ) &&
                ( characterAfterSelect == "" || reFind( "\s", characterAfterSelect ) );
            }

            if ( depth == 0 && hasOuterSelect ) {
                for ( var boundary in selectListBoundaries ) {
                    if (
                        position + len( boundary ) - 1 <= sqlLength &&
                        compareNoCase( arguments.sql.mid( position, len( boundary ) ), boundary ) == 0
                    ) {
                        return arguments.sql.left( position - 1 ) &
                        " INTO #arguments.table#" &
                        mid( arguments.sql, position, sqlLength - position + 1 );
                    }
                }
            }

            position++;
        }

        if ( hasOuterSelect ) {
            return rTrim( arguments.sql ) & " INTO #arguments.table#";
        }

        throw( type = "InvalidCreateAsQuery", message = "SQL Server CREATE AS queries require an outer SELECT clause." );
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
                    wrapColumn( { "type": "simple", "value": commandParameters.name } )
                ] );
            } else {
                var statements = [
                    arrayToList(
                        [
                            "ALTER TABLE",
                            wrapTable( blueprint.getTable() ),
                            "DROP COLUMN",
                            wrapColumn( { "type": "simple", "value": commandParameters.name.getName() } )
                        ],
                        " "
                    )
                ];
                if ( commandParameters.name.getHasDefaultValue() ) {
                    statements.prepend(
                        "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( "df_#listLast( blueprint.getTable(), "." )#_#commandParameters.name.getName()#" )#"
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

            return "EXEC sp_rename #quoteUnicodeStringLiteral( blueprint.getTable() )#, #quoteUnicodeStringLiteral( commandParameters.to )#";
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

            return "EXEC sp_rename #quoteUnicodeStringLiteral( blueprint.getTable() & "." & commandParameters.from )#, #quoteUnicodeStringLiteral( commandParameters.to.getName() )#, #quoteUnicodeStringLiteral( "COLUMN" )#";
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

            return "EXEC sp_rename #quoteUnicodeStringLiteral( commandParameters.from )#, #quoteUnicodeStringLiteral( commandParameters.to )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    private string function quoteUnicodeStringLiteral( required string value ) {
        return "N'" & replace( arguments.value, "'", "''", "all" ) & "'";
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
            var originalDefaultValue = commandParameters.to.getDefaultValue();
            var originalHasDefaultValue = commandParameters.to.getHasDefaultValue();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            if ( !originalHasDefaultValue ) {
                return concatenate( [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "ALTER COLUMN",
                    compileCreateColumn( commandParameters.to, blueprint )
                ] );
            }

            commandParameters.to.setDefaultValue( "" );
            commandParameters.to.setHasDefaultValue( false );

            var wrappedTable = wrapTable( blueprint.getTable(), false );
            var wrappedColumn = wrapValue( commandParameters.to.getName() );
            var escapedTable = replace( wrappedTable, "'", "''", "all" );
            var escapedColumn = replace(
                commandParameters.to.getName(),
                "'",
                "''",
                "all"
            );
            var alterColumnSql = concatenate( [
                "ALTER TABLE",
                wrappedTable,
                "ALTER COLUMN",
                compileCreateColumn( commandParameters.to, blueprint )
            ] );

            commandParameters.to.setDefaultValue( originalDefaultValue );
            commandParameters.to.setHasDefaultValue( originalHasDefaultValue );

            return [
                "DECLARE @objectId INT = OBJECT_ID(N'#escapedTable#'), @constraintName SYSNAME, @schemaName SYSNAME, @tableName SYSNAME; SELECT @constraintName = [dc].[name], @schemaName = OBJECT_SCHEMA_NAME([dc].[parent_object_id]), @tableName = OBJECT_NAME([dc].[parent_object_id]) FROM [sys].[default_constraints] AS [dc] INNER JOIN [sys].[columns] AS [c] ON [c].[default_object_id] = [dc].[object_id] WHERE [dc].[parent_object_id] = @objectId AND [c].[name] = N'#escapedColumn#'; IF @constraintName IS NOT NULL EXEC(N'ALTER TABLE ' + QUOTENAME(@schemaName) + N'.' + QUOTENAME(@tableName) + N' DROP CONSTRAINT ' + QUOTENAME(@constraintName))",
                alterColumnSql,
                concatenate( [
                    "ALTER TABLE",
                    wrappedTable,
                    "ADD CONSTRAINT",
                    wrapValue( "df_#listLast( blueprint.getTable(), "." )#_#commandParameters.to.getName()#" ),
                    "DEFAULT",
                    wrapDefaultType( commandParameters.to ),
                    "FOR",
                    wrappedColumn
                ] )
            ];
        } finally {
            commandParameters.to.setDefaultValue( originalDefaultValue );
            commandParameters.to.setHasDefaultValue( originalHasDefaultValue );
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function getAllTableNames( options, schema = "" ) {
        var sql = "SELECT #wrapColumn( { "type": "simple", "value": "table_name" } )#, #wrapColumn( { "type": "simple", "value": "table_schema" } )# FROM #wrapTable( "information_schema.tables" )#";
        var args = [];
        if ( schema != "" ) {
            sql &= " WHERE #wrapColumn( { "type": "simple", "value": "table_schema" } )# = ?";
            args.append( schema );
        }
        sql &= "#arguments.schema == "" ? " WHERE" : " AND"# #wrapColumn( { "type": "simple", "value": "table_type" } )# = 'BASE TABLE'";
        var tablesQuery = runQuery( sql, args, options, "query" );
        var tables = [];
        for ( var table in tablesQuery ) {
            arrayAppend( tables, "#table[ "table_schema" ]#.#table[ "table_name" ]#" );
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
            var foreignKeySchemaFilter = arguments.schema == "" ? "" : " WHERE OBJECT_SCHEMA_NAME(parent_object_id) = #quoteUnicodeStringLiteral( arguments.schema )#";
            return arrayFilter(
                [
                    "DECLARE @sql NVARCHAR(MAX) = N'';
                SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
                    + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
                FROM sys.foreign_keys#foreignKeySchemaFilter#;

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

    function typeBinary( column ) {
        return "VARBINARY(MAX)";
    }

    function typeBit( column ) {
        return "BIT";
    }

    function typeBoolean( column ) {
        return "BIT";
    }

    public string function getBooleanSqlType() {
        return "BIT";
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
            name = "enum_#listLast( blueprint.getTable(), "." )#_#column.getName()#",
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

    function typeJsonb( column ) {
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
