/**
* Represents a column in a create or alter sql schema.
*/
component accessors="true" {

    /**
    * Reference to the owning blueprint.
    * This allows methods to add commands to the schema builder as needed.
    */
    property name="blueprint";

    /**
    * The column name.
    */
    property name="name";

    /**
    * The schema builder type.
    */
    property name="type";

    /**
    * The column length.
    */
    property name="length" default="255";

    /**
    * The precision for the column.
    */
    property name="precision";

    /**
    * Whether the column value can be null.
    */
    property name="nullable" default="false";

    /**
    * Whether the column value is only unsigned.
    */
    property name="unsigned" default="false";

    /**
    * Whether the column is auto incremented.
    */
    property name="autoIncrement" default="false";

    /*
    * The default value for the column.
    */
    property name="default" default="";

    /**
    * A comment for the column.
    */
    property name="comment" default="";

    /**
    * Whether the column is unique.
    */
    property name="unique" default="false";

    /**
    * The possible values for the column.
    * Used mainly by the ENUM type.
    */
    property name="values";

    /**
    * Create a new column representation.
    *
    * @blueprint The blueprint object creating this column.
    *
    * @returns   The Column instance.
    */
    function init( blueprint ) {
        setBlueprint( blueprint );
        variables.values = [];
        return this;
    }

    /**
    * Attach a comment to the column.
    *
    * @comment The comment text.
    *
    * @returns The Column instance.
    */
    function comment( comment ) {
        setComment( comment );
        return this;
    }

    /**
    * Sets a default value for the column.
    *
    * @value   The default value.
    *
    * @returns The Column instance.
    */
    function default( value ) {
        setDefault( value );
        return this;
    }

    /**
    * Sets the column to allow null values.
    *
    * @returns The Column instance.
    */
    function nullable() {
        setNullable( true );
        return this;
    }

    /**
    * Adds the column as a primary key for the table.
    *
    * @indexName Optional. The name to use for the primary key constraint.
    *            If omitted, the indexName is derived from the table name and column name.
    *
    * @returns   The TableIndex instance created.
    */
    function primaryKey( indexName ) {
        arguments.indexName = isNull( arguments.indexName ) ? "pk_#getBlueprint().getTable()#_#getName()#" : arguments.indexName;
        return getBlueprint().appendIndex( type = "primary", columns = getName(), name = arguments.indexName );
    }

    /**
    * Creates a foreign key constraint for the column.
    * Additional configuration of the constraint is done by
    * calling methods on the returned TableIndex instance.
    *
    * @column  The column name referenced on the related table.
    *
    * @returns The TableIndex instance created.
    */
    function references( column ) {
        return getBlueprint().appendIndex(
            type = "foreign",
            columns = [ column ],
            foreignKey = [ getName() ],
            name = "fk_#getBlueprint().getTable()#_#getName()#"
        );
    }

    /**
    * Sets the column as unsigned.
    *
    * @returns The Column instance.
    */
    function unsigned() {
        setUnsigned( true );
        return this;
    }

    /**
    * Sets the column to have the UNIQUE constraint.
    *
    * @returns The Column instance.
    */
    function unique() {
        setUnique( true );
        return this;
    }
    
    /**
    * @returns true if the object is a column
    */
    function isColumn() {
        return true;
    }

}
