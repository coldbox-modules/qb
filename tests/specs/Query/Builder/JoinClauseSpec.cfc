component extends="testbox.system.BaseSpec" {
    function run() {
        describe( "join clause", function() {
            beforeEach( function() {
                variables.query = getMockBox().createMock( "qb.models.Query.QueryBuilder" );
            } );
            describe( "initialization", function() {
                it( "requires a parentQuery, type, and a table", function() {
                    expect( function() { new qb.models.Query.JoinClause(); } ).toThrow();
                    expect( function() { new qb.models.Query.JoinClause( "inner" ); } ).toThrow();
                    expect( function() { new qb.models.Query.JoinClause( "inner", "sometable" ); } ).toThrow();
                } );

                it( "validates the type is a valid sql join type", function() {
                    expect( function() { new qb.models.Query.JoinClause( query, "gibberish", "sometable" ); } ).toThrow();
                    expect( function() { new qb.models.Query.JoinClause( query, "left typo", "sometable" ); } ).toThrow();
                    expect( function() { new qb.models.Query.JoinClause( query, "left", "sometable" ); } ).notToThrow();
                    expect( function() { new qb.models.Query.JoinClause( query, "left outer", "sometable" ); } ).notToThrow();
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
                        join.on( "first.id", "=", "second.first_id", "and", false );

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
                        expect( clause.first ).toBe( "first.another_value", "First column should be [first.another_value]" );
                        expect( clause.operator ).toBe( ">=", "Operator should be [>=]" );
                        expect( clause.second ).toBe( "second.another_value", "First column should be [second.another_value]" );
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
                        expect( binding.cfsqltype ).toBe( "cf_sql_varchar" );
                    } );
                } );
            } );
        } );
    }
}