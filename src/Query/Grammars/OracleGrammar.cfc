component implements='Quick.Query.Grammars.Grammar' {

    variables.selectComponents = [
        'columns', 'from', 'wheres'
    ];

    public string function compileSelect(required Quick.Query.Builder query) {

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

    private string function compileColumns(required Quick.Query.Builder query, required array columns) {
        return 'SELECT ' & ArrayToList(columns);
    }

    private string function compileWheres(required Quick.Query.Builder query, requierd array wheres) {
        var whereStatements = ArrayMap(wheres, function(where, index) {
            if (! isStruct(where)) {
                return '';
            }

            if (index == 1) {
                return '#where.column# #where.operator# ?';
            }

            return '#where.combinator# #where.column# #where.operator# ?';
        });

        whereStatements = ArrayFilter(whereStatements, function(statement) {
            return statement != '';
        });

        if (arrayIsEmpty(whereStatements)) {
            return '';
        }

        return "WHERE #ArrayToList(whereStatements, ' ')#";
    }

    private string function compileFrom(required Quick.Query.Builder query, required string from) {
        return 'FROM ' & from;
    }

    private string function concatenate(required array sql) {
        return arrayToList(arrayFilter(sql, function(item) {
            return item != '';
        }), ' ');
    }
}