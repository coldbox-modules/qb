component extends="qb.models.Grammars.BaseGrammar" {

    /**
    * The different components of a select statement in the order of compilation.
    */
    variables.selectComponents = [
        "commonTables", "aggregate", "columns", "from", "joins", "wheres",
        "groups", "havings", "unions", "orders", "offsetValue", "limitValue"
    ];

    /**
    * Compile a Builder's query into an insert string.
    *
    * @query The Builder instance.
    * @columns The array of columns into which to insert.
    * @values The array of values to insert.
    *
    * @return string
    */
    public string function compileInsert(
        required query,
        required array columns,
        required array values
    ) {
        var columnsString = columns.map( wrapColumn ).toList( ", " );
        var returningColumns = query.getReturning().map( function( column ) {
            return "INSERTED." & wrapColumn( column );
        } ).toList( ", " );
        var returningClause = returningColumns != "" ? " OUTPUT #returningColumns#" : "";
        var placeholderString = values.map( function( valueArray ) {
            return "(" & valueArray.map( function() {
                return "?";
            } ).toList( ", " ) & ")";
        } ).toList( ", ");
        return trim( "INSERT INTO #wrapTable( query.getFrom() )# (#columnsString#)#returningClause# VALUES #placeholderString#" );
    }

    /**
    * Compiles the Common Table Expressions (CTEs).
    *
    * @query The Builder instance.
    * @columns The selected columns.
    *
    * @return string
    */
    private string function compileCommonTables(
        required query,
        required array commonTables
    ) {
        var results = getCommonTableExpressionSQL(
            query=arguments.query,
            commonTables=arguments.commonTables,
            supportsRecursiveKeyword=false
        );

        // the semi-colon can avoid some issues with the JDBC drivers
        return (results.len() ? ";" : "") & results;
    }

    /**
    * Compiles the columns portion of a sql statement.
    *
    * @query The Builder instance.
    * @columns The selected columns.
    *
    * @return string
    */
    private string function compileColumns(
        required query,
        required array columns
    ) {
        if ( ! query.getAggregate().isEmpty() ) {
            return "";
        }
        var select = query.getDistinct() ? "SELECT DISTINCT " : "SELECT ";
        if ( ! isNull( query.getLimitValue() ) && isNull( query.getOffsetValue() ) ) {
            select &= "TOP (#query.getLimitValue()#) ";
        }
        return select & columns.map( wrapColumn ).toList( ", " );
    }

    /**
    * Compiles the order by portion of a sql statement.
    *
    * @query The Builder instance.
    * @orders The where clauses.
    *
    * @return string
    */
    private string function compileOrders(
        required query,
        required array orders
    ) {
        if ( orders.isEmpty() ) {
            if ( isNull( query.getOffsetValue() ) ) {
                return "";
            }
            return "ORDER BY 1";
        }

        var orderBys = orders.map( function( orderBy ) {
            return orderBy.direction == "raw" ?
                orderBy.column.getSql() :
                "#wrapColumn( orderBy.column )# #uCase( orderBy.direction )#";
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
        if ( ! isNull( arguments.limitValue ) && ! isNull( query.getOffsetValue() ) ) {
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
    public string function wrapValue( required any value ) {
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
    public string function compileUpdate(
        required query,
        required array columns
    ) {
        var updateList = columns.map( function( column ) {
            return "#wrapColumn( column )# = ?";
        } ).toList( ", " );

        return arrayToList( arrayFilter( [
            "UPDATE",
            isNull( query.getLimitValue() ) ? "" : "TOP (#query.getLimitValue()#)",
            wrapTable( query.getFrom() ),
            "SET",
            updateList,
            compileWheres( query, query.getWheres() )
        ], function( str ) {
           return str != "";
        } ), " " );
    }

    function modifyUnsigned( column ) {
        return "";
    }

    function generateAutoIncrement( column ) {
        return column.getAutoIncrement() ? "IDENTITY" : "";
    }

    function generateDefault( column, blueprint ) {
        return column.getDefault() != "" ?
            "CONSTRAINT #wrapValue( "df_#blueprint.getTable()#_#column.getName()#" )# DEFAULT #wrapDefaultType( column )#" :
            "";
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
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "ALTER COLUMN",
            compileCreateColumn( commandParameters.to, blueprint )
        ], function( item ) {
            return item != "";
        } ), " " );
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
        return "DATETIME2";
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

    function typeFloat( column ) {
        return "DECIMAL(#column.getLength()#,#column.getPrecision()#)";
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

    function typeTinyInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "TINYINT";
    }

}
