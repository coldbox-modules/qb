component extends="tests.resources.querybuilder.AbstractQueryBuilderAggregateSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "common table expressions (i.e. CTEs)", function() {
                    it( "can create CTE from closure", function() {
                        testCase( function( builder ) {
                            builder
                                .with( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "can create CTE from QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var cte = getBuilder()
                                .select( "*" )
                                .from( "users" )
                                .join( "contacts", "users.id", "contacts.id" )
                                .where( "users.age", ">", 25 )
                            ;

                            builder
                                .with( "UsersCTE", cte )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "snapshots a builder passed to a common table expression", function() {
                        var cte = getBuilder().select( "id" ).from( "users" );
                        var builder = getBuilder().with( "UsersCTE", cte ).from( "UsersCTE" );

                        cte.where( "active", 1 );

                        expect( builder.toSQL() ).notToInclude( "active" );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can correctly bind parameters regardless of order", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                                .with( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "can create recursive CTE", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpressionWithRecursive() );
                    } );

                    it( "properly handles recursive CTEs with included columns", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive(
                                    "UsersCTE",
                                    function( q ) {
                                        q.select( [ "users.id AS usersId", "contacts.id AS contactsId" ] )
                                            .from( "users" )
                                            .join( "contacts", "users.id", "contacts.id" )
                                            .where( "users.age", ">", 25 )
                                        ;
                                    },
                                    [ "usersId", "contactsId" ]
                                )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpressionWithRecursiveWithColumns() );
                    } );

                    it( "can create multiple CTEs where the second CTE is not recursive", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                                .with( "OrderCTE", function( q ) {
                                    q.from( "orders" ).where( "created", ">", "2018-04-30" )
                                    ;
                                } )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpressionMultipleCTEsWithRecursive() );
                    } );

                    it( "can create bindings in the correct order", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                                .with( "OrderCTE", function( q ) {
                                    q.from( "orders" ).where( "created", ">", "2018-04-30" )
                                    ;
                                } )
                                .withRecursive( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                            ;
                        }, commonTableExpressionBindingOrder() );
                    } );

                    it( "can insert based off of a cte", function() {
                        testCase( function( builder ) {
                            return builder
                                .with( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                                .table( "oldUsers" )
                                .insertUsing(
                                    source = function( qb ) {
                                        qb.from( "UsersCTE" ).select( [ "fname", "lname", "username", "age" ] );
                                    },
                                    toSQL = true
                                );
                        }, cteInsertUsing() );
                    } );
                } );
            } );
        } );
    }

}
