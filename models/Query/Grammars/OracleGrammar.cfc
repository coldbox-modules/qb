component displayname='OracleGrammar' implements='Quick.models.Query.Grammars.GrammarInterface' {

    variables.selectComponents = [
        'columns', 'from', 'joins', 'wheres'
    ];

    public string function compileSelect(required Quick.models.Query.Builder query) {

        var sql = [];

        for (var component in selectComponents) {
            var componentResult = invoke(query, 'get' & component);
            arrayAppend(sql, invoke(this, 'compile' & component, {
                'query' = query,
                '#component#' = componentResult
            }));
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
        return arrayToList(arrayMap(arguments.joins, function(join) {
            var clauses = arrayToList(arrayMap(join.getClauses(), function(clause, index) {
                if (index == 1) {
                    return '#clause.first# #clause.operator# #clause.second#';
                } 

                return '#UCase(clause.combinator)# #clause.first# #clause.operator# #clause.second#';
            }), ' ');
            return '#UCase(join.getType())# JOIN #join.getTable()# ON #clauses#';
        }), ' ');
    }

    private string function compileWheres(required Quick.models.Query.Builder query, requierd array wheres) {
        var whereStatements = ArrayMap(wheres, function(where, index) {
            if (! isStruct(where)) {
                return '';
            }

            if (index == 1) {
                return '#where.column# #where.operator# ?';
            }

            return '#uCase(where.combinator)# #where.column# #where.operator# ?';
        });

        whereStatements = ArrayFilter(whereStatements, function(statement) {
            return statement != '';
        });

        if (arrayIsEmpty(whereStatements)) {
            return '';
        }

        return "WHERE #ArrayToList(whereStatements, ' ')#";
    }

    private string function concatenate(required array sql) {
        return arrayToList(arrayFilter(sql, function(item) {
            return item != '';
        }), ' ');
    }
}