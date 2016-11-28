component extends="testbox.system.BaseSpec" {
    function run() {
        describe( "where methods", function() {
            beforeEach( function() {
                variables.query = new Quick.models.Query.Builder();
                getMockBox().prepareMock( query );
                query.$property( propertyName = "utils", mock = new Quick.models.Query.QueryUtils() );
            } );

            it( "defaults to empty", function() {
                expect( query.getWheres() ).toBeEmpty( "Default `wheres` should be empty." );
            } );

            describe( "where", function() {
                it( "specifices a where clause", function() {
                    query.where( "::some column::", "=", "::some value::" );
                    expect( query.getWheres() ).toBe( [ {
                        column = "::some column::",
                        operator = "=",
                        value = "::some value::",
                        combinator = "and"
                    } ] );
                } );

                it( "only infers the = when only two arguments", function() {
                    query.where( "::some column::", "::some value::" );
                    expect( query.getWheres() ).toBe( [ {
                        column = "::some column::",
                        operator = "=",
                        value = "::some value::",
                        combinator = "and"
                    } ] );
                } );

                it( "can be specify the boolean combinator", function() {
                    query.where( "::some column::", "=", "::some value::" )
                         .where( "::another column::", "=", "::another value::", "or" );
                    expect( query.getWheres() ).toBe( [
                        {
                            column = "::some column::",
                            operator = "=",
                            value = "::some value::",
                            combinator = "and"
                        },
                        {
                            column = "::another column::",
                            operator = "=",
                            value = "::another value::",
                            combinator = "or"
                        }
                    ] );
                } );

                describe( "specialized where methods", function() {
                    it( "has a whereIn shortcut", function() {
                        query.whereIn( "::some column::", [ "::value one::", "::value two::" ] );

                        var wheres = query.getWheres();
                        expect( wheres ).toBeArray();
                        expect( arrayLen( wheres ) ).toBe( 1, "1 where clause should exist" );
                        var where = wheres[ 1 ];
                        expect( where.column ).toBe( "::some column::" );
                        expect( where.operator ).toBe( "in" );
                        expect( where.value ).toBe( [ "::value one::", "::value two::" ] );
                        expect( where.combinator ).toBe( "and" );
                    } );

                    it( "has a whereNotIn shortcut", function() {
                        query.whereNotIn( "::some column::", [ "::value one::", "::value two::" ] );

                        var wheres = query.getWheres();
                        expect( wheres ).toBeArray();
                        expect( arrayLen( wheres ) ).toBe( 1, "1 where clause should exist" );
                        var where = wheres[ 1 ];
                        expect( where.column ).toBe( "::some column::" );
                        expect( where.operator ).toBe( "not in" );
                        expect( where.value ).toBe( [ "::value one::", "::value two::" ] );
                        expect( where.combinator ).toBe( "and" );
                    } );

                    it( "has a orWhere shortcut", function() {
                        query.orWhere( "::some column::", "<>", "::some value::" );

                        var wheres = query.getWheres();
                        expect( wheres ).toBeArray();
                        expect( arrayLen( wheres ) ).toBe( 1, "1 where clause should exist" );
                        var where = wheres[ 1 ];
                        expect( where.column ).toBe( "::some column::" );
                        expect( where.operator ).toBe( "<>" );
                        expect( where.value ).toBe( "::some value::" );
                        expect( where.combinator ).toBe( "or" );
                    } );
                } );

                describe( "bindings", function() {
                    it( "adds the bindings for where statements received", function() {
                        query.where( "::some column::", "=", "::some value::" );

                        var bindings = query.getRawBindings().where;
                        expect( bindings ).toBeArray();
                        expect( arrayLen( bindings ) ).toBe( 1, "1 binding should exist" );
                        var binding = bindings[ 1 ];
                        expect( binding.value ).toBe( "::some value::" );
                        expect( binding.cfsqltype ).toBe( "cf_sql_varchar" );
                    } );
                } );

                describe( "dynamic where statements", function() {
                    it( "translates whereColumn in to where(""column""", function() {
                        query.whereSomeColumn( "::some value::" );
                        
                        expect( query.getWheres() ).toBe( [ {
                            column = "somecolumn",
                            operator = "=",
                            value = "::some value::",
                            combinator = "and"
                        } ] );
                    } );

                    it( "also translates orWhereColumn in to orWhere(""column""", function() {
                        query.orWhereSomeColumn( "::some value::" );
                        
                        expect( query.getWheres() ).toBe( [ {
                            column = "somecolumn",
                            operator = "=",
                            value = "::some value::",
                            combinator = "or"
                        } ] );
                    } );

                    it( "returns the query instance to continue chaining", function() {
                        var q = query.whereSomeColumn( "::some value::" );
                        expect( q ).toBeInstanceOf( "Quick.models.Query.Builder" );
                    } );
                } );

                describe( "operators", function() {
                    it( "throws an exception on illegal operators", function() {
                        expect( function() {
                            query.where( "::some column::", "::invalid operator::", "::some value::" );
                        } ).toThrow(
                            type = "InvalidArgumentException",
                            regex = "Illegal operator"
                        );
                    } );
                } );
            } );
        } );
    }
}