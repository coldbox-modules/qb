component accessors="true" {

    property name="schemaBuilder";
    property name="grammar";
    property name="table";

    property name="columns";
    property name="indexes";

    function init( schemaBuilder, grammar ) {
        setSchemaBuilder( schemaBuilder );
        setGrammar( grammar );

        variables.columns = [];
        variables.indexes = [];
        return this;
    }

    function toSql() {
        return getGrammar().compileCreate( this );
    }

    function addColumn() {
        var newColumn = new Column( this );
        var indexMetadata = getMetadata( newColumn );
        var functionNames = indexMetadata.functions.map( function( func ) {
            return lcase( func.name );
        } );
        for ( var arg in arguments ) {
            if ( functionNames.contains( lcase( "set#arg#" ) ) ) {
                invoke( newColumn, "set#arg#", { 1 = arguments[ arg ] } );
            }
        }
        variables.columns.append( newColumn );
        return newColumn;
    }

    function addIndex() {
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

    /*====================================
    =            Column Types            =
    ====================================*/

    function bigIncrements( name ) {
        arguments.autoIncrement = true;
        addIndex( type = "primary", column = name );
        return unsignedBigInteger( argumentCollection = arguments );
    }

    function bigInteger( name ) {
        arguments.type = "bigInteger";
        return addColumn( argumentCollection = arguments );
    }

    function boolean( name ) {
        arguments.length = 1;
        return tinyInteger( argumentCollection = arguments );
    }

    function increments( name ) {
        arguments.autoIncrement = true;
        addIndex( type = "primary", column = name );
        return unsignedInt( argumentCollection = arguments );
    }

    function integer( name, precision = 10 ) {
        arguments.type = "integer";
        return addColumn( argumentCollection = arguments );
    }

    function tinyInteger( name, length = "" ) {
        arguments.type = "tinyInteger";
        return addColumn( argumentCollection = arguments );
    }

    function unsignedBigInteger( name ) {
        arguments.unsigned = true;
        return bigInteger( argumentCollection = arguments );
    }

    function unsignedInteger( name ) {
        arguments.unsigned = true;
        return integer( argumentCollection = arguments );
    }

    function unsignedInt( name ) {
        arguments.type = "integer";
        arguments.unsigned = true;
        return addColumn( argumentCollection = arguments );
    }

    function string( name, length ) {
        arguments.type = "string";
        if ( isNull( arguments.length ) ) {
            arguments.length = getSchemaBuilder().getDefaultStringLength();
        }
        return addColumn( argumentCollection = arguments );
    }

    function text( name ) {
        arguments.type = "text";
        return addColumn( argumentCollection = arguments );
    }

    function timestamp( name ) {
        arguments.type = "timestamp";
        return addColumn( argumentCollection = arguments );
    }

}
