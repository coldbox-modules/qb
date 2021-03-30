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
     * The computed column type, if any.  Defaults to `none`.
     */
    property name="computedType" default="none";

    /**
     * The definition of the computed column, if any.
     */
    property name="computedDefinition";

    /**
     * Create a new column representation.
     *
     * @blueprint The blueprint object creating this column.
     *
     * @returns   The Column instance.
     */
    public Column function init( required Blueprint blueprint ) {
        setBlueprint( arguments.blueprint );
        variables.values = [];
        variables.computedType = "none";
        variables.computedDefinition = "";
        return this;
    }

    public Column function populate( struct args = {} ) {
        for ( var arg in arguments.args ) {
            if (
                ( structKeyExists( variables, "set#arg#" ) || structKeyExists( this, "set#arg#" ) ) &&
                !isNull( arguments.args[ arg ] )
            ) {
                invoke( this, "set#arg#", { 1: arguments.args[ arg ] } );
            }
        }
        return this;
    }

    /**
     * Attach a comment to the column.
     *
     * @comment The comment text.
     *
     * @returns The Column instance.
     */
    public Column function comment( required string comment ) {
        setComment( arguments.comment );
        return this;
    }

    /**
     * Sets a default value for the column.
     *
     * @value   The default value.
     *
     * @returns The Column instance.
     */
    public Column function default( required string value ) {
        setDefault( arguments.value );
        return this;
    }

    /**
     * Sets the column to allow null values.
     *
     * @returns The Column instance.
     */
    public Column function nullable() {
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
    public TableIndex function primaryKey( string indexName ) {
        param arguments.indexName = "pk_#getBlueprint().getTable()#_#getName()#";
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
    public TableIndex function references( required string column ) {
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
    public Column function unsigned() {
        setUnsigned( true );
        return this;
    }

    /**
     * Sets the column to have the UNIQUE constraint.
     *
     * @returns The Column instance.
     */
    public Column function unique() {
        setUnique( true );
        return this;
    }

    /**
     * @returns true if the object is a column
     */
    public boolean function isColumn() {
        return true;
    }

    /**
     * Sets the default equal to CURRENT_TIMESTAMP
     *
     * @returns Column
     */
    public Column function withCurrent() {
        setDefault( "CURRENT_TIMESTAMP" );
        return this;
    }

    /**
     * Marks the column as a stored computed column.
     *
     * @expression  The SQL used to define the computed column.
     *
     * @returns     Column
     */
    public Column function storedAs( required string expression ) {
        variables.computedType = "stored";
        variables.computedDefinition = arguments.expression;
        return this;
    }

    /**
     * Marks the column as a virtual computed column.
     *
     * @expression  The SQL used to define the computed column.
     *
     * @returns     Column
     */
    public Column function virtualAs( required string expression ) {
        variables.computedType = "virtual";
        variables.computedDefinition = arguments.expression;
        return this;
    }

}
