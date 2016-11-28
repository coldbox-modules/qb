component displayname="Builder" accessors="true" {

    property name="grammar" inject="Grammar@Quick";
    property name="utils" inject="QueryUtils@Quick";

    property name="distinct" type="boolean" default="false";
    property name="columns" type="array";
    property name="from" type="string";
    property name="joins" type="array";
    property name="wheres" type="array";

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
        any first,
        string operator,
        string second,
        string type = "inner",
        any conditions
    ) {
        var joinClause = new Quick.models.Query.JoinClause(
            type = arguments.type,
            table = arguments.table
        );

        if ( structKeyExists( arguments, "first" ) && isClosure( arguments.first ) ) {
            arguments.conditions = arguments.first;
        }

        if ( structKeyExists( arguments, "conditions" ) && isClosure( arguments.conditions ) ) {
            conditions( joinClause );
        }
        else {
            joinClause.on(
                first = arguments.first,
                operator = arguments.operator,
                second = arguments.second,
                combinator = "and"
            );
        }

        arrayAppend( variables.joins, joinClause );
        arrayAppend( bindings.join, joinClause.getBindings(), true );

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
            var binding = utils.extractBinding( arguments.value );
            arrayAppend( bindings.where, binding );
        }

        return this;
    }

    public Builder function orWhere( column, operator, value ) {
        arguments.combinator = "or";
        return where( argumentCollection = arguments );
    }

    public Builder function whereIn( column, value, combinator ) {
        arguments.operator = "in";
        return where( argumentCollection = arguments );
    }

    public Builder function whereNotIn( column, value, combinator ) {
        arguments.operator = "not in";
        return where( argumentCollection = arguments );
    }

    public Builder function whereRaw( required string sql, array whereBindings = [], string combinator = "and" ) {
        whereBindings.map( function( binding ) {
            return utils.extractBinding( binding );
        } ).each( function( binding ) {
            variables.bindings.where.append( binding );
        } );
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
        query.getBindings().each( function( binding ) {
            variables.bindings.where.append( binding );
        } );
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
            query.getBindings().each( function( binding ) {
                variables.bindings.where.append( binding );
            } );
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
        query.getBindings().each( function( binding ) {
            variables.bindings.where.append( binding );
        } );
        return this;
    }

    public Expression function raw( required string sql ) {
        return new quick.models.Query.Expression( sql );
    }

    private Builder function newQuery() {
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


    // Collaborators

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