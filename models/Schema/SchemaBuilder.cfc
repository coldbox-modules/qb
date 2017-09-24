component accessors="true" singleton {

    property name="grammar";
    property name="defaultStringLength" default="255";

    function init( grammar ) {
        variables.grammar = arguments.grammar;
        return this;
    }

    function create( table, callback, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.addCommand( "create" );
        blueprint.setCreating( true );
        blueprint.setTable( table );
        callback( blueprint );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    function drop( table, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.addCommand( "drop" );
        blueprint.setTable( table );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    function dropIfExists( table, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.addCommand( "drop" );
        blueprint.setTable( table );
        blueprint.setIfExists( true );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    function alter( table, callback, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.setTable( table );
        callback( blueprint );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    function rename( from, to, options = {}, execute = true ) {
        var blueprint = new Blueprint( this, getGrammar() );
        blueprint.setTable( from );
        blueprint.addCommand( "renameTable", { to = to } );
        if ( execute ) {
            blueprint.toSql().each( function( statement ) {
                getGrammar().runQuery( statement, [], options, "result" );
            } );
        }
        return blueprint;
    }

    function hasTable( name, options = {}, execute = true ) {
        var sql = getGrammar().compileTableExists( name );
        if ( execute ) {
            var q = getGrammar().runQuery( sql, [ name ], options, "query" );
            return q.RecordCount > 0;
        }
        return sql;
    }

    function hasColumn( table, column, options = {}, execute = true ) {
        var sql = getGrammar().compileColumnExists( table, column );
        if ( execute ) {
            var q = getGrammar().runQuery( sql, [ table, column ], options, "query" );
            return q.RecordCount > 0;
        }
        return sql;
    }

}
