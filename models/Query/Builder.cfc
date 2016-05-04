component {

    property name='columns' type='array';
    property name='wheres' type='array';
    property name='from' type='string';
    property name='distinct' type='boolean' default='false';

    variables.operators = [
        '='
    ];

    variables.combinators = [
        'AND', 'OR'
    ];

    variables.bindings = {
        "where" = []
    };

    public Builder function init(required Quick.Query.Grammars.Grammar grammar) {
        variables.grammar = arguments.grammar;

        setDefaultValues();

        return this;
    }


    private void function setDefaultValues() {
        variables.from = '';
        variables.columns = ['*'];
        variables.wheres = [];
        variables.distinct = false;
    }

    // API

    public Builder function from(required string from) {
        variables.from = arguments.from;
        return this;
    }

    // select methods

    public Builder function select(required any columns) {
        variables.columns = normalizeToArray(argumentCollection = arguments);
        return this;
    }

    public Builder function addSelect(required any columns) {
        arrayAppend(variables.columns, normalizeToArray(argumentCollection = arguments), true);
        return this;
    }

    public Builder function distinct() {
        variables.distinct = true;

        return this;
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

        arrayAppend(variables.bindings.where, arguments.value);

        return this;
    }

    // Accessors

    public string function getFrom() {
        return variables.from;
    }

    public array function getColumns() {
        return variables.columns;
    }

    public array function getWheres() {
        return variables.wheres;
    }

    public struct function getBindings() {
        return variables.bindings;
    }

    public boolean function getDistinct() {
        return variables.distinct;
    }

    // Collaborators

    public string function toSQL() {
        return variables.grammar.compileSelect(this);
    }

    public query function get() {
        return queryExecute(this.toSQL(), this.getBindings().where);
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
        return structCount(arguments.args) > 1;
    }

    private array function normalizeVariadicArgumentsToArray(required struct args) {
        return arrayMap(structKeyArray(arguments.args), function(arg) {
            return args[arg];
        });
    }

    private array function normalizeListArgumentsToArray(required string list) {
        return arrayMap(listToArray(list, ','), function(column) {
            return trim(column);
        });
    }

    private boolean function isInvalidOperator(required string operator) {
        return ! arrayContains(variables.operators, arguments.operator);
    }

    private boolean function isInvalidCombinator(required string combinator) {
        return ! arrayContainsNoCase(variables.combinators, arguments.combinator);
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
        }
    }
}