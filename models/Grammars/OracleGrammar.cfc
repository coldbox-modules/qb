component extends="qb.models.Grammars.BaseGrammar" singleton {

    /**
     * Creates a new Oracle Query Grammar.
     *
     * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
     *
     * @return qb.models.Grammars.OracleGrammar
     */
    public OracleGrammar function init( qb.models.Query.QueryUtils utils ) {
        super.init( argumentCollection = arguments );

        variables.tableAliasOperator = " ";

        return this;
    }

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
     * Compile a Builder's query into a sql string.
     *
     * @query The Builder instance.
     *
     * @return string
     */
    public string function compileSelect( required QueryBuilder query ) {
        var sql = super.compileSelect( argumentCollection = arguments );
        sql = compileOracleLimitAndOffset( query, sql );
        return compileOracleLockType( query, sql );
    }

    private string function orderByRandom() {
        return "DBMS_RANDOM.VALUE";
    }

    /**
     * Compiles the table portion of a sql statement.
     *
     * @query The Builder instance.
     * @from The selected table.
     *
     * @return string
     */
    private string function compileTableName( required QueryBuilder query, required any tableName ) {
        if ( !len( arguments.tableName ) ) {
            return "FROM DUAL";
        }

        var fullTable = arguments.tableName;
        if ( query.getAlias() != "" ) {
            fullTable &= " #query.getAlias()#";
        }
        return "FROM " & wrapTable( fullTable );
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
            case "update":
                return "FOR UPDATE";
            case "updateSkipLocked":
                return "FOR UPDATE SKIP LOCKED";
            default:
                return ""; // Oracle grammar adds the other lock types as an additional statement before the select statement.
        }
    }

    /**
     * Compiles the lock portion of a sql statement.
     *
     * @query The Builder instance.
     * @lockType The lock type to compile.
     *
     * @return string
     */
    private string function compileOracleLockType( required query, required string sql ) {
        switch ( arguments.query.getLockType() ) {
            case "shared":
                return "LOCK TABLE #wrapTable( arguments.query.getTableName() )# IN SHARE MODE NOWAIT; #arguments.sql#";
            case "custom":
                return "LOCK TABLE #wrapTable( arguments.query.getTableName() )# IN #arguments.query.getLockValue()# MODE NOWAIT; #arguments.sql#";
            case "none":
            case "nolock":
            default:
                return arguments.sql;
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

            var placeholderString = values
                .map( function( valueArray ) {
                    return "INTO #wrapTable( query.getTableName() )# (#columnsString#) VALUES (" & valueArray
                        .map( function( item ) {
                            if ( getUtils().isExpression( item ) ) {
                                return item.getSQL();
                            } else {
                                return "?";
                            }
                        } )
                        .toList( ", " ) & ")";
                } )
                .toList( " " );
            return trim( "INSERT#multiple ? " ALL" : ""# #placeholderString##multiple ? " SELECT 1 FROM dual" : ""#" );
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
        return super.compileUpdate( argumentCollection = arguments );
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
                    return wrapColumn( "QB_SRC.#column.formatted#" );
                } ),
                ", "
            );

            var placeholderString = "";
            if ( !isNull( arguments.source ) ) {
                placeholderString = compileSelect( arguments.source );
            } else {
                placeholderString = arguments.values
                    .map( function( valueArray ) {
                        return "SELECT " & valueArray
                            .map( function( item ) {
                                if ( getUtils().isExpression( item ) ) {
                                    return item.getSQL();
                                } else {
                                    return "?";
                                }
                            } )
                            .toList( ", " ) & " FROM dual";
                    } )
                    .toList( " UNION ALL " );
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

            return "MERGE INTO #wrapTable( arguments.qb.getTableName() )# ""QB_TARGET"" USING (#placeholderString#) ""QB_SRC"" ON #constraintString##updateStatement# WHEN NOT MATCHED THEN INSERT (#columnsString#) VALUES (#valuesString#)";
        } finally {
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Since Oracle doesn't know how to do a simple limit of offset without subquerys
     * add a subquery around the compiled value for the limit and the offset.
     *
     * @query The Builder instance.
     * @sql The generated sql string.
     *
     * @return string
     */
    private string function compileOracleLimitAndOffset( required QueryBuilder query, required string sql ) {
        var limitAndOffset = [];
        if ( !isNull( query.getOffsetValue() ) ) {
            limitAndOffset.append( """QB_RN"" > #query.getOffsetValue()#" );
        }

        if ( !isNull( query.getLimitValue() ) ) {
            var offset = isNull( query.getOffsetValue() ) ? 0 : query.getOffsetValue();
            limitAndOffset.append( """QB_RN"" <= #offset + query.getLimitValue()#" );
        }

        if ( limitAndOffset.isEmpty() ) {
            return sql;
        }

        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (#sql#) results ) WHERE #limitAndOffset.toList( " AND " )#";
    }

    /**
     * Compiles the limit portion of a sql statement.
     * Overridden here because Oracle needs to wrap the entire sql statement instead.
     *
     * @query The Builder instance.
     * @limitValue The limit clauses.
     *
     * @return string
     */
    private string function compileLimitValue( required QueryBuilder query, limitValue ) {
        return "";
    }

    /**
     * Compiles the offset portion of a sql statement.
     * Overridden here because Oracle needs to wrap the entire sql statement instead.
     *
     * @query The Builder instance.
     * @offsetValue The offset value.
     *
     * @return string
     */
    private string function compileOffsetValue( required QueryBuilder query, offsetValue ) {
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

        return """#uCase( arguments.value )#""";
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
                generateAutoIncrement( column, blueprint ),
                generateDefault( column ),
                generateNullConstraint( column ),
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
                "ADD",
                body
            ] );
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
                "MODIFY",
                "(" & compileCreateColumn( commandParameters.to, blueprint ) & ")"
            ] );
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

        return "GENERATED ALWAYS AS (#column.getComputedDefinition()#)" & (
            column.getComputedType() == "virtual" ? " VIRTUAL" : ""
        );
    }

    function generateAutoIncrement( column, blueprint ) {
        if ( !column.getAutoIncrement() ) {
            return "";
        }

        var table = uCase( blueprint.getTable() );
        var columnName = uCase( column.getName() );
        var sequenceName = "SEQ_#table#";
        var triggerName = "TRG_#table#";
        blueprint.addCommand( "raw", { "sql": "CREATE SEQUENCE ""#sequenceName#""" } );
        blueprint.addCommand(
            "raw",
            {
                "sql": "CREATE OR REPLACE TRIGGER ""#triggerName#"" BEFORE INSERT ON ""#table#"" FOR EACH ROW WHEN (NEW.""#columnName#"" IS NULL) BEGIN SELECT ""#sequenceName#"".NEXTVAL INTO ::NEW.""#columnName#"" FROM dual; END"
            }
        );
        return "";
    }

    function generateUniqueConstraint( column, blueprint ) {
        if ( column.getIsUnique() ) {
            blueprint.unique( [ column.getName() ] );
        }
        return "";
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
                return column.getDefaultValue() ? 1 : 0;
            case "char":
            case "string":
                return "'#column.getDefaultValue()#'";
            default:
                return column.getDefaultValue();
        }
    }

    function typeBigInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 19 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function typeBit( column ) {
        return "RAW";
    }

    function typeBoolean( column ) {
        return "NUMBER(1, 0)";
    }

    public string function getBooleanSqlType() {
        return "NUMERIC";
    }

    function typeDatetime( column ) {
        return typeTimestamp( column );
    }

    function typeDatetimeTz( column ) {
        return typeTimestampTz( column );
    }

    function typeDecimal( column ) {
        return "FLOAT";
    }

    function typeEnum( column ) {
        blueprint.appendIndex(
            type = "check",
            name = "enum_#blueprint.getTable()#_#column.getName()#",
            columns = column
        );
        return "VARCHAR2(255)";
    }

    function typeFloat( column ) {
        return "FLOAT";
    }

    function typeInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 10 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function typeJson( column ) {
        return "CLOB";
    }

    function typeJsonb( column ) {
        return "CLOB";
    }

    function typeLineString( column ) {
        return "SDO_GEOMETRY";
    }

    function typeLongText( column ) {
        return "CLOB";
    }

    function typeUnicodeLongText( column ) {
        return "NCLOB";
    }

    function typeMediumInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 7 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function typeMediumText( column ) {
        return "CLOB";
    }

    function typeMoney( column ) {
        return "NUMBER(19, 4)";
    }

    function typeSmallMoney( column ) {
        return "NUMBER(10, 4)";
    }

    function typePoint( column ) {
        return "SDO_GEOMETRY";
    }

    function typePolygon( column ) {
        return "SDO_GEOMETRY";
    }

    function typeSmallInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 5 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function typeString( column ) {
        return "VARCHAR2(#column.getLength()#)";
    }

    function typeUnicodeString( column ) {
        return "NVARCHAR2(#column.getLength()#)";
    }

    function typeText( column ) {
        return "CLOB";
    }

    function typeUnicodeText( column ) {
        return "NCLOB";
    }

    function typeTime( column ) {
        return typeTimestamp( column );
    }

    function typeTimeTz( column ) {
        return typeTimestampTz( column );
    }

    function typeTimestamp( column ) {
        return "TIMESTAMP#isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"#";
    }

    function typeTimestampTz( column ) {
        return "TIMESTAMP WITH TIME ZONE";
    }

    function typeTinyInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 3 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function indexForeign( index ) {
        // FOREIGN KEY ("country_id") REFERENCES countries ("id") ON DELETE CASCADE
        var keys = arguments.index
            .getForeignKey()
            .map( function( key ) {
                return wrapColumn( key );
            } )
            .toList( ", " );
        var references = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( column );
            } )
            .toList( ", " );
        return arrayToList(
            [
                "CONSTRAINT #wrapValue( arguments.index.getName() )#",
                "FOREIGN KEY (#keys#)",
                "REFERENCES #wrapTable( arguments.index.getTable() )# (#references#)",
                "ON DELETE #uCase( arguments.index.getOnDeleteAction() )#"
            ],
            " "
        );
    }

    function indexBasic( index, blueprint ) {
        blueprint.addCommand( "addIndex", { index: arguments.index, table: blueprint.getTable() } );
        return "";
    }

    function compileTableExists( tableName, schemaName = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "all_tables" )# WHERE #wrapColumn( "table_name" )# = ?";
        if ( schemaName != "" ) {
            sql &= " AND #wrapColumn( "owner" )# = ?";
        }
        return sql;
    }

    function compileColumnExists( table, column, schema = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "all_tab_columns" )# WHERE #wrapColumn( "table_name" )# = ? AND #wrapColumn( "column_name" )# = ?";
        if ( schema != "" ) {
            sql &= " AND #wrapColumn( "owner" )# = ?";
        }
        return sql;
    }

    function compileDrop( required blueprint ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var statements = [ "DROP TABLE #wrapTable( arguments.blueprint.getTable() )#" ];

            var sequenceName = "SEQ_#uCase( arguments.blueprint.getTable() )#";
            if ( hasSequence( arguments.blueprint, sequenceName ) ) {
                statements.append( "DROP SEQUENCE #wrapTable( sequenceName )#" );
            }

            var triggerName = "TRG_#uCase( arguments.blueprint.getTable() )#";
            if ( hasTrigger( arguments.blueprint, triggerName ) ) {
                statements.append( "DROP TRIGGER #wrapTable( triggerName )#" );
            }

            return statements;
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    private boolean function hasSequence( required Blueprint blueprint, required string sequenceName ) {
        var sql = "SELECT 1 FROM #wrapTable( "all_sequences" )# WHERE #wrapColumn( "sequence_name" )# = ?";
        var params = [ arguments.sequenceName ];
        if ( arguments.blueprint.getDefaultSchema() != "" ) {
            sql &= " AND #wrapColumn( "owner" )# = ?";
            params.append( arguments.blueprint.getDefaultSchema() );
        }
        var result = queryExecute( sql, params, arguments.blueprint.getQueryOptions() );
        return result.recordCount > 0;
    }

    private boolean function hasTrigger( required Blueprint blueprint, required string triggerName ) {
        var sql = "SELECT 1 FROM #wrapTable( "all_triggers" )# WHERE #wrapColumn( "trigger_name" )# = ?";
        var params = [ arguments.triggerName ];
        if ( arguments.blueprint.getDefaultSchema() != "" ) {
            sql &= " AND #wrapColumn( "owner" )# = ?";
            params.append( arguments.blueprint.getDefaultSchema() );
        }
        var result = queryExecute( sql, params, arguments.blueprint.getQueryOptions() );
        return result.recordCount > 0;
    }

    function compileDropAllObjects( required struct options, string schema = "", SchemaBuilder sb ) {
        return [
            "BEGIN
            FOR c IN (SELECT table_name FROM user_tables) LOOP
            EXECUTE IMMEDIATE ('DROP TABLE ""' || c.table_name || '"" CASCADE CONSTRAINTS');
            END LOOP;
            FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
            EXECUTE IMMEDIATE ('DROP SEQUENCE ' || s.sequence_name);
            END LOOP;
            END;"
        ];
    }

}
