component displayname='JoinClause' {

    property name="type" type="string";
    property name="table" type="string";
    property name="clauses" type="array";

    public JoinClause function init(required string type, required string table) {
        variables.type = arguments.type;
        variables.table = arguments.table;

        variables.clauses = [];

        return this;
    }

    public JoinClause function on(first, operator, second, combinator, where) {
        arrayAppend(variables.clauses, {
            first = arguments.first,
            operator = arguments.operator,
            second = arguments.second,
            combinator = arguments.combinator
        });

        return this;
    }

    public string function getType() {
        return variables.type;
    }

    public string function getTable() {
        return variables.table;
    }

    public array function getClauses() {
        return variables.clauses;
    }
}