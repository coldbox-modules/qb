component extends="tests.resources.querybuilder.AbstractQueryBuilderUnionSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "aggregates", function() {
                    it( "exists", () => {
                        testCase( function( builder ) {
                            return builder
                                .from( "users" )
                                .where( "id", 1 )
                                .exists( toSql = true )
                        }, aggregateExists() );
                    } );
                } );
            } );
        } );
    }

}
