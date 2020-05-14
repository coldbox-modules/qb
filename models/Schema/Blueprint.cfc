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

    function datetimeTz( name ) {
        arguments.type = "datetimeTz";
        return appendColumn( argumentCollection = arguments );
    }

    function decimal( name, length = 10, precision = 0 ) {
        arguments.type = "decimal";
        return appendColumn( argumentCollection = arguments );
    }

    function enum( name, values ) {
        prependCommand( "addType", { name: name, values: values } );
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

    function unicodeLongText( name ) {
        arguments.type = "unicodeLongText";
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

    function unicodeMediumText( name ) {
        arguments.type = "unicodeMediumText";
        return appendColumn( argumentCollection = arguments );
    }

    function lineString( name ) {
        arguments.type = "lineString";
        return appendColumn( argumentCollection = arguments );
    }

    function money( name ) {
        arguments.type = "money";
        return appendColumn( argumentCollection = arguments );
    }

    function smallMoney( name ) {
        arguments.type = "smallMoney";
        return appendColumn( argumentCollection = arguments );
    }

    function morphs( name ) {
        unsignedInteger( "#name#_id" );
        string( "#name#_type" );
        appendIndex( type = "basic", name = "#name#_index", columns = [ "#name#_id", "#name#_type" ] );
        return this;
    }

    function nullableMorphs( name ) {
        unsignedInteger( "#name#_id" ).nullable();
        string( "#name#_type" ).nullable();
        appendIndex( type = "basic", name = "#name#_index", columns = [ "#name#_id", "#name#_type" ] );
        return this;
    }

    function nullableTimestamps() {
        appendColumn( name = "createdDate", type = "timestamp", nullable = true );
        appendColumn( name = "modifiedDate", type = "timestamp", nullable = true );
        return this;
    }

    function point( name ) {
        arguments.type = "point";
        return appendColumn( argumentCollection = arguments );
    }

    function polygon( name ) {
        arguments.type = "polygon";
        return appendColumn( argumentCollection = arguments );
    }

    function raw( sql ) {
        var expression = new qb.models.Query.Expression( sql );
        variables.columns.append( expression );
        return expression;
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

    function softDeletes() {
        appendColumn( name = "deletedDate", type = "timestamp", nullable = true );
        return this;
    }

    function softDeletesTz() {
        appendColumn( name = "deletedDate", type = "timestampTz", nullable = true );
        return this;
    }

    function string( name, length ) {
        arguments.type = "string";
        if ( isNull( arguments.length ) ) {
            arguments.length = getSchemaBuilder().getDefaultStringLength();
        }
        return appendColumn( argumentCollection = arguments );
    }

    function unicodeString( name, length ) {
        arguments.type = "unicodeString";
        if ( isNull( arguments.length ) ) {
            arguments.length = getSchemaBuilder().getDefaultStringLength();
        }
        return appendColumn( argumentCollection = arguments );
    }

    function text( name ) {
        arguments.type = "text";
        return appendColumn( argumentCollection = arguments );
    }

    function unicodeText( name ) {
        arguments.type = "unicodeText";
        return appendColumn( argumentCollection = arguments );
    }

    function time( name ) {
        arguments.type = "time";
        return appendColumn( argumentCollection = arguments );
    }

    function timeTz( name ) {
        arguments.type = "timeTz";
        return appendColumn( argumentCollection = arguments );
    }

    function timestamp( name ) {
        arguments.type = "timestamp";
        return appendColumn( argumentCollection = arguments );
    }

    function timestamps() {
        appendColumn( name = "createdDate", type = "timestamp" ).withCurrent();
        appendColumn( name = "modifiedDate", type = "timestamp" ).withCurrent();
        return this;
    }

    function timestampTz( name ) {
        arguments.type = "timestampTz";
        return appendColumn( argumentCollection = arguments );
    }

    function timestampsTz() {
        appendColumn( name = "createdDate", type = "timestampTz" ).withCurrent();
        appendColumn( name = "modifiedDate", type = "timestampTz" ).withCurrent();
        return this;
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
        arguments.type = "UUID";
        arguments.length = 36;
        return appendColumn( argumentCollection = arguments );
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

    /**
     * Create a default constraint from a column.
     *
     * @columns The column that makes up the default constraint.
     * @name    The name of the default constraint.
     *          Default: A generated name consisting of the table name and column name.
     *
     * @returns The created TableIndex instance.
     */
    function default( column, name ) {
        arguments.name = isNull( name ) ? "df_#getTable()#_#column#" : arguments.name;
        return createIndex( type = "default", columns = column, name = name );
    }


    /*======================================
    =            Alter Commands            =
    ======================================*/

    function addColumn( column ) {
        addCommand( "addColumn", { column: column } );
        return this;
    }

    function dropColumn( name ) {
        addCommand( "dropColumn", { name: name } );
        return this;
    }

    function modifyColumn( name, column ) {
        addCommand( "modifyColumn", { from: name, to: column } );
        return this;
    }

    function renameColumn( name, column ) {
        addCommand( "renameColumn", { from: name, to: column } );
        return this;
    }

    function addConstraint( constraint ) {
        addCommand( "addConstraint", { index: constraint } );
        return this;
    }

    function dropConstraint( name ) {
        if ( !isSimpleValue( name ) ) {
            dropConstraint( name.getName() );
        } else {
            addCommand( "dropConstraint", { name: name } );
        }
        return this;
    }

    function dropForeignKey( name ) {
        if ( !isSimpleValue( name ) ) {
            dropForeignKey( name.getName() );
        } else {
            addCommand( "dropForeignKey", { name: name } );
        }
        return this;
    }

    function renameConstraint( oldName, newName ) {
        if ( !isSimpleValue( arguments.oldName ) ) {
            arguments.oldName = dropConstraint( arguments.oldName.getName() );
        }
        if ( !isSimpleValue( arguments.newName ) ) {
            arguments.newName = dropConstraint( arguments.newName.getName() );
        }
        addCommand( "renameConstraint", { from: arguments.oldName, to: arguments.newName } );
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
            return lCase( func.name );
        } );
        for ( var arg in arguments ) {
            if ( functionNames.contains( lCase( "set#arg#" ) ) && !isNull( arguments[ arg ] ) ) {
                invoke( newColumn, "set#arg#", { 1: arguments[ arg ] } );
            }
        }
        variables.columns.append( newColumn );
        return newColumn;
    }

    function appendIndex() {
        var newIndex = createIndex( argumentCollection = arguments );
        variables.indexes.append( newIndex );
        return newIndex;
    }

    function createIndex() {
        var newIndex = new TableIndex( this );
        var indexMetadata = getMetadata( newIndex );
        var functionNames = indexMetadata.functions.map( function( func ) {
            return lCase( func.name );
        } );
        for ( var arg in arguments ) {
            if ( functionNames.contains( lCase( "set#arg#" ) ) ) {
                invoke( newIndex, "set#arg#", { 1: arguments[ arg ] } );
            }
        }
        return newIndex;
    }

    function toSql() {
        var statements = [];
        // we use a for loop here because we can potentially modify this array while looping over it.
        for ( var i = 1; i <= variables.commands.len(); i++ ) {
            var command = variables.commands[ i ];
            var result = invoke(
                getGrammar(),
                "compile#command.getType()#",
                { blueprint: this, commandParameters: command.getParameters() }
            );
            if ( isArray( result ) || ( isSimpleValue( result ) && result != "" ) ) {
                statements.append( result, true );
            }
        }
        return statements;
    }

}
