/**
 * Builds JSON query definitions for a QueryBuilder without retaining builder
 * state between calls.
 */
component {

    /**
     * Creates a grammar-aware JSON scalar path expression.
     */
    public struct function jsonPath(
        required QueryBuilder builder,
        required string column,
        array path = [],
        string alias = ""
    ) {
        var parsedColumn = trim( arguments.column );
        var parsedAlias = arguments.alias;

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
            value: { column: arguments.builder.applyColumnFormatter( parsedColumn ), path: arguments.path }
        };
        if ( len( parsedAlias ) ) {
            definition.alias = parsedAlias;
        }
        return definition;
    }

    /**
     * Adds a normalized JSON containment predicate.
     */
    public QueryBuilder function whereJsonContains(
        required QueryBuilder builder,
        required string column,
        array path = [],
        required struct valueDefinition,
        string combinator = "and",
        boolean negate = false
    ) {
        var containsPath = jsonPath( builder = arguments.builder, column = arguments.column, path = arguments.path );
        containsPath.value.nullValue = arguments.valueDefinition.isNull;
        var binding = {};
        if ( arguments.valueDefinition.isNull ) {
            var preparedNullValue = arguments.builder.getGrammar().prepareJsonContainsBinding();
            binding = isNull( preparedNullValue )
             ? arguments.builder.getUtils().extractBinding( grammar = arguments.builder.getGrammar() )
             : arguments.builder.getUtils().extractBinding( preparedNullValue, arguments.builder.getGrammar() );
        } else {
            binding = arguments.builder
                .getUtils()
                .extractBinding(
                    arguments.builder.getGrammar().prepareJsonContainsBinding( arguments.valueDefinition.value ),
                    arguments.builder.getGrammar()
                );
        }

        arguments.builder
            .getWheres()
            .append( {
                type: "jsonContains",
                path: containsPath,
                combinator: arguments.combinator,
                negate: arguments.negate
            } );
        arguments.builder.addBindings( binding, "where" );
        return arguments.builder;
    }

    /**
     * Adds a JSON path existence predicate.
     */
    public QueryBuilder function whereJsonExists(
        required QueryBuilder builder,
        required string column,
        array path = [],
        string combinator = "and",
        boolean negate = false
    ) {
        arguments.builder
            .getWheres()
            .append( {
                type: "jsonExists",
                path: jsonPath( builder = arguments.builder, column = arguments.column, path = arguments.path ),
                combinator: arguments.combinator,
                negate: arguments.negate
            } );
        return arguments.builder;
    }

    /**
     * Adds a normalized JSON array length predicate.
     */
    public QueryBuilder function whereJsonLength(
        required QueryBuilder builder,
        required string column,
        array path = [],
        required any operator,
        required struct valueDefinition,
        string combinator = "and"
    ) {
        var binding = arguments.valueDefinition.isNull
         ? arguments.builder.getUtils().extractBinding( grammar = arguments.builder.getGrammar() )
         : arguments.builder
            .getUtils()
            .extractBinding( arguments.valueDefinition.value, arguments.builder.getGrammar() );
        arguments.builder
            .getWheres()
            .append( {
                type: "jsonLength",
                path: jsonPath( builder = arguments.builder, column = arguments.column, path = arguments.path ),
                operator: arguments.operator,
                combinator: arguments.combinator
            } );
        arguments.builder.addBindings( binding, "where" );
        return arguments.builder;
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
        return reFind( "^-?\d+$", normalized ) ? val( normalized ) : normalized;
    }

}
