/** Opt-in real PostgreSQL regression; every object is transactionally rolled back. */
component extends="testbox.system.BaseSpec" {

    function run() {
        var enabled = createObject( "java", "java.lang.System" ).getenv( "QB_POSTGRES_RESET_TEST" ) ?: "false";
        describe( "PostgreSQL reset routines", function() {
            it(
                title = "resets tables and overloaded routines while preserving extensions and other schemas",
                skip = enabled != "true",
                body = function() {
                    transaction {
                        try {
                            var target = "qb_reset_" & lCase( left( replace( createUUID(), "-", "", "all" ), 12 ) );
                            var other = target & "_other";
                            queryExecute( "CREATE SCHEMA " & target );
                            queryExecute( "CREATE SCHEMA " & other );
                            queryExecute( "CREATE EXTENSION pgcrypto WITH SCHEMA " & target );
                            queryExecute( "CREATE TABLE " & target & ".records (id integer)" );
                            queryExecute( "CREATE FUNCTION " & target & ".echo(input integer) RETURNS integer LANGUAGE sql AS 'SELECT input'" );
                            queryExecute( "CREATE FUNCTION " & target & ".echo(input text) RETURNS text LANGUAGE sql AS 'SELECT input'" );
                            queryExecute( "CREATE FUNCTION " & target & ".""Mixed Case""() RETURNS integer LANGUAGE sql AS 'SELECT 1'" );
                            queryExecute( "CREATE FUNCTION " & target & ".rows() RETURNS SETOF " & target & ".records LANGUAGE sql AS 'SELECT * FROM " & target & ".records'" );
                            queryExecute( "CREATE PROCEDURE " & target & ".noop() LANGUAGE plpgsql AS 'BEGIN NULL; END'" );
                            queryExecute( "CREATE FUNCTION " & other & ".keep() RETURNS integer LANGUAGE sql AS 'SELECT 1'" );
                            queryExecute( "CREATE FUNCTION " & target & ".dated(input timestamp with time zone) RETURNS timestamp with time zone LANGUAGE sql AS 'SELECT input'" );
                            var extensionsBefore = extensionRoutineCount( target );
                            expect( extensionsBefore ).toBeGT( 0 );
                            var schema = new qb.models.Schema.SchemaBuilder(
                                grammar = new qb.models.Grammars.PostgresGrammar()
                            );
                            schema.dropAllObjects( schema = target );
                            expect(
                                queryExecute(
                                    "SELECT tablename FROM pg_tables WHERE schemaname=:name",
                                    { name: target }
                                ).recordCount
                            ).toBe( 0 );
                            expect( applicationRoutineCount( target ) ).toBe( 0 );
                            expect( applicationRoutineCount( other ) ).toBe( 1 );
                            expect( extensionRoutineCount( target ) ).toBe( extensionsBefore );
                            // Reapply the same migration definitions, then exercise a routine-only reset.
                            queryExecute( "CREATE FUNCTION " & target & ".echo(input integer) RETURNS integer LANGUAGE sql AS 'SELECT input'" );
                            schema.dropAllObjects( schema = target );
                            expect( applicationRoutineCount( target ) ).toBe( 0 );
                            expect( extensionRoutineCount( target ) ).toBe( extensionsBefore );
                        } finally {
                            transactionRollback();
                        }
                    }
                }
            );
        } );
    }
    private numeric function applicationRoutineCount( required string schema ) {
        return queryExecute(
            "SELECT count(*) AS n FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname=:name AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.classid=CAST('pg_proc' AS regclass) AND d.objid=p.oid AND d.refclassid=CAST('pg_extension' AS regclass) AND d.deptype='e')",
            { name: arguments.schema }
        ).n[ 1 ];
    }
    private numeric function extensionRoutineCount( required string schema ) {
        return queryExecute(
            "SELECT count(*) AS n FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_depend d ON d.classid=CAST('pg_proc' AS regclass) AND d.objid=p.oid AND d.refclassid=CAST('pg_extension' AS regclass) AND d.deptype='e' WHERE n.nspname=:name",
            { name: arguments.schema }
        ).n[ 1 ];
    }

}
