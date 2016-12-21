import qb.models.Query.Builder;

component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "limits", function() {
            it( "can limit the record set returned", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).limit( 3 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT * FROM ""USERS"") WHERE ROWNUM <= 3"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );

            it( "has an alias of ""take""", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).take( 1 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT * FROM ""USERS"") WHERE ROWNUM <= 1"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );

        describe( "offsets", function() {
            it( "can offset the record set returned", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).offset( 3 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT * FROM ""USERS"") WHERE ROWNUM > 3"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );

        describe( "forPage", function() {
            it( "combines limits and offsets for easy pagination", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).forPage( 3, 15 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT * FROM ""USERS"") WHERE ROWNUM > 30 AND ROWNUM <= 45"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );

            it( "returns zeros values less than zero", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).forPage( 0, -2 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT * FROM ""USERS"") WHERE ROWNUM > 0 AND ROWNUM <= 0"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );

        describe( "wrapping values", function() {
            it( "it converts values to uppercase when wrapping them", function() {
                var builder = getBuilder();
                builder.select( "*" ).from( "users" ).forPage( 0, -2 );
                expect( builder.toSql() ).toBeWithCase(
                    "SELECT * FROM (SELECT * FROM ""USERS"") WHERE ROWNUM > 0 AND ROWNUM <= 0"
                );
                expect( getTestBindings( builder ) ).toBe( [] );
            } );
        } );
    }


    private Builder function getBuilder( returningArrays = false ) {
        var grammar = getMockBox()
            .createMock( "qb.models.Query.Grammars.OracleGrammar" );
        var queryUtils = getMockBox()
            .createMock( "qb.models.Query.QueryUtils" );
        var builder = getMockBox().createMock( "qb.models.Query.Builder" )
            .init( grammar, queryUtils );
        builder.setReturningArrays( returningArrays );
        return builder;
    }

    private array function getTestBindings( required Builder builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}