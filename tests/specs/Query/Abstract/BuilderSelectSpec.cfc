component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "select methods", function() {
            beforeEach( function() {
                variables.mockGrammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
                variables.query = new qb.models.Query.QueryBuilder( variables.mockGrammar );
            } );

            describe( "select()", function() {
                it( "defaults to all columns", function() {
                    expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "*" ] );
                } );

                it( "can specify a single column from a query", function() {
                    query.select( "::some_column::" );
                    expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::" ] );
                } );

                describe( "can specify multiple columns in a query", function() {
                    it( "using a list", function() {
                        query.select( "::some_column::, ::another_column::" );
                        expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::", "::another_column::" ] );
                    } );

                    it( "trims a list before splitting it", function() {
                        query.select(
                            "
                            ::some_column::, ::another_column::
                            ,::third_column::
                        "
                        );
                        expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::", "::another_column::", "::third_column::" ] );
                    } );

                    it( "using an array", function() {
                        query.select( [ "::some_column::", "::another_column::" ] );
                        expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::", "::another_column::" ] );
                    } );
                } );

                describe( "duplicate output name validation", function() {
                    it( "is disabled by default", function() {
                        expect( function() {
                            query
                                .select( [ "equipment.id", "racks.id" ] )
                                .from( "equipment" )
                                .toSQL();
                        } ).notToThrow();
                    } );

                    it( "throws for duplicate qualified column names when enabled", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        validatingQuery.select( [ "equipment.id", "racks.id" ] ).from( "equipment" );

                        expect( function() {
                            validatingQuery.toSQL();
                        } ).toThrow( type = "DuplicateSelectColumn", regex = "output name \[id\]" );
                    } );

                    it( "compares output names case-insensitively", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        validatingQuery
                            .select( [ "equipment.id AS equipmentId", "racks.id AS EquipmentID" ] )
                            .from( "equipment" );

                        expect( function() {
                            validatingQuery.toSQL();
                        } ).toThrow( type = "DuplicateSelectColumn" );
                    } );

                    it( "normalizes quoted output names", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        validatingQuery
                            .select( [ "equipment.id AS `equipmentId`", "racks.id AS equipmentId" ] )
                            .from( "equipment" );

                        expect( function() {
                            validatingQuery.toSQL();
                        } ).toThrow( type = "DuplicateSelectColumn" );
                    } );

                    it( "allows unique aliases", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        expect( function() {
                            validatingQuery
                                .select( [ "equipment.id AS equipmentId", "racks.id AS rackId" ] )
                                .from( "equipment" )
                                .toSQL();
                        } ).notToThrow();
                    } );

                    it( "ignores wildcard selections whose output names are not known", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        expect( function() {
                            validatingQuery
                                .select( [ "equipment.*", "racks.*" ] )
                                .from( "equipment" )
                                .toSQL();
                        } ).notToThrow();
                    } );

                    it( "validates explicit aliases on raw expressions", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        validatingQuery.selectRaw( [ "COUNT(*) AS total", "SUM(amount) AS total" ] ).from( "equipment" );

                        expect( function() {
                            validatingQuery.toSQL();
                        } ).toThrow( type = "DuplicateSelectColumn" );
                    } );

                    it( "does not treat SQL AS operators as output aliases", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        expect( function() {
                            validatingQuery
                                .selectRaw( [ "CAST(id AS VARCHAR)", "CAST(name AS VARCHAR)" ] )
                                .from( "equipment" )
                                .toSQL();
                        } ).notToThrow();
                    } );

                    it( "validates typed column aliases", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        validatingQuery
                            .select( [ validatingQuery.jsonPath( "profile", [ "name" ], "name" ), "users.name" ] )
                            .from( "users" );

                        expect( function() {
                            validatingQuery.toSQL();
                        } ).toThrow( type = "DuplicateSelectColumn" );
                    } );

                    it( "does not infer output names for unaliased typed expressions", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = new qb.models.Grammars.MySQLGrammar( new qb.models.Query.QueryUtils() ),
                            validateDuplicateSelectColumns = true
                        );

                        expect( function() {
                            validatingQuery
                                .select( [
                                    validatingQuery.jsonPath( "profile", [ "name" ] ),
                                    validatingQuery.jsonPath( "metadata", [ "name" ] )
                                ] )
                                .from( "users" )
                                .toSQL();
                        } ).notToThrow();
                    } );

                    it( "propagates validation to new queries", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        var childQuery = validatingQuery
                            .newQuery()
                            .select( [ "equipment.id", "racks.id" ] )
                            .from( "equipment" );

                        expect( function() {
                            childQuery.toSQL();
                        } ).toThrow( type = "DuplicateSelectColumn" );
                    } );

                    it( "validates the final selection after a reselect", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );

                        expect( function() {
                            validatingQuery
                                .select( [ "equipment.id", "racks.id" ] )
                                .reselect( [ "equipment.id AS equipmentId", "racks.id AS rackId" ] )
                                .from( "equipment" )
                                .toSQL();
                        } ).notToThrow();
                    } );

                    it( "does not validate columns excluded from aggregate output", function() {
                        var validatingQuery = new qb.models.Query.QueryBuilder(
                            grammar = variables.mockGrammar,
                            validateDuplicateSelectColumns = true
                        );
                        validatingQuery.select( [ "equipment.id", "racks.id" ] ).from( "equipment" );

                        expect( function() {
                            validatingQuery.count( toSQL = true );
                        } ).notToThrow();
                    } );
                } );
            } );

            describe( "addSelect()", function() {
                beforeEach( function() {
                    query.select( "::some_column::" );
                    expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::" ] );
                } );

                it( "can add a single column to an existing query", function() {
                    query.addSelect( "::another_column::" );
                    expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::", "::another_column::" ] );
                } );

                describe( "can add multiple columns to an existing query", function() {
                    it( "using a list", function() {
                        query.addSelect( "::another_column::, ::yet_another_column::" );
                        expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::", "::another_column::", "::yet_another_column::" ] );
                    } );

                    it( "using an array", function() {
                        query.addSelect( [ "::another_column::", "::yet_another_column::" ] );
                        expect( query.getColumns().map( ( c ) => c.value ) ).toBe( [ "::some_column::", "::another_column::", "::yet_another_column::" ] );
                    } );
                } );

                it( "validates duplicate output names across calls", function() {
                    var validatingQuery = new qb.models.Query.QueryBuilder(
                        grammar = variables.mockGrammar,
                        validateDuplicateSelectColumns = true
                    );
                    validatingQuery.select( "equipment.id" );
                    validatingQuery.addSelect( "racks.id" ).from( "equipment" );

                    expect( function() {
                        validatingQuery.toSQL();
                    } ).toThrow( type = "DuplicateSelectColumn" );
                } );

                it( "validates subselect aliases against selected columns", function() {
                    var validatingQuery = new qb.models.Query.QueryBuilder(
                        grammar = variables.mockGrammar,
                        validateDuplicateSelectColumns = true
                    );
                    validatingQuery.select( "users.id" );
                    validatingQuery
                        .subSelect( "id", function( subquery ) {
                            subquery.from( "contacts" ).select( "contacts.id" );
                        } )
                        .from( "users" );

                    expect( function() {
                        validatingQuery.toSQL();
                    } ).toThrow( type = "DuplicateSelectColumn" );
                } );
            } );

            describe( "distinct()", function() {
                it( "sets the distinct flag", function() {
                    expect( query.getDistinct() ).toBe( false, "Queries are not distinct by default" );

                    query.distinct();

                    expect( query.getDistinct() ).toBe( true, "Distinct should be set to true" );
                } );
            } );
        } );
    }

}
