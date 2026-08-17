/**
 * Creates and attaches JoinClause instances without retaining builder state.
 */
component {

    /**
     * Creates a detached join clause for the supplied builder.
     */
    public JoinClause function newJoin( required QueryBuilder builder, required any table, string type = "inner" ) {
        return new qb.models.Query.JoinClause(
            joiningQuery = arguments.builder,
            type = arguments.type,
            table = arguments.table
        );
    }

    /**
     * Creates and attaches a join clause to the supplied builder.
     */
    public QueryBuilder function join(
        required QueryBuilder builder,
        required any table,
        any first,
        string operator = "=",
        string second,
        string type = "inner",
        boolean where = false,
        boolean preventDuplicateJoins = arguments.builder.getPreventDuplicateJoins()
    ) {
        if ( arguments.builder.getUtils().isBuilder( arguments.table ) ) {
            arguments.table = arguments.builder
                .getCollaborator( "QueryExecutor" )
                .cloneJoinClause( arguments.builder, arguments.table, arguments.builder );
            if ( arguments.preventDuplicateJoins && containsJoin( arguments.builder, arguments.table ) ) {
                return arguments.builder;
            }
            return attachJoin( arguments.builder, arguments.table );
        }

        var join = newJoin( builder = arguments.builder, type = arguments.type, table = arguments.table );

        if ( isClosure( arguments.first ) || isCustomFunction( arguments.first ) ) {
            var commonTableState = arguments.builder
                .getCollaborator( "QueryExecutor" )
                .captureCommonTableState( arguments.builder );
            try {
                arguments.first( join );
            } catch ( any e ) {
                arguments.builder
                    .getCollaborator( "QueryExecutor" )
                    .restoreCommonTableState( arguments.builder, commonTableState );
                rethrow;
            }
            if ( arguments.preventDuplicateJoins && containsJoin( arguments.builder, join ) ) {
                arguments.builder
                    .getCollaborator( "QueryExecutor" )
                    .restoreCommonTableState( arguments.builder, commonTableState );
                return arguments.builder;
            }
            return attachJoin( arguments.builder, join );
        }

        if ( arguments.where ) {
            join.where(
                column = arguments.first,
                operator = arguments.operator,
                value = isNull( arguments.second ) ? javacast( "null", "" ) : arguments.second
            );
        } else {
            join.on(
                first = arguments.first,
                operator = arguments.operator,
                second = isNull( arguments.second ) ? javacast( "null", "" ) : arguments.second
            );
        }

        if ( arguments.preventDuplicateJoins && containsJoin( arguments.builder, join ) ) {
            return arguments.builder;
        }
        return attachJoin( arguments.builder, join );
    }

    /**
     * Attaches a cross join to the supplied builder.
     */
    public QueryBuilder function crossJoin( required QueryBuilder builder, required any table ) {
        return attachJoin(
            arguments.builder,
            newJoin( builder = arguments.builder, type = "cross", table = arguments.table )
        );
    }

    /**
     * Attaches a raw cross join while preserving its expression for grammar compilation.
     */
    public QueryBuilder function crossJoinRaw( required QueryBuilder builder, required string table ) {
        arguments.builder
            .getJoins()
            .append(
                newJoin( builder = arguments.builder, type = "cross", table = arguments.builder.raw( arguments.table ) )
            );
        return arguments.builder;
    }

    /**
     * Builds and attaches a join against a derived table.
     */
    public QueryBuilder function joinSub(
        required QueryBuilder builder,
        required string alias,
        required any input,
        required any first,
        string operator = "=",
        string second,
        string type = "inner",
        boolean where = false
    ) {
        var executor = arguments.builder.getCollaborator( "QueryExecutor" );
        var commonTableState = executor.captureCommonTableState( arguments.builder );
        try {
            if ( isClosure( arguments.input ) || isCustomFunction( arguments.input ) ) {
                var subquery = arguments.builder.newQuery();
                arguments.input( subquery );
                arguments.input = subquery;
            }
            arguments.input = executor.snapshotBuilder( arguments.builder, arguments.input );

            var table = arguments.builder.raw(
                arguments.builder.getGrammar().wrapTable( "(#arguments.input.toSQL()#) AS #arguments.alias#" ),
                arguments.input.getBindings()
            );

            var joinCount = arguments.builder.getJoins().len();
            var joinArguments = {
                builder: arguments.builder,
                table: table,
                first: arguments.first,
                operator: arguments.operator,
                type: arguments.type,
                where: arguments.where
            };
            if ( !isNull( arguments.second ) ) {
                joinArguments.second = arguments.second;
            }

            var result = join( argumentCollection = joinArguments );
            if ( arguments.builder.getJoins().len() > joinCount ) {
                arguments.builder.setGrammarCompiledJoin( true );
            } else {
                executor.restoreCommonTableState( arguments.builder, commonTableState );
            }
            return result;
        } catch ( any e ) {
            executor.restoreCommonTableState( arguments.builder, commonTableState );
            rethrow;
        }
    }

    /**
     * Builds and attaches an APPLY or LATERAL join.
     */
    public QueryBuilder function applyJoin(
        required QueryBuilder builder,
        required string name,
        required string type,
        required any tableLikeSource
    ) {
        var executor = arguments.builder.getCollaborator( "QueryExecutor" );
        var commonTableState = executor.captureCommonTableState( arguments.builder );
        try {
            if (
                arguments.type != "outer apply" &&
                arguments.type != "cross apply" &&
                arguments.type != "lateral"
            ) {
                throw(
                    type = "QBInvalidJoinType",
                    message = "Invalid join type: #arguments.type#. Valid types are [`outer apply`, `cross apply`, or `lateral`]"
                );
            }

            var sourceIsBuilder = arguments.builder.getUtils().isBuilder( arguments.tableLikeSource );
            var sourceIsFunc = isClosure( arguments.tableLikeSource ) || isCustomFunction( arguments.tableLikeSource );

            if ( !sourceIsBuilder && !sourceIsFunc ) {
                throw(
                    type = "QBInvalidJoinSource",
                    message = "Invalid join source. Valid types are a QueryBuilder instance or a callback function that receives a new QueryBuilder instance."
                );
            }

            if ( sourceIsFunc ) {
                var subquery = arguments.builder.newQuery();
                arguments.tableLikeSource( subquery );
                arguments.tableLikeSource = subquery;
            }

            arguments.tableLikeSource = executor.snapshotBuilder( arguments.builder, arguments.tableLikeSource );

            var join = new qb.models.Query.JoinClause(
                joiningQuery = arguments.builder,
                type = arguments.type,
                table = arguments.name,
                lateralRawExpression = arguments.tableLikeSource.toSQL(),
                lateralBindings = arguments.tableLikeSource.getBindings()
            );

            if ( arguments.builder.getPreventDuplicateJoins() && containsJoin( arguments.builder, join ) ) {
                executor.restoreCommonTableState( arguments.builder, commonTableState );
                return arguments.builder;
            }

            arguments.builder.addBindings( arguments.tableLikeSource.getBindings(), "join" );
            arguments.builder.getJoins().append( join );
            arguments.builder.setGrammarCompiledJoin( true );
            return arguments.builder;
        } catch ( any e ) {
            executor.restoreCommonTableState( arguments.builder, commonTableState );
            rethrow;
        }
    }

    /**
     * Builds and attaches a cross join against a derived table.
     */
    public QueryBuilder function crossJoinSub( required QueryBuilder builder, required any alias, required any input ) {
        var executor = arguments.builder.getCollaborator( "QueryExecutor" );
        var commonTableState = executor.captureCommonTableState( arguments.builder );
        try {
            if ( isClosure( arguments.input ) || isCustomFunction( arguments.input ) ) {
                var subquery = arguments.builder.newQuery();
                arguments.input( subquery );
                arguments.input = subquery;
            }
            arguments.input = executor.snapshotBuilder( arguments.builder, arguments.input );

            var table = arguments.builder.raw(
                arguments.builder.getGrammar().wrapTable( "(#arguments.input.toSQL()#) AS #arguments.alias#" ),
                arguments.input.getBindings()
            );

            var result = crossJoin( arguments.builder, table );
            arguments.builder.setGrammarCompiledJoin( true );
            return result;
        } catch ( any e ) {
            executor.restoreCommonTableState( arguments.builder, commonTableState );
            rethrow;
        }
    }

    /**
     * Adds a clause and its bindings to a builder.
     */
    private QueryBuilder function attachJoin( required QueryBuilder builder, required JoinClause join ) {
        var bindings = getJoinBindings( arguments.builder, arguments.join );
        arguments.builder.getJoins().append( arguments.join );
        arguments.builder.addBindings( bindings, "join" );
        return arguments.builder;
    }

    /**
     * Returns whether an equivalent join is already attached.
     */
    private boolean function containsJoin( required QueryBuilder builder, required JoinClause join ) {
        return arguments.builder
            .getJoins()
            .find( function( existingJoin ) {
                return existingJoin.isEqualTo( join );
            } ) > 0;
    }

    /**
     * Returns bindings in their compiled join order.
     */
    private array function getJoinBindings( required QueryBuilder builder, required JoinClause join ) {
        var queryBuilder = arguments.builder;
        var bindings = [];
        if (
            arguments.join.isJoin() &&
            arguments.builder.getUtils().isExpression( arguments.join.getTable() )
        ) {
            bindings.append(
                arguments.join
                    .getTable()
                    .getBindings()
                    .map( function( binding ) {
                        return queryBuilder.getUtils().extractBinding( binding, queryBuilder.getGrammar() );
                    } ),
                true
            );
        }
        bindings.append( arguments.join.getBindings(), true );
        return bindings;
    }

}
