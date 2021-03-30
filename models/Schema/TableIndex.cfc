/**
 * Represents an index or constraint in the schema.
 */
component accessors="true" {

    /**
     * The constraint type.
     */
    property name="type";

    /**
     * The constraint name.
     */
    property name="name";

    /**
     * The foreign key column
     * For example, `country_id` referencing `countries`.`id`.
     */
    property name="foreignKey";

    /**
     * The column or columns that make up the constraint.
     */
    property name="columns";

    /**
     * The table the foreign key is referencing.
     * For example, `countries` for a `country_id` column.
     */
    property name="table";

    /**
     * The strategy for updating foreign keys when the parent key is updated.
     * Available values are:
     * RESTRICT, CASCADE, SET NULL, NO ACTION, SET DEFAULT
     */
    property name="onUpdate" default="NO ACTION";

    /**
     * The strategy for updating foreign keys when the parent key is deleted.
     * Available values are:
     * RESTRICT, CASCADE, SET NULL, NO ACTION, SET DEFAULT
     */
    property name="onDelete" default="NO ACTION";

    /**
     * Create a new TableIndex instance.
     *
     * @returns A TableIndex instance.
     */
    public TableIndex function init() {
        variables.columns = [];
        return this;
    }

    public TableIndex function populate( struct args = {} ) {
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
     * Set the referencing column for a foreign key relationship.
     * For example, `id` for a `country_id` column.
     *
     * @columns A column or array of columns that represents the foreign key reference.
     *
     * @returns The TableIndex instance.
     */
    public TableIndex function references( required any columns ) {
        setColumns( arrayWrap( arguments.columns ) );
        return this;
    }

    /**
     * Sets the referencing table for a foreign key relationship.
     * For example, `countries` for a `country_id` column.
     *
     * @table   The referencing table name.
     *
     * @returns The TableIndex instance.
     */
    public TableIndex function onTable( required string table ) {
        setTable( arguments.table );
        return this;
    }

    /**
     * Set the strategy for updating foreign keys when the parent key is updated.
     *
     * @option  The strategy to use. Available values are:
     *          RESTRICT, CASCADE, SET NULL, NO ACTION, SET DEFAULT
     *
     * @returns The TableIndex instance.
     */
    public TableIndex function onUpdate( required string option ) {
        setOnUpdate( arguments.option );
        return this;
    }

    /**
     * Set the strategy for updating foreign keys when the parent key is deleted.
     *
     * @option  The strategy to use. Available values are:
     *          RESTRICT, CASCADE, SET NULL, NO ACTION, SET DEFAULT
     *
     * @returns The TableIndex instance.
     */
    public TableIndex function onDelete( required string option ) {
        setOnDelete( arguments.option );
        return this;
    }

    /**
     * Set the column or columns that make up the constraint.
     *
     * @columns A single column or an array of columns that make up the constraint.
     *
     * @returns The TableIndex instance.
     */
    public TableIndex function setColumns( required any columns ) {
        variables.columns = arrayWrap( arguments.columns );
        return this;
    }

    private array function arrayWrap( required any value ) {
        return isArray( arguments.value ) ? arguments.value : [ arguments.value ];
    }

}
