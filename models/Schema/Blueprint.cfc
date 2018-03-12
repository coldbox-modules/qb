component accessors="true" {

    property name="schemaBuilder";
    property name="grammar";
    property name="table";
    property name="commands";

    property name="columns";
    property name="dropColumns";
    property name="indexes";

    property name="creating" default="false";
    property name="ifExists" default="false";

    function init( schemaBuilder, grammar ) {
        setSchemaBuilder( schemaBuilder );
        setGrammar( grammar );

        setColumns( [] );
        setDropColumns( [] );
        setCommands( [] );
        setIndexes( [] );
        return this;
    }



    /*====================================
    =            Column Types            =
    ====================================*/

    function bigIncrements( name, indexName ) {
        arguments.autoIncrement = true;
        arguments.indexName = isNull( indexName ) ? "pk_#getTable()#_#name#" : arguments.indexName;
        appendIndex( type = "primary", columns = name, name = indexName );
        return unsignedBigInteger( argumentCollection = arguments );
    }

    function bigInteger( name, precision ) {
        arguments.type = "bigInteger";
        return appendColumn( argumentCollection = arguments );
    }

    function bit( name, length = 1 ) {
        arguments.type = "bit";
        return appendColumn( argumentCollection = arguments );
    }

    function boolean( name ) {
        arguments.length = 1;
        arguments.type = "boolean";
        return appendColumn( argumentCollection = arguments );
    }

    function char( name, length = 1 ) {
        arguments.length = arguments.length > 255 ? 255 : arguments.length;
        arguments.type = "char";
        return appendColumn( argumentCollection = arguments );
    }

    function date( name ) {
        arguments.type = "date";
        return appendColumn( argumentCollection = arguments );
    }

    function datetime( name ) {
        arguments.type = "datetime";
        return appendColumn( argumentCollection = arguments );
    }

    function decimal( name, length = 10, precision = 0 ) {
        arguments.type = "decimal";
        return appendColumn( argumentCollection = arguments );
    }

    function enum( name, values ) {
        prependCommand( "addType", { name = name, values = values } );
        arguments.type = "enum";
        return appendColumn( argumentCollection = arguments );
    }

    function float( name, length = 10, precision = 0 ) {
        arguments.type = "float";
        return appendColumn( argumentCollection = arguments );
    }

    function increments( name, indexName ) {
        arguments.autoIncrement = true;
        arguments.indexName = isNull( indexName ) ? "pk_#getTable()#_#name#" : arguments.indexName;
        appendIndex( type = "primary", columns = name, name = indexName );
        return unsignedInteger( argumentCollection = arguments );
    }

    function integer( name, precision ) {
        arguments.type = "integer";
        return appendColumn( argumentCollection = arguments );
    }

    function json( name ) {
        arguments.type = "json";
        return appendColumn( argumentCollection = arguments );
    }

    function longText( name ) {
        arguments.type = "longText";
        return appendColumn( argumentCollection = arguments );
    }

    function mediumIncrements( name, indexName ) {
        arguments.autoIncrement = true;
        arguments.indexName = isNull( indexName ) ? "pk_#getTable()#_#name#" : arguments.indexName;
        appendIndex( type = "primary", columns = name, name = indexName );
        return unsignedMediumInteger( argumentCollection = arguments );
    }

    function mediumInteger( name, precision ) {
        arguments.type = "mediumInteger";
        return appendColumn( argumentCollection = arguments );
    }

    function mediumText( name ) {
        arguments.type = "mediumText";
        return appendColumn( argumentCollection = arguments );
    }

    function morphs( name ) {
        unsignedInteger( "#name#_id" );
        string( "#name#_type" );
        appendIndex(
            type = "basic",
            name = "#name#_index",
            columns = [ "#name#_id", "#name#_type" ]
        );
        return this;
    }

    function nullableMorphs( name ) {
        unsignedInteger( "#name#_id" ).nullable();
        string( "#name#_type" ).nullable();
        appendIndex(
            type = "basic",
            name = "#name#_index",
            columns = [ "#name#_id", "#name#_type" ]
        );
        return this;
    }

    function raw( sql ) {
        variables.columns.append( new qb.models.Query.Expression( sql ) );
        return this;
    }

    function smallIncrements( name, indexName ) {
        arguments.autoIncrement = true;
        arguments.indexName = isNull( indexName ) ? "pk_#getTable()#_#name#" : arguments.indexName;
        appendIndex( type = "primary", columns = name, name = indexName );
        return unsignedSmallInteger( argumentCollection = arguments );
    }

    function smallInteger( name, precision ) {
        arguments.type = "smallInteger";
        return appendColumn( argumentCollection = arguments );
    }

    function string( name, length ) {
        arguments.type = "string";
        if ( isNull( arguments.length ) ) {
            arguments.length = getSchemaBuilder().getDefaultStringLength();
        }
        return appendColumn( argumentCollection = arguments );
    }

    function text( name ) {
        arguments.type = "text";
        return appendColumn( argumentCollection = arguments );
    }

    function time( name ) {
        arguments.type = "time";
        return appendColumn( argumentCollection = arguments );
    }

    function timestamp( name ) {
        arguments.type = "timestamp";
        return appendColumn( argumentCollection = arguments );
    }

    function tinyIncrements( name, indexName ) {
        arguments.autoIncrement = true;
        arguments.indexName = isNull( indexName ) ? "pk_#getTable()#_#name#" : arguments.indexName;
        appendIndex( type = "primary", columns = name, name = indexName );
        return unsignedTinyInteger( argumentCollection = arguments );
    }

    function tinyInteger( name, precision ) {
        arguments.type = "tinyInteger";
        return appendColumn( argumentCollection = arguments );
    }

    function unsignedBigInteger( name, precision ) {
        arguments.unsigned = true;
        return bigInteger( argumentCollection = arguments );
    }

    function unsignedInteger( name, precision ) {
        arguments.unsigned = true;
        return integer( argumentCollection = arguments );
    }

    function unsignedMediumInteger( name, precision ) {
        arguments.unsigned = true;
        return mediumInteger( argumentCollection = arguments );
    }

    function unsignedSmallInteger( name, precision ) {
        arguments.unsigned = true;
        return smallInteger( argumentCollection = arguments );
    }

    function unsignedTinyInteger( name, precision ) {
        arguments.unsigned = true;
        return tinyInteger( argumentCollection = arguments );
    }

    function uuid( name ) {
        return char( name, 35 );
    }



    /*===================================
    =            Constraints            =
    ===================================*/

    /**
    * Create a foreign key constraint from one or more columns.
    * Follow up this call with calls to the `TableIndex` `references` and `onTable` methods.
    *
    * @columns The column or array of columns that references a key or keys on another table.
    * @name    The name of the foreign key constraint.
    *          Default: A generated name consisting of the table name and column name(s).
    *
    * @returns The created TableIndex instance.
    */
    function foreignKey( columns, name ) {
        arguments.columns = isArray( columns ) ? columns : [ columns ];
        arguments.name = isNull( name ) ? "fk_#getTable()#_#arrayToList( columns, "_" )#" : arguments.name;
        return appendIndex( type = "foreign", foreignKey = columns, name = name );
    }

    /**
    * Create a generic index from one or more columns.
    *
    * @columns The column or array of columns that make up the index.
    * @name    The name of the index constraint.
    *          Default: A generated name consisting of the table name and column name(s).
    *
    * @returns The created TableIndex instance.
    */
    function index( columns, name ) {
        arguments.columns = isArray( columns ) ? columns : [ columns ];
        arguments.name = isNull( name ) ? "idx_#getTable()#_#arrayToList( columns, "_" )#" : arguments.name;
        return appendIndex( type = "basic", columns = columns, name = name );
    }

    /**
    * Create a primary key constraint from one or more columns.
    *
    * @columns The column or array of columns that make up the primary key.
    * @name    The name of the primary key constraint.
    *          Default: A generated name consisting of the table name and column name(s).
    *
    * @returns The created TableIndex instance.
    */
    function primaryKey( columns, name ) {
        arguments.columns = isArray( columns ) ? columns : [ columns ];
        arguments.name = isNull( name ) ? "pk_#getTable()#_#arrayToList( columns, "_" )#" : arguments.name;
        return appendIndex( type = "primary", columns = columns, name = name );
    }

    /**
    * Create a unique constraint from one or more columns.
    *
    * @columns The column or array of columns that make up the unique constraint.
    * @name    The name of the unique constraint.
    *          Default: A generated name consisting of the table name and column name(s).
    *
    * @returns The created TableIndex instance.
    */
    function unique( columns, name ) {
        arguments.columns = isArray( columns ) ? columns : [ columns ];
        arguments.name = isNull( name ) ? "unq_#getTable()#_#arrayToList( columns, "_" )#" : arguments.name;
        return appendIndex( type = "unique", columns = columns, name = name );
    }


    /*======================================
    =            Alter Commands            =
    ======================================*/

    function addColumn( column ) {
        addCommand( "addColumn", { column = column } );
        return this;
    }

    function dropColumn( name ) {
        addCommand( "dropColumn", { name = name } );
        return this;
    }

    function modifyColumn( name, column ) {
        addCommand( "modifyColumn", { from = name, to = column } );
        return this;
    }

    function renameColumn( name, column ) {
        addCommand( "renameColumn", { from = name, to = column } );
        return this;
    }

    function addConstraint( constraint ) {
        addCommand( "addConstraint", { index = constraint } );
        return this;
    }

    function dropConstraint( name ) {
        if ( ! isSimpleValue( name ) ) {
            dropConstraint( name.getName() );
        }
        else {
            addCommand( "dropConstraint", { name = name } );
        }
        return this;
    }

    function renameConstraint( oldName, newName ) {
        if ( ! isSimpleValue( arguments.oldName ) ) {
            arguments.oldName = dropConstraint( arguments.oldName.getName() );
        }
        if ( ! isSimpleValue( arguments.newName ) ) {
            arguments.newName = dropConstraint( arguments.newName.getName() );
        }
        addCommand( "renameConstraint", { from = arguments.oldName, to = arguments.newName } );
        return this;
    }



    /*=======================================
    =            Command Helpers            =
    =======================================*/

    function addCommand( command, parameters = [] ) {
        variables.commands.append( new SchemaCommand( type = command, parameters = parameters ) );
        return this;
    }

    function prependCommand( command, parameters = [] ) {
        variables.commands.prepend( new SchemaCommand( type = command, parameters = parameters ) );
        return this;
    }

    function appendColumn() {
        var newColumn = new Column( this );
        var indexMetadata = getMetadata( newColumn );
        var functionNames = indexMetadata.functions.map( function( func ) {
            return lcase( func.name );
        } );
        for ( var arg in arguments ) {
            if ( functionNames.contains( lcase( "set#arg#" ) ) && ! isNull( arguments[ arg ] ) ) {
                invoke( newColumn, "set#arg#", { 1 = arguments[ arg ] } );
            }
        }
        variables.columns.append( newColumn );
        return newColumn;
    }

    function appendIndex() {
        var newIndex = new TableIndex( this );
        var indexMetadata = getMetadata( newIndex );
        var functionNames = indexMetadata.functions.map( function( func ) {
            return lcase( func.name );
        } );
        for ( var arg in arguments ) {
            if ( functionNames.contains( lcase( "set#arg#" ) ) ) {
                invoke( newIndex, "set#arg#", { 1 = arguments[ arg ] } );
            }
        }
        variables.indexes.append( newIndex );
        return newIndex;
    }

    function toSql() {
        var statements = [];
        // we use a for loop here because we can potentially modify this array while looping over it.
        for ( var i = 1; i <= variables.commands.len(); i++ ) {
            var command = variables.commands[ i ];
            var result = invoke( getGrammar(), "compile#command.getType()#", {
                blueprint = this,
                commandParameters = command.getParameters()
            } );
            if ( result != "" ) {
                statements.append( result );
            }
        }
        return statements;
    }

}
