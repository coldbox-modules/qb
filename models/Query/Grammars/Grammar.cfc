import qb.models.Query.Builder;

component displayname="Grammar" accessors="true" {

    property name="tablePrefix" type="string" default="";

    variables.selectComponents = [
        "aggregate", "columns", "from", "joins", "wheres",
        "groups", "orders", "limitValue", "offsetValue"
    ];

    public Grammar function init() {
        variables.tablePrefix = "";
        return this;
    }

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

    private string function compileColumns( required Builder query, required array columns ) {
        if ( ! query.getAggregate().isEmpty() ) {
            return "";
        }
        var select = query.getDistinct() ? "SELECT DISTINCT " : "SELECT ";
        return select & columns.map( wrapColumn ).toList( ", " );
    }

    private string function compileFrom( required Builder query, required string from ) {
        return "FROM " & wrapTable( from );
    }

    private string function compileJoins( required Builder query, required array joins ) {
        var joinsArray = [];
        for ( var join in arguments.joins ) {
            var conditions = compileWheres( join, join.getWheres() );
            var table = wrapTable( join.getTable() );
            joinsArray.append( "#uCase( join.getType() )# JOIN #table# #conditions#" );
        }

        return arrayToList( joinsArray, " " );
    }

    private string function compileWheres( required Builder query, array wheres = [] ) {
        var wheresArray = [];
        
        if ( arguments.wheres.isEmpty() ) {
            return "";
        }

        for ( var where in arguments.wheres ) {
            var whereFunc = variables[ "where#where.type#" ];
            var sql = uCase( where.combinator ) & " " & whereFunc( where = where, query = query );
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

    private string function whereBasic( requried struct where, required Builder query ) {
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

    private string function whereRaw( required struct where, required Builder query ) {
        return where.sql;
    }

    private string function whereColumn( required struct where, required Builder query ) {
        return trim( "#wrapColumn( where.first )# #where.operator# #wrapColumn( where.second )#" );
    }

    private string function whereNested( required struct where, required Builder query ) {
        var sql = compileWheres( arguments.where.query, arguments.where.query.getWheres() );
        // cut off the first 7 characters to account for the extra "WHERE"
        return trim( "(#mid( sql, 7, len( sql ) - 6 )#)" );
    }

    private string function whereSub( required struct where, required Builder query ) {
        return "#wrapIdentifier( where.column )# #where.operator# (#compileSelect( where.query )#)";
    }

    private string function whereExists( required struct where, required Builder query ) {
        return "EXISTS (#compileSelect( where.query )#)";
    }

    private string function whereNotExists( required struct where, required Builder query ) {
        return "NOT EXISTS (#compileSelect( where.query )#)";
    }

    private string function whereNull( required struct where, required Builder query ) {
        return "#wrapColumn( where.column )# IS NULL";
    }

    private string function whereNotNull( required struct where, required Builder query ) {
        return "#wrapColumn( where.column )# IS NOT NULL";
    }

    private string function whereBetween( required struct where, required Builder query ) {
        return "#wrapColumn( where.column )# BETWEEN ? AND ?";
    }

    private string function whereNotBetween( required struct where, required Builder query ) {
        return "#wrapColumn( where.column )# NOT BETWEEN ? AND ?";
    }

    private string function whereIn( required struct where, required Builder query ) {
        var placeholderString = where.values.map( function( value ) {
            return isInstanceOf( value, "qb.models.Query.Expression" ) ? value.getSql() : "?";
        } ).toList( ", " );
        if ( placeholderString == "" ) {
            return "0 = 1";
        }
        return "#wrapColumn( where.column )# IN (#placeholderString#)";
    }

    private string function whereNotIn( required struct where, required Builder query ) {
        var placeholderString = where.values.map( function( value ) {
            return isInstanceOf( value, "qb.models.Query.Expression" ) ? value.getSql() : "?";
        } ).toList( ", " );
        if ( placeholderString == "" ) {
            return "1 = 1";
        }
        return "#wrapColumn( where.column )# NOT IN (#placeholderString#)";
    }

    private string function whereInSub( required struct where, required Builder query ) {
        return "#wrapColumn( where.column )# IN (#compileSelect( where.query )#)";
    }

    private string function whereNotInSub( required struct where, required Builder query ) {
        return "#wrapColumn( where.column )# NOT IN (#compileSelect( where.query )#)";
    }

    private string function compileGroups( required Builder query, required array groups ) {
        if ( groups.isEmpty() ) {
            return "";
        }

        return "GROUP BY #groups.map( wrapColumn ).toList( ", " )#";
    }

    private string function compileOrders( required Builder query, required array orders ) {
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

    private string function compileLimitValue( required Builder query, limitValue ) {
        if ( isNull( arguments.limitValue ) ) {
            return "";
        }
        return "LIMIT #limitValue#";
    }

    private string function compileOffsetValue( required Builder query, offsetValue ) {
        if ( isNull( arguments.offsetValue ) ) {
            return "";
        }
        return "OFFSET #offsetValue#";
    }

    public string function compileInsert( required Builder query, required array columns, required array values ) {
        var columnsString = columns.map( wrapColumn ).toList( ", " );

        var placeholderString = values.map( function( valueArray ) {
            return "(" & valueArray.map( function() {
                return "?";
            } ).toList( ", " ) & ")";
        } ).toList( ", ");
        return trim( "INSERT INTO #wrapTable( query.getFrom() )# (#columnsString#) VALUES #placeholderString#" );
    }

    public string function compileUpdate( required Builder query, required array columns ) {
        var updateList = columns.map( function( column ) {
            return "#wrapColumn( column )# = ?";
        } ).toList( ", " );

        return trim( "UPDATE #wrapTable( query.getFrom() )# SET #updateList# #compileWheres( query, query.getWheres() )# #compileLimitValue( query, query.getLimitValue() )#" );
    }

    public string function compileDelete( required Builder query ) {
        return trim( "DELETE FROM #wrapTable( query.getFrom() )# #compileWheres( query, query.getWheres() )#" );
    }

    private string function compileAggregate( required Builder query, required struct aggregate ) {
        if ( aggregate.isEmpty() ) {
            return "";
        }
        return "SELECT #uCase( aggregate.type )#(#wrapColumn( aggregate.column )#) AS ""aggregate""";
    }

    private string function concatenate( required array sql ) {
        return arrayToList( arrayFilter( sql, function( item ) {
            return item != "";
        } ), " " );
    }

    private string function removeLeadingCombinator( required string whereList ) {
        return REReplaceNoCase( whereList, "and\s|or\s", "", "one" );
    }

    private string function wrapIdentifier( required any identifier ) {
        return wrapValue( identifier );
    }

    private string function wrapTable( required any table ) {
        var alias = "";
        if ( table.find( " as " ) ) {
            alias = wrapTable( table.listToArray( " as ", false, true )[ 2 ] );
            table = table.listToArray( " as ", false, true )[ 1 ];
        }
        table = table.listToArray( "." ).map( function( tablePart, index ) {
            return wrapValue( index == 1 ? getTablePrefix() & tablePart : tablePart );
        } ).toList( "." );
        return alias == "" ? table : table & " AS " & alias;
    }

    private string function wrapColumn( required any column ) {
        if ( isInstanceOf( column, "qb.models.Query.Expression" ) ) {
            return column.getSQL();
        }
        var alias = "";
        if ( column.find( " as " ) ) {
            alias = column.listToArray( " as ", false, true )[ 2 ];
            column = column.listToArray( " as ", false, true )[ 1 ];
        }
        column = column.listToArray( "." ).map( wrapValue ).toList( "." );
        return alias == "" ? column : column & " AS " & wrapValue( alias ); 
    }

    private string function wrapValue( required any value ) {
        if ( value == "*" ) {
            return value;
        }
        return """#value#""";
    }

}