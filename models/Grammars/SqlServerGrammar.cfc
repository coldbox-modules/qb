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
        "from",
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
        var columnsString = arguments.columns
            .map( function( column ) {
                return wrapColumn( column.formatted );
            } )
            .toList( ", " );
        var returningColumns = query
            .getReturning()
            .map( function( column ) {
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
            "INSERT INTO #wrapTable( query.getFrom() )# (#columnsString#)#returningClause# VALUES #placeholderString#"
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
        if ( value == "*" ) {
            return value;
        }
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

        var updateStatement = arrayToList(
            arrayFilter(
                [
                    "UPDATE",
                    isNull( query.getLimitValue() ) ? "" : "TOP (#query.getLimitValue()#)",
                    wrapTable( query.getFrom() ),
                    "SET",
                    updateList
                ],
                function( str ) {
                    return str != "";
                }
            ),
            " "
        );

        if ( arguments.query.getJoins().isEmpty() ) {
            return trim( updateStatement & " " & compileWheres( query, query.getWheres() ) );
        }

        return trim(
            updateStatement & " FROM #wrapTable( query.getFrom() )# " & compileJoins(
                arguments.query,
                arguments.query.getJoins()
            ) & " " & compileWheres( query, query.getWheres() )
        );
    }

    public string function compileUpsert(
        required QueryBuilder qb,
        required array insertColumns,
        required array values,
        required array updateColumns,
        required any updates,
        required array target
    ) {
        var columnsString = arguments.insertColumns
            .map( function( column ) {
                return wrapColumn( column.formatted );
            } )
            .toList( ", " );

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

        return "MERGE #wrapTable( arguments.qb.getFrom() )# AS [qb_target] USING (VALUES #placeholderString#) AS [qb_src] (#columnsString#) ON #constraintString# WHEN MATCHED THEN UPDATE SET #updateList# WHEN NOT MATCHED BY TARGET THEN INSERT (#columnsString#) VALUES (#columnsString#);";
    }

    function generateType( column, blueprint ) {
        if ( column.getComputedType() != "none" ) {
            return "";
        }
        return super.generateType( argumentCollection = arguments );
    }

    function generateNullConstraint( column ) {
        return ( column.getNullable() || column.getComputedType() != "none" ) ? "" : "NOT NULL";
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
        return column.getDefault() != "" ? "CONSTRAINT #wrapValue( "df_#blueprint.getTable()#_#column.getName()#" )# DEFAULT #wrapDefaultType( column )#" : "";
    }

    function wrapDefaultType( column ) {
        switch ( column.getType() ) {
            case "boolean":
                return column.getDefault() ? 1 : 0;
            case "char":
            case "string":
                return "'#column.getDefault()#'";
            default:
                return column.getDefault();
        }
    }

    function generateComment( column ) {
        return "";
    }

    function compileDropColumn( blueprint, commandParameters ) {
        if ( isSimpleValue( commandParameters.name ) ) {
            return arrayToList(
                arrayFilter(
                    [
                        "ALTER TABLE",
                        wrapTable( blueprint.getTable() ),
                        "DROP COLUMN",
                        wrapColumn( commandParameters.name )
                    ],
                    function( item ) {
                        return item != "";
                    }
                ),
                " "
            );
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
            if ( commandParameters.name.getDefault() != "" ) {
                statements.prepend(
                    "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( "df_#blueprint.getTable()#_#commandParameters.name.getName()#" )#"
                );
            }
            return statements;
        }
    }

    function compileRenameTable( blueprint, commandParameters ) {
        return "EXEC sp_rename #wrapTable( blueprint.getTable() )#, #wrapTable( commandParameters.to )#";
    }

    function compileRenameColumn( blueprint, commandParameters ) {
        return "EXEC sp_rename #wrapValue( blueprint.getTable() & "." & commandParameters.from )#, #wrapColumn( commandParameters.to.getName() )#, [COLUMN]";
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        return "EXEC sp_rename #wrapValue( commandParameters.from )#, #wrapValue( commandParameters.to )#";
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
    }

    function compileModifyColumn( blueprint, commandParameters ) {
        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "ALTER COLUMN",
                    compileCreateColumn( commandParameters.to, blueprint )
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
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

    function compileDropAllObjects( options, schema = "" ) {
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

    function typeChar( column ) {
        return "NCHAR(#column.getLength()#)";
    }

    function typeDatetime( column ) {
        return typeTimestamp( column );
    }

    function typeDatetimeTz( column ) {
        return typeTimestampTz( column );
    }

    function typeUUID( column ) {
        return "uniqueidentifier";
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
        return "DATETIME2";
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
