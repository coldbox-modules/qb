component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "select methods", function() {
            beforeEach( function() {
                variables.mockGrammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" );
                variables.qb = new qb.models.Query.QueryBuilder( variables.mockGrammar );
            } );

            describe( "select()", function() {
                it( "defaults to all columns", function() {
                    expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "*" ] );
                } );

                it( "can specify a single column from a query", function() {
                    qb.select( "::some_column::" );
                    expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::" ] );
                } );

                describe( "can specify multiple columns in a query", function() {
                    it( "using a list", function() {
                        qb.select( "::some_column::, ::another_column::" );
                        expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::", "::another_column::" ] );
                    } );

                    it( "trims a list before splitting it", function() {
                        qb.select(
                            "
                            ::some_column::, ::another_column::
                            ,::third_column::
                        "
                        );
                        expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::", "::another_column::", "::third_column::" ] );
                    } );

                    it( "using an array", function() {
                        qb.select( [ "::some_column::", "::another_column::" ] );
                        expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::", "::another_column::" ] );
                    } );
                } );
            } );

            describe( "addSelect()", function() {
                beforeEach( function() {
                    qb.select( "::some_column::" );
                    expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::" ] );
                } );

                it( "can add a single column to an existing query", function() {
                    qb.addSelect( "::another_column::" );
                    expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::", "::another_column::" ] );
                } );

                describe( "can add multiple columns to an existing query", function() {
                    it( "using a list", function() {
                        qb.addSelect( "::another_column::, ::yet_another_column::" );
                        expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::", "::another_column::", "::yet_another_column::" ] );
                    } );

                    it( "using an array", function() {
                        qb.addSelect( [ "::another_column::", "::yet_another_column::" ] );
                        expect( qb.getColumns().map( qb.evaluateToString ) ).toBe( [ "::some_column::", "::another_column::", "::yet_another_column::" ] );
                    } );
                } );
            } );

            describe( "distinct()", function() {
                it( "sets the distinct flag", function() {
                    expect( qb.getDistinct() ).toBe( false, "Queries are not distinct by default" );

                    qb.distinct();

                    expect( qb.getDistinct() ).toBe( true, "Distinct should be set to true" );
                } );
            } );
        } );
    }

}
