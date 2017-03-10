import qb.models.Query.Builder;
import qb.models.Query.Grammars.Grammar;

/**
* Query Builder for fluently creating SQL queries.
*/
component displayname="Builder" accessors="true" {

    /**
    * The specific grammar that will compile the builder statements.
    * e.g. MySQLGrammar, OracleGrammar, etc.
    */
    property name="grammar";

    /**
    * Query utilities shared across multiple models.
    */
    property name="utils";

    /**
    * Flag specifying to return array of structs over queries.
    * @default true
    */
    property name="returningArrays" inject="coldbox:setting:returningArrays@qb";

    /**
    * Injected returnFormat callback, if any.
    * If provided, the result of the callback is returned as the result of builder.
    * @default ""
    */
    property name="returnFormat" inject="coldbox:setting:returnFormat@qb";

    /******************** Query Properties ********************/

    /**
    * Flag to bring back only distinct values.
    * @default false
    */
    property name="distinct" type="boolean";

    /**
    * The aggregate option and column to execute.
    * e.g. { type = "count", column = "*" }
    * @default {}
    */
    property name="aggregate" type="struct";

    /**
    * An array of columns to select.
    * @default [ "*" ]
    */
    property name="columns" type="array";

    /**
    * The base table of the query.
    * @default null
    */
    property name="from" type="string";

    /**
    * An array of JOIN statements.
    * @default []
    */
    property name="joins" type="array";

    /**
    * An array of WHERE statements.
    * @default []
    */
    property name="wheres" type="array";

    /**
    * An array of GROUP BY statements.
    * @default []
    */
    property name="groups" type="array";

    /**
    * An array of HAVING statements.
    * @default []
    */
    property name="havings" type="array";

    /**
    * An array of ORDER BY statements.
    * @default []
    */
    property name="orders" type="array";

    /**
    * The LIMIT value, if any.
    */
    property name="limitValue" type="numeric";

    /**
    * The OFFSET value, if any.
    */
    property name="offsetValue" type="numeric";

    /**
    * The list of allowed operators in join and where statements.
    */
    variables.operators = [
        "=", "<", ">", "<=", ">=", "<>", "!=",
        "like", "like binary", "not like", "between", "ilike",
        "&", "|", "^", "<<", ">>",
        "rlike", "regexp", "not regexp",
        "~", "~*", "!~", "!~*", "similar to",
        "not similar to"
    ];

    /**
    * The list of allowed combinators between statements.
    */
    variables.combinators = [
        "AND", "OR"
    ];

    /**
    * Object holding all of the different bindings.
    * Bindings are separated by the different clauses
    * so we can serialize them in the correct order.
    */
    variables.bindings = {
        "join" = [],
        "where" = [],
        "insert" = [],
        "update" = []
    };

    /**
    * Creates an empty query builder.
    *
    * @grammar The grammar to use when compiling queries. Default: qb.models.Query.Grammars.Grammar
    * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
    *
    * @return qb.models.Query.Builder
    */
    public Builder function init(
        Grammar grammar = new qb.models.Query.Grammars.Grammar(),
        QueryUtils utils = new qb.models.Query.QueryUtils()
    ) {
        variables.grammar = arguments.grammar;
        variables.utils = arguments.utils;

        variables.returningArrays = true;

        setDefaultValues();

        return this;
    }

    /**
    * Sets up the default values for a new builder instance.
    *
    * @return void
    */
    private void function setDefaultValues() {
        variables.distinct = false;
        variables.aggregate = {};
        variables.columns = [ "*" ];
        variables.joins = [];
        variables.wheres = [];
        variables.groups = [];
        variables.havings = [];
        variables.orders = [];
    }

    /**********************************************************************************************\
    |                                    SELECT clause functions                                   |
    \**********************************************************************************************/

    /**
    * Sets the DISTINCT flag for the query.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function distinct() {
        setDistinct( true );

        return this;
    }

    /**
    * Sets a selection of columns to select from the query.
    *
    * @columns A single column, a list or columns (comma-separated), or an array of columns. Default: "*".
    *
    * Individual columns can contain fully-qualified names (i.e. "some_table.some_column"),
    * fully-qualified names with table aliases (i.e. "alias.some_column"),
    * and even set column aliases themselves (i.e. "some_column AS c")
    * Each value will be wrapped correctly, according to the database grammar being used.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function select( any columns = "*" ) {
        // This block is necessary for ACF 10.
        // It can't be extracted to a function because
        // the arguments struct doesn't get passed correctly.
        var args = {};
        var count = structCount( arguments );
        for ( var arg in arguments ) {
            args[ count ] = arguments[ arg ];
            count--;
        }

        variables.columns = normalizeToArray( argumentCollection = args );
        if ( variables.columns.isEmpty() ) {
            variables.columns = [ "*" ];
        }
        return this;
    }

    /**
    * Adds a selection of columns to the already selected columns.
    *
    * @columns A single column, a list or columns (comma-separated), or an array of columns.
    *
    * Individual columns can contain fully-qualified names (i.e. "some_table.some_column"),
    * fully-qualified names with table aliases (i.e. "alias.some_column"),
    * and even set column aliases themselves (i.e. "some_column AS c")
    * Each value will be wrapped correctly, according to the database grammar being used.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function addSelect( required any columns ) {
        // This block is necessary for ACF 10.
        // It can't be extracted to a function because
        // the arguments struct doesn't get passed correctly.
        var args = {};
        var count = structCount( arguments );
        for ( var arg in arguments ) {
            args[ count ] = arguments[ arg ];
            count--;
        }
        
        if ( variables.columns.isEmpty() ||
            ( variables.columns.len() == 1 && variables.columns[ 1 ] == "*" ) ) {
            variables.columns = [];
        }
        arrayAppend( variables.columns, normalizeToArray( argumentCollection = args ), true );
        return this;
    }

    public Builder function selectRaw( required any expression ) {
        addSelect( raw( expression ) );
        return this;        
    }

    /**********************************************************************************************\
    |                                    FROM clause functions                                   |
    \**********************************************************************************************/

    /**
    * Sets the FROM table of the query.
    *
    * @from The name of the table to from which the query is based.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function from( required string from ) {
        variables.from = arguments.from;
        return this;
    }

    /**
    * Sets the FROM table of the query.
    * Alias for `from`
    *
    * @table The name of the table to from which the query is based.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function table( required string table ) {
        variables.from = arguments.table;
        return this;
    }

    /**********************************************************************************************\
    |                                    JOIN clause functions                                   |
    \**********************************************************************************************/

    public Builder function join(
        required string table,
        required any first,
        string operator = "=",
        string second,
        string type = "inner",
        boolean where = false
    ) {
        var join = new qb.models.Query.JoinClause(
            parentQuery = this,
            type = arguments.type,
            table = arguments.table
        );

        if ( isClosure( arguments.first ) ) {
            first( join );
            variables.joins.append( join );
            addBindings( join.getBindings(), "join" );
        }
        else {
            var method = where ? "where" : "on";
            arguments.column = arguments.first;
            arguments.value = isNull( arguments.second ) ? javacast( "null", "" ) : arguments.second;
            variables.joins.append(
                invoke( join, method, arguments )
            );
            addBindings( join.getBindings(), "join" );
        }

        return this;
    }

    public Builder function leftJoin(
        required string table,
        string first,
        string operator,
        string second,
        any conditions
    ) {
        arguments.type = "left";
        return join( argumentCollection = arguments );
    }

    public Builder function rightJoin(
        required string table,
        string first,
        string operator,
        string second,
        any conditions
    ) {
        arguments.type = "right";
        return join( argumentCollection = arguments );
    }

    public Builder function crossJoin(
        required string table,
        any first,
        string operator,
        any second
    ) {
        if ( ! isNull( arguments.first ) ) {
            arguments.type = "cross";
            return join( argumentCollection = arguments );
        }

        variables.joins.append(
            new qb.models.Query.JoinClause( this, "cross", table )
        );

        return this;
    }

    public Builder function joinWhere(
        required string table,
        required any first,
        string operator,
        string second,
        string type = "inner"
    ) {
        arguments.where = true;
        return join( argumentCollection = arguments );
    }

    // where methods

    public Builder function where( column, operator, value, string combinator = "and" ) {
        if ( isClosure( column ) ) {
            return whereNested( column, combinator );
        }

        var argCount = argumentCount( arguments );

        if ( isInvalidCombinator( arguments.combinator ) ) {
            throw(
                type = "InvalidSQLType",
                message = "Illegal combinator"
            );
        }

        if ( isNull( arguments.value ) ) {
            arguments.value = arguments.operator;
            arguments.operator = "=";
        }
        else if ( isInvalidOperator( arguments.operator ) ) {
            throw(
                type = "InvalidSQLType",
                message = "Illegal operator"
            );
        }

        if ( isClosure( value ) ) {
            return whereSub( column, operator, value, combinator );
        }

        arrayAppend( variables.wheres, {
            column = arguments.column,
            operator = arguments.operator,
            value = arguments.value,
            combinator = arguments.combinator,
            type = "basic"
        } );

        if ( ! isInstanceOf( arguments.value, "qb.models.Query.Expression" ) ) {
            addBindings( utils.extractBinding( arguments.value ), "where" );
        }

        return this;
    }

    public Builder function orWhere( column, operator, value ) {
        arguments.combinator = "or";
        return where( argumentCollection = arguments );
    }

    public Builder function whereIn( column, values, combinator = "and", negate = false ) {
        if ( isClosure( values ) ) {
            arguments.callback = arguments.values;
            return whereInSub( argumentCollection = arguments );
        }

        var type = negate ? "notIn" : "in";
        variables.wheres.append( {
            type = type,
            column = arguments.column,
            values = arguments.values,
            combinator = arguments.combinator
        } );

        // values.filter( function( value ) {
        //     return ! isInstanceOf( value, "qb.models.Query.Expression" );
        // } ).each( function( value ) {
        //     var binding = utils.extractBinding( value );
        //     variables.bindings.where.append( binding );
        // } );

        var bindings = values
            .filter( utils.isNotExpression )
            .map( function( value ) {
                return utils.extractBinding( value );
            } );
        addBindings( bindings, "where" );

        return this;
    }

    private Builder function whereInSub( column, callback, combinator = "and", negate = false ) {
        var query = newQuery();
        callback( query );

        var type = negate ? "notInSub" : "inSub";
        variables.wheres.append( {
            type = type,
            column = arguments.column,
            query = query,
            combinator = arguments.combinator
        } );
        addBindings( query.getBindings(), "where" );

        return this;
    }

    public Builder function orWhereIn( column, values, negate = false ) {
        arguments.combinator = "or";
        return whereIn( argumentCollection = arguments );
    }

    public Builder function whereNotIn( column, values, combinator = "and" ) {
        arguments.negate = true;
        return whereIn( argumentCollection = arguments );
    }

    public Builder function orWhereNotIn( column, values ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereIn( argumentCollection = arguments );
    }

    public Builder function whereRaw( required string sql, array whereBindings = [], string combinator = "and" ) {
        addBindings( whereBindings.map( function( binding ) {
            return utils.extractBinding( binding );
        } ), "where" );
        variables.wheres.append( {
            type = "raw",
            sql = sql,
            combinator = arguments.combinator
        } );
        return this;
    }

    public Builder function orWhereRaw( required string sql, array whereBindings = [] ) {
        arguments.combinator = "or";
        return whereRaw( argumentCollection = arguments );
    }

    public Builder function whereColumn( required first, operator, second, string combinator = "and" ) {
        if ( isNull( arguments.second ) ) {
            arguments.second = arguments.operator;
            arguments.operator = "=";
        }

        if ( isInvalidOperator( operator ) ) {
            throw(
                type = "InvalidSQLType",
                message = "Illegal operator"
            );
        }

        variables.wheres.append( {
            type = "column",
            first = arguments.first,
            operator = arguments.operator,
            second = arguments.second,
            combinator = arguments.combinator
        } );

        return this;
    }

    public Builder function orWhereColumn( required first, operator, second ) {
        arguments.combinator = "or";
        return whereColumn( argumentCollection = arguments );
    }

    public Builder function whereExists( callback, combinator = "and", negate = false ) {
        var query = newQuery();
        callback( query );
        return addWhereExistsQuery( query, combinator, negate );
    }

    private Builder function addWhereExistsQuery( query, combinator, negate ) {
        var type = negate ? "notExists" : "exists";
        variables.wheres.append( {
            type = type,
            query = arguments.query,
            combinator = arguments.combinator
        } );
        addBindings( query.getBindings(), "where" );
        return this;
    }

    public Builder function orWhereExists( callback, negate = false ) {
        arguments.combinator = "or";
        return whereExists( argumentCollection = arguments );
    }

    public Builder function whereNotExists( callback, combinator = "and" ) {
        arguments.negate = true;
        return whereExists( argumentCollection = arguments );
    }
    public Builder function orWhereNotExists( callback ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereExists( argumentCollection = arguments );
    }

    private Builder function whereNested( required callback, combinator = "and" ) {
        var query = forNestedWhere();
        callback( query );
        return addNestedWhereQuery( query, combinator );
    }

    private Builder function addNestedWhereQuery( required Builder query, string combinator = "and" ) {
        if ( ! query.getWheres().isEmpty() ) {
            variables.wheres.append( {
                type = "nested",
                query = arguments.query,
                combinator = arguments.combinator
            } );
            addBindings( query.getBindings(), "where" );
        }
        return this;
    }

    private Builder function forNestedWhere() {
        var query = newQuery();
        return query.from( getFrom() );
    }

    private Builder function whereSub( column, operator, callback, combinator ) {
        var query = newQuery();
        callback( query );
        variables.wheres.append( {
            type = "sub",
            column = arguments.column,
            operator = arguments.operator,
            query = query,
            combinator = arguments.combinator
        } );
        addBindings( query.getBindings(), "where" );
        return this;
    }

    public Builder function whereNull( column, combinator = "and", negate = false ) {
        var type = negate ? "notNull" : "null";
        variables.wheres.append( {
            type = type,
            column = arguments.column,
            combinator = arguments.combinator
        } );
        return this;
    }

    public Builder function orWhereNull( column, negate = false ) {
        arguments.combinator = "or";
        return whereNull( argumentCollection = arguments );
    }

    public Builder function whereNotNull( column, combinator = "and" ) {
        arguments.negate = true;
        return whereNull( argumentCollection = arguments );
    }

    public Builder function orWhereNotNull( column ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereNull( argumentCollection = arguments );
    }

    public Builder function whereBetween( column, start, end, combinator = "and", negate = false ) {
        var type = negate ? "notBetween" : "between";

        variables.wheres.append( {
            type = type,
            column = arguments.column,
            start = arguments.start,
            end = arguments.end,
            combinator = arguments.combinator
        } );

        addBindings( utils.extractBinding( arguments.start ), "where" );
        addBindings( utils.extractBinding( arguments.end ), "where" );

        return this;
    }

    public Builder function orWhereBetween( column, start, end, negate = false ) {
        arguments.combinator = "or";
        return whereBetween( argumentCollection = arguments );
    }

    public Builder function whereNotBetween( column, start, end, combinator ) {
        arguments.negate = true;
        return whereBetween( argumentCollection = arguments );
    }

    public Builder function orWhereNotBetween( column, start, end, combinator ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereBetween( argumentCollection = arguments );
    }

    // when

    public Builder function when(
        required boolean condition,
        onTrue,
        onFalse
    ) {
        var defaultCallback = function( q ) {
            return q;
        };
        onFalse = isNull( onFalse ) ? defaultCallback : onFalse;
        if ( condition ) {
            onTrue( this );
        } else {
            onFalse( this );
        }
        return this;
    }

    // group by

    public Builder function groupBy() {
        // This block is necessary for ACF 10.
        // It can't be extracted to a function because
        // the arguments struct doesn't get passed correctly.
        var args = {};
        var count = 1;
        for ( var arg in arguments ) {
            args[ count ] = arguments[ arg ];
            count++;
        }

        var groupBys = normalizeToArray( argumentCollection = args );
        groupBys.each( function( groupBy ) {
            variables.groups.append( groupBy );
        } );
        return this;
    }

    // having

    public Builder function having( column, operator, value, string combinator = "and" ) {
        if ( isClosure( column ) ) {
            return whereNested( column, combinator );
        }

        var argCount = argumentCount( arguments );

        if ( isInvalidCombinator( arguments.combinator ) ) {
            throw(
                type = "InvalidSQLType",
                message = "Illegal combinator"
            );
        }

        if ( isNull( arguments.value ) ) {
            arguments.value = arguments.operator;
            arguments.operator = "=";
        }
        else if ( isInvalidOperator( arguments.operator ) ) {
            throw(
                type = "InvalidSQLType",
                message = "Illegal operator"
            );
        }

        if ( isClosure( value ) ) {
            return whereSub( column, operator, value, combinator );
        }

        arrayAppend( variables.havings, {
            column = arguments.column,
            operator = arguments.operator,
            value = arguments.value,
            combinator = arguments.combinator
        } );

        if ( ! isInstanceOf( arguments.value, "qb.models.Query.Expression" ) ) {
            addBindings( utils.extractBinding( arguments.value ), "where" );
        }

        return this;
    }

    // order by

    public Builder function orderBy( required any column, string direction = "asc" ) {
        if ( getUtils().isExpression( column ) ) {
            direction = "raw";
        }
        variables.orders.append( {
            direction = direction,
            column = column
        } );
        return this;
    }

    // limit

    public Builder function limit( required numeric value ) {
        variables.limitValue = value;
        return this;
    }

    public Builder function take( required numeric value ) {
        return limit( argumentCollection = arguments );
    }

    // offset
    public Builder function offset( required numeric value ) {
        variables.offsetValue = value;
        return this;
    }

    public Builder function forPage( required numeric page, required numeric limitValue ) {
        arguments.limitValue = arguments.limitValue > 0 ? arguments.limitValue : 0;
        offset( arguments.page * arguments.limitValue - arguments.limitValue );
        limit( arguments.limitValue );
        return this;
    }

    // insert

    public any function insert( required any values, struct options = {}, boolean toSql = false ) {
        if ( values.isEmpty() ) {
            return;
        }

        if ( ! isArray( values ) ) {
            if ( ! isStruct( values ) ) {
                throw(
                    type = "InvalidSQLType",
                    message = "Please pass a struct or an array of structs mapping columns to values"
                );
            }
            values = [ values ];
        }

        var columns = values[ 1 ].keyArray();
        columns.sort( "textnocase" );
        var bindings = values.map( function( valueArray ) {
            return columns.map( function( column ) {
                return getUtils().extractBinding( valueArray[ column ] );
            } );
        } );
        addBindings( bindings.reduce( function( allBindings, bindingsArray ) {
            allBindings.append( bindingsArray, true /* merge */ );
            return allBindings;
        }, [] ), "insert" );

        var sql = getGrammar().compileInsert( this, columns, bindings );

        if ( toSql ) {
            return sql;
        }

        return run( sql, options );
    }

    public any function update( required any values, struct options = {}, boolean toSql = false ) {
        var updateArray = values.keyArray();
        updateArray.sort( "textnocase" );

        addBindings( updateArray.map( function( column ) {
            return getUtils().extractBinding( values[ column ] );
        } ), "update" );

        var sql = getGrammar().compileUpdate( this, updateArray );

        if ( toSql ) {
            return sql;
        }

        return run( sql, options );
    }

    public function updateOrInsert( required any values, struct options = {}, boolean toSql = false ) {
        if ( exists() ) {
            return this.limit( 1 ).update( argumentCollection = arguments ); 
        }

        return this.insert( argumentCollection = arguments );
    }

    public any function delete( any id, struct options = {}, boolean toSql = false ) {
        if ( ! isNull( arguments.id ) ) {
            where( "id", "=", arguments.id );
        }

        var sql = getGrammar().compileDelete( this );

        if ( toSql ) {
            return sql;
        }
        
        return run( sql, options );
    }

    public Builder function newQuery() {
        return new qb.models.Query.Builder( grammar = getGrammar() );
    }

    public array function getBindings() {
        var bindingOrder = [ "update", "insert", "join", "where" ];

        var flatBindings = [];
        for ( var key in bindingOrder ) {
            if ( structKeyExists( bindings, key ) ) {
                arrayAppend( flatBindings, bindings[ key ], true );
            }
        }

        return flatBindings;
    }

    public struct function getRawBindings() {
        return bindings;
    }

    private Builder function clearBindings() {
        variables.join = [];
        variables.where = [];
        variables.insert = [];
        variables.update = [];
        return this;
    }

    private Builder function addBindings( required any newBindings, string type = "where" ) {
        if ( ! isArray( newBindings ) ) {
            newBindings = [ newBindings ];
        }

        newBindings.each( function( binding ) {
            variables.bindings[ type ].append( binding );
        } );

        return this;
    }

    // Aggregates

    public numeric function count( string column = "*", struct options = {} ) {
        arguments.type = "count";
        return aggregateQuery( argumentCollection = arguments );
    }

    public any function max( required string column, struct options = {} ) {
        arguments.type = "max";
        return aggregateQuery( argumentCollection = arguments );
    }

    public any function min( required string column, struct options = {} ) {
        arguments.type = "min";
        return aggregateQuery( argumentCollection = arguments );
    }

    public any function sum( required string column, struct options = {} ) {
        arguments.type = "sum";
        return aggregateQuery( argumentCollection = arguments );
    }

    private any function aggregateQuery(
        required string type,
        required string column = "*",
        struct options = {}
    ) {
        setAggregate( { type = arguments.type, column = arguments.column } );
        var originalColumns = getColumns();
        select();
        var result = get( options = arguments.options ).aggregate;
        select( originalColumns );
        setAggregate( {} );
        return result;
    }

    public boolean function exists( struct options = {} ) {
        return get( argumentCollection = arguments ).RECORDCOUNT > 0;
    }

    // Collaborators

    public Expression function raw( required string sql ) {
        return new qb.models.Query.Expression( sql );
    }

    public string function toSQL() {
        return grammar.compileSelect( this );
    }

    public any function get( any columns, struct options = {} ) {
        var originalColumns = getColumns();
        if ( ! isNull( arguments.columns ) ) {
            select( arguments.columns );
        }
        var result = run( sql = toSql(), options = arguments.options );
        select( originalColumns );
        return result;
    }

    public any function first( struct options = {} ) {
        take( 1 );
        return get( options = arguments.options );
    }

    public any function find( required any id, struct options = {} ) {
        where( "id", "=", arguments.id );
        return first( options = arguments.options );
    }

    public any function value( required string column, struct options = {} ) {
        select( column );
        return first( options = arguments.options )[ column ];
    }

    public any function implode( required string column, string glue = "", struct options = {} ) {
        select( column );
        var result = get( options = arguments.options );
        var results = [];
        for ( var row in result ) {
            results.append( row[ column ] );
        }
        return results.toList( glue );
    }

    private any function run( required string sql, struct options = {} ) {
        var q = runQuery( argumentCollection = arguments );

        if ( isNull( q ) ) {
            return;
        }

        if ( isClosure( returnFormat ) ) {
            return returnFormat( q );
        }

        if ( getReturningArrays() ) {
            return getUtils().queryToArrayOfStructs( q );
        }

        return q;
    }

    private any function runQuery( required string sql, struct options = {} ) {
        var result = grammar.runQuery( sql, getBindings(), options );
        clearBindings();
        if ( ! isNull( result ) ) {
            return result;
        }
        return;
    }

    // Unused(?)

    private array function normalizeToArray() {
        if ( isVariadicFunction( args = arguments ) ) {
            return normalizeVariadicArgumentsToArray( args = arguments );
        }

        var arg = arguments[ 1 ];
        if ( isInstanceOf( arg, "qb.models.Query.Expression" ) ) {
            return [ arg ];
        }

        if ( ! isArray( arg ) ) {
            return normalizeListArgumentsToArray( arg );
        }

        return arg;
    }

    private boolean function isVariadicFunction( required struct args ) {
        return structCount( args ) > 1;
    }

    private array function normalizeVariadicArgumentsToArray( required struct args ) {
        var normalizedArgs = [];
        for ( var arg in arguments.args ) {
            arrayAppend( normalizedArgs, arguments.args[ arg ] );
        }
        return normalizedArgs;
    }

    private array function normalizeListArgumentsToArray( required string list ) {
        var listAsArray = listToArray( arguments.list );
        var items = [];
        for ( var item in listAsArray ) {
            arrayAppend( items, trim( item ) );
        }
        return items;
    }

    private boolean function isInvalidOperator( required string operator ) {
        return ! arrayContains( operators, operator );
    }

    private boolean function isInvalidCombinator( required string combinator ) {
        for ( var validCombinator in variables.combinators ) {
            if ( validCombinator == arguments.combinator ) {
                return false;
            }
        }
        return true;
    }

    private function argumentCount( args ) {
        var count = 0;
        for ( var key in args ) {
            if ( ! isNull( args[ key ] ) ) {
                count++;
            }
        }
        return count;
    }

    public any function onMissingMethod( string missingMethodName, struct missingMethodArguments ) {
        if ( ! arrayIsEmpty( REMatchNoCase( "^where(.+)", missingMethodName ) ) ) {
            var args = { "1" = mid( missingMethodName, 6, len( missingMethodName ) - 5 ) };
            for ( var key in missingMethodArguments ) {
                args[ key + 1 ] = missingMethodArguments[ key ];
            }
            return where( argumentCollection = args );
        }

        if ( ! arrayIsEmpty( REMatchNoCase( "^orWhere(.+)", missingMethodName ) ) ) {
            var args = { "1" = mid( missingMethodName, 8, len( missingMethodName ) - 7 ) };
            for ( var key in missingMethodArguments ) {
                args[ key + 1 ] = missingMethodArguments[ key ];
            }

            return orWhere( argumentCollection = args );
        }

        throw( "Method does not exist [#missingMethodName#]" );
    }
}