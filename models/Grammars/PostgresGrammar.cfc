component extends="qb.models.Grammars.BaseGrammar" singleton {

    /**
     * Creates a new Postgres Query Grammar.
     *
     * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
     *
     * @return qb.models.Grammars.PostgresGrammar
     */
    public PostgresGrammar function init( qb.models.Query.QueryUtils utils ) {
        super.init( argumentCollection = arguments );

        variables.cteColumnsRequireParentheses = true;

        return this;
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
                return "FOR SHARE";
            case "update":
                return "FOR UPDATE";
            case "custom":
                return arguments.query.getLockValue();
            case "none":
            case "nolock":
            default:
                return "";
        }
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
        var returningColumns = query
            .getReturning()
            .map( wrapColumn )
            .toList( ", " );
        var returningClause = returningColumns != "" ? " RETURNING #returningColumns#" : "";
        return super.compileInsert( argumentCollection = arguments ) & returningClause;
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

        var updateStatement = "UPDATE #wrapTable( query.getFrom() )# SET #updateList#";

        var joins = arguments.query.getJoins();

        if ( joins.isEmpty() ) {
            updateStatement = trim( "#updateStatement# #compileWheres( query, query.getWheres() )#" );
        }

        updateStatement = trim( "#updateStatement# #compileLimitValue( query, query.getLimitValue() )#" );

        if ( joins.isEmpty() ) {
            return updateStatement;
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
            return trim( updateStatement & " " & whereStatement );
        }

        var restJoins = joins.len() <= 1 ? [] : joins.slice( 2 );
        return trim( "#updateStatement# #compileJoins( arguments.query, restJoins )# #whereStatement#" );
    }

    /*===================================
    =              Schema               =
    ===================================*/

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

        return arrayToList(
            arrayFilter(
                [
                    wrapColumn( column.getName() ),
                    generateType( column, blueprint ),
                    modifyUnsigned( column ),
                    generateNullConstraint( column ),
                    generateComputed( column ),
                    generateUniqueConstraint( column, blueprint ),
                    generateAutoIncrement( column, blueprint ),
                    generateDefault( column, blueprint ),
                    generateComment( column, blueprint )
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function generateUniqueConstraint( column ) {
        return column.getUnique() ? "UNIQUE" : "";
    }

    function modifyUnsigned( column ) {
        return "";
    }

    function generateComputed( column ) {
        if ( column.getComputedType() == "none" ) {
            return "";
        }

        return "GENERATED ALWAYS AS (#column.getComputedDefinition()#) STORED";
    }

    function generateAutoIncrement( column ) {
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
                return uCase( column.getDefault() );
            case "char":
            case "string":
                return "'#column.getDefault()#'";
            default:
                return column.getDefault();
        }
    }

    /*=======================================
    =            Blueprint: Drop            =
    =======================================*/

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

    function compileModifyColumn( blueprint, commandParameters ) {
        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "ALTER COLUMN",
                    wrapColumn( commandParameters.to.getName() ),
                    "TYPE",
                    generateType( commandParameters.to, blueprint ) & ",",
                    "ALTER COLUMN",
                    wrapColumn( commandParameters.to.getName() ),
                    commandParameters.to.getNullable() ? "DROP" : "SET",
                    "NOT NULL"
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileDrop( required blueprint ) {
        return arrayToList(
            arrayFilter(
                [
                    "DROP TABLE",
                    generateIfExists( blueprint ),
                    wrapTable( blueprint.getTable() ),
                    "CASCADE"
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileDropColumn( blueprint, commandParameters ) {
        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "DROP COLUMN",
                    isSimpleValue( commandParameters.name ) ? wrapColumn( commandParameters.name ) : wrapColumn(
                        commandParameters.name.getName()
                    ),
                    "CASCADE"
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

    function compileDropAllObjects( options, schema = "" ) {
        var tables = getAllTableNames( options, schema );
        var tableList = arrayToList(
            arrayMap( tables, function( table ) {
                return wrapTable( table );
            } ),
            ", "
        );
        return arrayFilter( [ arrayIsEmpty( tables ) ? "" : "DROP TABLE #tableList# CASCADE" ], function( sql ) {
            return sql != "";
        } );
    }

    function getAllTableNames( options, schema = "" ) {
        var sql = "SELECT #wrapColumn( "table_name" )# FROM #wrapTable( "information_schema.tables" )# WHERE #wrapColumn( "table_schema" )# = 'public'";
        var args = [];
        if ( schema != "" ) {
            sql &= " AND #wrapColumn( "table_catalog" )# = ?";
            args.append( schema );
        }
        var tablesQuery = runQuery( sql, args, options, "query" );
        var tables = [];
        for ( var table in tablesQuery ) {
            arrayAppend( tables, table[ "table_name" ] );
        }
        return tables;
    }

    function compileTableExists( tableName, schemaName = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "information_schema.tables" )# WHERE #wrapColumn( "table_name" )# = ?";
        if ( schemaName != "" ) {
            sql &= " AND #wrapColumn( "table_catalog" )# = ?";
        }
        return sql;
    }

    /*========================================
    =            Blueprint: Alter            =
    ========================================*/

    function compileAddColumn( blueprint, commandParameters ) {
        return arrayToList(
            arrayFilter(
                [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "ADD COLUMN",
                    compileCreateColumn( commandParameters.column, blueprint )
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

    /*===================================
    =           Column Types            =
    ===================================*/

    function typeBoolean( column ) {
        return "BOOLEAN";
    }

    function typeDatetime( column ) {
        return typeTimestamp( column );
    }

    function typeDatetimeTz( column ) {
        return typeTimestampTz( column );
    }

    function typeEnum( column ) {
        return column.getName();
    }

    function typeFloat( column ) {
        return typeDecimal( column );
    }

    function typeInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "SERIAL";
        }

        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "INTEGER";
    }

    function typeJson( column ) {
        return "JSON";
    }

    function typeBigInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "BIGSERIAL";
        }

        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "BIGINT";
    }

    function typeLineString( column ) {
        return formatPostGisType( "linestring" );
    }

    function typeMediumInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "SERIAL";
        }

        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "INTEGER";
    }

    function typeMoney( column ) {
        return "MONEY";
    }

    function typeSmallMoney( column ) {
        return typeMoney( column );
    }

    function typePoint( column ) {
        return formatPostGisType( "point" );
    }

    function typePolygon( column ) {
        return formatPostGisType( "polygon" );
    }

    function typeSmallInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "SERIAL";
        }

        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "SMALLINT";
    }

    function typeUnicodeString( column ) {
        return typeString( argumentCollection = arguments );
    }

    function typeUnicodeText( column ) {
        return typeText( argumentCollection = arguments );
    }

    function typeTimeTz( column ) {
        return "TIME WITH TIME ZONE";
    }

    function typeTimestampTz( column ) {
        return typeTimestamp( column ) & " WITH TIME ZONE";
    }

    function typeTinyInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "SERIAL";
        }

        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "SMALLINT";
    }

    private function formatPostGisType( type ) {
        return "GEOGRAPHY(#uCase( type )#, 4326)";
    }

    /*===================================
    =            Index Types            =
    ===================================*/

    function indexBasic( index, blueprint ) {
        blueprint.addCommand( "addIndex", { index: index, table: blueprint.getTable() } );
        return "";
    }

    function indexUnique( index ) {
        var references = index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( column );
            } )
            .toList( ", " );
        return "CONSTRAINT #wrapValue( index.getName() )# UNIQUE (#references#)";
    }

    /*=====  End of Index Types  ======*/

    function compileAddType( blueprint, commandParameters ) {
        var values = arrayMap( commandParameters.values, function( val ) {
            return "'" & val & "'";
        } );
        return "CREATE TYPE #wrapColumn( commandParameters.name )# AS ENUM (#arrayToList( values, ", " )#)";
    }

}
