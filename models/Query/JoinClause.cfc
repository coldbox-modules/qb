component displayname='JoinClause' {

    property name='utils' inject='QueryUtils@Quick';

    property name='type' type='string';
    property name='table' type='string';
    property name='clauses' type='array';
    property name='bindings' type='array';

    variables.operators = [
        '=', '<', '>', '<=', '>=', '<>', '!=',
        'like', 'like binary', 'not like', 'between', 'ilike',
        '&', '|', '^', '<<', '>>',
        'rlike', 'regexp', 'not regexp',
        '~', '~*', '!~', '!~*', 'similar to',
        'not similar to',
    ];

    variables.types = [
        'inner', 'full', 'cross',
        'left', 'left outer', 'right', 'right outer'
    ];

    public JoinClause function init(
        required string type,
        required string table
    ) {
        if (! arrayContainsNoCase(types, arguments.type)) {
            throw('[#type#] is not a valid sql join type');
        }

        variables.type = arguments.type;
        variables.table = arguments.table;

        variables.clauses = [];
        variables.bindings = [];

        return this;
    }

    public JoinClause function on(first, operator, second, combinator = 'and', where = false) {
        // If we only receive the first two arguments, this is the shortcut where statement
        if (! structKeyExists(arguments, 'second')) {
            arguments.second = arguments.operator;
            arguments.operator = '=';
        }

        if (! arrayContainsNoCase(operators, arguments.operator)) {
            throw('[#operator#] is not a valid sql operator type');
        }

        if (arguments.where) {
            var binding = utils.extractBinding(arguments.second);
            arrayAppend(bindings, binding);
            arguments.second = '?';
        }

        arrayAppend(clauses, {
            first = arguments.first,
            operator = arguments.operator,
            second = arguments.second,
            combinator = arguments.combinator,
            where = arguments.where
        });

        return this;
    }

    public JoinClause function orOn(first, operator, second, where = false) {
        arguments.combinator = 'or';
        return on(argumentCollection = arguments);
    }

    public JoinClause function where(first, operator, second, combinator) {
        arguments.where = true;
        return on(argumentCollection = arguments);
    }

    public string function getType() {
        return type;
    }

    public string function getTable() {
        return table;
    }

    public array function getClauses() {
        return clauses;
    }

    public array function getBindings() {
        return bindings;
    }

    private struct function extractBindings(required any value) {
        var binding = {};

        if (isStruct(arguments.value)) {
            binding = arguments.value;
            arguments.value = arguments.value.value;
        }

        if (! structKeyExists(binding, 'value')) {
            binding.value = arguments.value;
        }

        return binding;
    }
}