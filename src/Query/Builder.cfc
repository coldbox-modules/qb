component {

    property name='columns' type='array';
    property name='wheres' type='array';
    property name='from' type='string';

    variables.operators = [
        '='
    ];

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

    public Builder function where() {
        var whereStruct = { column = '', operator = '', value = '' };
        var argCount = structCount(arguments);
        if (argCount == 2) {
            arguments[3] = arguments[2];
            arguments[2] = '=';
        }
        else if (isInvalidOperator(arguments[2])) {
            throw(
                type = 'InvalidArgumentException',
                message = 'Illegal operator'
            );
        }

        arrayAppend(variables.wheres, {
            column = arguments[1],
            operator = arguments[2],
            value = arguments[3]
        });

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