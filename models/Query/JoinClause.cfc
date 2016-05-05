component displayname='JoinClause' {

    property name="type" type="string";
    property name="table" type="string";
    property name="clauses" type="array";

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

    public JoinClause function init(required string type, required string table) {
        if (! arrayContainsNoCase(types, arguments.type)) {
            throw('[#type#] is not a valid sql join type');
        }

        variables.type = arguments.type;
        variables.table = arguments.table;

        clauses = [];

        return this;
    }

    public JoinClause function on(first, operator, second, combinator = 'and', where = false) {
        if (! arrayContainsNoCase(operators, arguments.operator)) {
            throw('[#operator#] is not a valid sql operator type');
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

    public JoinClause function orOn(first, operator, second) {
        arguments.combinator = 'or';
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
}