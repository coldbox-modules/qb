component extends="tests.resources.querybuilder.AbstractQueryBuilderUpdateSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "delete statements", function() {
                it( "can delete an entire table", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).delete( toSql = true );
                    }, deleteAll() );
                } );

                it( "can delete a specific id quickly", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).delete( id = 1, toSql = true );
                    }, deleteById() );
                } );

                it( "can be constrained with a where statement", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .where( "email", "foo" )
                            .delete( toSql = true );
                    }, deleteWhere() );
                } );

                it( "can delete with returning", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .where( "active", 0 )
                            .returning( "id" )
                            .delete( toSql = true );
                    }, deleteReturning() );
                } );

                it( "returning ignores table qualifiers in delete statements", function() {
                    testCase( function( builder ) {
                        return builder
                            .setColumnFormatter( function( column ) {
                                return "tablePrefix." & column;
                            } )
                            .from( "users" )
                            .where( "active", 0 )
                            .returning( "id" )
                            .delete( toSql = true );
                    }, deleteReturningIgnoresTableQualifiers() );
                } );

                it( "can handle delete statements with joins", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .join( "warnings", "users.id", "warnings.userId" )
                            .delete( toSql = true );
                    }, deleteWithJoins() );
                } );

                it( "can handle delete statements with aliased joins", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users u" )
                            .join( "warnings w", "u.id", "w.userId" )
                            .delete( toSql = true );
                    }, deleteWithJoinsAndAliases() );
                } );
            } );
        } );
    }

}
