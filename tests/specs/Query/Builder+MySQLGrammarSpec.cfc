import qb.models.Query.Builder;

component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "MySQL Grammar", function() {
            it( "correctly wraps values for MySQL", function() {
                var builder = getBuilder();
                builder.select( "name" ).from( "users" );
                expect( builder.toSql() ).toBe( "SELECT `name` FROM `users`" );
            } );
        } );
    }

    private Builder function getBuilder( returningArrays = false ) {
        var grammar = getMockBox()
            .createMock( "qb.models.Query.Grammars.MySQLGrammar" );
        var queryUtils = getMockBox()
            .createMock( "qb.models.Query.QueryUtils" );
        var builder = getMockBox().createMock( "qb.models.Query.Builder" )
            .init( grammar, queryUtils );
        builder.setReturningArrays( returningArrays );
        builder.setReturnFormat( "" );
        return builder;
    }

    private array function getTestBindings( required Builder builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}