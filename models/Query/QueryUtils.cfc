component displayname='QueryUtils' {
    public struct function extractBinding(required any value) {
        var binding = {};

        if (isStruct(arguments.value)) {
            binding = arguments.value;
            arguments.value = arguments.value.value;
        }

        if (! structKeyExists(binding, 'value')) {
            binding.value = arguments.value;
        }

        if (! structKeyExists(binding, 'cfsqltype')) {
            binding.cfsqltype = inferSqlType(binding.value);
        }

        return binding;
    }

    public string function inferSqlType(required any value) {
        if (isNumeric(value)) {
            return 'CF_SQL_NUMERIC';
        }

        if (isDate(value)) {
            return 'CF_SQL_TIMESTAMP';
        }

        return 'CF_SQL_VARCHAR';
    }
}