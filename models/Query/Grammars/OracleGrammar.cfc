component displayname='OracleGrammar' implements='Quick.models.Query.Grammars.GrammarInterface' {

    variables.selectComponents = [
        'columns', 'from', 'joins', 'wheres'
    ];

    public string function compileSelect(required Quick.models.Query.Builder query) {

        var sql = [];

        for (var component in selectComponents) {
            var componentResult = invoke(query, 'get' & component);
            var func = variables['compile#component#'];
            var args = {
                'query' = query,
                '#component#' = componentResult
            };
            arrayAppend(sql, func(argumentCollection = args));
        }

        return concatenate(sql);
    }

    private string function compileColumns(required Quick.models.Query.Builder query, required array columns) {
        var select = query.getDistinct() ? 'SELECT DISTINCT ' : 'SELECT ';
        return select & ArrayToList(columns);
    }

    private string function compileFrom(required Quick.models.Query.Builder query, required string from) {
        return 'FROM ' & from;
    }

    private string function compileJoins(required Quick.models.Query.Builder query, required array joins) {
        var joinsArray = [];
        for (var join in arguments.joins) {
            var firstOne = true;
            var clausesArray = [];
            for (var clause in join.getClauses()) {
                if (firstOne) {
                    firstOne = false;
                    arrayAppend(
                        clausesArray,
                        '#clause.first# #UCase(clause.operator)# #clause.second#'
                    );
                }
                else {
                    arrayAppend(
                        clausesArray,
                        '#UCase(clause.combinator)# #clause.first# #UCase(clause.operator)# #clause.second#'
                    );
                }
            }
            var clauses = arrayToList(clausesArray, ' ');
            arrayAppend(joinsArray, '#UCase(join.getType())# JOIN #join.getTable()# ON #clauses#');
        }

        return arrayToList(joinsArray, ' ');
    }

    private string function compileWheres(required Quick.models.Query.Builder query, requierd array wheres) {
        var wheresArray = [];
        var firstOne = true;
        for (var where in arguments.wheres) {
            if (! isStruct(where)) {
                continue;
            }

            var placeholder = '?';
            if (where.operator == 'in' || where.operator == 'not in') {
                placeholder = '(#placeholder#)';
            }

            if (firstOne) {
                firstOne = false;
                arrayAppend(
                    wheresArray,
                    '#where.column# #UCase(where.operator)# #placeholder#'
                );
            }
            else {
                arrayAppend(
                    wheresArray,
                    '#uCase(where.combinator)# #where.column# #UCase(where.operator)# #placeholder#'
                );
            }
        }

        if (arrayIsEmpty(wheresArray)) {
            return '';
        }

        return "WHERE #ArrayToList(wheresArray, ' ')#";
    }

    private string function concatenate(required array sql) {
        return arrayToList(arrayFilter(sql, function(item) {
            return item != '';
        }), ' ');
    }
}