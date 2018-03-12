import qb.models.Query.QueryBuilder;

component extends="qb.models.Grammars.BaseGrammar" {

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
        if ( result.recordCount > 0 ) {
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

        return compileOracleLimitAndOffset( query, sql );
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
        var columnsString = columns.map( wrapColumn ).toList( ", " );

        var placeholderString = values.map( function( valueArray ) {
            return "INTO #wrapTable( query.getFrom() )# (#columnsString#) VALUES (" & valueArray.map( function() {
                return "?";
            } ).toList( ", " ) & ")";
        } ).toList( " ");
        return trim( "INSERT ALL #placeholderString# SELECT 1 FROM dual" );
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
    private string function compileOracleLimitAndOffset(
        required QueryBuilder query,
        required string sql
    ) {
        var limitAndOffset = [];
        if ( ! isNull( query.getOffsetValue() ) ) {
            limitAndOffset.append( """QB_RN"" > #query.getOffsetValue()#" );
        }

        if ( ! isNull( query.getLimitValue() ) ) {
            var offset = query.getOffsetValue() ?: 0;
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
    private string function wrapValue( required any value ) {
        return super.wrapValue( uCase( arguments.value ) );
    }

    function compileCreateColumn( column, blueprint ) {
        if ( utils.isExpression( column ) ) {
            return column.getSql();
        }

        if ( isInstanceOf( column, "qb.models.Schema.TableIndex" ) ) {
            throw(
                type = "InvalidColumn",
                message = "Recieved a TableIndex instead of a Column when trying to create a Column.",
                detail = "Did you maybe try to add a column and a constraint in an ALTER clause at the same time? Split those up in to separate addColumn and addConstraint commands."
            );
        }

        return arrayToList( arrayFilter( [
            wrapColumn( column.getName() ),
            generateType( column, blueprint ),
            modifyUnsigned( column ),
            generateAutoIncrement( column, blueprint ),
            generateDefault( column ),
            generateNullConstraint( column ),
            generateUniqueConstraint( column, blueprint ),
            generateComment( column, blueprint )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileRenameColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "RENAME COLUMN",
            wrapColumn( commandParameters.from ),
            "TO",
            wrapColumn( commandParameters.to.getName() )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileAddColumn( blueprint, commandParameters ) {
        var originalIndexes = blueprint.getIndexes();
        blueprint.setIndexes( [] );

        var body = arrayToList( arrayFilter( [
            compileCreateColumn( commandParameters.column, blueprint )
        ], function( item ) {
            return item != "";
        } ), ", " );

        for ( var index in blueprint.getIndexes() ) {
            blueprint.addConstraint( index );
        }

        blueprint.setIndexes( originalIndexes );

        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "ADD",
            body
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileModifyColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "MODIFY",
            "(" & compileCreateColumn( commandParameters.to, blueprint ) & ")"
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "RENAME CONSTRAINT",
            wrapColumn( commandParameters.from ),
            "TO",
            wrapColumn( commandParameters.to )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
    }

    function generateIfExists( blueprint ) {
        return "";
    }

    function modifyUnsigned( column ) {
        return "";
    }

    function generateAutoIncrement( column, blueprint ) {
        if ( ! column.getAutoIncrement() ) {
            return "";
        }

        var table = ucase( blueprint.getTable() );
        var columnName = uCase( column.getName() );
        var sequenceName = "SEQ_#table#";
        var triggerName = "TRG_#table#";
        blueprint.addCommand( "raw", "CREATE SEQUENCE ""#sequenceName#""" );
        blueprint.addCommand( "raw", "CREATE OR REPLACE TRIGGER ""#triggerName#"" BEFORE INSERT ON ""#table#"" FOR EACH ROW WHEN (new.""#columnName#"" IS NULL) BEGIN SELECT ""#sequenceName#"".NEXTVAL INTO :new.""#columnName#"" FROM dual; END" );
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
            blueprint.addCommand( "addComment", { table = blueprint.getTable(), column = column } );
        }
        return "";
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
        return "DATE";
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

    function typeLongText( column ) {
        return "CLOB";
    }

    function typeMediumInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 7 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function typeMediumText( column ) {
        return "CLOB";
    }

    function typeSmallInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 5 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function typeString( column ) {
        return "VARCHAR2(#column.getLength()#)";
    }

    function typeText( column ) {
        return "CLOB";
    }

    function typeTime( column ) {
        return "DATE";
    }

    function typeTimestamp( column ) {
        return "DATE";
    }

    function typeTinyInteger( column ) {
        var precision = isNull( column.getPrecision() ) ? 3 : column.getPrecision();
        return "NUMBER(#precision#, 0)";
    }

    function indexForeign( index ) {
        //FOREIGN KEY ("country_id") REFERENCES countries ("id") ON DELETE CASCADE
        var keys = index.getForeignKey().map( function( key ) {
            return wrapColumn( key );
        } ).toList( ", " );
        var references = index.getColumns().map( function( column ) {
            return wrapColumn( column );
        } ).toList( ", " );
        return arrayToList( [
            "CONSTRAINT #wrapValue( index.getName() )#",
            "FOREIGN KEY (#keys#)",
            "REFERENCES #wrapTable( index.getTable() )# (#references#)",
            "ON DELETE #ucase( index.getOnDelete() )#"
        ], " " );
    }

    function indexBasic( index, blueprint ) {
        blueprint.addCommand( "addIndex", { index = index, table = blueprint.getTable() } );
        return "";
    }

    function compileTableExists( tableName ) {
        return "SELECT 1 FROM ""DBA_TABLES"" WHERE ""TABLE_NAME"" = ?";
    }

    function compileColumnExists( table, column ) {
        return "SELECT 1 FROM ""DBA_TAB_COLUMNS"" WHERE ""TABLE_NAME"" = ? AND ""COLUMN_NAME"" = ?";
    }

}
