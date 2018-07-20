component extends="qb.models.Grammars.BaseGrammar" {

    /**
    * The different components of a select statement in the order of compilation.
    */
    variables.selectComponents = [
        "aggregate", "columns", "from", "joins", "wheres",
        "groups", "havings", "orders", "offsetValue", "limitValue"
    ];

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
        return column.getDefault() != "" ? "CONSTRAINT #wrapValue( "df_#blueprint.getTable()#_#column.getName()#" )# DEFAULT #column.getDefault()#" : "";
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
        return "NTEXT";
    }

    function typeLongText( column ) {
        return "NTEXT";
    }

    function typeMediumInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "INTEGER";
    }

    function typeMediumText( column ) {
        return "NTEXT";
    }

    function typeSmallInteger( column ) {
        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "SMALLINT";
    }

    function typeString( column ) {
        return "NVARCHAR(#column.getLength()#)";
    }

    function typeText( column ) {
        return "NTEXT";
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
