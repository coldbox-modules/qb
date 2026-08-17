component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "orderByRaw binding atomicity regression", function() {
            it( "does not retain bindings when the raw expression is invalid", function() {
                var builder = new qb.models.Query.QueryBuilder()
                    .from( "users" )
                    .orderByRaw( "CASE WHEN id = ? THEN 0 ELSE 1 END", [ 1 ] );
                var originalBindings = duplicate( builder.getBindings() );

                expect( function() {
                    builder.orderByRaw( { "invalid": true }, [ 2 ] );
                } ).toThrow();

                expect( builder.getBindings() ).toBe( originalBindings );
            } );
        } );
    }

}
