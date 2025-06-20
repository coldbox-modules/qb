component extends="qb.models.Grammars.BaseGrammar" singleton {

    /**
     * Creates a new SQLite Query Grammar.
     *
     * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
     *
     * @return qb.models.Grammars.SQLiteGrammar
     */
    public SQLiteGrammar function init( qb.models.Query.QueryUtils utils ) {
        super.init( argumentCollection = arguments );

        variables.cteColumnsRequireParentheses = true;

        return this;
    }

    /*===================================
    =           Query Builder           =
    ===================================*/

    /**
     * Compiles the lock portion of a sql statement.
     *
     * @query The Builder instance.
     * @lockType The lock type to compile.
     *
     * @return string
     */
    private string function compileLockType( required query, required string lockType ) {
        return "";
    }

    /**
     * Compiles the offset portion of a sql statement.
     *
     * @query The Builder instance.
     * @offsetValue The offset value.
     *
     * @return string
     */
    private string function compileOffsetValue( required QueryBuilder query, offsetValue ) {
        if ( isNull( arguments.offsetValue ) ) {
            return "";
        }

        // SQLite requires LIMIT when using OFFSET. A negative integer means no limit
        if ( isNull( query.getLimitValue() ) ) {
            return "LIMIT -1 OFFSET #offsetValue#";
        }

        return "OFFSET #offsetValue#";
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
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var returningColumns = arguments.query
                .getReturning()
                .map( wrapColumn )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " RETURNING #returningColumns#" : "";
            return super.compileInsert( argumentCollection = arguments ) & returningClause;
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
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
            "INSERT OR IGNORE",
            "one"
        );
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

            var updateStatement = "UPDATE #wrapTable( query.getTableName() )# SET #updateList#";

            var joins = arguments.query.getJoins();

            if ( joins.isEmpty() ) {
                updateStatement = trim( "#updateStatement# #compileWheres( query, query.getWheres() )#" );
            }

            updateStatement = trim( "#updateStatement# #compileLimitValue( query, query.getLimitValue() )#" );

            var returningColumns = arguments.query
                .getReturning()
                .map( wrapColumn )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " RETURNING #returningColumns#" : "";

            if ( joins.isEmpty() ) {
                return updateStatement & returningClause;
            }

            var firstJoin = joins[ 1 ];
            var whereStatement = replace(
                compileWheres( query, query.getWheres() ),
                "WHERE",
                "AND",
                "one"
            );
            updateStatement &= " FROM #wrapTable( firstJoin.getTable() )# #compileWheres( arguments.query, firstJoin.getWheres() )#";

            if ( joins.len() <= 1 ) {
                return trim( updateStatement & " " & whereStatement & returningClause );
            }

            var restJoins = joins.len() <= 1 ? [] : joins.slice( 2 );

            return trim( "#updateStatement# #compileJoins( arguments.query, restJoins )# #whereStatement##returningClause#" );
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
        if ( !arguments.query.getJoins().isEmpty() ) {
            throw(
                type = "UnsupportedOperation",
                message = "This grammar does not support DELETE actions with JOIN clause(s)."
            );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var returningColumns = arguments.query
                .getReturning()
                .map( wrapColumn )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " RETURNING #returningColumns#" : "";
            return trim( "DELETE FROM #wrapTable( query.getTableName() )# #compileWheres( query, query.getWheres() )##returningClause#" );
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
                        return "#wrapColumn( column.formatted )# = EXCLUDED.#wrapColumn( column.formatted )#";
                    } )
                    .toList( ", " );
            } else {
                updateString = arguments.updateColumns
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

            var constraintString = arguments.target
                .map( function( column ) {
                    return wrapColumn( column.formatted );
                } )
                .toList( ", " );

            var returningColumns = arguments.qb
                .getReturning()
                .map( wrapColumn )
                .toList( ", " );
            var returningClause = returningColumns != "" ? " RETURNING #returningColumns#" : "";

            return insertString & " ON CONFLICT (#constraintString#) DO UPDATE SET #updateString##returningClause#";
        } finally {
            if ( !isNull( arguments.qb.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    public string function compileConcat( required string alias, required array items ) {
        return "#arrayToList( items, " || " )# AS #wrapAlias( alias )#";
    }

    /*=====  End of Query Builder  ======*/

    /*===================================
    =           Column Types            =
    ===================================*/

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

    function typeString( column ) {
        return "TEXT";
    }

    function typeUnicodeString( column ) {
        return typeString( argumentCollection = arguments );
    }

    function typeBigInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "INTEGER";
        }

        return "BIGINT";
    }

    function typeSmallInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "INTEGER";
        }

        return "SMALLINT";
    }

    function typeInteger( column ) {
        return "INTEGER";
    }

    function typeMediumInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "INTEGER";
        }

        return "MEDIUMINT";
    }

    function modifyUnsigned( column ) {
        return "";
    }

    function typeBit( column ) {
        return "BOOLEAN";
    }

    function typeBoolean( column ) {
        return "BOOLEAN";
    }

    public string function getBooleanSqlType() {
        return "OTHER";
    }

    public any function convertBooleanValue( required any value ) {
        return !!arguments.value;
    }

    function typeChar( column ) {
        return "VARCHAR(#column.getLength()#)";
    }

    function typeEnum( column, blueprint ) {
        return "TEXT";
    }

    function typeLineString( column, blueprint ) {
        return "TEXT";
    }

    function typePoint( column ) {
        return "TEXT";
    }

    function typePolygon( column ) {
        return "TEXT";
    }

    function typeTime( column ) {
        return "TEXT";
    }

    function typeTimeTz( column ) {
        return "TEXT";
    }

    function typeTimestamp( column ) {
        return "TEXT";
    }

    function typeTinyInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "INTEGER";
        }

        RETURN"TINYINT";
    }




    /*=====  End of Column Types  ======*/

    /*=========================================
    =            Blueprint: Create            =
    =========================================*/

    function generateAutoIncrement( column, blueprint ) {
        // SQLite does not allow the primary key defined as a constraint when using autoincrement
        if ( column.getAutoIncrement() ) {
            blueprint.setIndexes(
                blueprint
                    .getIndexes()
                    .filter( function( index ) {
                        return index.getType() != "primary";
                    } )
            );
        }
        return column.getAutoIncrement() ? "PRIMARY KEY AUTOINCREMENT" : "";
    }

    function generateUniqueConstraint( column, blueprint ) {
        // SQLite does not have an enum type so we add an CHECK constraint to enforce specific values
        if ( column.getType() == "enum" ) {
            var values = column
                .getValues()
                .map( function( value ) {
                    return "'#value#'";
                } )
                .toList( ", " );
            return "CHECK (#wrapColumn( { "type": "simple", "value": column.getName() } )# IN (#values#))";
        }

        return column.getIsUnique() ? "UNIQUE" : "";
    }

    function generateDefault( column ) {
        if (
            column.getDefaultValue() == "" &&
            column.getType().findNoCase( "TIMESTAMP" ) > 0
        ) {
            if ( column.getIsNullable() ) {
                return "";
            } else {
                column.withCurrent();
            }
        }
        return super.generateDefault( column );
    }

    function indexBasic( index, blueprint ) {
        blueprint.addCommand( "addIndex", { index: index, table: blueprint.getTable() } );
        return "";
    }

    function generateComment( column ) {
        return "";
    }


    /*=====  End of Blueprint: Create  ======*/

    /*========================================
    =            Blueprint: Alter            =
    ========================================*/

    function compileModifyColumn( blueprint, commandParameters ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support modifying columns" );
    }

    function compileAddColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "ADD COLUMN",
                compileCreateColumn( commandParameters.column, blueprint )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileAddConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var index = commandParameters.index;
            var constraint = invoke(
                this,
                "index#index.getType()#",
                { index: index, isAlter: true, tableName: blueprint.getTable() }
            );
            return "#constraint#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        throw(
            type = "UnsupportedOperation",
            message = "This grammar does not support renaming constraints. You can drop it and add a new one with a different name."
        );
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "DROP INDEX #wrapValue( commandParameters.name )#";
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

            return "DROP INDEX #wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropForeignKey( blueprint, commandParameters ) {
        throw(
            type = "UnsupportedOperation",
            message = "This grammar does not support droping foreign keys constraints."
        );
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
                wrapColumn( { "type": "simple", "value": commandParameters.from } ),
                "TO",
                wrapColumn( { "type": "simple", "value": commandParameters.to.getName() } )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /*=====  End of Blueprint: Alter  ======*/

    /*=======================================
    =            Blueprint: Drop            =
    =======================================*/

    function compileTableExists( tableName, schemaName = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "pragma_table_list" )# WHERE #wrapColumn( { "type": "simple", "value": "type" } )# = 'table' AND #wrapColumn( { "type": "simple", "value": "name" } )# = ?";

        if ( schemaName != "" ) {
            sql &= " AND #wrapColumn( { "type": "simple", "value": "schema" } )# = ?";
        } else {
            sql &= " AND #wrapColumn( { "type": "simple", "value": "schema" } )# = 'main'";
        }
        return sql;
    }

    function compileColumnExists( table, column, schema = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "pragma_table_list" )# tl JOIN pragma_table_info(tl.name) ti WHERE tl.#wrapColumn( { "type": "simple", "value": "type" } )# = 'table' AND tl.#wrapColumn( { "type": "simple", "value": "name" } )# = ? AND ti.#wrapColumn( { "type": "simple", "value": "name" } )# = ?";
        if ( schema != "" ) {
            sql &= " AND tl.#wrapColumn( { "type": "simple", "value": "schema" } )# = ?";
        } else {
            sql &= " AND tl.#wrapColumn( { "type": "simple", "value": "schema" } )# = 'main'";
        }
        return sql;
    }

    /*=====  End of Blueprint: Drop  ======*/

    /*===================================
    =            Index Types            =
    ===================================*/

    function indexUnique( index, tableName, isAlter = false ) {
        var references = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( { "type": "simple", "value": column } );
            } )
            .toList( ", " );

        if ( isAlter ) {
            return "CREATE UNIQUE INDEX #wrapValue( arguments.index.getName() )# ON #wrapTable( tableName )#(#references#)";
        } else {
            return "CONSTRAINT #wrapValue( arguments.index.getName() )# UNIQUE (#references#)";
        }
    }

    function indexPrimary( index ) {
        var references = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( { "type": "simple", "value": column } );
            } )
            .toList( ", " );
        return "PRIMARY KEY (#references#)";
    }

    function indexForeign( index ) {
        // FOREIGN KEY ("country_id") REFERENCES countries ("id") ON DELETE CASCADE
        var keys = arguments.index
            .getForeignKey()
            .map( function( key ) {
                return wrapColumn( { "type": "simple", "value": key } );
            } )
            .toList( ", " );
        var references = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( { "type": "simple", "value": column } );
            } )
            .toList( ", " );
        return arrayToList(
            [
                "FOREIGN KEY (#keys#)",
                "REFERENCES #wrapTable( arguments.index.getTable() )# (#references#)",
                "ON UPDATE #uCase( arguments.index.getOnUpdateAction() )#",
                "ON DELETE #uCase( arguments.index.getOnDeleteAction() )#"
            ],
            " "
        );
    }

    /*=====  End of Index Types  ======*/

    /*===================================
    =               Views               =
    ===================================*/

    function compileCreateView( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var query = commandParameters[ "query" ];
            return "CREATE VIEW #wrapTable( blueprint.getTable() )# AS #compileSelect( query )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /*=====  End of Views  ======*/

}
