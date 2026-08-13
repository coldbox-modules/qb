component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Blueprint lifecycle", function() {
            it( "restores indexes when add-column compilation throws", function() {
                [
                    new qb.models.Grammars.BaseGrammar(),
                    new qb.models.Grammars.DerbyGrammar(),
                    new qb.models.Grammars.OracleGrammar()
                ].each( function( grammar ) {
                    var blueprint = newBlueprint( grammar );
                    blueprint.appendIndex( type = "basic", columns = [ "email" ], name = "idx_users_email" );

                    expect( function() {
                        grammar.compileAddColumn( blueprint, { column: {} } );
                    } ).toThrow();

                    expect( blueprint.getIndexes() ).toHaveLength( 1 );
                } );
            } );

            it( "renames TableIndex instances by name", function() {
                var blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );
                var oldConstraint = blueprint.createIndex(
                    type = "unique",
                    columns = [ "email" ],
                    name = "unq_users_email"
                );
                var newConstraint = blueprint.createIndex(
                    type = "unique",
                    columns = [ "email" ],
                    name = "unq_users_login"
                );

                blueprint.renameConstraint( oldConstraint, newConstraint );

                expectCommandTypes( blueprint, [ "renameConstraint" ] );
                expect( blueprint.getCommands()[ 1 ].getParameters() ).toBe( { from: "unq_users_email", to: "unq_users_login" } );
            } );

            it( "registers morph columns and indexes when altering a table", function() {
                var blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );
                blueprint.morphs( "taggable" );
                expectCommandTypes( blueprint, [ "addColumn", "addColumn", "addIndex" ] );

                blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );
                blueprint.nullableMorphs( "taggable" );
                expectCommandTypes( blueprint, [ "addColumn", "addColumn", "addIndex" ] );
            } );

            it( "registers timestamp shortcuts when altering a table", function() {
                var blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );
                blueprint.nullableTimestamps();
                expectCommandTypes( blueprint, [ "addColumn", "addColumn" ] );

                blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );
                blueprint.timestampsTz();
                expectCommandTypes( blueprint, [ "addColumn", "addColumn" ] );
            } );

            it( "registers soft-delete shortcuts when altering a table", function() {
                var blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );
                blueprint.softDeletes();
                expectCommandTypes( blueprint, [ "addColumn" ] );

                blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );
                blueprint.softDeletesTz();
                expectCommandTypes( blueprint, [ "addColumn" ] );
            } );
        } );
    }

    private function newBlueprint( required grammar ) {
        var schema = new qb.models.Schema.SchemaBuilder( arguments.grammar );
        var blueprint = new qb.models.Schema.Blueprint( schema, arguments.grammar );
        blueprint.setTable( "users" );
        return blueprint;
    }

    private void function expectCommandTypes( required blueprint, required array expectedTypes ) {
        expect( arguments.blueprint.getCommands().map( ( command ) => command.getType() ) ).toBe(
            arguments.expectedTypes
        );
    }

}
