component displayname='Builder' {

    property name='grammar' inject='Grammar@Quick';

    property name='distinct' type='boolean' default='false';
    property name='columns' type='array';
    property name='from' type='string';
    property name='joins' type='array';
    property name='wheres' type='array';

    variables.operators = [
        '=', '<', '>', '<=', '>=', '<>', '!=',
        'like', 'like binary', 'not like', 'between', 'ilike',
        '&', '|', '^', '<<', '>>',
        'rlike', 'regexp', 'not regexp',
        '~', '~*', '!~', '!~*', 'similar to',
        'not similar to',
    ];

    variables.combinators = [
        'AND', 'OR'
    ];

    variables.bindings = {
        'join' = [],
        'where' = []
    };

    public Builder function init() {
        setDefaultValues();

        return this;
    }

    private void function setDefaultValues() {
        variables.distinct = false;
        variables.columns = ['*'];
        variables.joins = [];
        variables.from = '';
        variables.wheres = [];
    }

    // API
    // select methods

    public Builder function distinct() {
        variables.distinct = true;

        return this;
    }

    public Builder function select(required any columns) {
        variables.columns = normalizeToArray(argumentCollection = arguments);
        return this;
    }

    public Builder function addSelect(required any columns) {
        arrayAppend(variables.columns, normalizeToArray(argumentCollection = arguments), true);
        return this;
    }

    // from methods

    public Builder function from(required string from) {
        variables.from = arguments.from;
        return this;
    }

    // join methods

    public Builder function join(
        required string table,
        any first,
        string operator,
        string second,
        string type = 'inner',
        any conditions
    ) {
        var join = new JoinClause(type = arguments.type, table = arguments.table);

        if (structKeyExists(arguments, 'first') && isClosure(arguments.first)) {
            arguments.conditions = arguments.first;
        }

        if (structKeyExists(arguments, 'conditions') && isClosure(arguments.conditions)) {
            conditions(join);
        }
        else {
            join.on(
                first = arguments.first,
                operator = arguments.operator,
                second = arguments.second,
                combinator = 'and'
            );
        }

        arrayAppend(variables.joins, join);
        arrayAppend(bindings.join, join.getBindings(), true);

        return this;
    }

    public Builder function leftJoin(
        required string table,
        string first,
        string operator,
        string second,
        any conditions
    ) {
        arguments.type = 'left';
        return join(argumentCollection = arguments);
    }

    public Builder function rightJoin(
        required string table,
        string first,
        string operator,
        string second,
        any conditions
    ) {
        arguments.type = 'right';
        return join(argumentCollection = arguments);
    }

    // where methods

    public Builder function where(column, operator, value, combinator) {
        var argCount = argumentCount(arguments);

        if (isNull(arguments.combinator)) {
            arguments.combinator = 'AND';
        }
        else if (isInvalidCombinator(arguments.combinator)) {
            throw(
                type = 'InvalidArgumentException',
                message = 'Illegal combinator'
            );
        }

        if (argCount == 2) {
            arguments.value = arguments.operator;
            arguments.operator = '=';
        }
        else if (isInvalidOperator(arguments.operator)) {
            throw(
                type = 'InvalidArgumentException',
                message = 'Illegal operator'
            );
        }

        arrayAppend(variables.wheres, {
            column = arguments.column,
            operator = arguments.operator,
            value = arguments.value,
            combinator = arguments.combinator
        });

        arrayAppend(bindings.where, { value = arguments.value });

        return this;
    }

    // Accessors

    public boolean function getDistinct() {
        return distinct;
    }

    public array function getColumns() {
        return columns;
    }

    public string function getFrom() {
        return from;
    }

    public array function getJoins() {
        return joins;
    }

    public array function getWheres() {
        return wheres;
    }

    public array function getBindings() {
        var bindingOrder = ['join', 'where'];

        var flatBindings = [];
        for (var key in bindingOrder) {
            if (structKeyExists(bindings, key)) {
                arrayAppend(flatBindings, bindings[key], true);
            }
        }

        return flatBindings;
    }

    public struct function getRawBindings() {
        return bindings;
    }


    // Collaborators

    public string function toSQL() {
        return grammar.compileSelect(this);
    }

    public query function get(struct options = {}) {
        return queryExecute(this.toSQL(), this.getBindings(), options);
    }

    // Unused(?)

    private array function normalizeToArray() {
        if (isVariadicFunction(args = arguments)) {
            return normalizeVariadicArgumentsToArray(args = arguments);
        }

        var arg = arguments[1];
        if (! isArray(arg)) {
            return normalizeListArgumentsToArray(arg);
        }

        return arg;
    }

    private boolean function isVariadicFunction(required struct args) {
        return structCount(args) > 1;
    }

    private array function normalizeVariadicArgumentsToArray(required struct args) {
        return arrayMap(structKeyArray(args), function(arg) {
            return args[arg];
        });
    }

    private array function normalizeListArgumentsToArray(required string list) {
        return arrayMap(listToArray(list, ','), function(column) {
            return trim(column);
        });
    }

    private boolean function isInvalidOperator(required string operator) {
        return ! arrayContains(operators, operator);
    }

    private boolean function isInvalidCombinator(required string combinator) {
        return ! arrayContainsNoCase(combinators, combinator);
    }

    private function argumentCount(args) {
        var count = 0;
        for (var key in args) {
            if (! isNull(args[key]) && ! isEmpty(args[key])) {
                count++;
            }
        }
        return count;
    }

    public any function onMissingMethod(string missingMethodName, struct missingMethodArguments) {
        if (! arrayIsEmpty(REMatchNoCase('^where(.+)', missingMethodName))) {
            var args = { '1' = mid(missingMethodName, 6) };
            for (var key in missingMethodArguments) {
                args[key + 1] = missingMethodArguments[key];
            }
            where(argumentCollection = args);
            return;
        }

        throw("Method does not exist [#missingMethodName#]");
    }
}