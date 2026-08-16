component extends="tests.resources.querybuilder.AbstractQueryBuilderSelectSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "sub-selects", function() {
                    it( "can execute sub-selects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect( "latestUpdatedDate", function( q ) {
                                    return q
                                        .from( "posts" )
                                        .selectRaw( "MAX(updated_date)" )
                                        .whereColumn( "posts.user_id", "users.id" );
                                } );
                        }, subSelect() );
                    } );

                    it( "can take a query object in a sub-selects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect(
                                    "latestUpdatedDate",
                                    builder
                                        .newQuery()
                                        .from( "posts" )
                                        .selectRaw( "MAX(updated_date)" )
                                        .whereColumn( "posts.user_id", "users.id" )
                                );
                        }, subSelectQueryObject() );
                    } );

                    it( "can execute sub-selects with bindings", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect( "latestUpdatedDate", function( q ) {
                                    return q
                                        .from( "posts" )
                                        .selectRaw( "MAX(updated_date)" )
                                        .where( "posts.user_id", 1 );
                                } );
                        }, subSelectWithBindings() );
                    } );

                    it( "snapshots a builder passed to a sub-select", function() {
                        var child = getBuilder();
                        child.from( "posts" ).selectRaw( "MAX(updated_date)" );
                        var builder = getBuilder();
                        builder.from( "users" ).subSelect( "latestUpdatedDate", child );

                        child.where( "posts.user_id", 1 );

                        expect( builder.toSQL() ).notToInclude( "user_id" );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );
                } );
            } );
        } );
    }

}
