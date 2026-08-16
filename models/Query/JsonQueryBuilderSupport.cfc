/**
 * JSON query builder methods split from QueryBuilder to keep component
 * metadata within JVM method-size limits on all supported CFML engines.
 */
component {

    /**
     * Creates a grammar-aware JSON scalar path expression.
     *
     * The explicit form accepts a column and an array of path segments.  Arrow
     * syntax is accepted as a shortcut and is normalized to the same shape.
     * Numeric path segments address JSON array indexes.
     *
     * @column The JSON column, or an arrow path such as `profile->name`.
     * @path The JSON object keys and array indexes to traverse.
     * @alias An optional select alias.
     *
     * @return A typed column definition understood by each grammar.
     */
    public struct function jsonPath( required string column, array path = [], string alias ) {
        var parsedColumn = trim( arguments.column );
        var parsedAlias = structKeyExists( arguments, "alias" ) ? arguments.alias : "";

        var aliasMatch = reFindNoCase(
            "(.*)(?:\sAS\s)(.*)",
            parsedColumn,
            1,
            true
        );
        if ( aliasMatch.pos.len() >= 3 && aliasMatch.pos[ 1 ] > 0 ) {
            parsedAlias = trim( mid( parsedColumn, aliasMatch.pos[ 3 ], aliasMatch.len[ 3 ] ) );
            parsedColumn = trim( mid( parsedColumn, aliasMatch.pos[ 2 ], aliasMatch.len[ 2 ] ) );
        }

        var arrowParts = listToArray( parsedColumn, "->", false, true );
        if ( arrowParts.len() > 1 ) {
            if ( !arguments.path.isEmpty() ) {
                throw(
                    type = "QBInvalidJsonPath",
                    message = "JSON paths cannot combine arrow syntax with an explicit path array."
                );
            }
            parsedColumn = trim( arrowParts.shift() );
            arguments.path = arrowParts.map( ( segment ) => normalizeJsonPathSegment( segment ) );
        } else {
            arguments.path = arguments.path.map( ( segment ) => segment );
        }

        var definition = {
            type: "jsonPath",
            value: { column: variables.columnFormatter( parsedColumn ), path: arguments.path }
        };
        if ( len( parsedAlias ) ) {
            definition.alias = parsedAlias;
        }
        return definition;
    }

    /**
     * Normalizes an arrow-syntax JSON path segment for grammar compilation.
     * Numeric shortcut segments are converted to numbers so grammars can
     * distinguish JSON array indexes from object keys. Explicit path segments
     * preserve their CFML types and do not pass through this function.
     *
     * @segment The shortcut JSON object key or array index to normalize.
     *
     * @return The trimmed object key or numeric array index.
     */
    private any function normalizeJsonPathSegment( required any segment ) {
        var normalized = trim( arguments.segment );
        return reFind( "^\d+$", normalized ) ? val( normalized ) : normalized;
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
        any value,
        string combinator = "and",
        boolean negate = false
    ) {
        if ( this.getValidateOperatorsAndCombinators() && isInvalidJsonCombinator( arguments.combinator ) ) {
            throw( type = "InvalidSQLType", message = "Illegal combinator" );
        }
        var valueWasOmitted = !arguments.keyExists( "value" );
        if ( isNull( arguments.value ) ) {
            var pathCarriesValue = !isArray( arguments.path ) ||
            ( arguments.column.find( "->" ) > 0 && !arguments.path.isEmpty() );
            valueWasOmitted = server.keyExists( "boxlang" )
             ? pathCarriesValue
             : valueWasOmitted || pathCarriesValue;
        }
        if ( valueWasOmitted ) {
            arguments.value = arguments.path;
            arguments.path = [];
        }
        var containsPath = jsonPath( column = arguments.column, path = arguments.path );
        containsPath.value.nullValue = isNull( arguments.value );
        variables.wheres.append( {
            type: "jsonContains",
            path: containsPath,
            combinator: arguments.combinator,
            negate: arguments.negate
        } );
        if ( isNull( arguments.value ) ) {
            var preparedNullValue = variables.grammar.prepareJsonContainsBinding();
            addBindings(
                isNull( preparedNullValue )
                 ? utils.extractBinding( grammar = variables.grammar )
                 : utils.extractBinding( preparedNullValue, variables.grammar ),
                "where"
            );
        } else {
            addBindings(
                utils.extractBinding(
                    variables.grammar.prepareJsonContainsBinding( arguments.value ),
                    variables.grammar
                ),
                "where"
            );
        }
        return this;
    }

    public QueryBuilder function orWhereJsonContains( required string column, any path = [], any value ) {
        return whereJsonContains( argumentCollection = arguments, combinator = "or" );
    }

    public QueryBuilder function whereJsonDoesntContain( required string column, any path = [], any value ) {
        return whereJsonContains( argumentCollection = arguments, negate = true );
    }

    public QueryBuilder function orWhereJsonDoesntContain( required string column, any path = [], any value ) {
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
        if ( this.getValidateOperatorsAndCombinators() && isInvalidJsonCombinator( arguments.combinator ) ) {
            throw( type = "InvalidSQLType", message = "Illegal combinator" );
        }
        variables.wheres.append( {
            type: "jsonExists",
            path: jsonPath( column = arguments.column, path = arguments.path ),
            combinator: arguments.combinator,
            negate: arguments.negate
        } );
        return this;
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
        if ( this.getValidateOperatorsAndCombinators() && isInvalidJsonCombinator( arguments.combinator ) ) {
            throw( type = "InvalidSQLType", message = "Illegal combinator" );
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
        if ( this.getValidateOperatorsAndCombinators() && isInvalidJsonOperator( arguments.operator ) ) {
            throw( type = "InvalidSQLType", message = "Illegal operator" );
        }
        variables.wheres.append( {
            type: "jsonLength",
            path: jsonPath( column = arguments.column, path = arguments.path ),
            operator: arguments.operator,
            combinator: arguments.combinator
        } );
        addBindings( utils.extractBinding( arguments.value, variables.grammar ), "where" );
        return this;
    }

    public QueryBuilder function orWhereJsonLength(
        required string column,
        any path = [],
        any operator,
        any value
    ) {
        return whereJsonLength( argumentCollection = arguments, combinator = "or" );
    }

    private boolean function isInvalidJsonOperator( required any operator ) {
        if ( isNull( arguments.operator ) || !isSimpleValue( arguments.operator ) ) {
            return true;
        }
        return !arrayContains( variables.operators, lCase( arguments.operator ) );
    }

    private boolean function isInvalidJsonCombinator( required string combinator ) {
        return !arrayContains( variables.combinators, uCase( arguments.combinator ) );
    }

}
