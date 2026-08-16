/**
 * Validates query builder inputs using an immutable snapshot of the builder's
 * validation settings.
 */
component accessors="true" {

    property name="validateOperatorsAndCombinators" type="boolean";
    property name="validateDuplicateSelectColumns" type="boolean";
    property name="validateQueryExecuteReturnType" type="boolean";

    variables.operators = [
        "=",
        "<",
        ">",
        "<=",
        ">=",
        "<>",
        "!=",
        "like",
        "like binary",
        "not like",
        "between",
        "ilike",
        "&",
        "|",
        "^",
        "<<",
        ">>",
        "rlike",
        "regexp",
        "not regexp",
        "~",
        "~*",
        "!~",
        "!~*",
        "similar to",
        "not similar to"
    ];
    variables.combinators = [ "AND", "OR" ];
    variables.directions = [ "asc", "desc" ];

    /**
     * Creates a validator for one immutable set of builder settings.
     */
    public QueryValidator function init(
        boolean validateOperatorsAndCombinators = true,
        boolean validateDuplicateSelectColumns = false,
        boolean validateQueryExecuteReturnType = false
    ) {
        variables.validateOperatorsAndCombinators = arguments.validateOperatorsAndCombinators;
        variables.validateDuplicateSelectColumns = arguments.validateDuplicateSelectColumns;
        variables.validateQueryExecuteReturnType = arguments.validateQueryExecuteReturnType;
        return this;
    }

    /**
     * Returns whether a value is not a supported SQL operator.
     */
    public boolean function isInvalidOperator( any operator ) {
        if ( isNull( arguments.operator ) || !isSimpleValue( arguments.operator ) ) {
            return true;
        }
        return !arrayContains( variables.operators, lCase( arguments.operator ) );
    }

    /**
     * Throws when operator validation is enabled and the value is unsupported.
     */
    public void function validateOperator( any operator ) {
        if ( variables.validateOperatorsAndCombinators && isInvalidOperator( arguments.operator ) ) {
            throw( type = "InvalidSQLType", message = "Illegal operator" );
        }
    }

    /**
     * Throws when combinator validation is enabled and the value is unsupported.
     */
    public void function validateCombinator( required string combinator ) {
        if (
            variables.validateOperatorsAndCombinators &&
            !arrayContains( variables.combinators, uCase( arguments.combinator ) )
        ) {
            throw( type = "InvalidSQLType", message = "Illegal combinator" );
        }
    }

    /**
     * Throws when an ORDER BY direction is unsupported.
     */
    public void function validateOrderDirection( required string direction ) {
        if ( !arrayFindNoCase( variables.directions, trim( arguments.direction ) ) ) {
            throw( type = "InvalidSQLType", message = "Illegal order direction" );
        }
    }

    /**
     * Validates that all statically identifiable select output names are unique.
     */
    public void function validateUniqueSelectColumns( required array columns, required grammar ) {
        if ( !variables.validateDuplicateSelectColumns ) {
            return;
        }

        var outputNames = {};
        for ( var column in arguments.columns ) {
            var outputName = getSelectOutputName( column, arguments.grammar );
            if ( isNull( outputName ) ) {
                continue;
            }

            var normalizedName = normalizeSelectOutputName( outputName );
            if ( structKeyExists( outputNames, normalizedName ) ) {
                throw(
                    type = "DuplicateSelectColumn",
                    message = "Multiple selected columns produce the output name [#outputName#].",
                    detail = "Alias one of the columns to produce unique result keys."
                );
            }
            outputNames[ normalizedName ] = true;
        }
    }

    /**
     * Guards or removes native queryExecute return type options.
     */
    public void function validateQueryExecuteOptions( required struct options ) {
        if ( !arguments.options.keyExists( "returntype" ) ) {
            return;
        }

        if ( variables.validateQueryExecuteReturnType ) {
            throw(
                type = "InvalidQueryExecuteOption",
                message = "The queryExecute returntype option cannot be used with qb return formatters."
            );
        }

        structDelete( arguments.options, "returntype" );
        structDelete( arguments.options, "columnkey" );
        structDelete( arguments.options, "columnKey" );
    }

    /**
     * Returns a statically identifiable output name for a selected column.
     */
    private any function getSelectOutputName( required struct column, required grammar ) {
        if ( arguments.column.type == "builder" ) {
            return arguments.column.alias;
        }

        if ( arguments.column.type == "raw" ) {
            var rawSql = trim( arguments.column.value.getSQL() );
            var aliasMatch = reFindNoCase(
                "\s+AS\s+((?:`[^`]+`)|(?:\[[^\]]+\])|(?:""[^""]+"")|(?:[A-Za-z_][A-Za-z0-9_$]*))\s*$",
                rawSql,
                1,
                true
            );
            if ( aliasMatch.pos.len() < 2 || aliasMatch.pos[ 1 ] == 0 ) {
                return;
            }
            return mid( rawSql, aliasMatch.pos[ 2 ], aliasMatch.len[ 2 ] );
        }

        if ( arguments.column.type == "simple" && find( "*", arguments.column.value ) ) {
            return;
        }

        if ( arguments.column.type == "jsonPath" && !arguments.column.keyExists( "alias" ) ) {
            return;
        }

        if ( listFindNoCase( "simple,jsonPath", arguments.column.type ) ) {
            return arguments.grammar.extractAlias( arguments.column );
        }
    }

    /**
     * Normalizes an output name for the case-insensitive keys used by CFML structs.
     */
    private string function normalizeSelectOutputName( required string outputName ) {
        var normalizedName = trim( arguments.outputName );
        if (
            len( normalizedName ) >= 2 &&
            (
                ( left( normalizedName, 1 ) == "[" && right( normalizedName, 1 ) == "]" ) ||
                ( left( normalizedName, 1 ) == "`" && right( normalizedName, 1 ) == "`" ) ||
                ( left( normalizedName, 1 ) == """" && right( normalizedName, 1 ) == """" )
            )
        ) {
            normalizedName = mid( normalizedName, 2, len( normalizedName ) - 2 );
        }
        return lCase( normalizedName );
    }

}
