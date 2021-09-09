component extends="qb.models.Grammars.BaseGrammar" singleton {

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
        return arrayToList(
            arrayFilter(
                [
                    "RENAME TABLE",
                    wrapTable( blueprint.getTable() ),
                    "TO",
                    wrapTable( commandParameters.to )
                ],
                function( item ) {
                    return item != "";
                }
            ),
            " "
        );
    }

    function compileDropForeignKey( blueprint, commandParameters ) {
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP FOREIGN KEY #wrapValue( commandParameters.name )#";
    }

    function compileDropAllObjects( options ) {
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

    public string function compileUpsert(
        required QueryBuilder qb,
        required array insertColumns,
        required array values,
        required array updateColumns,
        required any updates
    ) {
        var insertString = this.compileInsert( arguments.qb, arguments.insertColumns, arguments.values );
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
    }

    function compileDisableForeignKeyConstraints() {
        return "SET FOREIGN_KEY_CHECKS=0";
    }

    function compileEnableForeignKeyConstraints() {
        return "SET FOREIGN_KEY_CHECKS=1";
    }

    function generateDefault( column ) {
        if (
            column.getDefault() == "" &&
            column.getType().findNoCase( "TIMESTAMP" ) > 0
        ) {
            if ( column.getNullable() ) {
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
                return column.getDefault() ? 1 : 0;
            case "char":
            case "string":
                return "'#column.getDefault()#'";
            default:
                return column.getDefault();
        }
    }

    function typeChar( column ) {
        return "NCHAR(#column.getLength()#)";
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
