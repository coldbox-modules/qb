/**
 * Builds predicate definitions for a QueryBuilder without retaining builder state.
 */
component {

    /**
     * Adds a basic, nested, or subquery WHERE predicate.
     */
    public QueryBuilder function where(
        required QueryBuilder builder,
        column,
        operator,
        value,
        string combinator = "and"
    ) {
        if ( isClosure( arguments.column ) || isCustomFunction( arguments.column ) ) {
            return whereNested( arguments.builder, arguments.column, arguments.combinator );
        }

        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );

        if (
            isNull( arguments.value ) &&
            arguments.builder.getQueryValidator().isInvalidOperator( arguments.operator )
        ) {
            arguments.value = arguments.operator;
            arguments.operator = "=";
        } else {
            arguments.builder.getQueryValidator().validateOperator( arguments.operator );
        }

        if (
            !isNull( arguments.value ) && (
                isClosure( arguments.value ) ||
                isCustomFunction( arguments.value ) ||
                arguments.builder.getUtils().isBuilder( arguments.value )
            )
        ) {
            return whereSub(
                arguments.builder,
                arguments.column,
                arguments.operator,
                arguments.value,
                arguments.combinator
            );
        }

        return whereBasic(
            arguments.builder,
            arguments.column,
            arguments.operator,
            isNull( arguments.value ) ? javacast( "null", "" ) : arguments.value,
            arguments.combinator
        );
    }

    /**
     * Adds a WHERE IN predicate.
     */
    public QueryBuilder function whereIn(
        required QueryBuilder builder,
        column,
        values,
        combinator = "and",
        negate = false
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        if (
            isClosure( arguments.values ) ||
            isCustomFunction( arguments.values ) ||
            arguments.builder.getUtils().isBuilder( arguments.values )
        ) {
            return whereInSub(
                builder = arguments.builder,
                column = arguments.column,
                query = arguments.values,
                combinator = arguments.combinator,
                negate = arguments.negate
            );
        }

        arguments.values = arguments.builder.normalizeToArray( arguments.values );

        var type = arguments.negate ? "notIn" : "in";
        var typedColumn = toColumnType( arguments.builder, arguments.column );
        var bindings = arguments.values.isEmpty() ? [] : arguments.builder.extractColumnBindings( [ typedColumn ] );
        for ( var valueIndex = 1; valueIndex <= arguments.values.len(); valueIndex++ ) {
            if ( !arrayIsDefined( arguments.values, valueIndex ) || isNull( arguments.values[ valueIndex ] ) ) {
                bindings.append(
                    arguments.builder.getUtils().extractBinding( grammar = arguments.builder.getGrammar() )
                );
                continue;
            }
            var value = arguments.values[ valueIndex ];
            if ( arguments.builder.getUtils().isExpression( value ) ) {
                bindings.append( arguments.builder.extractExpressionBindings( value ), true );
            } else {
                bindings.append( arguments.builder.getUtils().extractBinding( value, arguments.builder.getGrammar() ) );
            }
        }

        arguments.builder
            .getWheres()
            .append( {
                type: type,
                column: typedColumn,
                values: arguments.values,
                combinator: arguments.combinator
            } );
        arguments.builder.addBindings( bindings, "where" );
        return arguments.builder;
    }

    /**
     * Adds a bulk WHERE IN predicate.
     */
    public QueryBuilder function whereInBulk(
        required QueryBuilder builder,
        required column,
        required values,
        any sqlType = javacast( "null", "" ),
        string combinator = "and",
        boolean negate = false
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        arguments.values = arguments.builder.normalizeToArray( arguments.values );

        var extractedBindings = [];
        if ( !arguments.values.isEmpty() ) {
            arrayResize( extractedBindings, arguments.values.len() );
        }
        for ( var valueIndex = 1; valueIndex <= arguments.values.len(); valueIndex++ ) {
            if ( !arrayIsDefined( arguments.values, valueIndex ) || isNull( arguments.values[ valueIndex ] ) ) {
                extractedBindings[ valueIndex ] = arguments.builder
                    .getUtils()
                    .extractBinding( grammar = arguments.builder.getGrammar() );
                continue;
            }
            if ( arguments.builder.getUtils().isExpression( arguments.values[ valueIndex ] ) ) {
                throw( type = "InvalidBulkValue", message = "Bulk IN values cannot contain SQL expressions." );
            }
            extractedBindings[ valueIndex ] = arguments.builder
                .getUtils()
                .extractBinding( arguments.values[ valueIndex ], arguments.builder.getGrammar() );
        }

        if ( isNull( arguments.sqlType ) ) {
            arguments.sqlType = arguments.builder
                .getGrammar()
                .resolveWhereInBulkSqlType(
                    arguments.builder.getUtils().inferSqlType( arguments.values, arguments.builder.getGrammar() )
                );
        }

        arguments.sqlType = trim( arguments.sqlType );
        if (
            arguments.sqlType == "" ||
            !reFindNoCase(
                "^[a-z][a-z0-9_]*(?:\s+[a-z][a-z0-9_]*)*(?:\s*\(\s*(?:max|\d+)(?:\s*,\s*\d+)?\s*\))?$",
                arguments.sqlType
            )
        ) {
            throw(
                type = "InvalidSQLType",
                message = "Invalid SQL type [#arguments.sqlType#] for a bulk IN statement."
            );
        }

        var typedColumn = toColumnType( arguments.builder, arguments.column );
        var columnBindings = arguments.values.isEmpty()
         ? []
         : arguments.builder.extractColumnBindings( [ typedColumn ] );
        arguments.builder
            .getWheres()
            .append( {
                type: "inBulk",
                column: typedColumn,
                sqlType: arguments.sqlType,
                isEmpty: arguments.values.isEmpty(),
                negate: arguments.negate,
                combinator: arguments.combinator
            } );

        if ( !arguments.values.isEmpty() ) {
            var serializedValues = extractedBindings.map( function( binding ) {
                return binding.null ? javacast( "null", "" ) : binding.value;
            } );
            arguments.builder.addBindings( columnBindings, "where" );
            arguments.builder.addBindings(
                [
                    arguments.builder
                        .getUtils()
                        .extractBinding(
                            { value: serializeJSON( serializedValues ), cfsqltype: "LONGVARCHAR" },
                            arguments.builder.getGrammar()
                        )
                ],
                "where"
            );
        }

        return arguments.builder;
    }

    /**
     * Adds a raw WHERE predicate.
     */
    public QueryBuilder function whereRaw(
        required QueryBuilder builder,
        required string sql,
        array whereBindings = [],
        string combinator = "and"
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        var queryBuilder = arguments.builder;
        arguments.builder.addBindings(
            arguments.whereBindings.map( function( binding ) {
                return queryBuilder.getUtils().extractBinding( binding, queryBuilder.getGrammar() );
            } ),
            "where"
        );
        arguments.builder.getWheres().append( { type: "raw", sql: arguments.sql, combinator: arguments.combinator } );
        return arguments.builder;
    }

    /**
     * Adds a column comparison predicate.
     */
    public QueryBuilder function whereColumn(
        required QueryBuilder builder,
        required first,
        operator,
        second,
        string combinator = "and"
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        if ( isNull( arguments.second ) ) {
            arguments.second = arguments.operator;
            arguments.operator = "=";
        }

        arguments.builder.getQueryValidator().validateOperator( arguments.operator );

        if (
            isClosure( arguments.second ) ||
            isCustomFunction( arguments.second ) ||
            arguments.builder.getUtils().isBuilder( arguments.second )
        ) {
            return whereSub(
                arguments.builder,
                arguments.first,
                arguments.operator,
                arguments.second,
                arguments.combinator
            );
        }

        var firstColumn = toColumnType( arguments.builder, arguments.first );
        var secondColumn = toColumnType( arguments.builder, arguments.second );
        var bindings = arguments.builder.extractColumnBindings( [ firstColumn, secondColumn ] );
        arguments.builder
            .getWheres()
            .append( {
                type: "column",
                first: firstColumn,
                operator: arguments.operator,
                second: secondColumn,
                combinator: arguments.combinator
            } );
        arguments.builder.addBindings( bindings, "where" );
        return arguments.builder;
    }

    /**
     * Adds an EXISTS predicate.
     */
    public QueryBuilder function whereExists(
        required QueryBuilder builder,
        query,
        combinator = "and",
        negate = false
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        if ( isClosure( arguments.query ) || isCustomFunction( arguments.query ) ) {
            var callback = arguments.query;
            arguments.query = arguments.builder.newQuery();
            callback( arguments.query );
        }
        return addWhereExistsQuery(
            arguments.builder,
            arguments.query,
            arguments.combinator,
            arguments.negate
        );
    }

    /**
     * Adds a nested WHERE predicate.
     */
    public QueryBuilder function whereNested( required QueryBuilder builder, required callback, combinator = "and" ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        var query = forNestedWhere( arguments.builder );
        arguments.callback( query );
        return addNestedWhereQuery( arguments.builder, query, arguments.combinator );
    }

    /**
     * Attaches an existing nested WHERE query.
     */
    public QueryBuilder function addNestedWhereQuery(
        required QueryBuilder builder,
        required QueryBuilder query,
        string combinator = "and"
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        if ( !arguments.query.getWheres().isEmpty() ) {
            arguments.query = arguments.builder
                .getCollaborator( "QueryExecutor" )
                .snapshotBuilder( arguments.builder, arguments.query );
            arguments.builder
                .getWheres()
                .append( { type: "nested", query: arguments.query, combinator: arguments.combinator } );
            arguments.builder.addBindings( arguments.query.getBindings(), "where" );
        }
        return arguments.builder;
    }

    /**
     * Creates a builder for a nested WHERE predicate.
     */
    public QueryBuilder function forNestedWhere( required QueryBuilder builder ) {
        return arguments.builder.newQuery().from( arguments.builder.getTableName() );
    }

    /**
     * Adds a NULL predicate.
     */
    public QueryBuilder function whereNull(
        required QueryBuilder builder,
        column,
        combinator = "and",
        negate = false
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        if (
            isClosure( arguments.column ) ||
            isCustomFunction( arguments.column ) ||
            arguments.builder.getUtils().isBuilder( arguments.column )
        ) {
            return whereNullSub(
                arguments.builder,
                arguments.column,
                arguments.combinator,
                arguments.negate
            );
        }

        var type = arguments.negate ? "notNull" : "null";
        var typedColumn = toColumnType( arguments.builder, arguments.column );
        var bindings = arguments.builder.extractColumnBindings( [ typedColumn ] );
        arguments.builder.getWheres().append( { type: type, column: typedColumn, combinator: arguments.combinator } );
        arguments.builder.addBindings( bindings, "where" );
        return arguments.builder;
    }

    /**
     * Adds a NULL predicate against a subquery.
     */
    public QueryBuilder function whereNullSub(
        required QueryBuilder builder,
        query,
        combinator = "and",
        negate = false
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        if ( isClosure( arguments.query ) || isCustomFunction( arguments.query ) ) {
            var callback = arguments.query;
            arguments.query = arguments.builder.newQuery();
            callback( arguments.query );
        }
        arguments.query = arguments.builder
            .getCollaborator( "QueryExecutor" )
            .snapshotBuilder( arguments.builder, arguments.query );

        var type = arguments.negate ? "notNullSub" : "nullSub";
        arguments.builder.getWheres().append( { type: type, query: arguments.query, combinator: arguments.combinator } );
        arguments.builder.addBindings( arguments.query.getBindings(), "where" );
        return arguments.builder;
    }

    /**
     * Adds a BETWEEN predicate.
     */
    public QueryBuilder function whereBetween(
        required QueryBuilder builder,
        column,
        start,
        end,
        combinator = "and",
        negate = false
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );
        var type = arguments.negate ? "notBetween" : "between";
        var typedColumn = toColumnType( arguments.builder, arguments.column );

        if ( !isNull( arguments.start ) && ( isClosure( arguments.start ) || isCustomFunction( arguments.start ) ) ) {
            var callback = arguments.start;
            arguments.start = arguments.builder.newQuery();
            callback( arguments.start );
        }

        if ( !isNull( arguments.end ) && ( isClosure( arguments.end ) || isCustomFunction( arguments.end ) ) ) {
            var callback = arguments.end;
            arguments.end = arguments.builder.newQuery();
            callback( arguments.end );
        }

        if ( !isNull( arguments.start ) && arguments.builder.getUtils().isBuilder( arguments.start ) ) {
            arguments.start = arguments.builder
                .getCollaborator( "QueryExecutor" )
                .snapshotBuilder( arguments.builder, arguments.start );
        }
        if ( !isNull( arguments.end ) && arguments.builder.getUtils().isBuilder( arguments.end ) ) {
            arguments.end = arguments.builder
                .getCollaborator( "QueryExecutor" )
                .snapshotBuilder( arguments.builder, arguments.end );
        }

        var bindings = arguments.builder.extractColumnBindings( [ typedColumn ] );
        bindings.append(
            extractPredicateBindings(
                builder = arguments.builder,
                value = isNull( arguments.start ) ? javacast( "null", "" ) : arguments.start
            ),
            true
        );
        bindings.append(
            extractPredicateBindings(
                builder = arguments.builder,
                value = isNull( arguments.end ) ? javacast( "null", "" ) : arguments.end
            ),
            true
        );

        if (
            !isNull( arguments.start ) &&
            isStruct( arguments.start ) &&
            !structKeyExists( arguments.start, "isBuilder" ) &&
            structKeyExists( arguments.start, "value" )
        ) {
            arguments.start = arguments.start.value;
        }

        if (
            !isNull( arguments.end ) &&
            isStruct( arguments.end ) &&
            !structKeyExists( arguments.end, "isBuilder" ) &&
            structKeyExists( arguments.end, "value" )
        ) {
            arguments.end = arguments.end.value;
        }

        arguments.builder
            .getWheres()
            .append( {
                type: type,
                column: typedColumn,
                start: isNull( arguments.start ) ? javacast( "null", "" ) : arguments.start,
                end: isNull( arguments.end ) ? javacast( "null", "" ) : arguments.end,
                combinator: arguments.combinator
            } );
        arguments.builder.addBindings( bindings, "where" );
        return arguments.builder;
    }

    /**
     * Adds a HAVING predicate.
     */
    public QueryBuilder function having(
        required QueryBuilder builder,
        column,
        operator,
        value,
        string combinator = "and"
    ) {
        arguments.builder.getQueryValidator().validateCombinator( arguments.combinator );

        if (
            isNull( arguments.value ) &&
            isNull( arguments.operator ) &&
            arguments.builder.getUtils().isExpression( arguments.column )
        ) {
            var expressionBindings = arguments.builder.extractExpressionBindings( arguments.column );
            arguments.builder
                .getHavings()
                .append( { type: "raw", column: arguments.column, combinator: arguments.combinator } );
            arguments.builder.addBindings( expressionBindings, "having" );
            return arguments.builder;
        }

        if (
            isNull( arguments.value ) &&
            arguments.builder.getQueryValidator().isInvalidOperator( arguments.operator )
        ) {
            arguments.value = arguments.operator;
            arguments.operator = "=";
        } else {
            arguments.builder.getQueryValidator().validateOperator( arguments.operator );
        }

        var typedColumn = toColumnType( arguments.builder, arguments.column );
        var bindings = arguments.builder.extractColumnBindings( [ typedColumn ] );
        bindings.append(
            extractPredicateBindings(
                builder = arguments.builder,
                value = isNull( arguments.value ) ? javacast( "null", "" ) : arguments.value
            ),
            true
        );
        arguments.builder
            .getHavings()
            .append( {
                type: "normal",
                column: typedColumn,
                operator: arguments.operator,
                value: isNull( arguments.value ) ? javacast( "null", "" ) : arguments.value,
                combinator: arguments.combinator
            } );
        arguments.builder.addBindings( bindings, "having" );
        return arguments.builder;
    }

    /**
     * Runs a scope and groups newly added OR predicates when needed.
     */
    public QueryBuilder function withScoping( required QueryBuilder builder, required function callback ) {
        var originalWhereCount = arguments.builder.getWheres().len();
        arguments.callback();
        if ( arguments.builder.getWheres().len() > originalWhereCount ) {
            addNewWheresWithinGroup( arguments.builder, originalWhereCount );
        }
        return arguments.builder;
    }

    /**
     * Adds a simple WHERE predicate and its bindings.
     */
    private QueryBuilder function whereBasic(
        required QueryBuilder builder,
        required any column,
        required any operator,
        any value,
        string combinator = "and"
    ) {
        var typedColumn = toColumnType( arguments.builder, arguments.column );
        var bindings = arguments.builder.extractColumnBindings( [ typedColumn ] );
        bindings.append(
            extractPredicateBindings(
                builder = arguments.builder,
                value = isNull( arguments.value ) ? javacast( "null", "" ) : arguments.value
            ),
            true
        );
        arguments.builder
            .getWheres()
            .append( {
                column: typedColumn,
                operator: arguments.operator,
                value: isNull( arguments.value ) ? javacast( "null", "" ) : arguments.value,
                combinator: arguments.combinator,
                type: "basic"
            } );
        arguments.builder.addBindings( bindings, "where" );
        return arguments.builder;
    }

    /**
     * Adds a subquery WHERE predicate.
     */
    private QueryBuilder function whereSub(
        required QueryBuilder builder,
        column,
        operator,
        query,
        combinator = "and"
    ) {
        if ( isClosure( arguments.query ) || isCustomFunction( arguments.query ) ) {
            var callback = arguments.query;
            arguments.query = arguments.builder.newQuery();
            callback( arguments.query );
        }
        var typedColumn = toColumnType( arguments.builder, arguments.column );
        var columnBindings = arguments.builder.extractColumnBindings( [ typedColumn ] );
        arguments.query = arguments.builder
            .getCollaborator( "QueryExecutor" )
            .snapshotBuilder( arguments.builder, arguments.query );
        arguments.builder
            .getWheres()
            .append( {
                type: "sub",
                column: typedColumn,
                operator: arguments.operator,
                query: arguments.query,
                combinator: arguments.combinator
            } );
        arguments.builder.addBindings( columnBindings, "where" );
        arguments.builder.addBindings( arguments.query.getBindings(), "where" );
        return arguments.builder;
    }

    /**
     * Adds a subquery WHERE IN predicate.
     */
    private QueryBuilder function whereInSub(
        required QueryBuilder builder,
        column,
        query,
        combinator = "and",
        negate = false
    ) {
        if ( isClosure( arguments.query ) || isCustomFunction( arguments.query ) ) {
            var callback = arguments.query;
            arguments.query = arguments.builder.newQuery();
            callback( arguments.query );
        }
        var typedColumn = toColumnType( arguments.builder, arguments.column );
        var columnBindings = arguments.builder.extractColumnBindings( [ typedColumn ] );
        arguments.query = arguments.builder
            .getCollaborator( "QueryExecutor" )
            .snapshotBuilder( arguments.builder, arguments.query );

        var type = arguments.negate ? "notInSub" : "inSub";
        arguments.builder
            .getWheres()
            .append( {
                type: type,
                column: typedColumn,
                query: arguments.query,
                combinator: arguments.combinator
            } );
        arguments.builder.addBindings( columnBindings, "where" );
        arguments.builder.addBindings( arguments.query.getBindings(), "where" );
        return arguments.builder;
    }

    /**
     * Attaches an EXISTS query.
     */
    private QueryBuilder function addWhereExistsQuery(
        required QueryBuilder builder,
        query,
        combinator = "and",
        negate = false
    ) {
        arguments.query = arguments.builder
            .getCollaborator( "QueryExecutor" )
            .snapshotBuilder( arguments.builder, arguments.query );
        var type = arguments.negate ? "notExists" : "exists";
        arguments.builder.getWheres().append( { type: type, query: arguments.query, combinator: arguments.combinator } );
        arguments.builder.addBindings( arguments.query.getBindings(), "where" );
        return arguments.builder;
    }

    /**
     * Adds one expression or scalar binding.
     */
    private array function extractPredicateBindings( required QueryBuilder builder, any value ) {
        if ( !isNull( arguments.value ) && arguments.builder.getUtils().isExpression( arguments.value ) ) {
            return arguments.builder.extractExpressionBindings( arguments.value );
        }
        var binding = isNull( arguments.value )
         ? arguments.builder.getUtils().extractBinding( grammar = arguments.builder.getGrammar() )
         : arguments.builder.getUtils().extractBinding( arguments.value, arguments.builder.getGrammar() );
        return isArray( binding ) ? binding : [ binding ];
    }

    /**
     * Formats and classifies a predicate column.
     */
    private struct function toColumnType( required QueryBuilder builder, required any column ) {
        return arguments.builder.mapToColumnType( arguments.builder.applyColumnFormatter( arguments.column ) );
    }

    /**
     * Regroups predicates added by a scope.
     */
    private void function addNewWheresWithinGroup( required QueryBuilder builder, required numeric originalWhereCount ) {
        var allWheres = arguments.builder.getWheres();
        arguments.builder.setWheres( [] );

        if ( arguments.originalWhereCount > 0 ) {
            groupWhereSliceForScope( arguments.builder, arraySlice( allWheres, 1, arguments.originalWhereCount ) );
        }

        groupWhereSliceForScope( arguments.builder, arraySlice( allWheres, arguments.originalWhereCount + 1 ) );
    }

    /**
     * Groups a predicate slice when it contains an OR combinator.
     */
    private void function groupWhereSliceForScope( required QueryBuilder builder, required array whereSlice ) {
        for ( var where in arguments.whereSlice ) {
            if ( compareNoCase( where.combinator, "OR" ) == 0 ) {
                addNestedWhereQuery(
                    arguments.builder,
                    forNestedWhere( arguments.builder ).setWheres( arguments.whereSlice )
                );
                return;
            }
        }
        var newWheres = arguments.builder.getWheres();
        arrayAppend( newWheres, arguments.whereSlice, true );
        arguments.builder.setWheres( newWheres );
    }

}
