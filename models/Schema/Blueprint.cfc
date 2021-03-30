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

    public Blueprint function init( required SchemaBuilder schemaBuilder, required any grammar ) {
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

    public Column function bigIncrements( required string name, string indexName ) {
        arguments.autoIncrement = true;
        param arguments.indexName = "pk_#getTable()#_#name#";
        appendIndex( type = "primary", columns = arguments.name, name = arguments.indexName );
        return unsignedBigInteger( argumentCollection = arguments );
    }

    public Column function bigInteger( required string name, numeric precision ) {
        arguments.type = "bigInteger";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function bit( required string name, numeric length = 1 ) {
        arguments.type = "bit";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function boolean( required string name ) {
        arguments.length = 1;
        arguments.type = "boolean";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function char( required string name, numeric length = 1 ) {
        arguments.length = clamp( 1, arguments.length, 255 );
        arguments.type = "char";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function date( required string name ) {
        arguments.type = "date";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function datetime( required string name ) {
        arguments.type = "datetime";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function datetimeTz( required string name ) {
        arguments.type = "datetimeTz";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function decimal( required string name, numeric length = 10, numeric precision = 0 ) {
        arguments.type = "decimal";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function enum( required string name, required array values ) {
        prependCommand( "addType", { name: arguments.name, values: arguments.values } );
        arguments.type = "enum";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function float( required string name, numeric length = 10, numeric precision = 0 ) {
        arguments.type = "float";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function increments( required string name, string indexName ) {
        arguments.autoIncrement = true;
        param arguments.indexName = "pk_#getTable()#_#name#";
        appendIndex( type = "primary", columns = arguments.name, name = arguments.indexName );
        return unsignedInteger( argumentCollection = arguments );
    }

    public Column function integer( required string name, numeric precision ) {
        arguments.type = "integer";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function json( required string name ) {
        arguments.type = "json";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function longText( required string name ) {
        arguments.type = "longText";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function unicodeLongText( required string name ) {
        arguments.type = "unicodeLongText";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function mediumIncrements( required string name, string indexName ) {
        arguments.autoIncrement = true;
        param arguments.indexName = "pk_#getTable()#_#name#";
        appendIndex( type = "primary", columns = arguments.name, name = arguments.indexName );
        return unsignedMediumInteger( argumentCollection = arguments );
    }

    public Column function mediumInteger( required string name, numeric precision ) {
        arguments.type = "mediumInteger";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function mediumText( required string name ) {
        arguments.type = "mediumText";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function unicodeMediumText( required string name ) {
        arguments.type = "unicodeMediumText";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function lineString( required string name ) {
        arguments.type = "lineString";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function money( required string name ) {
        arguments.type = "money";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function smallMoney( required string name ) {
        arguments.type = "smallMoney";
        return appendColumn( argumentCollection = arguments );
    }

    public Blueprint function morphs( required string name ) {
        var morphIdColumnName = arguments.name & "_id";
        var morphTypeColumnName = arguments.name & "_type";
        unsignedInteger( morphIdColumnName );
        string( morphTypeColumnName );
        appendIndex(
            type = "basic",
            name = "#arguments.name#_index",
            columns = [ morphIdColumnName, morphTypeColumnName ]
        );
        return this;
    }

    public Blueprint function nullableMorphs( required string name ) {
        var morphIdColumnName = arguments.name & "_id";
        var morphTypeColumnName = arguments.name & "_type";
        unsignedInteger( morphIdColumnName ).nullable();
        string( morphTypeColumnName ).nullable();
        appendIndex(
            type = "basic",
            name = "#arguments.name#_index",
            columns = [ morphIdColumnName, morphTypeColumnName ]
        );
        return this;
    }

    public Blueprint function nullableTimestamps() {
        appendColumn( name = "createdDate", type = "timestamp", nullable = true );
        appendColumn( name = "modifiedDate", type = "timestamp", nullable = true );
        return this;
    }

    public Column function point( required string name ) {
        arguments.type = "point";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function polygon( required string name ) {
        arguments.type = "polygon";
        return appendColumn( argumentCollection = arguments );
    }

    public Expression function raw( sql ) {
        var expression = new qb.models.Query.Expression( arguments.sql );
        variables.columns.append( expression );
        return expression;
    }

    public Column function smallIncrements( required string name, string indexName ) {
        arguments.autoIncrement = true;
        param arguments.indexName = "pk_#getTable()#_#name#";
        appendIndex( type = "primary", columns = arguments.name, name = arguments.indexName );
        return unsignedSmallInteger( argumentCollection = arguments );
    }

    public Column function smallInteger( required string name, numeric precision ) {
        arguments.type = "smallInteger";
        return appendColumn( argumentCollection = arguments );
    }

    public Blueprint function softDeletes() {
        appendColumn( name = "deletedDate", type = "timestamp", nullable = true );
        return this;
    }

    public Blueprint function softDeletesTz() {
        appendColumn( name = "deletedDate", type = "timestampTz", nullable = true );
        return this;
    }

    public Column function string( required string name, numeric length ) {
        arguments.type = "string";
        param arguments.length = getSchemaBuilder().getDefaultStringLength();
        return appendColumn( argumentCollection = arguments );
    }

    public Column function unicodeString( required string name, numeric length ) {
        arguments.type = "unicodeString";
        param arguments.length = getSchemaBuilder().getDefaultStringLength();
        return appendColumn( argumentCollection = arguments );
    }

    public Column function text( required string name ) {
        arguments.type = "text";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function unicodeText( required string name ) {
        arguments.type = "unicodeText";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function time( required string name ) {
        arguments.type = "time";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function timeTz( required string name ) {
        arguments.type = "timeTz";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function timestamp( required string name ) {
        arguments.type = "timestamp";
        return appendColumn( argumentCollection = arguments );
    }

    public Blueprint function timestamps() {
        appendColumn( name = "createdDate", type = "timestamp" ).withCurrent();
        appendColumn( name = "modifiedDate", type = "timestamp" ).withCurrent();
        return this;
    }

    public Column function timestampTz( required string name ) {
        arguments.type = "timestampTz";
        return appendColumn( argumentCollection = arguments );
    }

    public Blueprint function timestampsTz() {
        appendColumn( name = "createdDate", type = "timestampTz" ).withCurrent();
        appendColumn( name = "modifiedDate", type = "timestampTz" ).withCurrent();
        return this;
    }

    public Column function tinyIncrements( required string name, string indexName ) {
        arguments.autoIncrement = true;
        param arguments.indexName = "pk_#getTable()#_#name#";
        appendIndex( type = "primary", columns = arguments.name, name = arguments.indexName );
        return unsignedTinyInteger( argumentCollection = arguments );
    }

    public Column function tinyInteger( required string name, numeric precision ) {
        arguments.type = "tinyInteger";
        return appendColumn( argumentCollection = arguments );
    }

    public Column function unsignedBigInteger( required string name, numeric precision ) {
        arguments.unsigned = true;
        return bigInteger( argumentCollection = arguments );
    }

    public Column function unsignedInteger( required string name, numeric precision ) {
        arguments.unsigned = true;
        return integer( argumentCollection = arguments );
    }

    public Column function unsignedMediumInteger( required string name, numeric precision ) {
        arguments.unsigned = true;
        return mediumInteger( argumentCollection = arguments );
    }

    public Column function unsignedSmallInteger( required string name, numeric precision ) {
        arguments.unsigned = true;
        return smallInteger( argumentCollection = arguments );
    }

    public Column function unsignedTinyInteger( required string name, numeric precision ) {
        arguments.unsigned = true;
        return tinyInteger( argumentCollection = arguments );
    }

    public Column function uuid( required string name ) {
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
    public TableIndex function foreignKey( required any columns, string name ) {
        arguments.columns = arrayWrap( arguments.columns );
        param arguments.name = "fk_#getTable()#_#arrayToList( columns, "_" )#";
        return appendIndex( type = "foreign", foreignKey = arguments.columns, name = arguments.name );
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
    public TableIndex function index( required any columns, string name ) {
        arguments.columns = arrayWrap( arguments.columns );
        param arguments.name = "idx_#getTable()#_#arrayToList( columns, "_" )#";
        return appendIndex( type = "basic", columns = arguments.columns, name = arguments.name );
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
    public TableIndex function primaryKey( required any columns, string name ) {
        arguments.columns = arrayWrap( arguments.columns );
        param arguments.name = "pk_#getTable()#_#arrayToList( columns, "_" )#";
        return appendIndex( type = "primary", columns = arguments.columns, name = arguments.name );
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
    public TableIndex function unique( required any columns, string name ) {
        arguments.columns = arrayWrap( arguments.columns );
        param arguments.name = "unq_#getTable()#_#arrayToList( columns, "_" )#";
        return appendIndex( type = "unique", columns = arguments.columns, name = arguments.name );
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
    public TableIndex function default( required string column, string name ) {
        param arguments.name = "df_#getTable()#_#column#";
        return createIndex( type = "default", columns = arguments.column, name = arguments.name );
    }


    /*======================================
    =            Alter Commands            =
    ======================================*/

    public Blueprint function addColumn( required any column ) {
        addCommand( "addColumn", { column: arguments.column } );
        return this;
    }

    public Blueprint function dropColumn( required any name ) {
        addCommand( "dropColumn", { name: arguments.name } );
        return this;
    }

    public Blueprint function modifyColumn( required any name, required any column ) {
        addCommand( "modifyColumn", { from: arguments.name, to: arguments.column } );
        return this;
    }

    public Blueprint function renameColumn( required any name, required any column ) {
        addCommand( "renameColumn", { from: arguments.name, to: arguments.column } );
        return this;
    }

    public Blueprint function addConstraint( required TableIndex constraint ) {
        addCommand( "addConstraint", { index: arguments.constraint } );
        return this;
    }

    public Blueprint function dropConstraint( required any name ) {
        if ( !isSimpleValue( arguments.name ) ) {
            dropConstraint( arguments.name.getName() );
        } else {
            addCommand( "dropConstraint", { name: arguments.name } );
        }
        return this;
    }

    public Blueprint function dropForeignKey( required any name ) {
        if ( !isSimpleValue( arguments.name ) ) {
            dropForeignKey( arguments.name.getName() );
        } else {
            addCommand( "dropForeignKey", { name: arguments.name } );
        }
        return this;
    }

    public Blueprint function renameConstraint( required any oldName, required any newName ) {
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

    public Blueprint function addCommand( required string command, struct parameters = {} ) {
        variables.commands.append( new SchemaCommand( type = arguments.command, parameters = arguments.parameters ) );
        return this;
    }

    public Blueprint function prependCommand( required string command, struct parameters = {} ) {
        variables.commands.prepend( new SchemaCommand( type = arguments.command, parameters = arguments.parameters ) );
        return this;
    }

    public Column function appendColumn() {
        var newColumn = new Column( this );
        newColumn.populate( arguments );
        variables.columns.append( newColumn );
        return newColumn;
    }

    public TableIndex function appendIndex() {
        var newIndex = createIndex( argumentCollection = arguments );
        variables.indexes.append( newIndex );
        return newIndex;
    }

    public TableIndex function createIndex() {
        var newIndex = new TableIndex( this );
        newIndex.populate( arguments );
        return newIndex;
    }

    public array function toSql() {
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

    private array function arrayWrap( required any value ) {
        return isArray( arguments.value ) ? arguments.value : [ arguments.value ];
    }

    private numeric function clamp( required numeric lowerLimit, required numeric result, required numeric upperLimit ) {
        arguments.result = ceiling( arguments.result );
        arguments.result = min( arguments.result, arguments.upperLimit );
        return max( arguments.lowerLimit, arguments.result );
    }

}
