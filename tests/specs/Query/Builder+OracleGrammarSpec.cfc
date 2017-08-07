import qb.models.Query.QueryBuilder;

component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "limits", function() {
            it( "can limit the record set returned", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).limit( 3 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" <= 3"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );

            it( "has an alias of ""take""", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).take( 1 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" <= 1"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );

        describe( "offsets", function() {
            it( "can offset the record set returned", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).offset( 3 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" > 3"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );

        describe( "forPage", function() {
            it( "combines limits and offsets for easy pagination", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).forPage( 3, 15 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" > 30 AND ""QB_RN"" <= 45"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );

            it( "returns zeros values less than zero", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).forPage( 0, -2 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" > 0 AND ""QB_RN"" <= 0"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );

        describe( "wrapping values", function() {
            it( "it converts values to uppercase when wrapping them", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).forPage( 0, -2 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" > 0 AND ""QB_RN"" <= 0"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );
    }


    private QueryBuilder function getBuilder() {
        variables.grammar = getMockBox()
            .createMock( "qb.models.Grammars.OracleGrammar" );
        var queryUtils = getMockBox()
            .createMock( "qb.models.Query.QueryUtils" );
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" )
            .init( grammar, queryUtils );
        return builder;
    }

    private array function getTestBindings( required QueryBuilder builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}