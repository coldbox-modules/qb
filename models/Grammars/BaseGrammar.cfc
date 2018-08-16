import qb.models.Query.QueryBuilder;
import qb.models.Query.QueryUtils;

/**
* Grammar represents a platform to run sql on.
*
* This is the Base Grammar that other grammars can extend to modify
* the generated sql for their specific platforms.
*/
component displayname="Grammar" accessors="true" {

    /**
    * ColdBox Interceptor Service to announce pre- and post- interception points
    * This is not injected since we need to determine if we are in CommandBox or ColdBox first.
    * This is handled in the ModuleConfig file
    */
    property name="interceptorService";

    /**
    * Query utilities shared across multiple models.
    */
    property name="utils";

    /**
    * Global table prefix for the grammar.
    */
    property name="tablePrefix" type="string" default="";

    /**
    * The different components of a select statement in the order of compilation.
    */
    variables.selectComponents = [
        "aggregate", "columns", "from", "joins", "wheres",
        "groups", "havings", "unions", "orders", "limitValue", "offsetValue"
    ];

    /**
    * Creates a new basic Query Grammar.
    *
    * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
    *
    * @return qb.models.Grammars.BaseGrammar
    */
    public BaseGrammar function init(
        QueryUtils utils = new qb.models.Query.QueryUtils()
    ) {
        variables.utils = arguments.utils;
        variables.tablePrefix = "";
        return this;
    }

    /**
    * Runs a query through `queryExecute`.
    * This function exists so that platform-specific grammars can override it if needed.
    *
    * @sql The sql string to execute.
    * @bindings The bindings to apply to the query.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function runQuery( sql, bindings, options, returnObject = "query" ) {
        local.result = "";
        var data = duplicate( arguments );
        tryPreInterceptor( data );
        structAppend( options, { result = "local.result" }, true );
        var q = queryExecute( sql, bindings, options );
        data.query = isNull( q ) ? javacast( "null", "" ) : q;
        data.result = local.result;
        tryPostInterceptor( data );
        return returnObject == "result" ? local.result : q;
    }

    /**
    * This method exists because the API for InterceptorService differs between ColdBox and CommandBox
    */
    private function tryPreInterceptor( data ) {
        if ( isNull( variables.interceptorService ) ) {
            return;
        }

        if ( structKeyExists( application, "applicationName" ) && application.applicationName == "CommandBox CLI" ) {
            variables.interceptorService.announceInterception( "preQBExecute", data );
            return;
        }

        variables.interceptorService.processState( "preQBExecute", data );
        return;
    }

    /**
    * This method exists because the API for InterceptorService differs between ColdBox and CommandBox
    */
    private function tryPostInterceptor( data ) {
        if ( isNull( variables.interceptorService ) ) {
            return;
        }

        if ( structKeyExists( application, "applicationName" ) && application.applicationName == "CommandBox CLI" ) {
            variables.interceptorService.announceInterception( "postQBExecute", data );
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
        var sql = [];

        for ( var component in selectComponents ) {
            var func = variables[ "compile#component#" ];
            var args = {
                "query" = query,
                "#component#" = invoke( query, "get" & component )
            };
            arrayAppend( sql, func( argumentCollection = args ) );
        }

        return trim( concatenate( sql ) );
    }

    /**
    * Compiles the columns portion of a sql statement.
    *
    * @query The Builder instance.
    * @columns The selected columns.
    *
    * @return string
    */
    private string function compileColumns(
        required QueryBuilder query,
        required array columns
    ) {
        if ( ! query.getAggregate().isEmpty() ) {
            return "";
        }
        var select = query.getDistinct() ? "SELECT DISTINCT " : "SELECT ";
        return select & columns.map( wrapColumn ).toList( ", " );
    }

    /**
    * Compiles the table portion of a sql statement.
    *
    * @query The Builder instance.
    * @from The selected table.
    *
    * @return string
    */
    private string function compileFrom(
        required QueryBuilder query,
        required string from
    ) {
        return "FROM " & wrapTable( from );
    }

    /**
    * Compiles the joins portion of a sql statement.
    *
    * @query The Builder instance.
    * @joins The selected joins.
    *
    * @return string
    */
    private string function compileJoins(
        required QueryBuilder query,
        required array joins
    ) {
        var joinsArray = [];
        for ( var join in arguments.joins ) {
            var conditions = compileWheres( join, join.getWheres() );
            var table = wrapTable( join.getTable() );
            joinsArray.append( "#uCase( join.getType() )# JOIN #table# #conditions#" );
        }

        return arrayToList( joinsArray, " " );
    }

    /**
    * Compiles the where portion of a sql statement.
    *
    * @query The Builder instance.
    * @wheres The where clauses.
    *
    * @return string
    */
    private string function compileWheres(
        required QueryBuilder query,
        array wheres = []
    ) {
        var wheresArray = [];

        if ( arguments.wheres.isEmpty() ) {
            return "";
        }

        for ( var where in arguments.wheres ) {
            var whereFunc = variables[ "where#where.type#" ];
            var sql = uCase( where.combinator ) & " " & whereFunc( query, duplicate( where ) );
            wheresArray.append( sql );
        }

        if ( wheresArray.isEmpty() ) {
            return "";
        }

        var whereList = wheresArray.toList( " " );
        var conjunction = isInstanceOf( query, "qb.models.Query.JoinClause" ) ?
            "ON" : "WHERE";

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
    private string function whereBasic(
        required QueryBuilder query,
        required struct where
    ) {
        if ( ! isStruct( where ) ) {
            return;
        }

        where.column = wrapColumn( where.column );

        var placeholder = "?";

        if ( isInstanceOf( where.value, "qb.models.Query.Expression" ) ) {
            placeholder = where.value.getSql();
        }

        return trim( "#where.column# #uCase( where.operator )# #placeholder#" );
    }

    /**
    * Compiles a raw where statement.
    *
    * @query The Builder instance.
    * @where The where clause to compile.
    *
    * @return string
    */
    private string function whereRaw(
        required QueryBuilder query,
        required struct where
    ) {
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
    private string function whereColumn(
        required QueryBuilder query,
        required struct where
    ) {
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
    private string function whereNested(
        required QueryBuilder query,
        required struct where
    ) {
        var sql = compileWheres(
            arguments.where.query,
            arguments.where.query.getWheres()
        );
        // cut off the first 7 characters to account for the extra "WHERE"
        return trim( "(#mid( sql, 7, len( sql ) - 6 )#)" );
    }

    /**
    * Compiles a subselect where statement.
    *
    * @query The Builder instance.
    * @where The where clause to compile.
    *
    * @return string
    */
    private string function whereSub(
        required QueryBuilder query,
        required struct where
    ) {
        return "#wrapValue( where.column )# #where.operator# (#compileSelect( where.query )#)";
    }

    /**
    * Compiles an exists where statement.
    *
    * @query The Builder instance.
    * @where The where clause to compile.
    *
    * @return string
    */
    private string function whereExists(
        required QueryBuilder query,
        required struct where
    ) {
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
    private string function whereNotExists(
        required QueryBuilder query,
        required struct where
    ) {
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
    private string function whereNull(
        required QueryBuilder query,
        required struct where
    ) {
        return "#wrapColumn( where.column )# IS NULL";
    }

    /**
    * Compiles a not null where statement.
    *
    * @query The Builder instance.
    * @where The where clause to compile.
    *
    * @return string
    */
    private string function whereNotNull(
        required QueryBuilder query,
        required struct where
    ) {
        return "#wrapColumn( where.column )# IS NOT NULL";
    }

    /**
    * Compiles a between where statement.
    *
    * @query The Builder instance.
    * @where The where clause to compile.
    *
    * @return string
    */
    private string function whereBetween(
        required QueryBuilder query,
        required struct where
    ) {
        return "#wrapColumn( where.column )# BETWEEN ? AND ?";
    }

    /**
    * Compiles a not between where statement.
    *
    * @query The Builder instance.
    * @where The where clause to compile.
    *
    * @return string
    */
    private string function whereNotBetween(
        required QueryBuilder query,
        required struct where
    ) {
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
    private string function whereIn(
        required QueryBuilder query,
        required struct where
    ) {
        var placeholderString = where.values.map( function( value ) {
            return isInstanceOf( value, "qb.models.Query.Expression" ) ? value.getSql() : "?";
        } ).toList( ", " );
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
    private string function whereNotIn(
        required QueryBuilder query,
        required struct where
    ) {
        var placeholderString = where.values.map( function( value ) {
            return isInstanceOf( value, "qb.models.Query.Expression" ) ? value.getSql() : "?";
        } ).toList( ", " );
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
    private string function whereInSub(
        required QueryBuilder query,
        required struct where
    ) {
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
    private string function whereNotInSub(
        required QueryBuilder query,
        required struct where
    ) {
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
        var placeholder = isInstanceOf( having.value, "qb.models.Query.Expression" ) ?
            having.value.getSQL() : "?";
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
        
        var sql = arguments.unions.map(function (union){
            /*
             * No queries being unioned to the origin query can contain an ORDER BY clause, only the outer-most
             * QueryBuilder instance can actually have a defined orderBy().
             */
            if( arguments.union.query.getOrders().len() ){
                throw(
                    type = "OrderByNotAllowed",
                    message = "The ORDER BY clause is not allowed in a UNION statement.",
                    detail = "A QueryBuilder instance used in a UNION statement is cannot have any ORDER BY clause, as this is not allowed by SQL. Only the outer most query is allowed to specify an ORDER BY clause which will be used on the unioned queries."
                );
            }

           var sql = arguments.union.query.toSQL();

            return "UNION " & (arguments.union.all ? "ALL " : "") & sql;
        });

        return trim( arrayToList(sql, ' ') );
    }

    /**
    * Compiles the order by portion of a sql statement.
    *
    * @query The Builder instance.
    * @orders The where clauses.
    *
    * @return string
    */
    private string function compileOrders(
        required QueryBuilder query,
        required array orders
    ) {
        if ( orders.isEmpty() ) {
            return "";
        }

        var orderBys = orders.map( function( orderBy ) {
            return orderBy.direction == "raw" ?
                orderBy.column.getSql() :
                "#wrapColumn( orderBy.column )# #uCase( orderBy.direction )#";
        } );

        return "ORDER BY #orderBys.toList( ", " )#";
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
    * Compile a Builder's query into an insert string.
    *
    * @query The Builder instance.
    * @columns The array of columns into which to insert.
    * @values The array of values to insert.
    *
    * @return string
    */
    public string function compileInsert(
        required QueryBuilder query,
        required array columns,
        required array values
    ) {
        var columnsString = columns.map( wrapColumn ).toList( ", " );

        var placeholderString = values.map( function( valueArray ) {
            return "(" & valueArray.map( function() {
                return "?";
            } ).toList( ", " ) & ")";
        } ).toList( ", ");
        return trim( "INSERT INTO #wrapTable( query.getFrom() )# (#columnsString#) VALUES #placeholderString#" );
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
        required array columns
    ) {
        var updateList = columns.map( function( column ) {
            return "#wrapColumn( column )# = ?";
        } ).toList( ", " );

        return trim( "UPDATE #wrapTable( query.getFrom() )# SET #updateList# #compileWheres( query, query.getWheres() )# #compileLimitValue( query, query.getLimitValue() )#" );
    }

    /**
    * Compile a Builder's query into a delete string.
    *
    * @query The Builder instance.
    *
    * @return string
    */
    public string function compileDelete( required QueryBuilder query ) {
        return trim( "DELETE FROM #wrapTable( query.getFrom() )# #compileWheres( query, query.getWheres() )#" );
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
        return "SELECT #uCase( aggregate.type )#(#wrapColumn( aggregate.column )#) AS ""aggregate""";
    }

    /**
    * Returns an array of sql concatenated together with empty spaces.
    *
    * @sql An array of sql fragments.
    *
    * @return string
    */
    private string function concatenate( required array sql ) {
        return arrayToList( arrayFilter( sql, function( item ) {
            return item != "";
        } ), " " );
    }

    /**
    * Removes the leading "AND" or "OR" from a sql fragment.
    *
    * @whereList The sql fragment
    *
    * @return string;
    */
    private string function removeLeadingCombinator( required string whereList ) {
        return REReplaceNoCase( whereList, "and\s|or\s", "", "one" );
    }

    /**
    * Parses and wraps a table from the Builder for use in a sql statement.
    *
    * @table The table to parse and wrap.
    *
    * @return string
    */
    public string function wrapTable( required any table ) {
        var alias = "";
        if ( table.findNoCase( " as " ) > 0 ) {
            var matches = REFindNoCase( "(.*)(?:\sAS\s)(.*)", table, 1, true );
            if ( matches.pos.len() >= 3 ) {
                alias = mid( table, matches.pos[3], matches.len[3] );
                table = mid( table, matches.pos[2], matches.len[2] );
            }
        }
        else if ( table.findNoCase( " " ) > 0 ) {
            alias = listGetAt( table, 2, " " );
            table = listGetAt( table, 1, " " );
        }

        table = table.listToArray( "." ).map( function( tablePart, index ) {
            return wrapValue( index == 1 ? getTablePrefix() & tablePart : tablePart );
        } ).toList( "." );
        return alias == "" ? table : table & " AS " & wrapValue( getTablePrefix() & alias );
    }

    /**
    * Parses and wraps a column from the Builder for use in a sql statement.
    *
    * @column The column to parse and wrap.
    *
    * @return string
    */
    public string function wrapColumn( required any column ) {
        // In this case, isInstanceOf takes ~30 ms while this takes ~0 ms
        if ( ! isSimpleValue( column ) &&
             isObject( column ) &&
             structKeyExists( column, "getSQL" )
        ) {
            return column.getSQL();
        }

        var alias = "";
        if ( column.findNoCase( " as " ) > 0 ) {
            var matches = REFindNoCase( "(.*)(?:\sAS\s)(.*)", column, 1, true );
            if ( matches.pos.len() >= 3 ) {
                alias = mid( column, matches.pos[3], matches.len[3] );
                column = mid( column, matches.pos[2], matches.len[2] );
            }
        }
        else if ( column.findNoCase( " " ) > 0 ) {
            alias = listGetAt( column, 2, " " );
            column = listGetAt( column, 1, " " );
        }
        column = column.listToArray( "." ).map( wrapValue ).toList( "." );
        return alias == "" ? column : column & " AS " & wrapValue( alias );
    }

    /**
    * Parses and wraps a value from the Builder for use in a sql statement.
    *
    * @table The value to parse and wrap.
    *
    * @return string
    */
    public string function wrapValue( required any value ) {
        if ( value == "*" ) {
            return value;
        }
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
        return commandParameters;
    }

    /*=========================================
    =            Blueprint: Create            =
    =========================================*/

    function compileCreate( required blueprint ) {
        return "CREATE TABLE #wrapTable( blueprint.getTable() )# (#compileCreateBody( blueprint )#)";
    }

    function compileCreateBody( blueprint ) {
        return arrayToList( arrayFilter( [
            compileCreateColumns( blueprint ),
            compileCreateIndexes( blueprint )
        ], function( item ) {
            return item != "";
        } ), ", " );
    }

    function compileCreateColumns( required blueprint ) {
        return blueprint.getColumns().map( function( column ) {
            return compileCreateColumn( column, blueprint );
        } ).toList( ", " );
    }

    function compileCreateColumn( column, blueprint ) {
        if ( utils.isExpression( column ) ) {
            return column.getSql();
        }

        if ( isInstanceOf( column, "qb.models.Schema.TableIndex" ) ) {
            throw(
                type = "InvalidColumn",
                message = "Recieved a TableIndex instead of a Column when trying to create a Column.",
                detail = "Did you maybe try to add a column and a constraint in an ALTER clause at the same time? Split those up in to separate addColumn and addConstraint commands."
            );
        }

        return arrayToList( arrayFilter( [
            wrapColumn( column.getName() ),
            generateType( column, blueprint ),
            modifyUnsigned( column ),
            generateNullConstraint( column ),
            generateUniqueConstraint( column, blueprint ),
            generateAutoIncrement( column, blueprint ),
            generateDefault( column, blueprint ),
            generateComment( column, blueprint )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function generateNullConstraint( column ) {
        return column.getNullable() ? "" : "NOT NULL";
    }

    function generateUniqueConstraint( column, blueprint ) {
        return column.getUnique() ? "UNIQUE" : "";
    }

    function modifyUnsigned( column ) {
        return column.getUnsigned() ? "UNSIGNED" : "";
    }

    function generateAutoIncrement( column, blueprint ) {
        return column.getAutoIncrement() ? "AUTO_INCREMENT" : "";
    }

    function generateDefault( column ) {
        return column.getDefault() != "" ? "DEFAULT #column.getDefault()#" : "";
    }

    function generateComment( column ) {
        return column.getComment() != "" ? "COMMENT #wrapValue( column.getComment() )#" : "";
    }

    function compileAddComment( blueprint, commandParameters ) {
        return arrayToList( [
            "COMMENT ON COLUMN",
            wrapColumn( commandParameters.table & "." & commandParameters.column.getName() ),
            "IS",
            "'" & commandParameters.column.getComment() & "'"
        ], " " );
    }

    /*=====  End of Blueprint: Create  ======*/

    /*=======================================
    =            Blueprint: Drop            =
    =======================================*/

    function compileDrop( required blueprint ) {
        return arrayToList( arrayFilter( [
            "DROP TABLE",
            generateIfExists( blueprint ),
            wrapTable( blueprint.getTable() )
        ], function( item ) {
            return item != "";
        } ), " ");
    }

    function generateIfExists( blueprint ) {
        return blueprint.getIfExists() ? "IF EXISTS" : "";
    }

    function compileDropAllObjects() {
        throw(
            type = "OperationNotSupported",
            message = "This database grammar does not support this operation",
            detail = "compileDropAllObjects"
        );
    }

    function compileEnableForeignKeyConstraints() {
        throw(
            type = "OperationNotSupported",
            message = "This database grammar does not support this operation",
            detail = "compileEnableForeignKeyConstraints"
        );
    }

    function compileDisableForeignKeyConstraints() {
        throw(
            type = "OperationNotSupported",
            message = "This database grammar does not support this operation",
            detail = "compileDisableForeignKeyConstraints"
        );
    }

    /*=====  End of Blueprint: Drop  ======*/

    /*========================================
    =            Blueprint: Alter            =
    ========================================*/

    function compileAddColumn( blueprint, commandParameters ) {
        var existingIndexes = blueprint.getIndexes();
        blueprint.setIndexes( [] );

        var body = arrayToList( arrayFilter( [
            compileCreateColumn( commandParameters.column, blueprint ),
            compileCreateIndexes( blueprint )
        ], function( item ) {
            return item != "";
        } ), ", " );

        blueprint.setIndexes( existingIndexes );

        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "ADD",
            body
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileDropColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "DROP COLUMN",
            wrapColumn( commandParameters.name )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileRenameTable( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "RENAME TO",
            wrapTable( commandParameters.to )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileRenameColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "CHANGE",
            wrapColumn( commandParameters.from ),
            compileCreateColumn( commandParameters.to, blueprint )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileRenameConstraint( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "RENAME INDEX",
            wrapColumn( commandParameters.from ),
            "TO",
            wrapColumn( commandParameters.to )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    function compileModifyColumn( blueprint, commandParameters ) {
        return arrayToList( arrayFilter( [
            "ALTER TABLE",
            wrapTable( blueprint.getTable() ),
            "CHANGE",
            wrapColumn( commandParameters.from ),
            compileCreateColumn( commandParameters.to, blueprint )
        ], function( item ) {
            return item != "";
        } ), " " );
    }

    /*=====  End of Blueprint: Alter  ======*/

    /*===================================
    =            Constraints            =
    ===================================*/

    function compileAddConstraint( blueprint, commandParameters ) {
        var index = commandParameters.index;
        var constraint = invoke( this, "index#index.getType()#", { index = index } );
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# ADD #constraint#";
    }

    function compileDropConstraint( blueprint, commandParameters ) {
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP INDEX #wrapValue( commandParameters.name )#";
    }

    function compileDropForeignKey( blueprint, commandParameters ) {
        return "ALTER TABLE #wrapTable( blueprint.getTable() )# DROP CONSTRAINT #wrapValue( commandParameters.name )#";
    }

    /*=====  End of Constraints  ======*/

    /*====================================
    =            Column Types            =
    ====================================*/

    function generateType( column, blueprint ) {
        return invoke( this, "type#column.getType()#", { column = column, blueprint = blueprint } );
    }

    function typeBigInteger( column ) {
        return arrayToList( arrayFilter( [
            "BIGINT",
            isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"
        ], function( item ) {
            return item != "";
        } ), "" );
    }

    function typeBit( column ) {
        return "BIT(#column.getLength()#)";
    }

    function typeBoolean( column ) {
        return "TINYINT(1)";
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

    function typeDecimal( column ) {
        return "DECIMAL(#column.getLength()#,#column.getPrecision()#)";
    }

    function typeEnum( column ) {
        var values = column.getValues().map( function ( value ) {
            return wrapValue( value );
        } ).toList( ", " );
        return "ENUM(#values#)";
    }

    function typeFloat( column ) {
        return "FLOAT(#column.getLength()#,#column.getPrecision()#)";
    }

    function typeInteger( column ) {
        return arrayToList( arrayFilter( [
            "INTEGER",
            isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"
        ], function( item ) {
            return item != "";
        } ), "" );
    }

    function typeJson( column ) {
        return "TEXT";
    }

    function typeLongText( column ) {
        return "TEXT";
    }

    function typeMediumInteger( column ) {
        return arrayToList( arrayFilter( [
            "MEDIUMINT",
            isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"
        ], function( item ) {
            return item != "";
        } ), "" );
    }

    function typeMediumText( column ) {
        return "TEXT";
    }

    function typeSmallInteger( column ) {
        return arrayToList( arrayFilter( [
            "SMALLINT",
            isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"
        ], function( item ) {
            return item != "";
        } ), "" );
    }

    function typeString( column ) {
        return "VARCHAR(#column.getLength()#)";
    }

    function typeText( column ) {
        return "TEXT";
    }

    function typeTime( column ) {
        return "TIME";
    }

    function typeTimestamp( column ) {
        return "TIMESTAMP";
    }

    function typeTinyInteger( column ) {
        return arrayToList( arrayFilter( [
            "TINYINT",
            isNull( column.getPrecision() ) ? "" : "(#column.getPrecision()#)"
        ], function( item ) {
            return item != "";
        } ), "" );
    }

    /*=====  End of Column Types  ======*/

    /*===================================
    =            Index Types            =
    ===================================*/

    function compileCreateIndexes( blueprint ) {
        return blueprint.getIndexes().map( function( index ) {
            return invoke( this, "index#index.getType()#", { index = index, blueprint = blueprint } );
        } ).filter( function( item ) {
            return item != "";
        } ).toList( ", " );
    }

    function compileAddIndex( blueprint, commandParameters ) {
        var columnList = commandParameters.index.getColumns().map( function( column ) {
            column = isSimpleValue( column ) ? column : column.getName();
            return wrapValue( column );
        } ).toList( ", " );
        return arrayToList( [
            "CREATE INDEX",
            wrapValue( commandParameters.index.getName() ),
            "ON",
            wrapTable( commandParameters.table ),
            "(#columnList#)"
        ], " " );
    }

    function indexBasic( index, blueprint ) {
        var columnsString = index.getColumns().map( function( column ) {
            return wrapValue( column );
        } ).toList( ", " );
        return "INDEX #wrapValue( index.getName() )# (#columnsString#)";
    }

    function indexForeign( index ) {
        //FOREIGN KEY ("country_id") REFERENCES countries ("id") ON DELETE CASCADE
        var keys = index.getForeignKey().map( function( key ) {
            return wrapColumn( key );
        } ).toList( ", " );
        var references = index.getColumns().map( function( column ) {
            return wrapColumn( column );
        } ).toList( ", " );
        return arrayToList( [
            "CONSTRAINT #wrapValue( index.getName() )#",
            "FOREIGN KEY (#keys#)",
            "REFERENCES #wrapTable( index.getTable() )# (#references#)",
            "ON UPDATE #ucase( index.getOnUpdate() )#",
            "ON DELETE #ucase( index.getOnDelete() )#"
        ], " " );
    }

    function indexPrimary( index ) {
        var references = index.getColumns().map( function( column ) {
            return wrapColumn( column );
        } ).toList( ", " );
        return "CONSTRAINT #wrapValue( index.getName() )# PRIMARY KEY (#references#)";
    }

    function indexUnique( index ) {
        var references = index.getColumns().map( function( column ) {
            return wrapColumn( column );
        } ).toList( ", " );
        return "CONSTRAINT #wrapValue( index.getName() )# UNIQUE (#references#)";
    }

    function indexCheck( index ) {
        var column = index.getColumns()[ 1 ];
        var values = column.getValues().map( function( val ) {
            return "'#val#'";
        } ).toList( ", " );
        return arrayToList( arrayFilter( [
            "CONSTRAINT",
            wrapValue( index.getName() ),
            "CHECK",
            "(#wrapValue( column.getName() )# IN (#values#))"
        ], function( str ) {
            return str != "";
        } ), " " );
    }

    /*=====  End of Index Types  ======*/

    function compileTableExists( tableName, schemaName = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "information_schema.tables" )# WHERE #wrapColumn( "table_name" )# = ?";
        if ( schemaName != "" ) {
            sql &= " AND #wrapColumn( "schema_name" )# = ?";
        }
        return sql;
    }

    function compileColumnExists( table, column, scehma = "" ) {
        var sql = "SELECT 1 FROM #wrapTable( "information_schema.columns" )# WHERE #wrapColumn( "table_name" )# = ? AND #wrapColumn( "column_name" )# = ?";
        if ( scehma != "" ) {
            sql &= " AND #wrapColumn( "schema_name" )# = ?";
        }
        return sql;
    }

    function compileAddType() {
        return "";
    }

}
