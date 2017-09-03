component accessors="true" singleton {

    property name="grammar";
    property name="defaultStringLength" default="255";

    function init( grammar ) {
        variables.grammar = arguments.grammar;
        return this;
    }

    function create( table, callback, build = true, options = {} ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.addCommand( "create" );
        blueprint.setTable( table );
        callback( blueprint );
        if ( build ) {
            blueprint.getSql().each( function( statement ) {
                getGrammar().runQuery( statement, {}, options, "result" );
            } );
        }
        return blueprint;
    }

}
