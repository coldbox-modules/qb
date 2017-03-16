import qb.models.Query.Builder;
import qb.models.Query.QueryUtils;

/**
* Grammar represents a platform to run sql on.
*
* This is the Base Grammar that other grammars can extend to modify
* the generated sql for their specific platforms.
*/
component displayname="Grammar" accessors="true" {

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
        "groups", "havings", "orders", "limitValue", "offsetValue"
    ];

    /**
    * Creates a new basic Query Grammar.
    *
    * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
    *
    * @return qb.models.Query.Grammars.Grammar
    */
    public Grammar function init(
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
    public any function runQuery( sql, bindings, options ) {
        return queryExecute( sql, bindings, options );
    }

    /**
    * Compile a Builder's query into a sql string.
    *
    * @query The Builder instance.
    *
    * @return string
    */
    public string function compileSelect( required Builder query ) {
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
        array wheres = []
    ) {
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
        required Builder query,
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
    private string function compileGroups( required Builder query, required array groups ) {
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
    private string function compileHavings( required Builder query, required array havings ) {
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
    * Compiles the order by portion of a sql statement.
    *
    * @query The Builder instance.
    * @orders The where clauses.
    *
    * @return string
    */
    private string function compileOrders(
        required Builder query,
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
    private string function compileLimitValue( required Builder query, limitValue ) {
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
    private string function compileOffsetValue( required Builder query, offsetValue ) {
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
        required Builder query,
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
        required Builder query,
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
    public string function compileDelete( required Builder query ) {
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
    private string function compileAggregate( required Builder query, required struct aggregate ) {
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
    private string function wrapTable( required any table ) {
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
    private string function wrapColumn( required any column ) {
        if ( isInstanceOf( column, "qb.models.Query.Expression" ) ) {
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
    private string function wrapValue( required any value ) {
        if ( value == "*" ) {
            return value;
        }
        return """#value#""";
    }

}