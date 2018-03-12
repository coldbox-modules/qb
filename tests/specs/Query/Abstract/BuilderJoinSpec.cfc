component extends="testbox.system.BaseSpec" {
    function run() {
        describe( "join methods", function() {
            beforeEach( function() {
                variables.query = new qb.models.Query.QueryBuilder();
                getMockBox().prepareMock( query );
                variables.utils = new qb.models.Query.QueryUtils();
                query.$property( propertyName = "utils", mock = utils );
                var mockJoinClause = getMockBox()
                    .prepareMock( new qb.models.Query.JoinClause( query, "inner", "second" ) );
                mockJoinClause.$property( propertyName = "utils", mock = utils );
            } );

            it( "does a simple inner join", function() {
                var mockJoinClause = getMockBox()
                    .prepareMock( new qb.models.Query.JoinClause( query, "inner", "second" ) );
                mockJoinClause.$property( propertyName = "utils", mock = utils );

                query.join( "second", "first.id", "=", "second.first_id" );

                var joins = query.getJoins();
                expect( arrayLen( joins ) ).toBe( 1, "Only one join should exist" );

                var join = joins[ 1 ];
                expect( join ).toBeInstanceOf( "qb.models.Query.JoinClause" );
                expect( join.getType() ).toBe( "inner" );
                expect( join.getTable() ).toBe( "second" );

                var clauses = join.getWheres();
                expect( arrayLen( clauses ) ).toBe( 1, "Only one join clause should exist" );

                var clause = clauses[ 1 ];
                expect( clause ).toBeStruct();
                expect( clause.first ).toBe( "first.id", "First column should be [first.id]" );
                expect( clause.operator ).toBe( "=", "Operator should be [=]" );
                expect( clause.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                expect( clause.combinator ).toBe( "and" );
            } );

            it( "does a left join", function() {
                var mockJoinClause = getMockBox()
                    .prepareMock( new qb.models.Query.JoinClause( query, "left", "second" ) );
                mockJoinClause.$property( propertyName = "utils", mock = utils );

                query.leftJoin( "second", "first.id", "=", "second.first_id" );

                var joins = query.getJoins();
                expect( arrayLen( joins ) ).toBe( 1, "Only one join should exist" );

                var join = joins[ 1 ];
                expect( join ).toBeInstanceOf( "qb.models.Query.JoinClause" );
                expect( join.getType() ).toBe( "left" );
                expect( join.getTable() ).toBe( "second" );

                var clauses = join.getWheres();
                expect( arrayLen( clauses ) ).toBe( 1, "Only one join clause should exist" );

                var clause = clauses[ 1 ];
                expect( clause ).toBeStruct();
                expect( clause.first ).toBe( "first.id", "First column should be [first.id]" );
                expect( clause.operator ).toBe( "=", "Operator should be [=]" );
                expect( clause.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                expect( clause.combinator ).toBe( "and" );
            } );

            it( "does a right join", function() {
                var mockJoinClause = getMockBox()
                    .prepareMock( new qb.models.Query.JoinClause( query, "right", "second" ) );
                mockJoinClause.$property( propertyName = "utils", mock = utils );

                query.rightJoin( "second", "first.id", "=", "second.first_id" );

                var joins = query.getJoins();
                expect( arrayLen( joins ) ).toBe( 1, "Only one join should exist" );

                var join = joins[ 1 ];
                expect( join ).toBeInstanceOf( "qb.models.Query.JoinClause" );
                expect( join.getType() ).toBe( "right" );
                expect( join.getTable() ).toBe( "second" );

                var clauses = join.getWheres();
                expect( arrayLen( clauses ) ).toBe( 1, "Only one join clause should exist" );

                var clause = clauses[ 1 ];
                expect( clause ).toBeStruct();
                expect( clause.first ).toBe( "first.id", "First column should be [first.id]" );
                expect( clause.operator ).toBe( "=", "Operator should be [=]" );
                expect( clause.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                expect( clause.combinator ).toBe( "and" );
            } );

            it( "can use a callback to specify advanced join clauses", function() {
                query.join( "second", function( join ) {
                    join.on( "first.id", "=", "second.first_id" )
                        .on( "first.locale", "=", "second.locale" );
                } );

                var joins = query.getJoins();
                expect( arrayLen( joins ) ).toBe( 1, "Only one join should exist" );

                var join = joins[ 1 ];
                expect( join ).toBeInstanceOf( "qb.models.Query.JoinClause" );
                expect( join.getType() ).toBe( "inner" );
                expect( join.getTable() ).toBe( "second" );

                var clauses = join.getWheres();
                expect( arrayLen( clauses ) ).toBe( 2, "Two join clauses should exist" );

                var clauseOne = clauses[ 1 ];
                expect( clauseOne ).toBeStruct();
                expect( clauseOne.first ).toBe( "first.id", "First column should be [first.id]" );
                expect( clauseOne.operator ).toBe( "=", "Operator should be [=]" );
                expect( clauseOne.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                expect( clauseOne.combinator ).toBe( "and" );

                var clauseTwo = clauses[ 2 ];
                expect( clauseTwo ).toBeStruct();
                expect( clauseTwo.first ).toBe( "first.locale", "First column should be [first.locale]" );
                expect( clauseTwo.operator ).toBe( "=", "Operator should be [=]" );
                expect( clauseTwo.second ).toBe( "second.locale", "First column should be [second.locale]" );
                expect( clauseTwo.combinator ).toBe( "and" );
            } );

            it( "can pass the callback as the second parameter when using positional parameters", function() {
                query.join( "second", function( join ) {
                    join.on( "first.id", "=", "second.first_id" )
                        .on( "first.locale", "=", "second.locale" );
                } );

                var joins = query.getJoins();
                expect( arrayLen( joins ) ).toBe( 1, "Only one join should exist" );

                var join = joins[ 1 ];
                expect( join ).toBeInstanceOf( "qb.models.Query.JoinClause" );
                expect( join.getType() ).toBe( "inner" );
                expect( join.getTable() ).toBe( "second" );

                var clauses = join.getWheres();
                expect( arrayLen( clauses ) ).toBe( 2, "Two join clauses should exist" );

                var clauseOne = clauses[ 1 ];
                expect( clauseOne ).toBeStruct();
                expect( clauseOne.first ).toBe( "first.id", "First column should be [first.id]" );
                expect( clauseOne.operator ).toBe( "=", "Operator should be [=]" );
                expect( clauseOne.second ).toBe( "second.first_id", "First column should be [second.first_id]" );
                expect( clauseOne.combinator ).toBe( "and" );

                var clauseTwo = clauses[ 2 ];
                expect( clauseTwo ).toBeStruct();
                expect( clauseTwo.first ).toBe( "first.locale", "First column should be [first.locale]" );
                expect( clauseTwo.operator ).toBe( "=", "Operator should be [=]" );
                expect( clauseTwo.second ).toBe( "second.locale", "First column should be [second.locale]" );
                expect( clauseTwo.combinator ).toBe( "and" );
            } );

            it( "adds the join bindings to the builder bindings", function() {
                query.join( "second", function( join ) {
                    join.where( "second.locale", "=", "en-US" );
                } );

                var bindings = query.getRawBindings().join;
                expect( bindings ).toBeArray();
                expect( arrayLen( bindings ) ).toBe( 1, "1 binding should exist" );
                var binding = bindings[ 1 ];
                expect( binding.value ).toBe( "en-US" );
                expect( binding.cfsqltype ).toBe( "cf_sql_varchar" );
            } );
        } );
    }
}