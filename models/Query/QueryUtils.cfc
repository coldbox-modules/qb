component displayname='QueryUtils' {
    public struct function extractBinding(required any value) {
        var binding = isStruct(value) ? value : { value = normalizeSqlValue(value) };

        structAppend(binding, {
            cfsqltype = inferSqlType(binding.value),
            list = isList(binding.value),
            null = false
        }, false);

        return binding;
    }

    public string function inferSqlType(required any value) {
        if (isList(arguments.value)) {
            arguments.value = listToArray(arguments.value);
        }

        if (isArray(value)) {
            return arraySame(value, function(val) {
                return inferSqlType(val);
            }, 'CF_SQL_VARCHAR');
        }

        if (isNumeric(value)) {
            return 'CF_SQL_NUMERIC';
        }

        if (isDate(value)) {
            return 'CF_SQL_TIMESTAMP';
        }

        return 'CF_SQL_VARCHAR';
    }

    private string function normalizeSqlValue(required any value) {
        if (isArray(arguments.value)) {
            return arrayToList(arguments.value);
        }

        return arguments.value;
    }

    private boolean function isList(required any value) {
        if (isStruct(value) || isArray(value)) {
            return false;
        }
        
        var listAsArray = listToArray(arguments.value);
        return arrayLen(listAsArray) > 1;
    }

    private any function arraySame(required array args, required any closure, any default = '') {
        if (arrayLen(arguments.args) == 0) {
            return arguments.default;
        }

        var initial = closure(arguments.args[1]);

        var same = arrayEvery(arguments.args, function(arg) {
            return initial == closure(arg);
        });

        return same ? initial : default;
    }
}