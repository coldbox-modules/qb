component extends="qb.models.Grammars.BaseGrammar" singleton {

    /**
     * The different components of a select statement in the order of compilation.
     */
    variables.selectComponents = [
        "commonTables",
        "aggregate",
        "columns",
        "tableName",
        "joins",
        "wheres",
        "groups",
        "havings",
        "unions",
        "orders",
        "offsetValue",
        "limitValue",
        "lockType"
    ];

    /**
     * Runs a query through `queryExecute`.
     * This function exists so that platform-specific grammars can override it if needed.
     *
     * @sql The sql string to execute.
     * @bindings The bindings to apply to the query.
     * @options Any options to pass to `queryExecute`. Default: {}.
     *
     * @return any
     */
    public any function runQuery( sql, bindings, options ) {
        var result = super.runQuery( argumentCollection = arguments );
        if ( isQuery( result ) && result.recordCount > 0 ) {
            return utils.queryRemoveColumns( result, "QB_RN" );
        }
        return result;
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
            case "shared":
            case "update":
            case "updateSkipLocked":
                return "FOR UPDATE";
            case "custom":
                return query.getLockValue();
            default:
                return ""; // Oracle grammar adds the other lock types as an additional statement before the select statement.
        }
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
        return getCommonTableExpressionSQL(
            query = arguments.query,
            commonTables = arguments.commonTables,
            supportsRecursiveKeyword = false
        );
    }

    /**
     * Compiles the Common Table Expressions (CTEs).
     *
     * @query                      The Builder instance.
     * @columns                    The selected columns.
     * @supportsRecursiveKeyword   Determines if the current grammar requires the RECURSIVE keyword if any CTEs are recursive.
     *
     * @return string
     */
    private string function getCommonTableExpressionSQL(
        required query,
        required array commonTables,
        boolean supportsRecursiveKeyword = true
    ) {
        if ( arguments.commonTables.isEmpty() ) {
            return "";
        }

        if ( arguments.supportsRecursiveKeyword ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support recursive CTEs." );
        }

        var hasRecursion = false;

        var sql = arguments.commonTables.map( function( commonTable ) {
            var sql = arguments.commonTable.query.toSQL();

            // generate the optional column definition
            var columns = arguments.commonTable.columns
                .map( function( value ) {
                    return wrapColumn( arguments.value );
                } )
                .toList();

            // we need to track if any of the CTEs are recursive
            if ( arguments.commonTable.recursive ) {
                throw( type = "UnsupportedOperation", message = "This grammar does not support recursive CTEs." );
            }

            return wrapColumn( arguments.commonTable.name ) & (
                len( columns ) ? " " & ( variables.cteColumnsRequireParentheses ? "(" : "" ) & columns & (
                    variables.cteColumnsRequireParentheses ? ")" : ""
                ) : ""
            ) & " AS (" & sql & ")";
        } );

        /*
            Most implementations of CTE require the RECURSIVE keyword if *any* single CTE uses recursive,
            but some grammars, like SQL Server, does not support the keyword (as it's not necessary).
        */
        return trim(
            "WITH " & ( arguments.supportsRecursiveKeyword && hasRecursion ? "RECURSIVE " : "" ) & sql.toList( ", " )
        );
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
    public string function compileInsert( required QueryBuilder query, required array columns, required array values ) {
        if ( !query.getReturning().isEmpty() ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support a RETURNING clause" );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var multiple = arguments.values.len() > 1;

            var columnsString = arguments.columns
                .map( function( column ) {
                    return wrapColumn( column.formatted );
                } )
                .toList( ", " );

            var results = arguments.values.map( function( valueArray ) {
                return "INSERT INTO #wrapTable( query.getTableName() )# (#columnsString#) VALUES (" & valueArray
                    .map( function( item ) {
                        if ( getUtils().isExpression( item ) ) {
                            return item.getSQL();
                        } else {
                            return "?";
                        }
                    } )
                    .toList( ", " ) & ")";
            } );

            return trim( results.toList( "; " ) );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Compile a Builder's query into an update string.
     *
     * @query The Builder instance.
     * @columns The array of columns into which to insert.
     *
     * @return string
     */
    public string function compileUpdate(
        required QueryBuilder query,
        required array columns,
        required struct updateMap
    ) {
        if ( !query.getJoins().isEmpty() ) {
            throw(
                type = "UnsupportedOperation",
                message = "This grammar does not support UPDATEs with JOINs. Use a subselect to update the necessary values instead."
            );
        }

        if ( !arguments.query.getReturning().isEmpty() ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support a RETURNING clause" );
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

            var updateStatement = "UPDATE #wrapTable( query.getTableName() )#";

            if ( !arguments.query.getJoins().isEmpty() ) {
                updateStatement &= " " & compileJoins( arguments.query, arguments.query.getJoins() );
            }

            return trim( updateStatement & " SET #updateList# #compileWheres( query, query.getWheres() )#" );
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
        if ( !isBoolean( arguments.deleteUnmatched ) || arguments.deleteUnmatched ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support DELETE in a upsert clause" );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.qb.getShouldWrapValues() );
            }

            var columnsString = arguments.insertColumns
                .map( function( column ) {
                    return wrapColumn( column.formatted );
                } )
                .toList( ", " );

            var valuesString = arrayToList(
                arguments.insertColumns.map( function( column ) {
                    return wrapColumn( "qb_src.#column.formatted#" );
                } ),
                ", "
            );

            var placeholderString = "";
            if ( !isNull( arguments.source ) ) {
                placeholderString = compileSelect( arguments.source );
            } else {
                placeholderString = "VALUES " & arguments.values
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

            return "MERGE INTO #wrapTable( arguments.qb.getTableName() )# ""qb_target"" USING (#placeholderString#) AS ""qb_src"" ON #constraintString##updateStatement# WHEN NOT MATCHED THEN INSERT (#columnsString#) VALUES (#valuesString#)";
        } finally {
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
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
        if ( !isNull( arguments.query.getLimitValue() ) && isNull( arguments.offsetValue ) ) {
            param arguments.offsetValue = 0;
        } else if ( isNull( arguments.offsetValue ) ) {
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
        if ( !isNull( arguments.limitValue ) ) {
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

        if (
            len( arguments.value ) == 0 ||
            arguments.value == "*" ||
            left( arguments.value, 1 ) == """"
        ) {
            return arguments.value;
        }

        return """#arguments.value#""";
    }

    function compileCreateColumn( column, blueprint ) {
        if ( utils.isExpression( column ) ) {
            return column.getSql();
        }

        try {
            if ( !column.isColumn() ) {
                throw( message = "Not a Column" );
            }
        } catch ( any e ) {
            // exception happens when isColumn returns false or is not a method on the column object
            throw(
                type = "InvalidColumn",
                message = "Recieved a TableIndex instead of a Column when trying to create a Column.",
                detail = "Did you maybe try to add a column and a constraint in an ALTER clause at the same time? Split those up in to separate addColumn and addConstraint commands."
            );
        }

        // Oracle: Default value must come before column constraints
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var values = [
                wrapColumn( column.getName() ),
                generateType( column, blueprint ),
                modifyUnsigned( column ),
                generateComputed( column ),
                generateNullConstraint( column ),
                generateDefault( column ),
                generateAutoIncrement( column, blueprint ),
                generateUniqueConstraint( column, blueprint ),
                generateComment( column, blueprint )
            ];

            return concatenate( values );
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

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "RENAME COLUMN",
                wrapColumn( commandParameters.from ),
                "TO",
                wrapColumn( commandParameters.to.getName() )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileAddColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var originalIndexes = blueprint.getIndexes();
            blueprint.setIndexes( [] );

            var body = concatenate( [ compileCreateColumn( commandParameters.column, blueprint ) ], ", " );

            for ( var index in blueprint.getIndexes() ) {
                blueprint.addConstraint( index );
            }

            blueprint.setIndexes( originalIndexes );

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "ADD COLUMN",
                body
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileModifyColumn( blueprint, commandParameters ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support modifying columns." );
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "RENAME CONSTRAINT",
                wrapColumn( commandParameters.from ),
                "TO",
                wrapColumn( commandParameters.to )
            ] );
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

            return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function generateIfExists( blueprint ) {
        return "";
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

        throw( type = "UnsupportedOperation", message = "This grammar does not support computed columns." );
    }

    function generateAutoIncrement( column, blueprint ) {
        return column.getAutoIncrement() ? "GENERATED ALWAYS AS IDENTITY" : "";
    }

    function generateComment( column, blueprint ) {
        if ( column.getCommentValue() != "" ) {
            blueprint.addCommand( "addComment", { table: blueprint.getTable(), column: column } );
        }
        return "";
    }

    function wrapDefaultType( column ) {
        switch ( column.getType() ) {
            case "boolean":
                return column.getDefaultValue() ? "TRUE" : "FALSE";
            case "char":
            case "string":
                return "'#column.getDefaultValue()#'";
            default:
                return column.getDefaultValue();
        }
    }

    function typeBigInteger( column ) {
        return "BIGINT";
    }

    function typeBit( column ) {
        var length = isNull( column.getLength() ) ? 1 : column.getLength();
        return "CHAR(#length#)";
    }

    function typeBoolean( column ) {
        return "BOOLEAN";
    }

    public string function getBooleanSqlType() {
        return "OTHER";
    }

    function typeDatetime( column ) {
        return typeTimestamp( column );
    }

    function typeDatetimeTz( column ) {
        return typeTimestampTz( column );
    }

    function typeDecimal( column ) {
        return "DECIMAL(#column.getLength()#,#column.getPrecision()#)";
    }

    function typeEnum( column ) {
        blueprint.appendIndex(
            type = "check",
            name = "enum_#blueprint.getTable()#_#column.getName()#",
            columns = column
        );
        return "VARCHAR(255)";
    }

    function typeFloat( column ) {
        return "FLOAT";
    }

    function typeInteger( column ) {
        return "INTEGER";
    }

    function typeJson( column ) {
        return "CLOB";
    }

    function typeLineString( column ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support LineString columns." );
    }

    function typeLongText( column ) {
        return "CLOB";
    }

    function typeUnicodeLongText( column ) {
        return "CLOB";
    }

    function typeMediumInteger( column ) {
        return "INTEGER";
    }

    function typeMediumText( column ) {
        return "CLOB";
    }

    function typeMoney( column ) {
        return "DECIMAL(19, 4)";
    }

    function typeSmallMoney( column ) {
        return "DECIMAL(10, 4)";
    }

    function typePoint( column ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support Point columns." );
    }

    function typePolygon( column ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support Polygon columns." );
    }

    function typeSmallInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 5 : column.getPrecision();
        return "SMALLINT";
    }

    function typeString( column ) {
        return "VARCHAR(#column.getLength()#)";
    }

    function typeUnicodeString( column ) {
        return "VARCHAR(#column.getLength()#)";
    }

    function typeText( column ) {
        return "CLOB";
    }

    function typeUnicodeText( column ) {
        return "CLOB";
    }

    function typeTime( column ) {
        return "TIME";
    }

    function typeTimeTz( column ) {
        return typeTime( column );
    }

    function typeTimestamp( column ) {
        return "TIMESTAMP";
    }

    function typeTimestampTz( column ) {
        return typeTimestamp( column );
    }

    function typeTinyInteger( column ) {
        return "SMALLINT";
    }

    function indexBasic( index, blueprint ) {
        blueprint.addCommand( "addIndex", { index: arguments.index, table: blueprint.getTable() } );
        return "";
    }

    function compileTableExists( tableName, schemaName = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "sys.systables t" )#";
        if ( schemaName != "" ) {
            sql &= " JOIN #wrapTable( "sys.sysschemas s" )# ON #wrapColumn( "t.schemaid" )# = #wrapColumn( "s.schemaid" )#";
        }
        sql &= " WHERE #wrapColumn( "t.tablename" )# = ?";
        if ( schemaName != "" ) {
            sql &= " AND #wrapColumn( "s.schemanname" )# = ?";
        }
        return sql;
    }

    function compileColumnExists( table, column, schema = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "sys.syscolumns c" )# JOIN #wrapTable( "sys.systables t" )# ON #wrapColumn( "c.referenceid" )# = #wrapColumn( "t.tableid" )#";
        if ( schema != "" ) {
            sql &= " JOIN #wrapTable( "sys.sysschemas s" )# ON #wrapColumn( "t.schemaid" )# = #wrapColumn( "s.schemaid" )#";
        }
        sql &= " WHERE #wrapColumn( "t.tablename" )# = ? AND #wrapColumn( "c.columnname" )# = ?";
        if ( schema != "" ) {
            sql &= " AND #wrapColumn( "s.schemanname" )# = ?";
        }
        return sql;
    }

    function compileDropAllObjects( required struct options, string schema = "", required SchemaBuilder sb ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.sb.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.sb.getShouldWrapValues() );
            }

            var tables = getAllTableNames( options );
            return arrayMap( tables, function( table ) {
                return "DROP TABLE #wrapTable( table )#";
            } );
        } finally {
            if ( !isNull( arguments.sb.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

}
