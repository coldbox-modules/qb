component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "grammar returning-row capabilities", function() {
            it( "defaults insert and update support to false", function() {
                var grammar = new qb.models.Grammars.BaseGrammar();

                expect( grammar.supportsReturningRowsOnInsert() ).toBeFalse();
                expect( grammar.supportsReturningRowsOnUpdate() ).toBeFalse();
            } );

            it( "reports insert and update support for returning-row grammars", function() {
                var grammars = [
                    new qb.models.Grammars.PostgresGrammar(),
                    new qb.models.Grammars.SQLiteGrammar(),
                    new qb.models.Grammars.SqlServerGrammar()
                ];

                for ( var grammar in grammars ) {
                    expect( grammar.supportsReturningRowsOnInsert() ).toBeTrue();
                    expect( grammar.supportsReturningRowsOnUpdate() ).toBeTrue();
                }
            } );

            it( "leaves other concrete grammars on the safe defaults", function() {
                var grammars = [
                    new qb.models.Grammars.DerbyGrammar(),
                    new qb.models.Grammars.MySQLGrammar(),
                    new qb.models.Grammars.OracleGrammar()
                ];

                for ( var grammar in grammars ) {
                    expect( grammar.supportsReturningRowsOnInsert() ).toBeFalse();
                    expect( grammar.supportsReturningRowsOnUpdate() ).toBeFalse();
                }
            } );
        } );
    }

}
