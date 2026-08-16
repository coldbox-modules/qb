component extends="tests.resources.querybuilder.AbstractQueryBuilderGroupingSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "unions", function() {
                    it( "can union multiple statements using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 )
                                    ;
                                } )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 3 )
                                    ;
                                } )
                            ;
                        }, union() );
                    } );

                    it( "can union multiple statements using a QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var union2 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 2 );
                            var union3 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 3 );

                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( union2 )
                                .union( union3 )
                            ;
                        }, union() );
                    } );

                    it( "union can contain order by on main query only", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 )
                                    ;
                                } )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 3 )
                                    ;
                                } )
                                .orderBy( "name" )
                            ;
                        }, unionOrderBy() );
                    } );

                    it( "union query cannot contain orderBy", function() {
                        var builder = getBuilder();

                        builder
                            .select( "name" )
                            .from( "users" )
                            .where( "id", 1 )
                            .union( function( q ) {
                                q.select( "name" )
                                    .from( "users" )
                                    .where( "id", 2 )
                                    .orderBy( "name" )
                                ;
                            } )
                            .union( function( q ) {
                                q.select( "name" )
                                    .from( "users" )
                                    .where( "id", 3 )
                                ;
                            } )
                            .orderBy( "name" )
                        ;


                        try {
                            var statements = builder.toSql();
                        } catch ( any e ) {
                            // Darn ACF nests the exception message. ðŸ˜ 
                            if ( e.message == "An exception occurred while calling the function map." ) {
                                expect( e.detail ).toBe( "The ORDER BY clause is not allowed in a UNION statement." );
                            } else {
                                expect( e.message ).toBe( "The ORDER BY clause is not allowed in a UNION statement." );
                            }
                            return;
                        }
                        fail( "Should have caught an exception, but didn't." );
                    } );

                    it( "can union all multiple statements using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .unionAll( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 );
                                } )
                                .unionAll( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 3 );
                                } );
                        }, unionAll() );
                    } );

                    it( "can union all multiple statements using a QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var union2 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 2 );
                            var union3 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 3 );

                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .unionAll( union2 )
                                .unionAll( union3 )
                            ;
                        }, unionAll() );
                    } );

                    it( "snapshots a builder passed to a union", function() {
                        var unionQuery = getBuilder().select( "name" ).from( "archived_users" );
                        var builder = getBuilder()
                            .select( "name" )
                            .from( "users" )
                            .unionAll( unionQuery );

                        unionQuery.where( "active", 1 );

                        expect( builder.toSQL() ).notToInclude( "active" );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "orders union bindings before outer order bindings", function() {
                        var builder = getBuilder()
                            .select( "name" )
                            .from( "users" )
                            .where( "status", "current" )
                            .union( function( unionQuery ) {
                                unionQuery
                                    .select( "name" )
                                    .from( "archived_users" )
                                    .where( "status", "archived" );
                            } )
                            .orderByRaw( "CASE WHEN name = ? THEN 0 ELSE 1 END", [ "preferred" ] );

                        expect( getTestBindings( builder ) ).toBe( [ "current", "archived", "preferred" ] );
                    } );

                    it( "retains root select bindings when aggregating a union", function() {
                        var builder = getBuilder()
                            .selectRaw( "? AS name", [ "current" ] )
                            .from( "users" )
                            .union( function( unionQuery ) {
                                unionQuery.selectRaw( "? AS name", [ "archived" ] ).from( "archived_users" );
                            } );

                        expect( function() {
                            builder.count( toSQL = true, showBindings = "inline" );
                        } ).notToThrow();
                    } );

                    it( "can run an aggregate query like count on a union query", function() {
                        testCase( function( builder ) {
                            return builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 );
                                } )
                                .count( toSQL = true );
                        }, unionCount() );
                    } );
                } );
            } );
        } );
    }

}
