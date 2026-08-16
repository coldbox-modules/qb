/**
 * Coordinates isolated query execution, formatting, and query state snapshots
 * without retaining builder state between calls.
 */
component {

    /**
     * Executes a select and applies the builder's return format.
     */
    public any function run( required QueryBuilder builder, required string sql, struct options = {} ) {
        var q = arguments.builder.runQuery( sql = arguments.sql, options = arguments.options );

        if ( isNull( q ) ) {
            if ( arguments.builder.isPretending() ) {
                return applyReturnFormat( arguments.builder, queryNew( "" ) );
            }
            return;
        }

        if ( isQuery( q ) || isArray( q ) ) {
            return applyReturnFormat( arguments.builder, q );
        }

        if ( !q.keyExists( "result" ) || !q.keyExists( "query" ) ) {
            return applyReturnFormat( arguments.builder, q );
        }

        return { result: q.result, query: applyReturnFormat( arguments.builder, q.query ) };
    }

    /**
     * Runs a query through the configured grammar.
     */
    public any function runQuery(
        required QueryBuilder builder,
        required string sql,
        struct options = {},
        string returnObject = "query",
        struct bindingsDefinition = { provided: false }
    ) {
        var queryOptions = structCopy( arguments.options );
        var queryBuilder = arguments.builder;
        structAppend( queryOptions, arguments.builder.getDefaultOptions(), false );
        if ( queryOptions.keyExists( "returntype" ) ) {
            arguments.builder.getQueryValidator().validateQueryExecuteOptions( queryOptions );
        }

        var aggregateBindingExclusions = arguments.builder.getAggregate().isEmpty()
         ? []
         : ( arguments.builder.getUnions().isEmpty() ? [ "select", "orderBy" ] : [ "orderBy" ] );
        var queryBindings = arguments.bindingsDefinition.provided
         ? arguments.bindingsDefinition.value
         : arguments.builder.getBindings( except = aggregateBindingExclusions );

        var result = arguments.builder
            .getGrammar()
            .runQuery(
                sql = arguments.builder
                    .getSqlCommenter()
                    .appendSqlComments(
                        sql = arguments.sql,
                        datasource = queryOptions.keyExists( "datasource" ) && !isNull( queryOptions.datasource ) ? queryOptions.datasource : javacast(
                            "null",
                            ""
                        ),
                        bindings = queryBindings
                    ),
                bindings = queryBindings,
                options = queryOptions,
                returnObject = arguments.returnObject,
                pretend = arguments.builder.isPretending(),
                postProcessHook = function( data ) {
                    if ( queryBuilder.getCollectQueryLog() ) {
                        queryBuilder.getQueryLog().append( data );
                    }
                }
            );

        if ( !isNull( result ) ) {
            return result;
        }
    }

    /**
     * Copies a builder for an internal operation and propagates pretend mode.
     */
    public QueryBuilder function prepareInternalExecutionBuilder(
        required QueryBuilder builder,
        required QueryBuilder query
    ) {
        if ( arguments.builder.isPretending() ) {
            arguments.query.pretend();
        }
        return arguments.query;
    }

    /**
     * Creates an isolated clone without copying lazily instantiated collaborators.
     */
    public QueryBuilder function cloneBuilder( required QueryBuilder builder ) {
        var clonedQuery = arguments.builder.newQuery();
        copyQueryState( arguments.builder, clonedQuery );
        return clonedQuery;
    }

    /**
     * Clones a child builder and hoists statement-level CTEs when needed.
     */
    public QueryBuilder function snapshotBuilder( required QueryBuilder owner, required QueryBuilder builder ) {
        var snapshot = cloneBuilder( arguments.builder );
        var hoistTarget = arguments.owner.isJoin() ? arguments.owner.getJoiningQuery() : arguments.owner;
        hoistNestedCommonTables( snapshot, hoistTarget );
        return snapshot;
    }

    /**
     * Captures the part of a builder changed while attaching nested CTEs.
     */
    public struct function captureCommonTableState( required QueryBuilder builder ) {
        return {
            commonTableCount: arguments.builder.getCommonTables().len(),
            commonTableBindingCount: arguments.builder.getRawBindings().commonTables.len()
        };
    }

    /**
     * Restores statement-level CTE state after a failed nested operation.
     */
    public void function restoreCommonTableState( required QueryBuilder builder, required struct state ) {
        arguments.builder.setCommonTables(
            arguments.state.commonTableCount == 0
             ? []
             : arguments.builder.getCommonTables().slice( 1, arguments.state.commonTableCount )
        );
        arguments.builder.getRawBindings().commonTables = arguments.state.commonTableBindingCount == 0
         ? []
         : arguments.builder.getRawBindings().commonTables.slice( 1, arguments.state.commonTableBindingCount );
    }

    /**
     * Moves SQL Server CTEs from an embedded query to its containing statement.
     */
    public QueryBuilder function hoistNestedCommonTables( required QueryBuilder source, required QueryBuilder target ) {
        if (
            !isInstanceOf( arguments.target.getGrammar(), "qb.models.Grammars.SqlServerGrammar" ) ||
            arguments.source.getCommonTables().isEmpty()
        ) {
            return arguments.source;
        }

        var targetCommonTables = arguments.target.getCommonTables();
        targetCommonTables.append( arguments.source.getCommonTables(), true );
        arguments.target.setCommonTables( targetCommonTables );
        arguments.target.addBindings( arguments.source.getRawBindings().commonTables, "commonTables" );

        arguments.source.setCommonTables( [] );
        arguments.source.getRawBindings().commonTables = [];
        return arguments.source;
    }

    /**
     * Runs a callback with temporary selected columns and restores them.
     */
    public any function withColumns( required QueryBuilder builder, required any columns, required any callback ) {
        var originalColumns = [ { "type": "simple", "value": "*" } ];
        var shouldRestoreColumns = arguments.builder.getUnions().isEmpty();
        if ( shouldRestoreColumns ) {
            originalColumns = arguments.builder.getColumns();
            arguments.builder.select( arguments.columns );
        }
        var result = javacast( "null", "" );
        try {
            result = arguments.callback();
        } finally {
            if ( shouldRestoreColumns ) {
                arguments.builder.select( originalColumns );
            }
        }
        return result;
    }

    /**
     * Runs a callback with temporary aggregate state and restores it.
     */
    public any function withAggregate( required QueryBuilder builder, required struct aggregate, required any callback ) {
        var originalAggregate = arguments.builder.getAggregate();
        var originalOrders = arguments.builder.getOrders();
        var originalAggregateBindings = arguments.builder.getRawBindings().aggregate;
        arguments.builder.setAggregate( arguments.aggregate );
        arguments.builder.setOrders( [] );
        arguments.builder.getRawBindings().aggregate = [];
        arguments.builder.addColumnBindings( [ arguments.aggregate.column ], "aggregate" );
        var result = javacast( "null", "" );
        try {
            result = arguments.callback();
        } finally {
            arguments.builder.setAggregate( originalAggregate );
            arguments.builder.setOrders( originalOrders );
            arguments.builder.getRawBindings().aggregate = originalAggregateBindings;
        }
        return result;
    }

    private any function applyReturnFormat( required QueryBuilder builder, required any value ) {
        var formatter = arguments.builder.getReturnFormat();

        if ( isClosure( formatter ) || isCustomFunction( formatter ) ) {
            return formatter( arguments.value );
        }

        if ( structKeyExists( formatter, "format" ) ) {
            return formatter.format( arguments.value );
        }

        throw(
            type = "InvalidFormat",
            message = "The configured return formatter must be a closure or a component with a format method."
        );
    }

    private void function copyQueryState( required QueryBuilder source, required QueryBuilder target ) {
        arguments.target.setDistinct( arguments.source.getDistinct() );
        arguments.target.setAggregate( cloneQueryStateValue( arguments.source, arguments.source.getAggregate() ) );
        arguments.target.setColumns( cloneQueryStateValue( arguments.source, arguments.source.getColumns() ) );
        arguments.target.setTableName( cloneQueryStateValue( arguments.source, arguments.source.getTableName() ) );
        if ( !isNull( arguments.source.getForClause() ) ) {
            arguments.target.setForClause( cloneQueryStateValue( arguments.source, arguments.source.getForClause() ) );
        }
        arguments.target.setAlias( arguments.source.getAlias() );
        arguments.target.setLockType( arguments.source.getLockType() );
        arguments.target.setLockValue( arguments.source.getLockValue() );
        var clonedJoins = [];
        for ( var join in arguments.source.getJoins() ) {
            clonedJoins.append( cloneJoinClause( arguments.source, join, arguments.target ) );
        }
        arguments.target.setJoins( clonedJoins );
        arguments.target.setWheres( cloneQueryStateValue( arguments.source, arguments.source.getWheres() ) );
        arguments.target.setGroups( cloneQueryStateValue( arguments.source, arguments.source.getGroups() ) );
        arguments.target.setHavings( cloneQueryStateValue( arguments.source, arguments.source.getHavings() ) );
        arguments.target.setUnions( cloneQueryStateValue( arguments.source, arguments.source.getUnions() ) );
        arguments.target.setOrders( cloneQueryStateValue( arguments.source, arguments.source.getOrders() ) );
        arguments.target.setCommonTables( cloneQueryStateValue( arguments.source, arguments.source.getCommonTables() ) );
        if ( !isNull( arguments.source.getLimitValue() ) ) {
            arguments.target.setLimitValue( arguments.source.getLimitValue() );
        }
        if ( !isNull( arguments.source.getOffsetValue() ) ) {
            arguments.target.setOffsetValue( arguments.source.getOffsetValue() );
        }
        arguments.target.setReturning( cloneQueryStateValue( arguments.source, arguments.source.getReturning() ) );
        arguments.target.setUpdates( cloneQueryStateValue( arguments.source, arguments.source.getUpdates() ) );
        arguments.target.setGrammarCompiledFrom( arguments.source.getGrammarCompiledFrom() );
        arguments.target.setGrammarCompiledJoin( arguments.source.getGrammarCompiledJoin() );

        var sourceBindings = arguments.source.getRawBindings();
        for ( var bindingType in sourceBindings ) {
            arguments.target.addBindings(
                cloneQueryStateValue( arguments.source, sourceBindings[ bindingType ] ),
                bindingType
            );
        }
    }

    public JoinClause function cloneJoinClause(
        required QueryBuilder source,
        required JoinClause join,
        required QueryBuilder joiningQuery
    ) {
        var clonedJoin = new qb.models.Query.JoinClause(
            arguments.joiningQuery,
            arguments.join.getType(),
            cloneQueryStateValue( arguments.source, arguments.join.getTable() ),
            arguments.join.getLateralRawExpression(),
            cloneQueryStateValue( arguments.source, arguments.join.getLateralBindings() )
        );
        copyQueryState( arguments.join, clonedJoin );
        return clonedJoin;
    }

    private any function cloneQueryStateValue( required QueryBuilder source, any value ) {
        if ( isSimpleValue( arguments.value ) ) {
            return arguments.value;
        }
        if ( isNull( arguments.value ) ) {
            return javacast( "null", "" );
        }
        if ( arguments.source.getUtils().isBuilder( arguments.value ) ) {
            return cloneBuilder( arguments.value );
        }
        if ( arguments.source.getUtils().isExpression( arguments.value ) ) {
            return new qb.models.Query.Expression(
                arguments.value.getSQL(),
                cloneQueryStateValue( arguments.source, arguments.value.getBindings() )
            );
        }
        if ( isObject( arguments.value ) ) {
            return arguments.value;
        }
        if ( isArray( arguments.value ) ) {
            var clonedArray = [];
            if ( !arguments.value.isEmpty() ) {
                arrayResize( clonedArray, arguments.value.len() );
            }
            for ( var i = 1; i <= arguments.value.len(); i++ ) {
                if ( arrayIsDefined( arguments.value, i ) && !isNull( arguments.value[ i ] ) ) {
                    clonedArray[ i ] = cloneQueryStateValue( arguments.source, arguments.value[ i ] );
                }
            }
            return clonedArray;
        }
        if ( isStruct( arguments.value ) ) {
            var clonedStruct = {};
            for ( var key in arguments.value ) {
                clonedStruct[ key ] = isNull( arguments.value[ key ] )
                 ? javacast( "null", "" )
                 : cloneQueryStateValue( arguments.source, arguments.value[ key ] );
            }
            return clonedStruct;
        }
        return arguments.value;
    }

}
