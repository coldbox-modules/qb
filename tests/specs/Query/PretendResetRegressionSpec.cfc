component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "pretend reset regression", function() {
            it( "keeps pretend mode enabled when resetting the same builder", function() {
                var builder = new qb.models.Query.QueryBuilder().pretend();

                builder.reset();

                expect( builder.isPretending() ).toBeTrue();
            } );
        } );
    }

}
