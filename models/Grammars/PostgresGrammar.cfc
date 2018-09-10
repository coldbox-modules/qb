component extends="qb.models.Grammars.BaseGrammar" {

    /*===================================
    =              Schema               =
    ===================================*/

    function generateUniqueConstraint( column ) {
        return column.getUnique() ? "UNIQUE" : "";
    }

    function modifyUnsigned( column ) {
        return "";
    }

    function generateAutoIncrement( column ) {
        return "";
    }

    function generateComment( column, blueprint ) {
        if ( column.getComment() != "" ) {
            blueprint.addCommand( "addComment", { table = blueprint.getTable(), column = column } );
        }
        return "";
    }

    /*=======================================
    =            Blueprint: Drop            =
    =======================================*/

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

    function compileModifyColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
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
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileDrop( required blueprint ) {
        return arrayToList( arrayFilter( [
            "DROP TABLE",
            generateIfExists( blueprint ),
            wrapTable( blueprint.getTable() ),
            "CASCADE"
        ], function( item ) {
            return item != "";
        } ), " ");
    }

    function compileDropColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "DROP COLUMN",
            wrapColumn( commandParameters.name ),
            "CASCADE"
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
    }

    function compileDropAllObjects( options ) {
        var tables = getAllTableNames( options );
        var tableList = arrayToList( arrayMap( tables, function( table ) {
            return wrapTable( table );
        } ), ", " );
        return arrayFilter( [
            arrayIsEmpty( tables ) ? "" : "DROP TABLE #tableList# CASCADE"
        ], function( sql ) { return sql != ""; } );
    }

    function getAllTableNames( options ) {
        var tablesQuery = runQuery(
            "SELECT ""table_name"" FROM ""information_schema"".""tables"" WHERE ""table_schema"" = 'public'",
            {},
            options,
            "query"
        );
        var tables = [];
        for ( var table in tablesQuery ) {
            arrayAppend( tables, table[ "table_name" ] );
        }
        return tables;
    }

    /*========================================
    =            Blueprint: Alter            =
    ========================================*/

    function compileAddColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "ADD COLUMN",
            compileCreateColumn( commandParameters.column, blueprint )
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

    /*===================================
    =           Column Types            =
    ===================================*/

    function typeBoolean( column ) {
        return "BOOLEAN";
    }

    function typeDatetime( column ) {
        return "TIMESTAMP";
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

    function typeMediumInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "SERIAL";
        }

        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "INTEGER";
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

    function typeTinyInteger( column ) {
        if ( column.getAutoIncrement() ) {
            return "SERIAL";
        }

        if ( !isNull( column.getPrecision() ) ) {
            return "NUMERIC(#column.getPrecision()#)";
        }

        return "SMALLINT";
    }

    /*===================================
    =            Index Types            =
    ===================================*/

    function indexBasic( index, blueprint ) {
        blueprint.addCommand( "addIndex", { index = index, table = blueprint.getTable() } );
        return "";
    }

    function indexUnique( index ) {
        var references = index.getColumns().map( function( column ) {
            return wrapColumn( column );
        } ).toList( ", " );
        return "CONSTRAINT #wrapValue( index.getName() )# UNIQUE (#references#)";
    }

    /*=====  End of Index Types  ======*/

    function compileAddType( blueprint, commandParameters ) {
        var values = arrayMap(commandParameters.values, function( val ) {
            return wrapValue( val );
        } );
        return "CREATE TYPE #wrapColumn( commandParameters.name )# AS ENUM (#arrayToList( values, ", " )#)";
    }

}
