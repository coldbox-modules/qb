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

            it( "rejects invalid foreign-key actions", function() {
                var index = new qb.models.Schema.TableIndex();

                expect( function() {
                    index.onDelete( "CASCADE; DROP TABLE users" );
                } ).toThrow( type = "InvalidReferentialAction" );
                expect( function() {
                    index.setOnUpdateAction( "CUSTOM ACTION" );
                } ).toThrow( type = "InvalidReferentialAction" );

                expect( index.onDelete( " set null " ).getOnDeleteAction() ).toBe( "SET NULL" );
                expect( index.onUpdate( "cascade" ).getOnUpdateAction() ).toBe( "CASCADE" );
            } );

            it( "rejects unsupported named default constraints when declared", function() {
                var blueprint = newBlueprint( new qb.models.Grammars.BaseGrammar() );

                expect( function() {
                    blueprint.default( "status" );
                } ).toThrow( type = "UnsupportedOperation" );
            } );

            it( "does not mutate per-operation schema options", function() {
                var options = { "timeout": 5 };
                var originalOptions = duplicate( options );
                var schema = new qb.models.Schema.SchemaBuilder(
                    grammar = new qb.models.Grammars.BaseGrammar(),
                    defaultOptions = { "datasource": "main" }
                ).pretend();

                schema.create( "users", ( table ) => table.integer( "id" ), options );

                expect( options ).toBe( originalOptions );
            } );

            it( "does not retain PostgreSQL comment commands generated during compilation", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();
                var schema = new qb.models.Schema.SchemaBuilder( grammar );
                var blueprint = schema.create(
                    "users",
                    function( table ) {
                        table.string( "name" ).comment( "Display name" );
                    },
                    {},
                    false
                );

                var firstCompilation = blueprint.toSql();
                var secondCompilation = blueprint.toSql();

                expect( secondCompilation ).toBe( firstCompilation );
                expect( blueprint.getCommands() ).toHaveLength( 1 );
            } );

            it( "does not retain Oracle sequence and trigger commands generated during compilation", function() {
                var grammar = new qb.models.Grammars.OracleGrammar();
                var schema = new qb.models.Schema.SchemaBuilder( grammar );
                var blueprint = schema.create(
                    "users",
                    function( table ) {
                        table.increments( "id" );
                    },
                    {},
                    false
                );

                var firstCompilation = blueprint.toSql();
                var secondCompilation = blueprint.toSql();

                expect( secondCompilation ).toBe( firstCompilation );
                expect( blueprint.getCommands() ).toHaveLength( 1 );
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
