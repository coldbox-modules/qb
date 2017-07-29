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
    * returnFormat callback
    * If provided, the result of the callback is returned as the result of builder.
    * Can optionally pass either "array" or "query"
    * and the correct callback will be generated
    * @default "array"
    */
    property name="returnFormat";

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
    * Array holding the valid directions that a column can be sorted by in an order by clause.
    */
    variables.directions = [ "asc", "desc" ];

    /**
    * Creates an empty query builder.
    *
    * @grammar The grammar to use when compiling queries. Default: qb.models.Query.Grammars.Grammar
    * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
    * @returnFormat the closure (or string format shortcut) that modifies the query and is eventually returned to the caller. Default: 'array'
    *
    * @return qb.models.Query.Builder
    */
    public Builder function init(
        Grammar grammar = new qb.models.Query.Grammars.Grammar(),
        QueryUtils utils = new qb.models.Query.QueryUtils(),
        any returnFormat = "array"
    ) {
        variables.grammar = arguments.grammar;
        variables.utils = arguments.utils;

        setReturnFormat( arguments.returnFormat );

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
    * If no columns have been set, this column will overwrite the global "*".
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

    /**
    * Adds a Expression to the already selected columns.
    *
    * @expression A raw query expression to add to the query.
    *
    * Individual columns can contain fully-qualified names (i.e. "some_table.some_column"),
    * fully-qualified names with table aliases (i.e. "alias.some_column"),
    * and even set column aliases themselves (i.e. "some_column AS c")
    * Each value will be wrapped correctly, according to the database grammar being used.
    * If no columns have been set, this column will overwrite the global "*".
    *
    * @return qb.models.Query.Builder
    */
    public Builder function selectRaw( required any expression ) {
        addSelect( raw( expression ) );
        return this;        
    }

    /********************************************************************************\
    |                             FROM clause functions                              |
    \********************************************************************************/

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

    /*******************************************************************************\
    |                            JOIN clause functions                              |
    \*******************************************************************************/

    /**
    * Adds an INNER JOIN to another table.
    *
    * For simple joins, this specifies a column on which to join the two tables.
    * For complex joins, a closure can be passed to `first`.
    * This allows multiple `on` and `where` conditions to be applied to the join.
    *
    * @table The table to join to the query.
    * @first The first column in the join's `on` statement. This alternatively can be a closure that will be passed a JoinClause for complex joins. Passing a closure ignores all subsequent parameters.
    * @operator The boolean operator for the join clause. Default: "=".
    * @second The second column in the join's `on` statement.
    * @type The type of the join. Default: "inner".  Passing this as an argument is discouraged for readability.  Use the dedicated methods like `leftJoin` and `rightJoin` where possible.
    * @where Sets if the value of `second` should be interpreted as a column or a value.  Passing this as an argument is discouraged.  Use the dedicated `joinWhere` or a join closure where possible.
    *
    * @return qb.models.Query.Builder
    */
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

    /**
    * Adds a LEFT JOIN to another table.
    *
    * For simple joins, this specifies a column on which to join the two tables.
    * For complex joins, a closure can be passed to `first`.
    * This allows multiple `on` and `where` conditions to be applied to the join.
    *
    * @table The table to join to the query.
    * @first The first column in the join's `on` statement. This alternatively can be a closure that will be passed a JoinClause for complex joins. Passing a closure ignores all subsequent parameters.
    * @operator The boolean operator for the join clause. Default: "=".
    * @second The second column in the join's `on` statement.
    * @where Sets if the value of `second` should be interpreted as a column or a value.  Passing this as an argument is discouraged.  Use the dedicated `joinWhere` or a join closure where possible.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function leftJoin(
        required string table,
        string first,
        string operator,
        string second,
        boolean where
    ) {
        arguments.type = "left";
        return join( argumentCollection = arguments );
    }

    /**
    * Adds a RIGHT JOIN to another table.
    *
    * For simple joins, this specifies a column on which to join the two tables.
    * For complex joins, a closure can be passed to `first`.
    * This allows multiple `on` and `where` conditions to be applied to the join.
    *
    * @table The table to join to the query.
    * @first The first column in the join's `on` statement. This alternatively can be a closure that will be passed a JoinClause for complex joins. Passing a closure ignores all subsequent parameters.
    * @operator The boolean operator for the join clause. Default: "=".
    * @second The second column in the join's `on` statement.
    * @where Sets if the value of `second` should be interpreted as a column or a value.  Passing this as an argument is discouraged.  Use the dedicated `joinWhere` or a join closure where possible.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function rightJoin(
        required string table,
        string first,
        string operator,
        string second,
        boolean where
    ) {
        arguments.type = "right";
        return join( argumentCollection = arguments );
    }

    /**
    * Adds a CROSS JOIN to another table.
    *
    * For simple joins, this joins one table to another in a cross join.
    * For complex joins, a closure can be passed to `first`.
    * This allows multiple `on` and `where` conditions to be applied to the join.
    *
    * @table The table to join to the query.
    * @first The first column in the join's `on` statement. This alternatively can be a closure that will be passed a JoinClause for complex joins. Passing a closure ignores all subsequent parameters.
    * @operator The boolean operator for the join clause. Default: "=".
    * @second The second column in the join's `on` statement.
    *
    * @return qb.models.Query.Builder
    */
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

    /**
    * Adds a JOIN to another table based on a `WHERE` clause instead of an `ON` clause.
    *
    * `where` clauses introduce parameters and parameter bindings
    * whereas `on` clauses join between columns and don't need parameter bindings.
    *
    * For simple joins, this specifies a column on which to join the two tables.
    * For complex joins, a closure can be passed to `first`.
    * This allows multiple `on` and `where` conditions to be applied to the join.
    *
    * @table The table to join to the query.
    * @first The first column in the join's `on` statement. This alternatively can be a closure that will be passed a JoinClause for complex joins. Passing a closure ignores all subsequent parameters.
    * @operator The boolean operator for the join clause. Default: "=".
    * @second The second column in the join's `on` statement.
    * @type The type of the join. Default: "inner".  Passing this as an argument is discouraged for readability.  Use the dedicated methods like `leftJoin` and `rightJoin` where possible.
    *
    * @return qb.models.Query.Builder
    */
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

    /*******************************************************************************\
    |                            WHERE clause functions                             |
    \*******************************************************************************/

    /**
    * Adds a WHERE clause to the query.
    *
    * @column The name of the column with which to constrain the query. A closure can be passed to begin a nested where statement.
    * @operator The operator to use for the constraint (i.e. "=", "<", ">=", etc.).  A value can be passed as the `operator` and the `value` left null as a shortcut for equals (e.g. where( "column", 1 ) == where( "column", "=", 1 ) ).
    * @value The value with which to constrain the column.  An expression (`builder.raw()`) can be passed as well.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    public Builder function where(
        column,
        operator,
        value,
        string combinator = "and"
    ) {
        if ( isClosure( column ) ) {
            return whereNested( column, combinator );
        }

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

        if ( getUtils().isNotExpression( arguments.value ) ) {
            addBindings( utils.extractBinding( arguments.value ), "where" );
        }

        return this;
    }

    /**
    * Adds a where clause where the value is a subquery.
    *
    * @column The name of the column with which to constrain the query.
    * @operator The operator to use for the constraint (i.e. "=", "<", ">=", etc.).
    * @callback The closure that defines the subquery. A new query will be passed to the closure as the only argument.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    private Builder function whereSub(
        column,
        operator,
        callback,
        combinator = "and"
    ) {
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

    /**
    * Adds an OR WHERE clause to the query.
    *
    * @column The name of the column with which to constrain the query. A closure can be passed to begin a nested where statement.
    * @operator The operator to use for the constraint (i.e. "=", "<", ">=", etc.).  A value can be passed as the `operator` and the `value` left null as a shortcut for equals (e.g. where( "column", 1 ) == where( "column", "=", 1 ) ).
    * @value The value with which to constrain the column.  An expression (`builder.raw()`) can be passed as the value as well.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhere( column, operator, value ) {
        arguments.combinator = "or";
        return where( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE IN clause to the query.
    *
    * @column The name of the column with which to constrain the query. A closure can be passed to begin a nested where statement.
    * @values The values with which to constrain the column. An expression (`builder.raw()`) can be passed as any of the values as well.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    * @negate False for IN, True for NOT IN. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereIn(
        column,
        values,
        combinator = "and",
        negate = false
    ) {
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

        var bindings = values
            .filter( utils.isNotExpression )
            .map( function( value ) {
                return utils.extractBinding( value );
            } );
        // writeDump( var = bindings, abort = true );
        addBindings( bindings, "where" );

        return this;
    }

    /**
    * Adds a WHERE IN clause to the query using a subselect.  To call this using the public api, pass a closure to `whereIn` as the second argument (`values`).
    *
    * @column The name of the column with which to constrain the query.
    * @callback A closure that will contain the subquery with which to constain this clause.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    * @negate False for IN, True for NOT IN. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    private Builder function whereInSub(
        column,
        callback,
        combinator = "and",
        negate = false
    ) {
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

    /**
    * Adds an OR WHERE IN clause to the query.
    *
    * @column The name of the column with which to constrain the query. A closure can be passed to begin a nested where statement.
    * @values The values with which to constrain the column. An expression (`builder.raw()`) can be passed as any of the values as well.
    * @negate False for IN, True for NOT IN. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereIn( column, values, negate = false ) {
        arguments.combinator = "or";
        return whereIn( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE NOT IN clause to the query.
    *
    * @column The name of the column with which to constrain the query. A closure can be passed to begin a nested where statement.
    * @values The values with which to constrain the column. An expression (`builder.raw()`) can be passed as any of the values as well.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereNotIn( column, values, combinator = "and" ) {
        arguments.negate = true;
        return whereIn( argumentCollection = arguments );
    }

    /**
    * Adds an OR WHERE NOT IN clause to the query.
    *
    * @column The name of the column with which to constrain the query. A closure can be passed to begin a nested where statement.
    * @values The values with which to constrain the column. An expression (`builder.raw()`) can be passed as any of the values as well.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereNotIn( column, values ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereIn( argumentCollection = arguments );
    }

    /**
    * Adds a raw SQL statement to the WHERE clauses.
    *
    * @sql The raw SQL to add to the query.
    * @whereBindings Any bindings needed for the raw SQL. Default: [].
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereRaw(
        required string sql,
        array whereBindings = [],
        string combinator = "and"
    ) {
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

    /**
    * Adds a raw SQL statement to the WHERE clauses with an OR combinator.
    *
    * @sql The raw SQL to add to the query.
    * @whereBindings Any bindings needed for the raw SQL. Default: [].
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereRaw(
        required string sql,
        array whereBindings = []
    ) {
        arguments.combinator = "or";
        return whereRaw( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE clause to the query comparing two columns
    *
    * @first The name of the first column to compare.
    * @operator The operator to use for the constraint (i.e. "=", "<", ">=", etc.).  A value can be passed as the `operator` and the `second` left null as a shortcut for equals (e.g. whereColumn( "columnA", "columnB" ) == where( "column", "=", "columnB" ) ).
    * @second The name of the second column to compare.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
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

    /**
    * Adds a OR WHERE clause to the query comparing two columns
    *
    * @first The name of the first column to compare.
    * @operator The operator to use for the constraint (i.e. "=", "<", ">=", etc.).  A value can be passed as the `operator` and the `second` left null as a shortcut for equals (e.g. whereColumn( "columnA", "columnB" ) == where( "column", "=", "columnB" ) ).
    * @second The name of the second column to compare.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereColumn( required first, operator, second ) {
        arguments.combinator = "or";
        return whereColumn( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE EXISTS clause to the query.
    *
    * @callback A callback to specify the query for the EXISTS clause.  It will be passed a query as the only argument.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    * @negate False for EXISTS, True for NOT EXISTS. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereExists(
        callback,
        combinator = "and",
        negate = false
    ) {
        var query = newQuery();
        callback( query );
        return addWhereExistsQuery( query, combinator, negate );
    }

    /**
    * Adds a WHERE EXISTS clause to the query.
    *
    * @query The EXISTS query to add as a constraint.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    * @negate False for EXISTS, True for NOT EXISTS. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    private Builder function addWhereExistsQuery(
        query,
        combinator = "and",
        negate = false
    ) {
        var type = negate ? "notExists" : "exists";
        variables.wheres.append( {
            type = type,
            query = arguments.query,
            combinator = arguments.combinator
        } );
        addBindings( query.getBindings(), "where" );
        return this;
    }

    /**
    * Adds an OR WHERE EXISTS clause to the query.
    *
    * @callback A callback to specify the query for the EXISTS clause.  It will be passed a query as the only argument.
    * @negate False for EXISTS, True for NOT EXISTS. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereExists( callback, negate = false ) {
        arguments.combinator = "or";
        return whereExists( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE NOT EXISTS clause to the query.
    *
    * @callback A callback to specify the query for the EXISTS clause.  It will be passed a query as the only argument.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereNotExists( callback, combinator = "and" ) {
        arguments.negate = true;
        return whereExists( argumentCollection = arguments );
    }

    /**
    * Adds a OR WHERE NOT EXISTS clause to the query.
    *
    * @callback A callback to specify the query for the EXISTS clause.  It will be passed a query as the only argument.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereNotExists( callback ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereExists( argumentCollection = arguments );
    }

    /**
    * Adds a nested where statement to the query. (Basically adding parenthesis to the statments in the nested section.)
    * The public api to create a nested WHERE statement is by passing a callback as the first parameter to `where`.
    *
    * @callback The callback that contains the nested query logic.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    private Builder function whereNested( required callback, combinator = "and" ) {
        var query = forNestedWhere();
        callback( query );
        return addNestedWhereQuery( query, combinator );
    }

    /**
    * Adds the bindings for a nested WHERE statment to the current query.
    *
    * @query The query to add as a nested WHERE statement
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    private Builder function addNestedWhereQuery(
        required Builder query,
        string combinator = "and"
    ) {
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

    /**
    * Creates a new query scoped to the same table as the current query.
    *
    * @return qb.models.Query.Builder
    */
    private Builder function forNestedWhere() {
        var query = newQuery();
        return query.from( getFrom() );
    }

    /**
    * Adds a WHERE NULL clause to the query.
    *
    * @column The name of the column to check if it is NULL.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    * @negate False for NULL, True for NOT NULL. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereNull( column, combinator = "and", negate = false ) {
        var type = negate ? "notNull" : "null";
        variables.wheres.append( {
            type = type,
            column = arguments.column,
            combinator = arguments.combinator
        } );
        return this;
    }

    /**
    * Adds an OR WHERE NULL clause to the query.
    *
    * @column The name of the column to check if it is NULL.
    * @negate False for NULL, True for NOT NULL. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereNull( column, negate = false ) {
        arguments.combinator = "or";
        return whereNull( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE NOT NULL clause to the query.
    *
    * @column The name of the column to check if it is NULL.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereNotNull( column, combinator = "and" ) {
        arguments.negate = true;
        return whereNull( argumentCollection = arguments );
    }

    /**
    * Adds an OR WHERE NOT NULL clause to the query.
    *
    * @column The name of the column to check if it is NULL.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereNotNull( column ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereNull( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE BETWEEN clause to the query.
    *
    * @column The name of the column with which to constrain the query.
    * @start The beginning value of the BETWEEN statement.
    * @end The end value of the BETWEEN statement.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    * @negate False for BETWEEN, True for NOT BETWEEN. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereBetween(
        column,
        start,
        end,
        combinator = "and",
        negate = false
    ) {
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

    /**
    * Adds a OR WHERE BETWEEN clause to the query.
    *
    * @column The name of the column with which to constrain the query.
    * @start The beginning value of the BETWEEN statement.
    * @end The end value of the BETWEEN statement.
    * @negate False for BETWEEN, True for NOT BETWEEN. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereBetween( column, start, end, negate = false ) {
        arguments.combinator = "or";
        return whereBetween( argumentCollection = arguments );
    }

    /**
    * Adds a WHERE NOT BETWEEN clause to the query.
    *
    * @column The name of the column with which to constrain the query.
    * @start The beginning value of the BETWEEN statement.
    * @end The end value of the BETWEEN statement.
    * @combinator The boolean combinator for the clause (e.g. "and" or "or"). Default: "and"
    *
    * @return qb.models.Query.Builder
    */
    public Builder function whereNotBetween( column, start, end, combinator ) {
        arguments.negate = true;
        return whereBetween( argumentCollection = arguments );
    }

    /**
    * Adds an OR WHERE NOT BETWEEN clause to the query.
    *
    * @column The name of the column with which to constrain the query.
    * @start The beginning value of the BETWEEN statement.
    * @end The end value of the BETWEEN statement.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orWhereNotBetween( column, start, end, combinator ) {
        arguments.combinator = "or";
        arguments.negate = true;
        return whereBetween( argumentCollection = arguments );
    }

    /*******************************************************************************\
    |         GROUP BY / HAVING / ORDER BY / LIMIT / OFFSET clause functions        |
    \*******************************************************************************/

    /**
    * Add a group by clause to the query.
    * `groupBy` allows three ways to specify the grouping columns:
    * - a comma-separated list 
    * - an array
    * - variadic arguments
    * All the columns passed this way will be individually added to the query.
    *
    * @return qb.models.Query.Builder
    */
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

    /**
    * Add a having clause to a query.
    *
    * @column The column with which to constrain the having clause. An expression (`builder.raw()`) can be passed as well.
    * @operator The operator to use for the constraint (i.e. "=", "<", ">=", etc.).  A value can be passed as the `operator` and the `value` left null as a shortcut for equals (e.g. where( "column", 1 ) == where( "column", "=", 1 ) ).
    * @value The value with which to constrain the column.  An expression (`builder.raw()`) can be passed as well.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function having(
        column,
        operator,
        value,
        string combinator = "and"
    ) {
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

        arrayAppend( variables.havings, {
            column = arguments.column,
            operator = arguments.operator,
            value = arguments.value,
            combinator = arguments.combinator
        } );

        if ( getUtils().isNotExpression( arguments.value ) ) {
            addBindings( utils.extractBinding( arguments.value ), "where" );
        }

        return this;
    }

    /**
    * Add an order by clause to the query.  To order by multiple columns, call `orderBy` multiple times.
    * The order in which `orderBy` is called matters and is the order it appears in the SQL.
    *
    * @column The name of the column(s) to order by. An expression (`builder.raw()`) can be passed as well. An array can be passed with any combination of simple values, array, struct, or list for each entry in the array (an example with all possible value styles: column = [ "last_name", [ "age", "desc" ], { column = "favorite_color", direction = "desc" }, "height|desc" ];. The column argument can also just accept a comman delimited list with a pipe ( | ) as the secondary delimiter denoting the direction of the order by. The pipe delimiter is also used when parsing the column argument when it is passed as an array and the entry in the array is a pipe delimited string. 
    * @direction The direction by which to order the query.  Accepts "asc" OR "desc". Default: "asc". If column argument is an array this argument will be used as the default value for all entries in the column list or array that fail to specify a direction for a speicifc column.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function orderBy( required any column, string direction = "asc" ) {

        if ( getUtils().isExpression( column ) ) {
            variables.orders.append( {
                direction = "raw",
                column = column
            } );
        }
        // if the column argument is an array 
        else if ( isArray( column ) ) {

            for ( var col in column ) {
                //check the value of the current iteration to determine what blend of column def they went with
                // ex: "DATE(created_at)" -- RAW expression
                 if ( getUtils().isExpression( col ) ) {
                    variables.orders.append( {
                        direction = "raw",
                        column = col
                    } );
                }
                // ex: "age|desc" || "last_name"
                else if ( isSimpleValue( col ) ) {
                    var colName = listFirst( col, "|" );
                    // ex: "age|desc"
                    if ( listLen( col, "|" ) == 2 ) {
                        var dir = ( arrayFindNoCase( variables.directions, listLast( col, "|" ) ) ) ? listLast( col, "|" ) : direction;
                    } else {
                        var dir = direction;
                    }

                    // now append the simple value column name and determined direction
                    variables.orders.append( {
                        direction = dir,
                        column = colName
                    } );
                }
                // ex: { "column" = "favorite_color" } || { "column" = "favorite_color", direction = "desc" }
                else if ( isStruct( col ) && structKeyExists( col, "column" ) ) {
                    //as long as the struct provided contains the column keyName then we can append it. If the direction column is omitted we will assume direction argument's value
                    if ( getUtils().isExpression( col.column ) ) {
                        var dir = "raw";
                    } else {
                        var dir = ( structKeyExists( col, "direction") && arrayFindNoCase( variables.directions, col.direction ) ) ? col.direction : direction;
                    }
                    variables.orders.append({
                        direction = dir,
                        column = col.column
                    });
                }
                // ex: [ "age", "desc" ]
                else if ( isArray( col ) ) {
                    //assume position 1 is the column name and position 2 if it exists and is a valid direction ( asc | desc ) use it.
                    variables.orders.append({
                        direction = ( arrayLen( col ) == 2 && arrayFindNoCase( variables.directions, col[2] ) ) ? col[2] : direction,
                        column = col[1]
                    });
                }
                
            }

        }
        // ex: "last_name|asc,age|desc"
        else if ( listLen( column ) > 1 ) {
            //convert list to array for easier looping and access to vals
            var arCols = listToArray( column );

            for ( var col in arCols ) {
                var colName = listFirst( col, "|" );
                
                if ( listLen( col, "|" ) == 2 ) {
                    var dir = ( arrayFindNoCase( variables.directions, listLast( col, "|" ) ) ) ? listLast( col, "|" ) : direction;
                } else {
                    var dir = direction;
                }

                variables.orders.append( {
                    direction = dir,
                    column = colName
                } );
            }
        }
        else {
            variables.orders.append( {
                direction = direction,
                column = column
            } );
        }

        return this;
    }

    /**
    * Sets the limit value for the query.
    *
    * @value The limit value for the query.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function limit( required numeric value ) {
        variables.limitValue = value;
        return this;
    }

    /**
    * Sets the limit value for the query.
    * Alias for `limit`.
    *
    * @value The limit value for the query.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function take( required numeric value ) {
        return limit( argumentCollection = arguments );
    }

    /**
    * Sets the offset value for the query.
    *
    * @value The offset value for the query.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function offset( required numeric value ) {
        variables.offsetValue = value;
        return this;
    }

    /**
    * Helper method to calculate the limit and offset given a page number and count per page.
    *
    * @pageNumber The page number to retrieve
    * @pageCount The number of records per page.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function forPage(
        required numeric pageNumber,
        required numeric pageCount
    ) {
        arguments.pageCount = arguments.pageCount > 0 ? arguments.pageCount : 0;
        offset( arguments.pageNumber * arguments.pageCount - arguments.pageCount );
        limit( arguments.pageCount );
        return this;
    }

    /*******************************************************************************\
    |                             control flow functions                            |
    \*******************************************************************************/

    /**
    * When is a useful helper method that introduces if / else control flow without breaking chainability.
    * When the `condition` is true, the `onTrue` callback is triggered.  If the `condition` is false and an `onFalse` callback is passed, it is triggered.  Otherwise, the query is returned unmodified.
    * 
    * @condition A boolean condition that if true will trigger the `onTrue` callback. If not true, the `onFalse` callback will trigger if it was passed. Otherwise, the query is returned unmodified.
    * @onTrue A closure that will be triggered if the `condition` is true.
    * @onFlase A closure that will be triggered if the `condition` is false.
    *
    * @return qb.models.Query.Builder
    */
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

    /**
    * Tap takes a callback and calls that callback with a copy of the current query.
    * The results of calling the callback are ignored.  The query is returned unmodified.
    *
    * @callback A callback to execute with the current query.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function tap( required callback ) {
        callback( duplicate( this ) );
        return this;
    }

    /*******************************************************************************\
    |                        INSERT / UPDATE / DELETE functions                     |
    \*******************************************************************************/

    /**
    * Inserts a single struct or an array of structs in to a table.
    * This call must come after setting the query's table using `from` or `table`.
    *
    * @values A struct or array of structs to insert in to the table.
    * @options Any options to pass to `queryExecute`. Default: {}.
    * @toSql If true, returns the raw sql string instead of running the query.  Useful for debugging. Default: false.
    *
    * @return query
    */
    public any function insert(
        required any values,
        struct options = {},
        boolean toSql = false
    ) {
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

        return runQuery( sql, options, "result" );
    }

    /**
    * Updates a table with a struct of column and value pairs.
    * This call must come after setting the query's table using `from` or `table`.
    * Any constraining of the update query should be done using the appropriate WHERE statement before calling `update`.
    *
    * @values A struct of column and value pairs to update.
    * @options Any options to pass to `queryExecute`. Default: {}.
    * @toSql If true, returns the raw sql string instead of running the query.  Useful for debugging. Default: false.
    *
    * @return query
    */
    public any function update(
        required struct values,
        struct options = {},
        boolean toSql = false
    ) {
        var updateArray = values.keyArray();
        updateArray.sort( "textnocase" );

        addBindings( updateArray.map( function( column ) {
            return getUtils().extractBinding( values[ column ] );
        } ), "update" );

        var sql = getGrammar().compileUpdate( this, updateArray );

        if ( toSql ) {
            return sql;
        }

        return runQuery( sql, options, "result" );
    }

    /**
    * If the query returns any rows, updates the first result found. Otherwise, inserts the values into the table.
    * This call must come after setting the query's table using `from` or `table`.
    * Any constraining of the query should be done using the appropriate WHERE statement before calling `updateOrInsert`.
    *
    * @values A struct of column and value pairs to update.
    * @options Any options to pass to `queryExecute`. Default: {}.
    * @toSql If true, returns the raw sql string instead of running the query.  Useful for debugging. Default: false.
    *
    * @return query
    */
    public any function updateOrInsert(
        required struct values,
        struct options = {},
        boolean toSql = false 
    ) {
        if ( exists() ) {
            return this.limit( 1 ).update( argumentCollection = arguments ); 
        }

        return this.insert( argumentCollection = arguments );
    }

    /**
    * Deletes a record set.
    * This call must come after setting the query's table using `from` or `table`.
    * Any constraining of the update query should be done using the appropriate WHERE statement before calling `update`.
    *
    * @id A convience argument for `where( "id", "=", arguments.id ).  The query can be constrained by normal WHERE methods if you have more complex needs.
    * @idColumnName The name of the id column for the delete shorthand. Default: "id".
    * @options Any options to pass to `queryExecute`. Default: {}.
    * @toSql If true, returns the raw sql string instead of running the query.  Useful for debugging. Default: false.
    *
    * @return qb.models.Query.Builder
    */
    public any function delete(
        any id,
        string idColumnName = "id",
        struct options = {},
        boolean toSql = false
    ) {
        if ( ! isNull( arguments.id ) ) {
            where( arguments.idColumnName, "=", arguments.id );
        }

        var sql = getGrammar().compileDelete( this );

        if ( toSql ) {
            return sql;
        }
        
        return runQuery( sql, options, "result" );
    }

    /*******************************************************************************\
    |                               binding functions                               |
    \*******************************************************************************/

    /**
    * Returns a flat array of bindings.  Used as the parameter list for `queryExecute`.
    *
    * @return array of bindings
    */
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

    /**
    * Returns all the binding types and their associated bindings.
    *
    * @return struct of binding types and their bindings
    */
    public struct function getRawBindings() {
        return bindings;
    }

    /**
    * Clear all the bindings on the query.
    *
    * @return qb.models.Query.Builder
    */
    private Builder function clearBindings() {
        variables.join = [];
        variables.where = [];
        variables.insert = [];
        variables.update = [];
        return this;
    }

    /**
    * Adds a single binding or an array of bindings to a query for a given type.
    *
    * @newBindings A single binding or an array of bindings to add for a given type.
    * @type The type of binding to add.
    *
    * @return qb.models.Query.Builder
    */
    private Builder function addBindings(
        required any newBindings,
        string type = "where"
    ) {
        if ( ! isArray( newBindings ) ) {
            newBindings = [ newBindings ];
        }

        newBindings.each( function( binding ) {
            variables.bindings[ type ].append( binding );
        } );

        return this;
    }

    /*******************************************************************************\
    |                              aggregate functions                              |
    \*******************************************************************************/

    /**
    * Return a count from a query.
    * The original query is unaltered by this operation.
    *
    * @column The column on which to count records. Default: "*".
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return numeric
    */
    public numeric function count( string column = "*", struct options = {} ) {
        arguments.type = "count";
        return aggregateQuery( argumentCollection = arguments );
    }

    /**
    * Return the max of a column from a query.
    * The original query is unaltered by this operation.
    *
    * @column The column on which to find the max.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function max( required string column, struct options = {} ) {
        arguments.type = "max";
        return aggregateQuery( argumentCollection = arguments );
    }

    /**
    * Return the min of a column from a query.
    * The original query is unaltered by this operation.
    *
    * @column The column on which to find the min.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function min( required string column, struct options = {} ) {
        arguments.type = "min";
        return aggregateQuery( argumentCollection = arguments );
    }

    /**
    * Return the sum of a column from a query.
    * The original query is unaltered by this operation.
    *
    * @column The column on which to find the sum.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function sum( required string column, struct options = {} ) {
        arguments.type = "sum";
        return aggregateQuery( argumentCollection = arguments );
    }

    /**
    * Perform an aggregate function on a query.
    * The original query is unaltered by this operation.
    *
    * @type The aggregate type to execute.
    * @column The column on which to find the specified aggregate. Default: "*".
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    private any function aggregateQuery(
        required string type,
        required string column = "*",
        struct options = {}
    ) {
        return withAggregate( { type = type, column = column }, function() {
            return withReturnFormat( "query", function() {
                return withColumns( "*", function() {
                    return get( options = options ).aggregate;;
                } );
            } );
        } );
    }

    /**
    * Returns true if the query returns any rows.
    *
    * @options Any options to pass to `queryExecute`. Default: {}. 
    *
    * @return boolean
    */
    public boolean function exists( struct options = {} ) {
        return get( argumentCollection = arguments ).RECORDCOUNT > 0;
    }

    /*******************************************************************************\
    |                               select functions                                |
    \*******************************************************************************/

    /**
    * Runs the current select query.
    *
    * @columns An optional column, list of columns, or array of columns to select.
    * The selected columns before calling get will be restored after running the query.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function get( any columns, struct options = {} ) {
        var originalColumns = getColumns();
        if ( ! isNull( arguments.columns ) ) {
            select( arguments.columns );
        }
        var result = run( sql = toSql(), options = arguments.options );
        select( originalColumns );
        return result;
    }

    /**
    * Returns the first record returned from a query.
    *
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function first( struct options = {} ) {
        take( 1 );
        var results = withReturnFormat( "array", function() {
            return get( options = options );
        } );
        if ( arrayIsEmpty( results ) ) {
            return {};
        }
        return results[ 1 ];
    }

    /**
    * Adds an id constraint to the query and returns the first record from the query.
    *
    * @id The id value to look up.
    * @idColumn The name of the id column to constrain.  Default: "id".
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function find(
        required any id,
        string idColumn = "id",
        struct options = {}
    ) {
        where( idColumn, "=", arguments.id );
        return first( options = arguments.options );
    }

    /**
    * Returns the first value of a column in a query.
    *
    * @column The column for which to retrieve the value.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public any function value( required string column, struct options = {} ) {
        return withReturnFormat( "query", function() {
            select( column );
            return first( options = options )[ column ];
        } );
    }

    /**
    * Returns an array of values for a column in a query.
    *
    * @column The column for which to retrieve the values.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    public array function values( required string column, struct options = {} ) {
        return withReturnFormat( "query", function() {
            select( column );
            var result = get( options = options );
            var results = [];
            for ( var row in result ) {
                results.append( row[ column ] );
            }
            return results;
        } );
    }

    /**
    * Get all the values of a column in a query and return it as a single string glued together.
    *
    * @column The name of the column from which to extract the values.
    * @glue The string to use when joining the columns together.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return string
    */
    public string function implode(
        required string column,
        string glue = "",
        struct options = {}
    ) {
        return arrayToList( values( argumentCollection = arguments ), glue );
    }

    /**
    * Execute a query and convert it to the proper return format.
    *
    * @sql The sql string to execute.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    private any function run( required string sql, struct options = {} ) {
        var q = runQuery( argumentCollection = arguments );

        if ( isNull( q ) ) {
            return;
        }

        return returnFormat( q );
    }

    /**
    * Run a query through the specified grammar then clear all bindings.
    *
    * @sql The sql string to execute.
    * @options Any options to pass to `queryExecute`. Default: {}.
    *
    * @return any
    */
    private any function runQuery(
        required string sql,
        struct options = {},
        string returnObject = "query"
    ) {
        var result = grammar.runQuery( sql, getBindings(), options, returnObject );
        clearBindings();
        if ( ! isNull( result ) ) {
            return result;
        }
        return;
    }

    /*******************************************************************************\
    |                               utility functions                               |
    \*******************************************************************************/

    /**
    * Creates a new query using the same Grammar and QueryUtils.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function newQuery() {
        return new qb.models.Query.Builder(
            grammar = getGrammar(),
            utils = getUtils()
        );
    }

    /**
    * Wrap up any sql in an Expression.
    * Expressions are not parameterized or escaped in any way.
    *
    * @sql The raw sql to wrap up in an Expression.
    *
    * @return qb.models.Query.Expression
    */
    public Expression function raw( required string sql ) {
        return new qb.models.Query.Expression( sql );
    }

    /**
    * Returns the Builder compiled to grammar-specific sql.
    *
    * @return string
    */
    public string function toSQL() {
        return grammar.compileSelect( this );
    }

    /**
    * Sets the return format for the query.
    * The return format can be a simple string like "query" to return queries or "array" to return an array of structs.
    * Alternative, the return format can be a closure.  The closure is passed the query as the only argument.  The result of the closure is returned as the result of the query.
    * 
    * @format "query", "array", or a closure.
    *
    * @return qb.models.Query.Builder
    */
    public Builder function setReturnFormat( required any format ) {
        if ( isClosure( arguments.format ) || isCustomFunction( arguments.format ) ) {
            variables.returnFormat = format;
        }
        else if ( arguments.format == "array" ) {
            variables.returnFormat = function( q ) {
                return getUtils().queryToArrayOfStructs( q );
            };
        }
        else if ( arguments.format == "query" ) {
            variables.returnFormat = function( q ) {
                return q;
            };
        }
        else {
            throw( type = "InvalidFormat", message = "The format passed to Builder is invalid." );
        }

        return this;
    }

    /**
    * Runs the code inside the callback with the return format specified and then sets the return format back to its original value.
    *
    * @returnFormat "query", "array", or a closure.
    * @callback The code to execute with the given return format.
    *
    * @return any
    */
    private any function withReturnFormat(
        required any returnFormat,
        required any callback
    ) {
        var originalReturnFormat = getReturnFormat();
        setReturnFormat( arguments.returnFormat );
        var result = callback();
        setReturnFormat( originalReturnFormat );
        return result;
    }

    /**
    * Runs the code inside the callback with the given columns selected and then sets the columns back to its original value.
    *
    * @columns A single column, a list or columns (comma-separated), or an array of columns.
    * @callback The code to execute with the given columns.
    *
    * @return any
    */
    private any function withColumns(
        required any columns,
        required any callback
    ) {
        var originalColumns = getColumns();
        select( arguments.columns );
        var result = callback();
        select( originalColumns );
        return result;
    }

    /**
    * Runs the code inside the callback with the given aggregate in place and then sets the aggregate back to its original value.
    *
    * @aggregate he aggregate option and column to execute. (e.g. `{ type = "count", column = "*" }`).
    * @callback The code to execute with the given aggregate.
    *
    * @return any
    */
    private function withAggregate(
        required struct aggregate,
        required any callback
    ) {
        var originalAggregate = getAggregate();
        setAggregate( arguments.aggregate );
        var result = callback();
        setAggregate( originalAggregate );
        return result;
    }

    /**
    * Converts the arguments passed in to it into an array.
    *
    * @return array
    */
    private array function normalizeToArray() {
        if ( isVariadicFunction( args = arguments ) ) {
            return normalizeVariadicArgumentsToArray( args = arguments );
        }

        var arg = arguments[ 1 ];
        if ( getUtils().isExpression( arg ) ) {
            return [ arg ];
        }

        if ( ! isArray( arg ) ) {
            return normalizeListArgumentsToArray( arg );
        }

        return arg;
    }

    /**
    * Returns true if the arguments passed constitute a variadic function.
    *
    * @args The arguments of another function.
    *
    * @return boolean
    */
    private boolean function isVariadicFunction( required struct args ) {
        return structCount( args ) > 1;
    }

    /**
    * Converts a variadic list of arguments to an array.
    *
    * @args The arguments of another function.
    *
    * @return array
    */
    private array function normalizeVariadicArgumentsToArray( required struct args ) {
        var normalizedArgs = [];
        for ( var arg in arguments.args ) {
            arrayAppend( normalizedArgs, arguments.args[ arg ] );
        }
        return normalizedArgs;
    }

    /**
    * Converts a list of arguments to an array.
    *
    * @list A list containing multiple arguments.
    *
    * @return array
    */
    private array function normalizeListArgumentsToArray( required string list ) {
        var listAsArray = listToArray( arguments.list );
        var items = [];
        for ( var item in listAsArray ) {
            arrayAppend( items, trim( item ) );
        }
        return items;
    }

    /**
    * Checks if an operator is an invalid sql operator (according to qb).
    *
    * @operator The operator to check.
    *
    * @return boolean
    */
    private boolean function isInvalidOperator( required string operator ) {
        return ! arrayContains( operators, operator );
    }

    /**
    * Checks if a combinator is an invalid sql combinator (according to qb).
    *
    * @combinator The combinator to check.
    *
    * @return boolean
    */
    private boolean function isInvalidCombinator( required string combinator ) {
        for ( var validCombinator in variables.combinators ) {
            if ( validCombinator == arguments.combinator ) {
                return false;
            }
        }
        return true;
    }

    /**
    * onMissingMethod serves the following purpose for Builder:
    *
    * Magic `where` methods. If a method starts with `where` or `orWhere`
    * but doesn't match any other methods, Builder assumes that what
    * comes after is the column name to constrain.
    * All the other arguments to `where` are shifted accordingly.
    *
    * @return any
    */
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
