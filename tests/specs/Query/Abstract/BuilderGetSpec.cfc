component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "get methods", function() {
            beforeEach( function() {
                variables.qb = new qb.models.Query.QueryBuilder();
                getMockBox().prepareMock( qb );

                var utils = new qb.models.Query.QueryUtils();
                qb.$property( propertyName = "utils", mock = utils );

                var mockWirebox = getMockBox().createStub();
                var mockJoinClause = getMockBox().prepareMock( new qb.models.Query.JoinClause( qb, "inner", "second" ) );
                mockJoinClause.$property( propertyName = "utils", mock = utils );
                mockWirebox
                    .$( "getInstance" )
                    .$args(
                        name = "JoinClause@Quick",
                        initArguments = { parentQuery: qb, type: "inner", table: "second" }
                    )
                    .$results( mockJoinClause );
                qb.$property( propertyName = "wirebox", mock = mockWirebox );
            } );

            it( "retreives bindings in a flat array", function() {
                qb.join( "second", function( join ) {
                        join.where( "second.locale", "=", "en-US" );
                    } )
                    .where( "first.quantity", ">=", 10 );

                var bindings = qb.getBindings();
                expect( bindings ).toBeArray();
                expect( arrayLen( bindings ) ).toBe( 2, "2 bindings should exist" );
                var binding = bindings[ 1 ];
                expect( binding.value ).toBe( "en-US" );
                expect( binding.cfsqltype ).toBe( "cf_sql_varchar" );
                var binding = bindings[ 2 ];
                expect( binding.value ).toBe( 10 );
                expect( binding.cfsqltype ).toBe( "CF_SQL_INTEGER" );
            } );

            it( "retreives a map of bindings", function() {
                qb.join( "second", function( join ) {
                        join.where( "second.locale", "=", "en-US" );
                    } )
                    .where( "first.quantity", ">=", "10" );

                var bindings = qb.getRawBindings();

                expect( bindings ).toBeStruct();
            } );
        } );
    }

}
