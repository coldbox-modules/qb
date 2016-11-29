component displayname="Builder" accessors="true" {

    property name="grammar" inject="Grammar@Quick";
    property name="utils" inject="QueryUtils@Quick";

    property name="distinct" type="boolean" default="false";
    property name="columns" type="array";
    property name="from" type="string";
    property name="joins" type="array";
    property name="wheres" type="array";
    property name="groups" type="array";

    variables.operators = [
        "=", "<", ">", "<=", ">=", "<>", "!=",
        "like", "not like", "between", "in", "not in"
    ];

    variables.combinators = [
        "AND", "OR"
    ];

    variables.bindings = {
        "join" = [],
        "where" = []
    };

    public Builder function init(
        Grammar grammar = new Quick.models.Query.Grammars.Grammar( ),
        QueryUtils utils = new Quick.models.Query.QueryUtils()
    ) {
        variables.grammar = arguments.grammar;
        variables.utils = arguments.utils;

        setDefaultValues();

        return this;
    }

    private void function setDefaultValues() {
        variables.distinct = false;
        variables.columns = [ "*" ];
        variables.joins = [];
        variables.from = "";
        variables.wheres = [];
        variables.groups = [];
    }

    // API
    // select methods

    public Builder function distinct() {
        setDistinct( true );

        return this;
    }

    public Builder function select( required any columns ) {
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
        return this;
    }

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
        
        arrayAppend( variables.columns, normalizeToArray( argumentCollection = args ), true );
        return this;
    }

    // from methods

    public Builder function from( required string from ) {
        variables.from = arguments.from;
        return this;
    }

    // join methods

    public Builder function join(
        required string table,
        required any first,
        string operator,
        string second,
        string type = "inner",
        boolean where = false
    ) {
        var join = new Quick.models.Query.JoinClause(
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
            arguments.value = arguments.second;
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
            new Quick.models.Query.JoinClause( this, "cross", table )
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

        if ( isClosure( column ) ) {
            return whereNested( column, combinator );
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

        if ( ! isInstanceOf( arguments.value, "Quick.models.Query.Expression" ) ) {
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
        //     return ! isInstanceOf( value, "Quick.models.Query.Expression" );
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
        arguments.negate = true
        return whereIn( argumentCollection = arguments );
    }

    public Builder function orWhereNotIn( column, values ) {
        arguments.combinator = "or";
        arguments.negate = true
        return whereIn( argumentCollection = arguments );
    }

    public Builder function whereRaw( required string sql, array whereBindings = [], string combinator = "and" ) {
        addBindings( whereBindings.map( function( binding ) {
            return utils.extractBinding( binding );
        } ), "where" );
        variables.wheres.append( {
            type = "raw",
            sql = sql,
            combinator = arguments.combinator,
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

    public Builder function whereNotBetween( column, start, end, combinator ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereBetween( argumentCollection = arguments );
    }

    // when

    public Builder function when(
        required boolean condition,
        onTrue,
        onFalse = function( q ) { return q; }
    ) {
        return condition ? onTrue( this ) : onFalse( this );
    }

    // group by

    public Builder function groupBy() {
        // This block is necessary for ACF 10.
        // It can't be extracted to a function because
        // the arguments struct doesn't get passed correctly.
        var args = {};
        var count = structCount( arguments );
        for ( var arg in arguments ) {
            args[ count ] = arguments[ arg ];
            count--;
        }

        var groupBys = normalizeToArray( argumentCollection = args );
        groupBys.each( function( groupBy ) {
            variables.groups.append( groupBy );
        } );
        return this;
    }

    public Builder function newQuery() {
        return new Quick.models.Query.Builder( grammar = getGrammar() );
    }

    public array function getBindings() {
        var bindingOrder = [ "join", "where" ];

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

    private Builder function addBindings( required any newBindings, string type = "where" ) {
        if ( ! isArray( newBindings ) ) {
            newBindings = [ newBindings ];
        }

        newBindings.each( function( binding ) {
            variables.bindings[ type ].append( binding );
        } );

        return this;
    }


    // Collaborators

    public Expression function raw( required string sql ) {
        return new quick.models.Query.Expression( sql );
    }

    public string function toSQL() {
        return grammar.compileSelect( this );
    }

    public query function get( struct options = {} ) {
        return queryExecute( this.toSQL(), this.getBindings(), options );
    }

    // Unused(?)

    private array function normalizeToArray() {
        if ( isVariadicFunction( args = arguments ) ) {
            return normalizeVariadicArgumentsToArray( args = arguments );
        }

        var arg = arguments[ 1 ];
        if ( isInstanceOf( arg, "Quick.models.Query.Expression" ) ) {
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