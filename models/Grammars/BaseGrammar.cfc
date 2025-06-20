/**
 * Grammar represents a platform to run sql on.
 *
 * This is the Base Grammar that other grammars can extend to modify
 * the generated sql for their specific platforms.
 */
component displayname="Grammar" accessors="true" singleton {

    /**
     * ColdBox Interceptor Service to announce pre- and post- interception points
     */
    property name="interceptorService" inject="box:interceptorService";

    /**
     * LogBox logger to log out SQL and bindings.
     * If this is not a ColdBox application, a NullLogger will be created in the constructor.
     */
    property name="log" inject="logbox:logger:{this}";

    /**
     * Query utilities shared across multiple models.
     */
    property name="utils";

    /**
     * Global table prefix for the grammar.
     */
    property name="tablePrefix" type="string" default="";

    /**
     * Table alias operator for the grammar.
     */
    property name="tableAliasOperator" type="string" default=" AS ";

    /**
     * The different components of a select statement in the order of compilation.
     */
    variables.selectComponents = [
        "commonTables",
        "aggregate",
        "columns",
        "tableName",
        "forClause",
        "joins",
        "wheres",
        "groups",
        "havings",
        "unions",
        "orders",
        "limitValue",
        "offsetValue",
        "lockType"
    ];

    /**
     * Creates a new basic Query Grammar.
     *
     * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
     *
     * @return qb.models.Grammars.BaseGrammar
     */
    public BaseGrammar function init( qb.models.Query.QueryUtils utils ) {
        param arguments.utils = new qb.models.Query.QueryUtils();
        variables.utils = arguments.utils;
        variables.tablePrefix = "";
        variables.tableAliasOperator = " AS ";
        variables.cteColumnsRequireParentheses = false;
        variables.shouldWrapValues = true;
        // These are overwritten by WireBox, if it exists.
        variables.interceptorService = {
            "processState": function() {
            }
        };
        variables.log = {
            "canDebug": function() {
                return false;
            },
            "debug": function() {
            }
        };
        return this;
    }

    /**
     * Runs a query through `queryExecute`.
     * This function exists so that platform-specific grammars can override it if needed.
     *
     * @sql The sql string to execute.
     * @bindings The bindings to apply to the query. Default: []
     * @options Any options to pass to `queryExecute`. Default: {}.
     * @returnObject The type of object to return, "query" or "result". Default: "query".
     * @pretend Flag to only pretend to run the query, if true. Default: false.
     * @postProcessHook An optional function to run after executing the query.
     *
     * @return any
     */
    public any function runQuery(
        required string sql,
        any bindings = [],
        struct options = {},
        string returnObject = "query",
        boolean pretend = false,
        function postProcessHook
    ) {
        local.result = "";
        var data = {
            "sql": arguments.sql,
            "bindings": arguments.bindings,
            "options": arguments.options,
            "returnObject": arguments.returnObject,
            "pretend": arguments.pretend
        };
        tryPreInterceptor( data );
        structAppend( data.options, { result: "local.result" }, true );
        if ( variables.log.canDebug() ) {
            variables.log.debug(
                "Executing sql: #data.sql#",
                "With bindings: #variables.utils.serializeBindings( data.bindings, this )#"
            );
        }
        var startTick = getTickCount();
        data.result = {};
        data.executionTime = 0;
        data.query = javacast( "null", "" );
        if ( !arguments.pretend ) {
            var q = queryExecute( data.sql, data.bindings, data.options );
            data.executionTime = getTickCount() - startTick;
            data.query = isNull( q ) ? javacast( "null", "" ) : q;
            data.result = local.result;
        }
        tryPostInterceptor( data );
        if ( !isNull( arguments.postProcessHook ) ) {
            arguments.postProcessHook( data );
        }
        return arguments.returnObject == "query" ? ( isNull( q ) ? javacast( "null", "" ) : q ) : {
            result: data.result,
            query: ( isNull( q ) ? javacast( "null", "" ) : q )
        };
    }

    /**
     * This method exists because the API for InterceptorService differs between ColdBox and CommandBox
     */
    private function tryPreInterceptor( data ) {
        variables.interceptorService.processState( "preQBExecute", data );
        return;
    }

    /**
     * This method exists because the API for InterceptorService differs between ColdBox and CommandBox
     */
    private function tryPostInterceptor( data ) {
        if ( structKeyExists( application, "applicationName" ) && application.applicationName == "CommandBox CLI" ) {
            variables.interceptorService.announce( "postQBExecute", data );
            return;
        }

        variables.interceptorService.processState( "postQBExecute", data );
        return;
    }

    /**
     * Compile a Builder's query into a sql string.
     *
     * @query The Builder instance.
     *
     * @return string
     */
    public string function compileSelect( required QueryBuilder query ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var sql = [];

            for ( var component in selectComponents ) {
                var func = variables[ "compile#component#" ];
                var args = { "query": query, "#component#": invoke( query, "get" & component ) };
                arrayAppend( sql, func( argumentCollection = args ) );
            }

            return trim( concatenate( sql ) );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Compiles the Common Table Expressions (CTEs).
     *
     * @query The Builder instance.
     * @columns The selected columns.
     *
     * @return string
     */
    private string function compileCommonTables( required QueryBuilder query, required array commonTables ) {
        return getCommonTableExpressionSQL( arguments.query, arguments.commonTables );
    }

    /**
     * Compiles the Common Table Expressions (CTEs).
     *
     * @query                      The Builder instance.
     * @columns                    The selected columns.
     * @supportsRecursiveKeyword   Determines if the current grammar requires the RECURSIVE keyword if any CTEs are recursive.
     *
     * @return string
     */
    private string function getCommonTableExpressionSQL(
        required query,
        required array commonTables,
        boolean supportsRecursiveKeyword = true
    ) {
        if ( arguments.commonTables.isEmpty() ) {
            return "";
        }

        var hasRecursion = false;

        var sql = arguments.commonTables.map( function( commonTable ) {
            var sql = arguments.commonTable.query.toSQL();

            // generate the optional column definition
            var columns = arguments.commonTable.columns
                .map( function( value ) {
                    return wrapColumn( arguments.value );
                } )
                .toList();

            // we need to track if any of the CTEs are recursive
            if ( arguments.commonTable.recursive ) {
                hasRecursion = true;
            }

            return wrapColumn( arguments.commonTable.name ) & (
                len( columns ) ? " " & ( variables.cteColumnsRequireParentheses ? "(" : "" ) & columns & (
                    variables.cteColumnsRequireParentheses ? ")" : ""
                ) : ""
            ) & " AS (" & sql & ")";
        } );

        /*
            Most implementations of CTE require the RECURSIVE keyword if *any* single CTE uses recursive,
            but some grammars, like SQL Server, does not support the keyword (as it's not necessary).
        */
        return trim(
            "WITH " & ( arguments.supportsRecursiveKeyword && hasRecursion ? "RECURSIVE " : "" ) & sql.toList( ", " )
        );
    }

    /**
     * Compiles the columns portion of a sql statement.
     *
     * @query The Builder instance.
     * @columns The selected columns.
     *
     * @return string
     */
    private string function compileColumns( required QueryBuilder query, required array columns ) {
        if ( !query.getAggregate().isEmpty() ) {
            return "";
        }
        var select = query.getDistinct() && query.getAggregate().isEmpty() ? "SELECT DISTINCT " : "SELECT ";
        return select & columns.map( wrapColumn ).toList( ", " );
    }

    public string function compileConcat( required string alias, required array items ) {
        return "CONCAT(#arrayToList( items )#) AS #wrapAlias( alias )#";
    }

    /**
     * Compiles the table portion of a sql statement.
     *
     * @query The Builder instance.
     * @from The selected table.
     *
     * @return string
     */
    private string function compileTableName( required QueryBuilder query, required any tableName ) {
        if ( isNull( arguments.tableName ) || ( isSimpleValue( arguments.tableName ) && !len( arguments.tableName ) ) ) {
            return "";
        }

        var fullTable = arguments.tableName;
        if ( query.getAlias() != "" ) {
            fullTable &= " #query.getAlias()#";
        }
        return "FROM " & wrapTable( fullTable );
    }

    private string function compileForClause( required QueryBuilder query, any forClause ) {
        if ( isNull( arguments.forClause ) ) {
            return "";
        }

        throw( type = "UnsupportedOperation", message = "This grammar does not support FOR clauses" );
    }

    /**
     * Compiles the joins portion of a sql statement.
     *
     * @query The Builder instance.
     * @joins The selected joins.
     *
     * @return string
     */
    private string function compileJoins( required QueryBuilder query, required array joins ) {
        var joinsArray = [];

        if ( arguments.joins.isEmpty() ) {
            return "";
        }

        for ( var join in arguments.joins ) {
            var joinFunc = variables[ "compile#replace( join.getType(), " ", "", "all" )#join" ];
            joinsArray.append( joinFunc( arguments.query, join ) );
        }

        if ( joinsArray.isEmpty() ) {
            return "";
        }

        return joinsArray.toList( " " );
    }

    private string function compileInnerJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "INNER JOIN #table# #conditions#";
    }

    private string function compileFullJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "FULL JOIN #table# #conditions#";
    }

    private string function compileFullOuterJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "FULL OUTER JOIN #table# #conditions#";
    }

    private string function compileLeftJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "LEFT JOIN #table# #conditions#";
    }

    private string function compileLeftOuterJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "LEFT OUTER JOIN #table# #conditions#";
    }

    private string function compileRightJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "RIGHT JOIN #table# #conditions#";
    }

    private string function compileRightOuterJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "RIGHT OUTER JOIN #table# #conditions#";
    }

    private string function compileCrossJoin( required QueryBuilder query, required JoinClause join ) {
        var conditions = compileWheres( arguments.join, arguments.join.getWheres() );
        var table = wrapTable( arguments.join.getTable() );
        return "CROSS JOIN #table# #conditions#";
    }

    private string function compileOuterApplyJoin( required QueryBuilder query, required JoinClause join ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support OUTER APPLY joins" );
    }

    private string function compileCrossApplyJoin( required QueryBuilder query, required JoinClause join ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support CROSS APPLY joins" );
    }

    private string function compileLateralJoin( required QueryBuilder query, required JoinClause join ) {
        throw( type = "UnsupportedOperation", message = "This grammar does not support LATERAL joins" );
    }

    /**
     * Compiles the where portion of a sql statement.
     *
     * @query The Builder instance.
     * @wheres The where clauses.
     *
     * @return string
     */
    private string function compileWheres( required QueryBuilder query, array wheres = [] ) {
        var wheresArray = [];

        if ( arguments.wheres.isEmpty() ) {
            return "";
        }

        for ( var where in arguments.wheres ) {
            var whereFunc = variables[ "where#where.type#" ];
            var sql = uCase( where.combinator ) & " " & whereFunc( query, where );
            wheresArray.append( sql );
        }

        if ( wheresArray.isEmpty() ) {
            return "";
        }

        var whereList = wheresArray.toList( " " );
        var conjunction = query.isJoin() ? "ON" : "WHERE";

        return trim( "#conjunction# #removeLeadingCombinator( whereList )#" );
    }

    /**
     * Compiles a basic where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereBasic( required QueryBuilder query, required struct where ) {
        if ( !isStruct( where ) ) {
            return;
        }

        var placeholder = "?";
        if ( variables.utils.isExpression( where.value ) ) {
            placeholder = where.value.getSql();
        }

        return trim( "#wrapColumn( where.column )# #uCase( where.operator )# #placeholder#" );
    }

    /**
     * Compiles a raw where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereRaw( required QueryBuilder query, required struct where ) {
        return where.sql;
    }

    /**
     * Compiles a column where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereColumn( required QueryBuilder query, required struct where ) {
        return trim( "#wrapColumn( where.first )# #where.operator# #wrapColumn( where.second )#" );
    }

    /**
     * Compiles a nested where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNested( required QueryBuilder query, required struct where ) {
        var sql = compileWheres( arguments.where.query, arguments.where.query.getWheres() );
        return "(" & trim( removeLeadingFilterKeyword( sql ) ) & ")";
    }

    /**
     * Compiles a subselect where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereSub( required QueryBuilder query, required struct where ) {
        return "#wrapColumn( where.column )# #where.operator# (#compileSelect( where.query )#)";
    }

    /**
     * Compiles an exists where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereExists( required QueryBuilder query, required struct where ) {
        return "EXISTS (#compileSelect( where.query )#)";
    }

    /**
     * Compiles a not exists where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNotExists( required QueryBuilder query, required struct where ) {
        return "NOT EXISTS (#compileSelect( where.query )#)";
    }

    /**
     * Compiles a null where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNull( required QueryBuilder query, required struct where ) {
        return "#wrapColumn( where.column )# IS NULL";
    }

    /**
     * Compiles a null where subselect statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNullSub( required QueryBuilder query, required struct where ) {
        return "(#compileSelect( where.query )#) IS NULL";
    }

    /**
     * Compiles a not null where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNotNull( required QueryBuilder query, required struct where ) {
        return "#wrapColumn( where.column )# IS NOT NULL";
    }

    /**
     * Compiles a not null where subselect statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNotNullSub( required QueryBuilder query, required struct where ) {
        return "(#compileSelect( where.query )#) IS NOT NULL";
    }

    /**
     * Compiles a between where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereBetween( required QueryBuilder query, required struct where ) {
        var start = isSimpleValue( where.start ) ? "?" : "(#compileSelect( where.start )#)";
        var end = isSimpleValue( where.end ) ? "?" : "(#compileSelect( where.end )#)";
        return "#wrapColumn( where.column )# BETWEEN #start# AND #end#";
    }

    /**
     * Compiles a not between where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNotBetween( required QueryBuilder query, required struct where ) {
        return "#wrapColumn( where.column )# NOT BETWEEN ? AND ?";
    }

    /**
     * Compiles an in where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereIn( required QueryBuilder query, required struct where ) {
        var placeholderString = where.values
            .map( function( value ) {
                return variables.utils.isExpression( value ) ? value.getSql() : "?";
            } )
            .toList( ", " );
        if ( placeholderString == "" ) {
            return "0 = 1";
        }
        return "#wrapColumn( where.column )# IN (#placeholderString#)";
    }

    /**
     * Compiles a not in where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNotIn( required QueryBuilder query, required struct where ) {
        var placeholderString = where.values
            .map( function( value ) {
                return variables.utils.isExpression( value ) ? value.getSql() : "?";
            } )
            .toList( ", " );
        if ( placeholderString == "" ) {
            return "1 = 1";
        }
        return "#wrapColumn( where.column )# NOT IN (#placeholderString#)";
    }

    /**
     * Compiles a in subselect where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereInSub( required QueryBuilder query, required struct where ) {
        return "#wrapColumn( where.column )# IN (#compileSelect( where.query )#)";
    }

    /**
     * Compiles a not in subselect where statement.
     *
     * @query The Builder instance.
     * @where The where clause to compile.
     *
     * @return string
     */
    private string function whereNotInSub( required QueryBuilder query, required struct where ) {
        return "#wrapColumn( where.column )# NOT IN (#compileSelect( where.query )#)";
    }

    /**
     * Compiles the group by portion of a sql statement.
     *
     * @query The Builder instance.
     * @wheres The group clauses.
     *
     * @return string
     */
    private string function compileGroups( required QueryBuilder query, required array groups ) {
        if ( groups.isEmpty() ) {
            return "";
        }

        return trim( "GROUP BY #groups.map( wrapColumn ).toList( ", " )#" );
    }

    /**
     * Compiles the having portion of a sql statement.
     *
     * @query The Builder instance.
     * @havings The having clauses.
     *
     * @return string
     */
    private string function compileHavings( required QueryBuilder query, required array havings ) {
        if ( arguments.havings.isEmpty() ) {
            return "";
        }
        var sql = arguments.havings.map( compileHaving );
        return trim( "HAVING #removeLeadingCombinator( sql.toList( " " ) )#" );
    }

    /**
     * Compiles a single having clause.
     *
     * @having The having clauses.
     *
     * @return string
     */
    private string function compileHaving( required struct having ) {
        if ( having.type == "raw" ) {
            return trim( "#having.combinator# #having.column.getSQL()#" );
        }
        var placeholder = variables.utils.isExpression( having.value ) ? having.value.getSQL() : "?";
        return trim( "#having.combinator# #wrapColumn( having.column )# #having.operator# #placeholder#" );
    }


    /**
     * Compiles the UNION portion of a sql statement.
     *
     * @query The Builder instance.
     * @orders The union clauses.
     *
     * @return string
     */
    private string function compileUnions( required QueryBuilder query, required array unions ) {
        if ( arguments.unions.isEmpty() ) {
            return "";
        }

        var sql = arguments.unions.map( function( union ) {
            /*
             * No queries being unioned to the origin query can contain an ORDER BY clause, only the outer-most
             * QueryBuilder instance can actually have a defined orderBy().
             */
            if ( arguments.union.query.getOrders().len() ) {
                throw(
                    type = "OrderByNotAllowed",
                    message = "The ORDER BY clause is not allowed in a UNION statement.",
                    detail = "A QueryBuilder instance used in a UNION statement is cannot have any ORDER BY clause, as this is not allowed by SQL. Only the outer most query is allowed to specify an ORDER BY clause which will be used on the unioned queries."
                );
            }

            var sql = arguments.union.query.toSQL();

            return "UNION " & ( arguments.union.all ? "ALL " : "" ) & sql;
        } );

        return trim( arrayToList( sql, " " ) );
    }

    /**
     * Compiles the order by portion of a sql statement.
     *
     * @query The Builder instance.
     * @orders The where clauses.
     *
     * @return string
     */
    private string function compileOrders( required QueryBuilder query, required array orders ) {
        if ( orders.isEmpty() ) {
            return "";
        }

        var orderBys = orders.map( function( orderBy ) {
            if ( orderBy.direction == "raw" ) {
                return orderBy.column.getSQL();
            } else if ( orderBy.direction == "random" ) {
                return orderByRandom();
            } else if ( orderBy.keyExists( "query" ) ) {
                return "(#this.compileSelect( orderBy.query )#) #uCase( orderBy.direction )#";
            } else {
                return "#wrapColumn( orderBy.column )# #uCase( orderBy.direction )#";
            }
        } );

        return "ORDER BY #orderBys.toList( ", " )#";
    }

    private string function orderByRandom() {
        return "RANDOM()";
    }

    /**
     * Compiles the limit portion of a sql statement.
     *
     * @query The Builder instance.
     * @limitValue The limit clauses.
     *
     * @return string
     */
    private string function compileLimitValue( required QueryBuilder query, limitValue ) {
        if ( isNull( arguments.limitValue ) ) {
            return "";
        }
        return "LIMIT #limitValue#";
    }

    /**
     * Compiles the offset portion of a sql statement.
     *
     * @query The Builder instance.
     * @offsetValue The offset value.
     *
     * @return string
     */
    private string function compileOffsetValue( required QueryBuilder query, offsetValue ) {
        if ( isNull( arguments.offsetValue ) ) {
            return "";
        }
        return "OFFSET #offsetValue#";
    }

    /**
     * Compiles the lock portion of a sql statement.
     *
     * @query The Builder instance.
     * @lockType The lock type to compile.
     *
     * @return string
     */
    private string function compileLockType( required query, required string lockType ) {
        switch ( arguments.lockType ) {
            case "shared":
                return "LOCK IN SHARE MODE";
            case "update":
                return "FOR UPDATE";
            case "updateSkipLocked":
                return "FOR UPDATE SKIP LOCKED";
            case "custom":
                return arguments.query.getLockValue();
            case "none":
            case "nolock":
            default:
                return "";
        }
    }

    /**
     * Compile a Builder's query into an insert string.
     *
     * @query The Builder instance.
     * @columns The array of columns into which to insert.
     * @values The array of values to insert.
     *
     * @return string
     */
    public string function compileInsert( required any query, required array columns, required array values ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var columnsString = arguments.columns
                .map( function( column ) {
                    return wrapColumn( column.formatted );
                } )
                .toList( ", " );

            var placeholderString = values
                .map( function( valueArray ) {
                    return "(" & valueArray
                        .map( function( item ) {
                            if ( getUtils().isExpression( item ) ) {
                                return item.getSQL();
                            } else {
                                return "?";
                            }
                        } )
                        .toList( ", " ) & ")";
                } )
                .toList( ", " );
            return trim( "INSERT INTO #wrapTable( query.getTableName() )# (#columnsString#) VALUES #placeholderString#" );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Compile a Builder's query into an insert string ignoring duplicate key values.
     *
     * @qb The Builder instance.
     * @columns The array of columns into which to insert.
     * @target The array of key columns to match.
     * @values The array of values to insert.
     *
     * @return string
     */
    public string function compileInsertIgnore(
        required QueryBuilder qb,
        required array columns,
        required array target,
        required array values
    ) {
        return compileUpsert(
            arguments.qb,
            arguments.columns,
            arguments.values,
            [],
            [],
            arguments.target
        );
    }

    /**
     * Compile a Builder's query into an insert using string.
     *
     * @query The Builder instance.
     * @columns The array of columns into which to insert.
     * @source The source builder object to insert from.
     *
     * @return string
     */
    public string function compileInsertUsing(
        required any query,
        required array columns,
        required QueryBuilder source
    ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var columnsString = arguments.columns
                .map( function( column ) {
                    return wrapColumn( column.formatted );
                } )
                .toList( ", " );

            return trim(
                compileCommonTables( query, query.getCommonTables() ) & " INSERT INTO #wrapTable( arguments.query.getTableName() )# (#columnsString#) #compileSelect( arguments.source )#"
            );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Compile a Builder's query into an update string.
     *
     * @query The Builder instance.
     * @columns The array of columns into which to insert.
     *
     * @return string
     */
    public string function compileUpdate(
        required QueryBuilder query,
        required array columns,
        required struct updateMap
    ) {
        if ( !arguments.query.getReturning().isEmpty() ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support a RETURNING clause" );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            var updateList = columns
                .map( function( column ) {
                    var value = updateMap[ column.original ];
                    var assignment = "?";
                    if ( utils.isExpression( value ) ) {
                        assignment = value.getSql();
                    } else if ( utils.isBuilder( value ) ) {
                        assignment = "(#value.toSQL()#)";
                    }
                    return "#wrapColumn( column.formatted )# = #assignment#";
                } )
                .toList( ", " );

            var updateStatement = "UPDATE #wrapTable( query.getTableName() )#";

            if ( !arguments.query.getJoins().isEmpty() ) {
                updateStatement &= " " & compileJoins( arguments.query, arguments.query.getJoins() );
            }

            return trim(
                updateStatement & " SET #updateList# #compileWheres( query, query.getWheres() )# #compileLimitValue( query, query.getLimitValue() )#"
            );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Compile a Builder's query into a delete string.
     *
     * @query The Builder instance.
     *
     * @return string
     */
    public string function compileDelete( required QueryBuilder query ) {
        if ( !arguments.query.getReturning().isEmpty() ) {
            throw(
                type = "UnsupportedOperation",
                message = "This grammar does not support DELETE actions with a RETURNING clause."
            );
        }

        if ( !arguments.query.getJoins().isEmpty() ) {
            throw(
                type = "UnsupportedOperation",
                message = "This grammar does not support DELETE actions with JOIN clause(s)."
            );
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }

            return trim( "DELETE FROM #wrapTable( query.getTableName() )# #compileWheres( query, query.getWheres() )#" );
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Compile a Builder's query into an aggregate select string.
     *
     * @query The Builder instance.
     * @aggregate The aggregate query to execute.
     *
     * @return string
     */
    private string function compileAggregate( required QueryBuilder query, required struct aggregate ) {
        if ( aggregate.isEmpty() ) {
            return "";
        }

        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.query.getShouldWrapValues() );
            }
            var shouldIncludeDistinct = query.getDistinct() && aggregate.column.type == "simple" && aggregate.column.value != "*";
            var aggString = "#uCase( aggregate.type )#(#shouldIncludeDistinct ? "DISTINCT " : ""##wrapColumn( aggregate.column )#)";
            if ( aggregate.keyExists( "defaultValue" ) && !isNull( aggregate.defaultValue ) ) {
                aggString = "COALESCE(#aggString#, #aggregate.defaultValue#)";
            }

            if ( !query.getUnions().isEmpty() ) {
                var clonedQuery = query.clone().setAggregate( {} );
                query.reset();
                query.setAggregate( arguments.aggregate );
                query.fromSub( "qb_aggregate_source", clonedQuery );
            }

            return "SELECT #aggString# AS ""aggregate""";
        } finally {
            if ( !isNull( arguments.query.getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /**
     * Returns an array of sql concatenated together with empty spaces.
     *
     * @sql An array of sql fragments.
     *
     * @return string
     */
    private string function concatenate( required array sql, string separator = " " ) {
        return arrayToList(
            arrayFilter( arguments.sql, function( item ) {
                return item != "";
            } ),
            arguments.separator
        );
    }

    /**
     * Removes the leading "AND" or "OR" from a sql fragment.
     *
     * @whereList The sql fragment
     *
     * @return string;
     */
    private string function removeLeadingCombinator( required string whereList ) {
        return reReplaceNoCase( whereList, "and\s|or\s", "", "one" );
    }

    /**
     * Removes the leading "AND" or "OR" from a sql fragment.
     *
     * @whereList The sql fragment
     *
     * @return string;
     */
    private string function removeLeadingFilterKeyword( required string whereList ) {
        return reReplaceNoCase( whereList, "where\s|on\s", "", "one" );
    }

    /**
     * Parses and wraps a table from the Builder for use in a sql statement.
     *
     * @table The table to parse and wrap.
     *
     * @return string
     */
    public string function wrapTable( required any table, boolean includeAlias = true ) {
        // if we have a raw expression, just return it as-is
        if ( variables.utils.isExpression( arguments.table ) ) {
            return arguments.table.getSql();
        }

        var parts = explodeTable( arguments.table );
        if ( getUtils().isNotSubQuery( parts.table ) ) {
            parts.table = parts.table
                .listToArray( "." )
                .map( function( tablePart, index, tableParts ) {
                    // Add the tableprefix when we get to the last element
                    if ( index == tableParts.len() ) {
                        return wrapValue( getTablePrefix() & tablePart );
                    }
                    return wrapValue( tablePart );
                } )
                .toList( "." );
        }
        if ( !parts.alias.len() ) {
            return parts.table;
        }

        if ( !arguments.includeAlias ) {
            return parts.table;
        }

        return parts.table & getTableAliasOperator() & wrapAlias( getTablePrefix() & parts.alias );
    }

    public struct function explodeTable( required string table ) {
        var parts = { "alias": "", "table": trim( arguments.table ) };

        // Quick check to see if we should bother to use a regex to look for a table alias
        if ( parts.table.find( " " ) ) {
            var matches = reFindNoCase(
                "(.*?)(?:\s(?:AS\s){0,1})([^\)]+)$",
                parts.table,
                1,
                true
            );
            if ( matches.pos.len() >= 3 ) {
                parts.alias = mid( parts.table, matches.pos[ 3 ], matches.len[ 3 ] );
                parts.table = mid( parts.table, matches.pos[ 2 ], matches.len[ 2 ] );
            }
        }

        return parts;
    }

    /**
     * Parses and wraps a column from the Builder for use in a sql statement.
     *
     * @column The column to parse and wrap.
     *
     * @return string
     */
    public string function wrapColumn( required any column ) {
        if ( arguments.column.type == "raw" ) {
            return trim( arguments.column.value.getSQL() );
        }

        if ( arguments.column.type == "builder" ) {
            return trim( wrapTable( "(#arguments.column.value.toSQL()#) AS #arguments.column.alias#" ) );
        }

        arguments.column = trim( arguments.column.value );
        var alias = "";
        if ( arguments.column.findNoCase( " as " ) > 0 ) {
            var matches = reFindNoCase(
                "(.*)(?:\sAS\s)(.*)",
                arguments.column,
                1,
                true
            );
            if ( matches.pos.len() >= 3 ) {
                alias = mid( arguments.column, matches.pos[ 3 ], matches.len[ 3 ] );
                arguments.column = mid( arguments.column, matches.pos[ 2 ], matches.len[ 2 ] );
            }
        } else if ( arguments.column.findNoCase( " " ) > 0 ) {
            alias = listGetAt( arguments.column, 2, " " );
            arguments.column = listGetAt( arguments.column, 1, " " );
        }
        arguments.column = arguments.column
            .listToArray( "." )
            .map( wrapValue )
            .toList( "." );
        if ( !alias.len() ) {
            return arguments.column;
        }
        return arguments.column & " AS " & wrapValue( alias );
    }

    /**
     * Extracts the alias from a column. Returns the column if no alias is found.
     *
     * @column The column to extract the alias
     *
     * @return string
     */
    public string function extractAlias( required any column ) {
        if ( arguments.column.type == "raw" ) {
            arguments.column = trim( arguments.column.value.getSQL() );
        } else {
            arguments.column = trim( arguments.column.value );
        }

        var alias = "";
        if ( arguments.column.findNoCase( " as " ) > 0 ) {
            var matches = reFindNoCase(
                "(.*)(?:\sAS\s)(.*)",
                arguments.column,
                1,
                true
            );
            if ( matches.pos.len() >= 3 ) {
                return mid( arguments.column, matches.pos[ 3 ], matches.len[ 3 ] );
            }
        } else if ( arguments.column.findNoCase( " " ) > 0 ) {
            return listLast( arguments.column, " " );
        }

        return listLast( arguments.column, "." );
    }

    /**
     * Parses and wraps a value from the Builder for use in a sql statement.
     *
     * @table The value to parse and wrap.
     *
     * @return string
     */
    function wrapValue( required any value ) {
        if ( !variables.shouldWrapValues ) {
            return arguments.value;
        }

        if ( len( arguments.value ) == 0 ) {
            return arguments.value;
        }

        if ( arguments.value == "*" ) {
            return arguments.value;
        }

        arguments.value = reReplace( arguments.value, """", "", "all" );

        return """#value#""";
    }

    /**
     * Parses and wraps a value from the Builder for use in a sql statement.
     *
     * @table The value to parse and wrap.
     *
     * @return string
     */
    public string function wrapAlias( required any value ) {
        return wrapValue( value );
    }

    function compileRaw( blueprint, commandParameters ) {
        return commandParameters[ "sql" ];
    }

    /*=========================================
    =            Blueprint: Create            =
    =========================================*/

    function compileCreate( required blueprint ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "CREATE TABLE #wrapTable( blueprint.getTable() )# (#compileCreateBody( blueprint )#)";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileCreateBody( blueprint ) {
        return concatenate( [ compileCreateColumns( blueprint ), compileCreateIndexes( blueprint ) ], ", " );
    }

    function compileCreateColumns( required blueprint ) {
        return blueprint
            .getColumns()
            .map( function( column ) {
                return compileCreateColumn( column, blueprint );
            } )
            .toList( ", " );
    }

    function compileCreateColumn( column, blueprint ) {
        if ( utils.isExpression( column ) ) {
            return column.getSql();
        }

        try {
            if ( !column.isColumn() ) {
                throw( message = "Not a Column" );
            }
        } catch ( any e ) {
            // exception happens when isColumn returns false or is not a method on the column object
            throw(
                type = "InvalidColumn",
                message = "Recieved a TableIndex instead of a Column when trying to create a Column.",
                detail = "Did you maybe try to add a column and a constraint in an ALTER clause at the same time? Split those up in to separate addColumn and addConstraint commands."
            );
        }

        return concatenate( [
            wrapColumn( { "type": "simple", "value": column.getName() } ),
            generateType( column, blueprint ),
            modifyUnsigned( column ),
            generateComputed( column ),
            generateNullConstraint( column ),
            generateUniqueConstraint( column, blueprint ),
            generateAutoIncrement( column, blueprint ),
            generateDefault( column, blueprint ),
            generateComment( column, blueprint )
        ] );
    }

    function generateNullConstraint( column ) {
        return column.getIsNullable() ? "" : "NOT NULL";
    }

    function generateUniqueConstraint( column, blueprint ) {
        return column.getIsUnique() ? "UNIQUE" : "";
    }

    function modifyUnsigned( column ) {
        return column.getIsUnsigned() ? "UNSIGNED" : "";
    }

    function generateComputed( column ) {
        if ( column.getComputedType() == "none" ) {
            return "";
        }

        return "GENERATED ALWAYS AS (#column.getComputedDefinition()#) " & (
            column.getComputedType() == "virtual" ? "VIRTUAL" : "STORED"
        );
    }

    function generateAutoIncrement( column, blueprint ) {
        return column.getAutoIncrement() ? "AUTO_INCREMENT" : "";
    }

    function generateDefault( column ) {
        if ( column.getDefaultValue() == "" ) {
            return "";
        }
        return "DEFAULT #wrapDefaultType( column )#";
    }

    function generateComment( column ) {
        return column.getCommentValue() != "" ? "COMMENT '#column.getCommentValue()#'" : "";
    }

    function compileAddComment( blueprint, commandParameters ) {
        return concatenate( [
            "COMMENT ON COLUMN",
            wrapColumn( { "type": "simple", "value": commandParameters.table & "." & commandParameters.column.getName() } ),
            "IS",
            "'" & commandParameters.column.getCommentValue() & "'"
        ] );
    }

    /*=====  End of Blueprint: Create  ======*/

    /*=======================================
    =            Blueprint: Drop            =
    =======================================*/

    function compileDrop( required blueprint ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [ "DROP TABLE", generateIfExists( blueprint ), wrapTable( blueprint.getTable() ) ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileTruncate( required blueprint ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [ "TRUNCATE TABLE", generateIfExists( blueprint ), wrapTable( blueprint.getTable() ) ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function generateIfExists( blueprint ) {
        return blueprint.getIfExists() ? "IF EXISTS" : "";
    }

    function compileDropAllObjects( struct options = {}, string schema = "", SchemaBuilder sb ) {
        throw(
            type = "UnsupportedOperation",
            message = "This database grammar does not support this operation",
            detail = "compileDropAllObjects"
        );
    }

    function compileEnableForeignKeyConstraints() {
        throw(
            type = "UnsupportedOperation",
            message = "This database grammar does not support this operation",
            detail = "compileEnableForeignKeyConstraints"
        );
    }

    function compileDisableForeignKeyConstraints() {
        throw(
            type = "UnsupportedOperation",
            message = "This database grammar does not support this operation",
            detail = "compileDisableForeignKeyConstraints"
        );
    }

    /*=====  End of Blueprint: Drop  ======*/

    /*========================================
    =            Blueprint: Alter            =
    ========================================*/

    function compileAddColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var existingIndexes = blueprint.getIndexes();
            blueprint.setIndexes( [] );

            var body = concatenate(
                [ compileCreateColumn( commandParameters.column, blueprint ), compileCreateIndexes( blueprint ) ],
                ", "
            );

            blueprint.setIndexes( existingIndexes );

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "ADD",
                body
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            if ( isSimpleValue( commandParameters.name ) ) {
                return concatenate( [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "DROP COLUMN",
                    wrapColumn( { "type": "simple", "value": commandParameters.name } )
                ] );
            } else {
                return concatenate( [
                    "ALTER TABLE",
                    wrapTable( blueprint.getTable() ),
                    "DROP COLUMN",
                    wrapColumn( { "type": "simple", "value": commandParameters.name.getName() } )
                ] );
            }
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileRenameTable( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "RENAME TO",
                wrapTable( commandParameters.to )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileRenameColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "CHANGE",
                wrapColumn( { "type": "simple", "value": commandParameters.from } ),
                compileCreateColumn( commandParameters.to, blueprint )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "RENAME INDEX",
                wrapColumn( { "type": "simple", "value": commandParameters.from } ),
                "TO",
                wrapColumn( { "type": "simple", "value": commandParameters.to } )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileModifyColumn( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return concatenate( [
                "ALTER TABLE",
                wrapTable( blueprint.getTable() ),
                "CHANGE",
                wrapColumn( { "type": "simple", "value": commandParameters.from } ),
                compileCreateColumn( commandParameters.to, blueprint )
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /*=====  End of Blueprint: Alter  ======*/

    /*===================================
    =            Constraints            =
    ===================================*/

    function compileAddConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var index = commandParameters.index;
            var constraint = invoke( this, "index#index.getType()#", { index: index } );
            return "ALTER TABLE #wrapTable( blueprint.getTable() )# ADD #constraint#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP INDEX #wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropIndex( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP INDEX #wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropForeignKey( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /*=====  End of Constraints  ======*/

    /*====================================
    =            Column Types            =
    ====================================*/

    function generateType( column, blueprint ) {
        return invoke( this, "type#column.getType()#", { column: column, blueprint: blueprint } );
    }

    function typeBigInteger( column ) {
        return concatenate( [ "BIGINT", isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)" ], "" );
    }

    function typeBit( column ) {
        return "BIT(#column.getLength()#)";
    }

    function typeBoolean( column ) {
        return "TINYINT(1)";
    }

    public string function getBooleanSqlType() {
        return "TINYINT";
    }

    public any function convertBooleanValue( required any value ) {
        return arguments.value ? 1 : 0;
    }

    function convertToBooleanType( any value ) {
        return {
            "value": isNull( value ) ? javacast( "null", "" ) : convertBooleanValue( value ),
            "cfsqltype": getBooleanSqlType(),
            "sqltype": getBooleanSqlType()
        };
    }

    function typeChar( column ) {
        return "CHAR(#column.getLength()#)";
    }

    function typeDate( column ) {
        return "DATE";
    }

    function typeDatetime( column ) {
        return "DATETIME";
    }

    function typeDatetimeTz( column ) {
        return typeDatetime( column );
    }

    function typeDecimal( column ) {
        return "DECIMAL(#column.getLength()#,#column.getPrecision()#)";
    }

    function typeEnum( column ) {
        var values = column
            .getValues()
            .map( function( value ) {
                return "'#value#'";
            } )
            .toList( ", " );
        return "ENUM(#values#)";
    }

    function typeFloat( column ) {
        return "FLOAT(#column.getLength()#,#column.getPrecision()#)";
    }

    function typeGUID( column ) {
        return typeChar( column );
    }

    function typeInteger( column ) {
        return concatenate( [ "INTEGER", isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)" ], "" );
    }

    function typeJson( column ) {
        return "TEXT";
    }

    function typeJsonb( column ) {
        return "TEXT";
    }

    function typeLongText( column ) {
        return "TEXT";
    }

    function typeMoney( column ) {
        return typeInteger( column );
    }

    function typeSmallMoney( column ) {
        return typeInteger( column );
    }

    function typeUnicodeLongText( column ) {
        return "TEXT";
    }

    function typeUUID( column ) {
        return typeChar( column );
    }

    function typeLineString( column ) {
        return "GEOGRAPHY";
    }

    function typeMediumInteger( column ) {
        return concatenate( [ "MEDIUMINT", isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)" ], "" );
    }

    function typeMediumText( column ) {
        return "TEXT";
    }

    function typeUnicodeMediumText( column ) {
        return "TEXT";
    }

    function typePoint( column ) {
        return "GEOGRAPHY";
    }

    function typePolygon( column ) {
        return "GEOGRAPHY";
    }

    function typeSmallInteger( column ) {
        return concatenate( [ "SMALLINT", isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)" ], "" );
    }

    function typeString( column ) {
        return "VARCHAR(#column.getLength()#)";
    }

    function typeUnicodeString( column ) {
        return "NVARCHAR(#column.getLength()#)";
    }

    function typeText( column ) {
        return "TEXT";
    }

    function typeUnicodeText( column ) {
        return "TEXT";
    }

    function typeTime( column ) {
        return "TIME";
    }

    function typeTimeTz( column ) {
        return "TIME";
    }

    function typeTimestamp( column ) {
        return "TIMESTAMP#isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"#";
    }

    function typeTimestampTz( column ) {
        return typeTimestamp( column );
    }

    function typeTinyInteger( column ) {
        return concatenate( [ "TINYINT", isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)" ], "" );
    }

    /*=====  End of Column Types  ======*/

    /*===================================
    =               Views               =
    ===================================*/

    function compileCreateView( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var query = commandParameters[ "query" ];
            return "CREATE VIEW #wrapTable( blueprint.getTable() )# AS (#compileSelect( query )#)";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileAlterView( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return [
                compileDropView( blueprint, commandParameters ),
                compileCreateView( blueprint, commandParameters )
            ];
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileDropView( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return "DROP VIEW #wrapTable( blueprint.getTable() )#";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileCreateAs( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var query = commandParameters[ "query" ];
            return "CREATE TABLE #wrapTable( blueprint.getTable() )# AS (#compileSelect( query )#)";
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    /*===================================
    =            Index Types            =
    ===================================*/

    function compileCreateIndexes( blueprint ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            return blueprint
                .getIndexes()
                .map( function( index ) {
                    return invoke( this, "index#index.getType()#", { index: index, blueprint: blueprint } );
                } )
                .filter( function( item ) {
                    return item != "";
                } )
                .toList( ", " );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function compileAddIndex( blueprint, commandParameters ) {
        try {
            var originalShouldWrapValues = getShouldWrapValues();
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() );
            }

            var columnList = commandParameters.index
                .getColumns()
                .map( function( column ) {
                    column = isSimpleValue( column ) ? column : column.getName();
                    return wrapValue( column );
                } )
                .toList( ", " );

            return concatenate( [
                "CREATE INDEX",
                wrapValue( commandParameters.index.getName() ),
                "ON",
                wrapTable( commandParameters.table ),
                "(#columnList#)"
            ] );
        } finally {
            if ( !isNull( arguments.blueprint.getSchemaBuilder().getShouldWrapValues() ) ) {
                setShouldWrapValues( originalShouldWrapValues );
            }
        }
    }

    function indexBasic( index, blueprint ) {
        var columnsString = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( { "type": "simple", "value": column } );
            } )
            .toList( ", " );
        return "INDEX #wrapValue( arguments.index.getName() )# (#columnsString#)";
    }

    function indexForeign( index ) {
        // FOREIGN KEY ("country_id") REFERENCES countries ("id") ON DELETE CASCADE
        var keys = arguments.index
            .getForeignKey()
            .map( function( key ) {
                return wrapColumn( { "type": "simple", "value": key } );
            } )
            .toList( ", " );
        var references = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( { "type": "simple", "value": column } );
            } )
            .toList( ", " );
        return concatenate( [
            "CONSTRAINT #wrapValue( arguments.index.getName() )#",
            "FOREIGN KEY (#keys#)",
            "REFERENCES #wrapTable( arguments.index.getTable() )# (#references#)",
            "ON UPDATE #uCase( arguments.index.getOnUpdateAction() )#",
            "ON DELETE #uCase( arguments.index.getOnDeleteAction() )#"
        ] );
    }

    function indexPrimary( index ) {
        var references = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( { "type": "simple", "value": column } );
            } )
            .toList( ", " );
        return "CONSTRAINT #wrapValue( arguments.index.getName() )# PRIMARY KEY (#references#)";
    }

    function indexUnique( index ) {
        var references = arguments.index
            .getColumns()
            .map( function( column ) {
                return wrapColumn( { "type": "simple", "value": column } );
            } )
            .toList( ", " );
        return "CONSTRAINT #wrapValue( arguments.index.getName() )# UNIQUE (#references#)";
    }

    function indexCheck( index ) {
        var column = arguments.index.getColumns()[ 1 ];
        var values = column
            .getValues()
            .map( function( val ) {
                return "'#val#'";
            } )
            .toList( ", " );
        return concatenate( [
            "CONSTRAINT",
            wrapValue( arguments.index.getName() ),
            "CHECK",
            "(#wrapValue( column.getName() )# IN (#values#))"
        ] );
    }

    /*=====  End of Index Types  ======*/

    function compileTableExists( tableName, schemaName = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "information_schema.tables" )# WHERE #wrapColumn( { "type": "simple", "value": "table_name" } )# = ?";
        if ( schemaName != "" ) {
            sql &= " AND #wrapColumn( { "type": "simple", "value": "table_schema" } )# = ?";
        }
        return sql;
    }

    function compileColumnExists( table, column, schema = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "information_schema.columns" )# WHERE #wrapColumn( { "type": "simple", "value": "table_name" } )# = ? AND #wrapColumn( { "type": "simple", "value": "column_name" } )# = ?";
        if ( schema != "" ) {
            sql &= " AND #wrapColumn( { "type": "simple", "value": "table_schema" } )# = ?";
        }
        return sql;
    }

    function compileAddType() {
        return "";
    }

    function getShouldWrapValues() {
        if ( isNull( variables.shouldWrapValues ) ) {
            throw( type = "InvalidState", message = "The shouldWrapValues property has not been set." );
        }
        return variables.shouldWrapValues;
    }

    function setShouldWrapValues( required boolean shouldWrap ) {
        if ( isNull( arguments.shouldWrap ) ) {
            throw( type = "InvalidState", message = "The shouldWrapValues property has not been set." );
        }
        variables.shouldWrapValues = arguments.shouldWrap;
        return this;
    }

}
