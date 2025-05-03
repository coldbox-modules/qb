component extends="qb.models.Grammars.BaseGrammar" singleton {

    private string function orderByRandom() {
        return "RAND()";
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

        return "`#value#`";
    }

    /**
     * Parses and wraps a value from the Builder for use in a sql statement.
     *
     * @table The value to parse and wrap.
     *
     * @return string
     */
    public string function wrapAlias( required any value ) {
        return "`#value#`";
    }

    function compileRenameTable( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "RENAME TABLE",
                wrapTable( blueprint.getTable() ),
                "TO",
                wrapTable( commandParameters.to )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropForeignKey( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP FOREIGN KEY #wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropAllObjects( required struct options, string schema = "", required SchemaBuilder sb ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.sb.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.sb.getShouldWrapValues() );
            }

            var tables = getAllTableNames( options );
            var tableList = arrayToList(
                arrayMap( tables, function( table ) {
                    return wrapTable( table );
                } ),
                ", "
            );

            return arrayFilter(
                [
                    compileDisableForeignKeyConstraints(),
                    arrayIsEmpty( tables ) ? "" : "DROP TABLE #tableList#",
                    compileEnableForeignKeyConstraints()
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

    function getAllTableNames( options ) {
        var tablesQuery = runQuery(
            "SHOW FULL TABLES WHERE table_type = 'BASE TABLE'",
            {},
            options,
            "query"
        );
        var columnName = arrayToList(
            arrayFilter( tablesQuery.getColumnNames(), function( columnName ) {
                return columnName != "Table_type";
            } )
        );
        var tables = [];
        for ( var table in tablesQuery ) {
            arrayAppend( tables, table[ columnName ] );
        }
        return tables;
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
        return super.compileInsert( argumentCollection = arguments );
    }

    /**
     * Compile a Builder's query into an insert string ignoring duplicate key values.
     *
     * @qb The Builder instance.
     * @columns The array of columns into which to insert.
     * @target The array of key columns to match.
     * @values The array of values to insert.
     *
     * @return string
     */
    public string function compileInsertIgnore(
        required QueryBuilder qb,
        required array columns,
        required array target,
        required array values
    ) {
        return replace(
            compileInsert( arguments.qb, arguments.columns, arguments.values ),
            "INSERT",
            "INSERT IGNORE",
            "one"
        );
    }

    /**
     * Compile a Builder's query into an insert using string.
     *
     * @query The Builder instance.
     * @columns The array of columns into which to insert.
     * @source The source builder object to insert from.
     *
     * @return string
     */
    public string function compileInsertUsing(
        required any query,
        required array columns,
        required QueryBuilder source
    ) {
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

            var cteClause = query.getCommonTables().isEmpty() ? "" : " #compileCommonTables( query, query.getCommonTables() )#";

            return "INSERT INTO #wrapTable( arguments.query.getTableName() )# (#columnsString#)#cteClause# #compileSelect( arguments.source )#";
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
        if ( !arguments.query.getReturning().isEmpty() ) {
            throw(
                type = "UnsupportedOperation",
                message = "This grammar does not support DELETE actions with a RETURNING clause."
            );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var hasJoins = !arguments.query.getJoins().isEmpty();

            return trim(
                arrayToList(
                    arrayFilter(
                        [
                            "DELETE",
                            hasJoins ? wrapTable( query.getTableName() ) : "",
                            "FROM",
                            wrapTable( query.getTableName() ),
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
        if ( !isBoolean( arguments.deleteUnmatched ) || arguments.deleteUnmatched ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support DELETE in a upsert clause" );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.qb.getShouldWrapValues() );
            }

            var insertString = isNull( arguments.source ) ? this.compileInsert(
                arguments.qb,
                arguments.insertColumns,
                arguments.values
            ) : this.compileInsertUsing( arguments.qb, arguments.insertColumns, arguments.source );
            var updateString = "";
            if ( isArray( arguments.updates ) ) {
                updateString = arguments.updateColumns
                    .map( function( column ) {
                        return "#wrapValue( column.formatted )# = VALUES(#wrapValue( column.formatted )#)";
                    } )
                    .toList( ", " );
            } else {
                updateString = arguments.updateColumns
                    .map( function( column ) {
                        var value = updates[ column.original ];
                        return "#wrapValue( column.formatted )# = #getUtils().isExpression( value ) ? value.getSQL() : "?"#";
                    } )
                    .toList( ", " );
            }
            return insertString & " ON DUPLICATE KEY UPDATE #updateString#";
        } finally {
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDisableForeignKeyConstraints() {
        return "SET FOREIGN_KEY_CHECKS=0";
    }

    function compileEnableForeignKeyConstraints() {
        return "SET FOREIGN_KEY_CHECKS=1";
    }

    function generateDefault( column ) {
        if (
            column.getDefaultValue() == "" &&
            column.getType().findNoCase( "TIMESTAMP" ) > 0
        ) {
            if ( column.getIsNullable() ) {
                return "NULL DEFAULT NULL";
            } else {
                column.withCurrent();
            }
        }
        return super.generateDefault( column );
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

    function typeChar( column ) {
        return "NCHAR(#column.getLength()#)";
    }

    function typeGUID( column ) {
        return "CHAR(#column.getLength()#)";
    }

    function typeUUID( column ) {
        return typeGUID( column );
    }

    function typeJson( column ) {
        return "JSON";
    }
    function typeLineString( column ) {
        return "LINESTRING";
    }

    function typePoint( column ) {
        return "POINT";
    }

    function typePolygon( column ) {
        return "POLYGON";
    }

    function typeLongText( column ) {
        return "LONGTEXT";
    }

    function typeMediumText( column ) {
        return "MEDIUMTEXT";
    }

}
