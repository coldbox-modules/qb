component displayname="Grammar" accessors="true" {

    property name="tablePrefix" type="string" default="";

    variables.selectComponents = [
        "columns", "from", "joins", "wheres"
    ];

    public Grammar function init() {
        variables.tablePrefix = "";
        return this;
    }

    public string function compileSelect( required Quick.models.Query.Builder query ) {

        var sql = [];

        for ( var component in selectComponents ) {
            var componentResult = invoke( query, "get" & component );
            var func = variables[ "compile#component#" ];
            var args = {
                "query" = query,
                "#component#" = componentResult
            };
            arrayAppend( sql, func( argumentCollection = args ) );
        }

        return concatenate( sql );
    }

    private string function compileColumns( required Quick.models.Query.Builder query, required array columns ) {
        var select = query.getDistinct() ? "SELECT DISTINCT " : "SELECT ";
        return select & columns.map( wrapColumn ).toList( ", " );
    }

    private string function compileFrom( required Quick.models.Query.Builder query, required string from ) {
        return "FROM " & wrapTable( from );
    }

    private string function compileJoins( required Quick.models.Query.Builder query, required array joins ) {
        var joinsArray = [];
        for ( var join in arguments.joins ) {
            var firstOne = true;
            var clausesArray = [];
            for ( var clause in join.getClauses() ) {
                if ( firstOne ) {
                    firstOne = false;
                    arrayAppend(
                        clausesArray,
                        "#clause.first# #uCase( clause.operator )# #clause.second#"
                    );
                }
                else {
                    arrayAppend(
                        clausesArray,
                        "#uCase( clause.combinator )# #clause.first# #uCase( clause.operator )# #clause.second#"
                    );
                }
            }
            var clauses = arrayToList( clausesArray, " " );
            arrayAppend( joinsArray, "#uCase( join.getType() )# JOIN #join.getTable()# ON #clauses#" );
        }

        return arrayToList( joinsArray, " " );
    }

    private string function compileWheres(
        required Quick.models.Query.Builder query,
        required array wheres
    ) {
        var wheresArray = [];
        var firstOne = true;
        for ( var where in arguments.wheres ) {
            var sql = invoke( this, "where#where.type#", { where = where, query = query } );
            sql = firstOne ? sql : "#uCase( where.combinator )# #sql#";
            wheresArray.append( sql );
            firstOne = false;
        }

        if ( arrayIsEmpty( wheresArray ) ) {
            return "";
        }

        return "WHERE #arrayToList( wheresArray, " " )#";
    }

    private function whereBasic( requried struct where, required Builder query ) {
        if ( ! isStruct( where ) ) {
            return;
        }

        where.column = wrapValue( where.column );

        var placeholder = "?";
        if ( where.operator == "in" || where.operator == "not in" ) {
            placeholder = "(#placeholder#)";
        }

        return "#where.column# #uCase( where.operator )# #placeholder#";
    }

    private function whereRaw( required struct where, required Builder query ) {
        return where.sql;
    }

    private function whereColumn( required struct where, required Builder query ) {
        return "#wrapColumn( where.first )# #where.operator# #wrapColumn( where.second )#";
    }

    private function whereNested( required struct where, required Builder query ) {
        var sql = compileWheres( arguments.where.query, arguments.where.query.getWheres() );
        // cut off the first 7 characters to account for the extra "WHERE"
        return "(#mid( sql, 7 )#)";
    }

    private function whereSub( required struct where, required Builder query ) {
        return "#wrapIdentifier( where.column )# #where.operator# (#compileSelect( where.query )#)";
    }

    private string function concatenate( required array sql ) {
        return arrayToList( arrayFilter( sql, function( item ) {
            return item != "";
        } ), " " );
    }

    private string function wrapIdentifier( required any identifier ) {
        return wrapValue( identifier );
    }

    private string function wrapTable( required any table ) {
        var alias = "";
        if ( table.find( " as " ) ) {
            alias = table.listToArray( " as ", false, true )[ 2 ];
            table = table.listToArray( " as ", false, true )[ 1 ];
        }
        table = table.listToArray( "." ).map( function( tablePart, index ) {
            return wrapValue( index == 1 ? getTablePrefix() & tablePart : tablePart );
        } ).toList( "." );
        return alias == "" ? table : table & " AS " & wrapTable( alias );
    }

    private string function wrapColumn( required any column ) {
        if ( isInstanceOf( column, "quick.models.Query.Expression" ) ) {
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