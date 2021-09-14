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

    /**
     * Compiles the lock portion of a sql statement.
     *
     * @query The Builder instance.
     * @lockType The lock type to compile.
     *
     * @return string
     */
    private string function compileLockType( required query, required string lockType ) {
        return ""; // Oracle grammar adds it as an additional statement before the select statement.
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
                return "LOCK TABLE #wrapTable( arguments.query.getFrom() )# IN SHARE MODE NOWAIT; #arguments.sql#";
            case "update":
                return "LOCK TABLE #wrapTable( arguments.query.getFrom() )# IN ROW EXCLUSIVE MODE NOWAIT; #arguments.sql#";
            case "custom":
                return "LOCK TABLE #wrapTable( arguments.query.getFrom() )# IN #arguments.query.getLockValue()# MODE NOWAIT; #arguments.sql#";
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

        var multiple = arguments.values.len() > 1;

        var columnsString = arguments.columns
            .map( function( column ) {
                return wrapColumn( column.formatted );
            } )
            .toList( ", " );

        var placeholderString = values
            .map( function( valueArray ) {
                return "INTO #wrapTable( query.getFrom() )# (#columnsString#) VALUES (" & valueArray
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
        required array target
    ) {
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

        var placeholderString = arguments.values
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

        return "MERGE INTO #wrapTable( arguments.qb.getFrom() )# ""QB_TARGET"" USING (#placeholderString#) ""QB_SRC"" ON #constraintString# WHEN MATCHED THEN UPDATE SET #updateList# WHEN NOT MATCHED THEN INSERT (#columnsString#) VALUES (#valuesString#)";
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
        arguments.value = uCase( arguments.value );
        if ( value == "*" ) {
            return value;
        }
        return """#value#""";
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
        return arrayToList(
            arrayFilter(
                [
                    wrapColumn( column.getName() ),
                    generateType( column, blueprint ),
                    modifyUnsigned( column ),
                    generateComputed( column ),
                    generateAutoIncrement( column, blueprint ),
                    generateDefault( column ),
                    generateNullConstraint( column ),
                    generateUniqueConstraint( column, blueprint ),
                    generateComment( column, blueprint )
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileRenameColumn( blueprint, commandParameters ) {
        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "RENAME COLUMN",
                    wrapColumn( commandParameters.from ),
                    "TO",
                    wrapColumn( commandParameters.to.getName() )
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileAddColumn( blueprint, commandParameters ) {
        var originalIndexes = blueprint.getIndexes();
        blueprint.setIndexes( [] );

        var body = arrayToList(
            arrayFilter( [ compileCreateColumn( commandParameters.column, blueprint ) ], function( item ) {
                return item != "";
            } ),
            ", "
        );

        for ( var index in blueprint.getIndexes() ) {
            blueprint.addConstraint( index );
        }

        blueprint.setIndexes( originalIndexes );

        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "ADD",
                    body
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileModifyColumn( blueprint, commandParameters ) {
        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "MODIFY",
                    "(" & compileCreateColumn( commandParameters.to, blueprint ) & ")"
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "RENAME CONSTRAINT",
                    wrapColumn( commandParameters.from ),
                    "TO",
                    wrapColumn( commandParameters.to )
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
    }

    function generateIfExists( blueprint ) {
        return "";
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
                "sql": "CREATE OR REPLACE TRIGGER ""#triggerName#"" BEFORE INSERT ON ""#table#"" FOR EACH ROW WHEN (new.""#columnName#"" IS NULL) BEGIN SELECT ""#sequenceName#"".NEXTVAL INTO :new.""#columnName#"" FROM dual; END"
            }
        );
        return "";
    }

    function generateUniqueConstraint( column, blueprint ) {
        if ( column.getUnique() ) {
            blueprint.unique( [ column.getName() ] );
        }
        return "";
    }

    function generateComment( column, blueprint ) {
        if ( column.getComment() != "" ) {
            blueprint.addCommand( "addComment", { table: blueprint.getTable(), column: column } );
        }
        return "";
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

    function typeLineString( column ) {
        return "SDO_GEOMETRY";
    }

    function typeLongText( column ) {
        return "CLOB";
    }

    function typeUnicodeLongText( column ) {
        return "CLOB";
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
        return "VARCHAR2(#column.getLength()#)";
    }

    function typeText( column ) {
        return "CLOB";
    }

    function typeUnicodeText( column ) {
        return "CLOB";
    }

    function typeTime( column ) {
        return typeTimestamp( column );
    }

    function typeTimeTz( column ) {
        return typeTimestampTz( column );
    }

    function typeTimestamp( column ) {
        return "DATE";
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
        var keys = index
            .getForeignKey()
            .map( function( key ) {
                return wrapColumn( key );
            } )
            .toList( ", " );
        var references = index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( column );
            } )
            .toList( ", " );
        return arrayToList(
            [
                "CONSTRAINT #wrapValue( index.getName() )#",
                "FOREIGN KEY (#keys#)",
                "REFERENCES #wrapTable( index.getTable() )# (#references#)",
                "ON DELETE #uCase( index.getOnDelete() )#"
            ],
            " "
        );
    }

    function indexBasic( index, blueprint ) {
        blueprint.addCommand( "addIndex", { index: index, table: blueprint.getTable() } );
        return "";
    }

    function compileTableExists( tableName, schemaName = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "dba_tables" )# WHERE #wrapColumn( "table_name" )# = ?";
        if ( schemaName != "" ) {
            sql &= " AND #wrapColumn( "owner" )# = ?";
        }
        return sql;
    }

    function compileColumnExists( table, column, scehma = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "dba_tab_columns" )# WHERE #wrapColumn( "table_name" )# = ? AND #wrapColumn( "column_name" )# = ?";
        if ( scehma != "" ) {
            sql &= " AND #wrapColumn( "owner" )# = ?";
        }
        return sql;
    }

    function compileDropAllObjects() {
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
