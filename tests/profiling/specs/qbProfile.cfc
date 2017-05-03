component extends="profiling.resources.Profiler" {

    function run() {
        describe( "qb profiling", function() {
            it( "simple query", function() {
                // var baseline = getAverageExecutionTime( function() {
                //     queryExecute( "SELECT * FROM entries", {}, {} );
                // }, 10 );

                expect( function() {
                    newMySQLBuilder()
                        .from( "entries" )
                        .get();
                } ).toAverageLessThan( ms = 50, iterations = 10 );
            } );

            it( "selecting columns", function() {
                // var baseline = getAverageExecutionTime( function() {
                //     queryExecute( "SELECT title, entryBody FROM entries", {}, {} );
                // }, 10 );

                expect( function() {
                    newMySQLBuilder()
                        .select( [ "title", "entryBody" ] )
                        .from( "entries" )
                        .get();
                } ).toAverageLessThan( ms = 50, iterations = 10 );
            } );

            it( "simple where", function() {
                // var baseline = getAverageExecutionTime( function() {
                //     queryExecute(
                //         "SELECT * FROM entries WHERE entry_id = ?",
                //         [ "402881882814615e01282b14964d0016" ],
                //         {}
                //     );
                // }, 10 );

                expect( function() {
                    newMySQLBuilder()
                        .from( "entries" )
                        .where( "entry_id", "402881882814615e01282b14964d0016" )
                        .get();
                } ).toAverageLessThan( ms = 50, iterations = 10 );
            } );

            it( "simple join", function() {
                var baseline = getAverageExecutionTime( function() {
                    queryExecute(
                        "
                            SELECT
                                e.entry_id,
                                e.title,
                                e.entryBody,
                                e.postedDate
                            FROM entries e
                            JOIN entry_categories ec
                            ON e.entry_id = ec.FKentry_id
                            JOIN categories c
                            ON c.category_id = ec.FKcategory_id
                            WHERE c.category = ?
                        ",
                        [ "Presentations" ],
                        {}
                    );
                }, 10 );

                expect( function() {
                    newMySQLBuilder()
                        .select( [
                            "entry_id",
                            "title",
                            "entryBody",
                            "postedDate"
                        ] )
                        .from( "entries e" )
                        .join( "entry_categories ec", function( j ) {
                            j.on( "e.entry_id", "ec.FKentry_id" );
                        } )
                        .join( "categories c", function( j ) {
                            j.on( "c.category_id", "ec.FKcategory_id" );
                        } )
                        .where( "c.category", "Presentations" )
                        .get();
                } ).toAverageLessThan( ms = 50, iterations = 10 );
            } );
        } );
    }

}