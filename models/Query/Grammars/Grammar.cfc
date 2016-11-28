component displayname="Grammar" implements="Quick.models.Query.Grammars.GrammarInterface" {

    variables.selectComponents = [
        "columns", "from", "joins", "wheres"
    ];

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

    private string function compileWheres( required Quick.models.Query.Builder query, requierd array wheres ) {
        var wheresArray = [];
        var firstOne = true;
        for ( var where in arguments.wheres ) {
            if ( ! isStruct( where ) ) {
                continue;
            }

            var placeholder = "?";
            if ( where.operator == "in" || where.operator == "not in" ) {
                placeholder = "(#placeholder#)";
            }

            if ( firstOne ) {
                firstOne = false;
                arrayAppend(
                    wheresArray,
                    "#where.column# #uCase( where.operator )# #placeholder#"
                );
            }
            else {
                arrayAppend(
                    wheresArray,
                    "#uCase( where.combinator )# #where.column# #uCase( where.operator )# #placeholder#"
                );
            }
        }

        if ( arrayIsEmpty( wheresArray ) ) {
            return "";
        }

        return "WHERE #arrayToList( wheresArray, " " )#";
    }

    private string function concatenate( required array sql ) {
        return arrayToList( arrayFilter( sql, function( item ) {
            return item != "";
        } ), " " );
    }

    private string function wrapTable( required any table ) {
        return table.listToArray( "." ).map( wrapValue ).toList( "." );
    }

    private string function wrapColumn( required any column ) {
        if ( isInstanceOf( column, "quick.models.Query.Expression" ) ) {
            return column.getSQL();
        }
        var alias = "";
        if ( column.find( "as" ) ) {
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