component extends="tests.resources.querybuilder.AbstractQueryBuilderCteSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "limits", function() {
                    it( "can limit the record set returned", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).limit( 3 );
                        }, limit() );
                    } );

                    it( "has an alias of ""take""", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).take( 1 );
                        }, take() );
                    } );
                } );

                describe( "offsets", function() {
                    it( "can offset the record set returned", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).offset( 3 );
                        }, this.offset() );
                    } );

                    it( "can offset with an order by", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy( "id" )
                                .offset( 3 );
                        }, offsetWithOrderBy() );
                    } );
                } );

                describe( "forPage", function() {
                    it( "combines limits and offsets for easy pagination", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).forPage( 3, 15 );
                        }, forPage() );
                    } );

                    it( "returns zeros values less than zero", function() {
                        testCase( function( builder ) {
                            builder
                                .setShouldMaxRowsOverrideToAll( function() {
                                    return false;
                                } )
                                .from( "users" )
                                .forPage( 0, -2 );
                        }, forPageWithLessThanZeroValues() );
                    } );
                } );

                describe( "reset", function() {
                    it( "can reset the query to default values", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .where( "active", 1 )
                                .orderByAsc( "createdDate" )
                                .forPage( 3, 15 )
                                .reset()
                                .from( "otherTable" );
                        }, reset() );
                    } );
                } );
            } );
        } );
    }

}
