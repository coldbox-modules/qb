component {

    property name='columns' type='array';
    property name='wheres' type='array';
    property name='from' type='string';

    variables.operators = [
        '='
    ];

    variables.bindings = {
        "where" = []
    };

    public Builder function init(required Quick.Query.Grammars.Grammar grammar) {
        variables.grammar = arguments.grammar;

        variables._ = new modules.UnderscoreCF.Underscore();

        setDefaultValues();

        return this;
    }


    private void function setDefaultValues() {
        variables.from = '';
        variables.columns = ['*'];
        variables.wheres = [];
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

    // where methods

    public Builder function where(column, operator, value, combinator) {
        var argCount = argumentCount(arguments);

        arguments.combinator = IsNull(arguments.combinator) ? 'and' : arguments.combinator;

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

    // Collaborators

    public string function toSQL() {
        return variables.grammar.compileSelect(this);
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
        return _.size(arguments.args) > 1;
    }

    private array function normalizeVariadicArgumentsToArray(required struct args) {
        return _.toArray(arguments.args);
    }

    private array function normalizeListArgumentsToArray(required string list) {
        return _.map(_.split(list, ','), function(column) {
            return trim(column);
        });
    }

    private boolean function isInvalidOperator(required string operator) {
        return ! arrayContains(variables.operators, arguments.operator);
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