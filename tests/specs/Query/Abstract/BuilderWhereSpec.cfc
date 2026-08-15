component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "where methods", function() {
            beforeEach( function() {
                variables.qb = new qb.models.Query.QueryBuilder();
                getMockBox().prepareMock( qb );
                qb.$property( propertyName = "utils", mock = new qb.models.Query.QueryUtils() );
            } );

            it( "defaults to empty", function() {
                expect( qb.getWheres() ).toBeEmpty( "Default `wheres` should be empty." );
            } );

            describe( "where", function() {
                it( "specifices a where clause", function() {
                    qb.where( "::some column::", "=", "::some value::" );
                    expect( qb.getWheres() ).toBe( [
                        {
                            column: { "type": "simple", "value": "::some column::" },
                            operator: "=",
                            value: "::some value::",
                            combinator: "and",
                            type: "basic"
                        }
                    ] );
                } );

                it( "only infers the = when only two arguments", function() {
                    qb.where( "::some column::", "::some value::" );
                    expect( qb.getWheres() ).toBe( [
                        {
                            column: { "type": "simple", "value": "::some column::" },
                            operator: "=",
                            value: "::some value::",
                            combinator: "and",
                            type: "basic"
                        }
                    ] );
                } );

                it( "can be specify the boolean combinator", function() {
                    qb.where( "::some column::", "=", "::some value::" )
                        .where(
                            "::another column::",
                            "=",
                            "::another value::",
                            "or"
                        );
                    expect( qb.getWheres() ).toBe( [
                        {
                            column: { "type": "simple", "value": "::some column::" },
                            operator: "=",
                            value: "::some value::",
                            combinator: "and",
                            type: "basic"
                        },
                        {
                            column: { "type": "simple", "value": "::another column::" },
                            operator: "=",
                            value: "::another value::",
                            combinator: "or",
                            type: "basic"
                        }
                    ] );
                } );

                describe( "specialized where methods", function() {
                    it( "has a whereIn shortcut", function() {
                        qb.whereIn( "::some column::", [ "::value one::", "::value two::" ] );

                        var wheres = qb.getWheres();
                        expect( wheres ).toBeArray();
                        expect( arrayLen( wheres ) ).toBe( 1, "1 where clause should exist" );
                        var where = wheres[ 1 ];
                        expect( where.column.value ).toBe( "::some column::" );
                        expect( where.values ).toBe( [ "::value one::", "::value two::" ] );
                        expect( where.combinator ).toBe( "and" );
                        expect( where.type ).toBe( "in" );
                    } );

                    it( "has a whereNotIn shortcut", function() {
                        qb.whereNotIn( "::some column::", [ "::value one::", "::value two::" ] );

                        var wheres = qb.getWheres();
                        expect( wheres ).toBeArray();
                        expect( arrayLen( wheres ) ).toBe( 1, "1 where clause should exist" );
                        var where = wheres[ 1 ];
                        expect( where.column.value ).toBe( "::some column::" );
                        expect( where.values ).toBe( [ "::value one::", "::value two::" ] );
                        expect( where.combinator ).toBe( "and" );
                        expect( where.type ).toBe( "notIn" );
                    } );

                    it( "does not retain raw column bindings for empty IN predicates", function() {
                        var cases = [
                            { apply: ( builder, column ) => builder.whereIn( column, [] ), predicate: "0 = 1" },
                            { apply: ( builder, column ) => builder.whereNotIn( column, [] ), predicate: "1 = 1" },
                            { apply: ( builder, column ) => builder.whereInBulk( column, [] ), predicate: "0 = 1" },
                            { apply: ( builder, column ) => builder.whereNotInBulk( column, [] ), predicate: "1 = 1" }
                        ];

                        cases.each( function( testCase ) {
                            var builder = new qb.models.Query.QueryBuilder().from( "users" );
                            testCase.apply( builder, builder.raw( "COALESCE(?, id)", [ 99 ] ) );

                            expect( builder.toSQL( showBindings = true ) ).toBe(
                                "SELECT * FROM ""users"" WHERE #testCase.predicate#"
                            );
                            expect( builder.getBindings() ).toBeEmpty();
                        } );
                    } );

                    it( "treats null query parameter structs as BETWEEN bindings", function() {
                        var builder = new qb.models.Query.QueryBuilder()
                            .from( "users" )
                            .whereBetween(
                                "age",
                                { value: javacast( "null", "" ), cfsqltype: "INTEGER", null: true },
                                10
                            );

                        expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""age"" BETWEEN ? AND ?" );
                        expect( builder.getBindings()[ 1 ].null ).toBeTrue();
                    } );

                    it( "has a orWhere shortcut", function() {
                        qb.orWhere( "::some column::", "<>", "::some value::" );

                        var wheres = qb.getWheres();
                        expect( wheres ).toBeArray();
                        expect( arrayLen( wheres ) ).toBe( 1, "1 where clause should exist" );
                        var where = wheres[ 1 ];
                        expect( where.column.value ).toBe( "::some column::" );
                        expect( where.operator ).toBe( "<>" );
                        expect( where.value ).toBe( "::some value::" );
                        expect( where.combinator ).toBe( "or" );
                        expect( where.type ).toBe( "basic" );
                    } );
                } );

                describe( "bindings", function() {
                    it( "adds the bindings for where statements received", function() {
                        qb.where( "::some column::", "=", "::some value::" );

                        var bindings = qb.getRawBindings().where;
                        expect( bindings ).toBeArray();
                        expect( arrayLen( bindings ) ).toBe( 1, "1 binding should exist" );
                        var binding = bindings[ 1 ];
                        expect( binding.value ).toBe( "::some value::" );
                        expect( binding.cfsqltype ).toBe( "varchar" );
                    } );
                } );

                describe( "dynamic where statements", function() {
                    it( "translates whereColumn in to where(""column""", function() {
                        qb.whereSomeColumn( "::some value::" );

                        expect( qb.getWheres() ).toBe( [
                            {
                                column: { "type": "simple", "value": "somecolumn" },
                                operator: "=",
                                value: "::some value::",
                                combinator: "and",
                                type: "basic"
                            }
                        ] );
                    } );

                    it( "also translates orWhereColumn in to orWhere(""column""", function() {
                        qb.orWhereSomeColumn( "::some value::" );

                        expect( qb.getWheres() ).toBe( [
                            {
                                column: { "type": "simple", "value": "somecolumn" },
                                operator: "=",
                                value: "::some value::",
                                combinator: "or",
                                type: "basic"
                            }
                        ] );
                    } );

                    it( "returns the query instance to continue chaining", function() {
                        var q = qb.whereSomeColumn( "::some value::" );
                        expect( q ).toBeInstanceOf( "QueryBuilder" );
                    } );
                } );

                describe( "operators", function() {
                    it( "throws an exception on illegal operators", function() {
                        expect( function() {
                            qb.where( "::some column::", "::invalid operator::", "::some value::" );
                        } ).toThrow( type = "InvalidSQLType", regex = "Illegal operator" );
                    } );

                    it( "validates combinators for every where clause type", function() {
                        var invalidCalls = [
                            ( builder ) => builder.whereIn( "id", [ 1 ], "xor" ),
                            ( builder ) => builder.whereInBulk(
                                "id",
                                [ 1 ],
                                javacast( "null", "" ),
                                "xor"
                            ),
                            ( builder ) => builder.whereRaw( "1 = 1", [], "xor" ),
                            ( builder ) => builder.whereColumn( "id", "=", "otherId", "xor" ),
                            ( builder ) => builder.whereExists( ( query ) => query.from( "users" ), "xor" ),
                            ( builder ) => builder.whereNested( ( query ) => query.where( "id", 1 ), "xor" ),
                            ( builder ) => builder.addNestedWhereQuery( builder.newQuery().where( "id", 1 ), "xor" ),
                            ( builder ) => builder.whereNull( "deletedDate", "xor" ),
                            ( builder ) => builder.whereNullSub( ( query ) => query.select( "deletedDate" ).from( "users" ), "xor" ),
                            ( builder ) => builder.whereBetween( "id", 1, 2, "xor" )
                        ];

                        invalidCalls.each( function( invalidCall ) {
                            expect( function() {
                                invalidCall( new qb.models.Query.QueryBuilder() );
                            } ).toThrow( type = "InvalidSQLType", regex = "Illegal combinator" );
                        } );
                    } );

                    it( "can disable operator and combinator validation", function() {
                        var relaxedQB = new qb.models.Query.QueryBuilder( validateOperatorsAndCombinators = false );
                        getMockBox().prepareMock( relaxedQB );
                        relaxedQB.$property( propertyName = "utils", mock = new qb.models.Query.QueryUtils() );

                        expect( function() {
                            relaxedQB.where(
                                "::some column::",
                                "::invalid operator::",
                                "::some value::",
                                "::invalid combinator::"
                            );
                        } ).notToThrow();

                        expect( relaxedQB.getWheres() ).toBe( [
                            {
                                column: { "type": "simple", "value": "::some column::" },
                                operator: "::invalid operator::",
                                value: "::some value::",
                                combinator: "::invalid combinator::",
                                type: "basic"
                            }
                        ] );
                    } );

                    it( "preserves disabled operator validation in nested queries", function() {
                        var relaxedQB = new qb.models.Query.QueryBuilder( validateOperatorsAndCombinators = false );

                        expect( relaxedQB.newQuery().getValidateOperatorsAndCombinators() ).toBeFalse();
                        expect( function() {
                            relaxedQB.whereExists( function( query ) {
                                query.from( "users" ).where( "name", "CUSTOM_OPERATOR", "value" );
                            } );
                        } ).notToThrow();
                    } );
                } );
            } );
        } );
    }

}
