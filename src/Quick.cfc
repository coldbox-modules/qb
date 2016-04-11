component {

    property name='table' type='string';
    property name='columns' type='array';

    public Quick function init() {
        variables._ = new modules.UnderscoreCF.Underscore();
        variables.columns = ['*'];
        return this;
    }

    public Quick function from(required string table) {
        variables.table = arguments.table;
        return this;
    }

    public Quick function select(required any columns) {
        variables.columns = normalizeToArray(argumentCollection = arguments);
        return this;
    }

    public Quick function addSelect(required any columns) {
        arrayAppend(variables.columns, normalizeToArray(argumentCollection = arguments), true);
        return this;
    }

    public string function toSQL() {
        return "SELECT #ArrayToList(variables.columns, ',')# FROM #variables.table#";
    }

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
}