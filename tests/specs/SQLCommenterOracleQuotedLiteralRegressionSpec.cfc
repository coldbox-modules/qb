component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SQL commenter Oracle quoted literal regression", function() {
            it( "appends comments when comment tokens occur inside alternative quoted literals", function() {
                var sqlCommenter = new qb.models.SQLCommenter.SQLCommenter();

                expect(
                    sqlCommenter.appendCommentsToSQL(
                        sql = "SELECT q'[isn't -- a comment /* still literal */]' AS marker FROM dual",
                        comments = { "framework": "qb" }
                    )
                ).toBeWithCase(
                    "SELECT q'[isn't -- a comment /* still literal */]' AS marker FROM dual /*framework='qb'*/"
                );
            } );
        } );
    }

}
