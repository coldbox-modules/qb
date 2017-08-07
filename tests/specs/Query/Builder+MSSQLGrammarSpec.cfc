import qb.models.Query.QueryBuilder;

component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "MSSQL Grammar", function() {
            describe( "limits and offsets", function() {
                it( "correctly compiles limits", function() {
                    var builder = getBuilder();
                    builder.from( "users" ).orderBy( "id" ).limit( 1 );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" ORDER BY ""id"" ASC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY"
                    );
                } );

                it( "correctly compiles offsets", function() {
                    var builder = getBuilder();
                    builder.from( "users" ).orderBy( "id" ).offset( 1 );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" ORDER BY ""id"" ASC OFFSET 1 ROWS"
                    );
                } );

                it( "correctly compiles both limits and offsets", function() {
                    var builder = getBuilder();
                    builder.from( "users" ).orderBy( "id" ).limit( 1 ).offset( 1 );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" ORDER BY ""id"" ASC OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY"
                    );
                } );
            } );
        } );
    }

    private QueryBuilder function getBuilder() {
        var grammar = getMockBox()
            .createMock( "qb.models.Grammars.MSSQLGrammar" );
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