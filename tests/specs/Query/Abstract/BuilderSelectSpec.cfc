component extends="testbox.system.BaseSpec" {
    function run() {
        describe( "select methods", function() {
            beforeEach( function() {
                variables.mockGrammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" );
                variables.query = new qb.models.Query.QueryBuilder( variables.mockGrammar );
            } );

            describe( "select()", function() {
                it ( "defaults to all columns", function() {
                    expect( query.getColumns() ).toBe( [ "*" ] );
                } );

                it( "can specify a single column from a query", function() {
                    query.select( "::some_column::" );
                    expect( query.getColumns() ).toBe( [ "::some_column::" ] );
                } );

                describe( "can specify multiple columns in a query", function() {
                    it( "using a list", function() {
                        query.select( "::some_column::, ::another_column::" );
                        expect( query.getColumns() ).toBe( [ "::some_column::", "::another_column::" ] );
                    } );

                    it( "trims a list before splitting it", function() {
                        query.select( "
                            ::some_column::, ::another_column::
                            ,::third_column::
                        " );
                        expect( query.getColumns() ).toBe( [ "::some_column::", "::another_column::", "::third_column::" ] );
                    } );

                    it( "using an array", function() {
                        query.select( [ "::some_column::", "::another_column::" ] );
                        expect( query.getColumns() ).toBe( [ "::some_column::", "::another_column::" ] );
                    } );
                } );
            } );

            describe( "addSelect()", function() {
                beforeEach( function() {
                    query.select( "::some_column::" );
                    expect( query.getColumns() ).toBe( [ "::some_column::" ] );
                } );

                it( "can add a single column to an existing query", function() {
                    query.addSelect( "::another_column::" );
                    expect( query.getColumns() ).toBe( [ "::some_column::", "::another_column::" ] );
                } );

                describe( "can add multiple columns to an existing query", function() {
                    it( "using a list", function() {
                        query.addSelect( "::another_column::, ::yet_another_column::" );
                        expect( query.getColumns() ).toBe( [ "::some_column::", "::another_column::", "::yet_another_column::" ] );
                    } );

                    it( "using an array", function() {
                        query.addSelect( [ "::another_column::", "::yet_another_column::" ] );
                        expect( query.getColumns() ).toBe( [ "::some_column::", "::another_column::", "::yet_another_column::" ] );
                    } );
                } );
            } );

            describe( "distinct()", function() {
                it( "sets the distinct flag", function() {
                    expect( query.getDistinct() ).toBe( false,
                        "Queries are not distinct by default" );

                    query.distinct();

                    expect( query.getDistinct() ).toBe( true,
                        "Distinct should be set to true" );
                } );
            } );
        } );
    }
}
