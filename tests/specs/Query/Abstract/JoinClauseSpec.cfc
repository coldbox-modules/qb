component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "join clause", function() {
            beforeEach( function() {
                variables.query = prepareMock( new qb.models.Query.QueryBuilder() );
            } );
            describe( "initialization", function() {
                it( "requires a parentQuery, type, and a table", function() {
                    expect( function() {
                        new qb.models.Query.JoinClause();
                    } ).toThrow();
                    expect( function() {
                        new qb.models.Query.JoinClause( "inner" );
                    } ).toThrow();
                    expect( function() {
                        new qb.models.Query.JoinClause( "inner", "sometable" );
                    } ).toThrow();
                } );

                it( "validates the type is a valid sql join type", function() {
                    expect( function() {
                        new qb.models.Query.JoinClause( query, "gibberish", "sometable" );
                    } ).toThrow();
                    expect( function() {
                        new qb.models.Query.JoinClause( query, "left typo", "sometable" );
                    } ).toThrow();
                    expect( function() {
                        new qb.models.Query.JoinClause( query, "left", "sometable" );
                    } ).notToThrow();
                    expect( function() {
                        new qb.models.Query.JoinClause( query, "left outer", "sometable" );
                    } ).notToThrow();
                } );
            } );

            describe( "adding join conditions", function() {
                beforeEach( function() {
                    variables.join = new qb.models.Query.JoinClause( query, "inner", "second" );
                    getMockBox().prepareMock( join );
                    join.$property( propertyName = "utils", mock = new qb.models.Query.QueryUtils() );
                } );

                afterEach( function() {
                    structDelete( variables, "join" );
                } );

                describe( "on()", function() {
                    it( "can add a single join condition", function() {
                        join.on(
                            "first.id",
                            "=",
                            "second.first_id",
                            "and",
                            false
                        );

                        var clauses = join.getWheres();
                        expect( arrayLen( clauses ) ).toBe( 1, "Only one clause should exist in the join statement" );

                        var clause = clauses[ 1 ];
                        expect( clause.first ).toBe( "first.id", "First column should be [first.id]" );
                        expect( clause.operator ).toBe( "=", "Operator should be [=]" );
                        expect( clause.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                        expect( clause.combinator ).toBe( "and" );
                    } );

                    it( "defaults to ""and"" for the combinator and ""false"" for the where flag", function() {
                        join.on( "first.id", "=", "second.first_id" );

                        var clauses = join.getWheres();
                        expect( arrayLen( clauses ) ).toBe( 1, "Only one clause should exist in the join statement" );

                        var clause = clauses[ 1 ];
                        expect( clause.first ).toBe( "first.id", "First column should be [first.id]" );
                        expect( clause.operator ).toBe( "=", "Operator should be [=]" );
                        expect( clause.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                        expect( clause.combinator ).toBe( "and" );
                    } );

                    it( "can add multiple join clauses", function() {
                        join.on( "first.id", "=", "second.first_id" );
                        join.on( "first.locale", "=", "second.locale" );

                        var clauses = join.getWheres();
                        expect( arrayLen( clauses ) ).toBe( 2, "Two clauses should exist in the join statement" );

                        var clauseOne = clauses[ 1 ];
                        expect( clauseOne.first ).toBe( "first.id", "First column should be [first.id]" );
                        expect( clauseOne.operator ).toBe( "=", "Operator should be [=]" );
                        expect( clauseOne.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                        expect( clauseOne.combinator ).toBe( "and" );

                        var clauseTwo = clauses[ 2 ];
                        expect( clauseTwo.first ).toBe( "first.locale", "First column should be [first.locale]" );
                        expect( clauseTwo.operator ).toBe( "=", "Operator should be [=]" );
                        expect( clauseTwo.second ).toBe( "second.locale", "First column should be [second.locale]" );
                        expect( clauseTwo.combinator ).toBe( "and" );
                    } );

                    it( "validates that the operator is a valid sql operator", function() {
                        expect( function() {
                            join.on( "first.id", "==", "second.first_id" );
                        } ).toThrow();

                        expect( function() {
                            join.on( "first.id", "<>", "second.first_id" );
                        } ).notToThrow();
                    } );
                } );

                describe( "orOn()", function() {
                    it( "can add a single join condition", function() {
                        join.orOn( "first.another_value", ">=", "second.another_value" );

                        var clauses = join.getWheres();
                        expect( arrayLen( clauses ) ).toBe( 1, "Only one clause should exist in the join statement" );

                        var clause = clauses[ 1 ];
                        expect( clause.first ).toBe(
                            "first.another_value",
                            "First column should be [first.another_value]"
                        );
                        expect( clause.operator ).toBe( ">=", "Operator should be [>=]" );
                        expect( clause.second ).toBe(
                            "second.another_value",
                            "First column should be [second.another_value]"
                        );
                        expect( clause.combinator ).toBe( "or" );
                    } );
                } );

                describe( "where()", function() {
                    it( "adds a where statement to a join clause", function() {
                        join.where( "second.locale", "=", "en-US" );

                        var clauses = join.getWheres();
                        expect( arrayLen( clauses ) ).toBe( 1, "Only one clause should exist in the join statement" );

                        var clause = clauses[ 1 ];
                        expect( clause.column ).toBe( "second.locale", "First column should be [second.locale]" );
                        expect( clause.operator ).toBe( "=", "Operator should be [>=]" );
                        expect( clause.combinator ).toBe( "and" );
                    } );

                    it( "can use the shortcut where statement when the operator is equals (=)", function() {
                        join.where( "second.locale", "en-US" );

                        var clauses = join.getWheres();
                        expect( arrayLen( clauses ) ).toBe( 1, "Only one clause should exist in the join statement" );

                        var clause = clauses[ 1 ];
                        expect( clause.column ).toBe( "second.locale", "First column should be [second.locale]" );
                        expect( clause.operator ).toBe( "=", "Operator should be [>=]" );
                        expect( clause.combinator ).toBe( "and" );
                    } );

                    it( "adds the where value to the bindings", function() {
                        join.where( "second.locale", "=", "en-US" );

                        var bindings = join.getBindings();
                        expect( arrayLen( bindings ) ).toBe( 1, "Only one clause should exist in the join statement" );

                        var binding = bindings[ 1 ];
                        expect( binding.value ).toBe( "en-US" );
                        expect( binding.cfsqltype ).toBe( "varchar" );
                    } );
                } );

                describe( "newQuery()", function() {
                    it( "creates a new JoinClause instance", function() {
                        expect( join.newQuery() ).toBeInstanceOf( "qb.models.Query.JoinClause" );
                    } );

                    it( "binds the parent query", function() {
                        var newJoin = join.newQuery();
                        expect( newJoin.getParentQuery() ).toBe( join.getParentQuery() );
                    } );

                    it( "binds the type", function() {
                        var newJoin = join.newQuery();
                        expect( newJoin.getType() ).toBe( join.getType() );
                    } );

                    it( "binds the table", function() {
                        var newJoin = join.newQuery();
                        expect( newJoin.getTable() ).toBe( join.getTable() );
                    } );
                } );

                describe( "getMementoForComparison", function() {
                    beforeEach( function() {
                        variables.qb = new qb.models.Query.QueryBuilder( preventDuplicateJoins = true ).from(
                            new qb.models.Query.QueryBuilder( preventDuplicateJoins = true )
                                .select( "FK_otherTable" )
                                .from( "second_table" )
                        );

                        variables.otherQb = new qb.models.Query.QueryBuilder( preventDuplicateJoins = true ).from(
                            "third_table"
                        );

                        variables.joinOther = new qb.models.Query.JoinClause( qb, "inner", otherQb );
                    } );

                    afterEach( function() {
                        structDelete( variables, "qb" );
                        structDelete( variables, "otherQb" );
                    } );

                    it( "can produce a memento for a table with a QB object as a FROM", function() {
                        expect( qb.getMementoForComparison().from ).toBe(
                            "SELECT ""FK_otherTable"" FROM ""second_table"""
                        );
                    } );

                    it( "can produce a memento for a joinClause", function() {
                        expect( joinOther.getMementoForComparison().table ).toBe( "SELECT * FROM ""third_table""" );
                    } );
                } );

                describe( "preventDuplicateJoins", function() {
                    beforeEach( function() {
                        variables.qb = new qb.models.Query.QueryBuilder( preventDuplicateJoins = true );
                        variables.joinOther = new qb.models.Query.JoinClause( query, "inner", "second" );
                        getMockBox().prepareMock( joinOther );
                    } );

                    afterEach( function() {
                        structDelete( variables, "joinOther" );
                        structDelete( variables, "qb" );
                    } );

                    it( "can match two identical, simple joins", function() {
                        expect( variables.join.isEqualTo( variables.joinOther ) ).toBeTrue();
                    } );

                    it( "can tell that an inner join does not match a left join", function() {
                        variables.joinOther.setType( "left" );
                        expect( variables.join.isEqualTo( variables.joinOther ) ).toBeFalse();
                    } );

                    it( "can tell that the same kind of join on two different tables do not match", function() {
                        variables.joinOther.setTable( "third" );
                        expect( variables.join.isEqualTo( variables.joinOther ) ).toBeFalse();
                    } );

                    it( "can tell that two joins on the same table with different conditions do not match", function() {
                        join.on( "first.id", "=", "second.first_id" );
                        joinOther.on( "first.locale", "=", "second.locale" );
                        expect( variables.join.isEqualTo( variables.joinOther ) ).toBeFalse();
                    } );

                    it( "will prevent an identical join from being added when preventDuplicateJoins is true", function() {
                        variables.qb.join( variables.join );
                        variables.qb.join( variables.joinOther );
                        expect( variables.qb.getJoins().len() ).toBe( 1 );
                    } );

                    it( "will prevent an identical join from being added using the closure syntax when preventDuplicateJoins is true", function() {
                        variables.qb.join( "secondTable", function( j ) {
                            j.on( "secondTable.id", "firstTable.secondId" );
                        } );
                        variables.qb.join( "secondTable", function( j ) {
                            j.on( "secondTable.id", "firstTable.secondId" );
                        } );
                        expect( variables.qb.getJoins().len() ).toBe( 1 );
                    } );

                    it( "will allow an identical join from being added when preventDuplicateJoins is false", function() {
                        variables.qb.setPreventDuplicateJoins( false );
                        variables.qb.join( variables.join );
                        variables.qb.join( variables.joinOther );
                        expect( variables.qb.getJoins().len() ).toBe( 2 );
                    } );
                } );
            } );
        } );
    }

}
