/**
 * Exposes the public JSON builder API while delegating JSON definition work
 * to the lazily instantiated JsonQueryClause collaborator.
 */
component {

    /**
     * Creates a grammar-aware JSON scalar path expression.
     *
     * The explicit form accepts a column and an array of path segments. Arrow
     * syntax is accepted as a shortcut and is normalized to the same shape.
     *
     * @column The JSON column, or an arrow path such as `profile->name`.
     * @path The JSON object keys and array indexes to traverse.
     * @alias An optional select alias.
     *
     * @return A typed column definition understood by each grammar.
     */
    public struct function jsonPath( required string column, array path = [], string alias ) {
        return getCollaborator( "JsonQueryClause" ).jsonPath(
            builder = this,
            column = arguments.column,
            path = arguments.path,
            alias = arguments.keyExists( "alias" ) ? arguments.alias : ""
        );
    }

    /**
     * Adds a JSON containment predicate.
     *
     * Explicit: `whereJsonContains( "profile", [ "languages" ], "en" )`
     * Shortcut: `whereJsonContains( "profile->languages", "en" )`
     */
    public QueryBuilder function whereJsonContains(
        required string column,
        any path = [],
        any value = "__QB_INTERNAL_JSON_VALUE_OMITTED_8E1A33F6__",
        string combinator = "and",
        boolean negate = false
    ) {
        if ( getValidateOperatorsAndCombinators() ) {
            getCollaborator( "QueryValidator" ).validateCombinator( arguments.combinator );
        }

        // Native BoxLang materializes omitted optional arguments as null, so use a non-null
        // default token here because null is also a valid JSON containment value.
        var valueWasOmitted = !isNull( arguments.value ) &&
        isSimpleValue( arguments.value ) &&
        arguments.value == "__QB_INTERNAL_JSON_VALUE_OMITTED_8E1A33F6__";
        if ( valueWasOmitted ) {
            arguments.value = arguments.path;
            arguments.path = [];
        }

        var valueDefinition = { isNull: isNull( arguments.value ) };
        if ( !valueDefinition.isNull ) {
            valueDefinition.value = arguments.value;
        }

        return getCollaborator( "JsonQueryClause" ).whereJsonContains(
            builder = this,
            column = arguments.column,
            path = arguments.path,
            valueDefinition = valueDefinition,
            combinator = arguments.combinator,
            negate = arguments.negate
        );
    }

    public QueryBuilder function orWhereJsonContains(
        required string column,
        any path = [],
        any value = "__QB_INTERNAL_JSON_VALUE_OMITTED_8E1A33F6__"
    ) {
        return whereJsonContains( argumentCollection = arguments, combinator = "or" );
    }

    public QueryBuilder function whereJsonDoesntContain(
        required string column,
        any path = [],
        any value = "__QB_INTERNAL_JSON_VALUE_OMITTED_8E1A33F6__"
    ) {
        return whereJsonContains( argumentCollection = arguments, negate = true );
    }

    public QueryBuilder function orWhereJsonDoesntContain(
        required string column,
        any path = [],
        any value = "__QB_INTERNAL_JSON_VALUE_OMITTED_8E1A33F6__"
    ) {
        return whereJsonContains( argumentCollection = arguments, combinator = "or", negate = true );
    }

    /**
     * Adds a JSON path existence predicate.
     *
     * Explicit: `whereJsonExists( "profile", [ "name" ] )`
     * Shortcut: `whereJsonExists( "profile->name" )`
     */
    public QueryBuilder function whereJsonExists(
        required string column,
        array path = [],
        string combinator = "and",
        boolean negate = false
    ) {
        if ( getValidateOperatorsAndCombinators() ) {
            getCollaborator( "QueryValidator" ).validateCombinator( arguments.combinator );
        }
        return getCollaborator( "JsonQueryClause" ).whereJsonExists(
            builder = this,
            column = arguments.column,
            path = arguments.path,
            combinator = arguments.combinator,
            negate = arguments.negate
        );
    }

    public QueryBuilder function orWhereJsonExists( required string column, array path = [] ) {
        return whereJsonExists( argumentCollection = arguments, combinator = "or" );
    }

    public QueryBuilder function whereJsonDoesntExist( required string column, array path = [] ) {
        return whereJsonExists( argumentCollection = arguments, negate = true );
    }

    public QueryBuilder function orWhereJsonDoesntExist( required string column, array path = [] ) {
        return whereJsonExists( argumentCollection = arguments, combinator = "or", negate = true );
    }

    /**
     * Adds a JSON array length predicate.
     *
     * Explicit: `whereJsonLength( "profile", [ "languages" ], ">", 1 )`
     * Shortcut: `whereJsonLength( "profile->languages", ">", 1 )`
     * Explicit equality shortcut: `whereJsonLength( "profile", [ "languages" ], 1 )`
     * Arrow equality shortcut: `whereJsonLength( "profile->languages", 1 )`
     */
    public QueryBuilder function whereJsonLength(
        required string column,
        any path = [],
        any operator,
        any value,
        string combinator = "and"
    ) {
        if ( getValidateOperatorsAndCombinators() ) {
            getCollaborator( "QueryValidator" ).validateCombinator( arguments.combinator );
        }
        if ( isNull( arguments.operator ) ) {
            if ( isNull( arguments.value ) ) {
                arguments.value = arguments.path;
                arguments.path = [];
            }
            arguments.operator = "=";
        } else if ( isNull( arguments.value ) ) {
            arguments.value = arguments.operator;
            if ( isArray( arguments.path ) ) {
                arguments.operator = "=";
            } else {
                arguments.operator = arguments.path;
                arguments.path = [];
            }
        }
        if ( getValidateOperatorsAndCombinators() ) {
            getCollaborator( "QueryValidator" ).validateOperator( arguments.operator );
        }

        var valueDefinition = { isNull: isNull( arguments.value ) };
        if ( !valueDefinition.isNull ) {
            valueDefinition.value = arguments.value;
        }
        return getCollaborator( "JsonQueryClause" ).whereJsonLength(
            builder = this,
            column = arguments.column,
            path = arguments.path,
            operator = arguments.operator,
            valueDefinition = valueDefinition,
            combinator = arguments.combinator
        );
    }

    public QueryBuilder function orWhereJsonLength(
        required string column,
        any path = [],
        any operator,
        any value
    ) {
        return whereJsonLength( argumentCollection = arguments, combinator = "or" );
    }

}
