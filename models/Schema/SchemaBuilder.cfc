component accessors="true" singleton {

    property name="grammar";
    property name="defaultStringLength" default="255";

    function init( grammar ) {
        variables.grammar = arguments.grammar;
        return this;
    }

    function create( table, callback, build = true, options = {} ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.setTable( table );
        callback( blueprint );
        if ( build ) {
            getGrammar().runQuery( blueprint.toSql(), {}, options, "result" );
        }
        return blueprint;
    }

}