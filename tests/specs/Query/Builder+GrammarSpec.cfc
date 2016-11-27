component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query builder + grammar integration", function() {
            describe( "basic selects", function() {
                it( "can select all columns from a table", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" );
                    expect( builder.toSql() ).toBe( 'SELECT * FROM "users"' );
                } );

                it( "can add selects to a query", function() {
                    var builder = getBuilder();
                    builder.select( "foo" )
                        .addSelect( "bar" )
                        .addSelect( [ "baz", "boom" ] )
                        .addSelect( "fe", "fi", "fo" )
                        .from( "users" );
                    expect( builder.toSql() ).toBe(
                        'SELECT "foo", "bar", "baz", "boom", "fe", "fi", "fo" FROM "users"'
                    );
                } );

                it( "can select distinct records", function() {
                    var builder = getBuilder();
                    builder.distinct().select( "foo", "bar" ).from( "users" );
                    expect( builder.toSql() ).toBe(
                        'SELECT DISTINCT "foo", "bar" FROM "users"'
                    );
                } );

                it( "can parse column aliases", function() {
                    var builder = getBuilder();
                    builder.select( "foo as bar" ).from( "users" );
                    expect( builder.toSql() ).toBe(
                        'SELECT "foo" AS "bar" from "users"'
                    );
                } );

                it( "wraps columns and aliases correctly", function() {
                    var builder = getBuilder();
                    builder.select( "x.y as foo.bar" ).from( "public.users" );
                    expect( builder.toSql() ).toBe(
                        'SELECT "x"."y" AS "foo.bar" from "public"."users"'
                    );
                } );
            } );

            describe( "using table prefixes", function() {
                it( "can perform a basic select with a table prefix", function() {
                    var builder = getBuilder();
                    builder.getGrammar().setTablePrefix( "prefix_" );
                    builder.select( "*" ).from( "users" );
                    expect( builder.toSql() ).toBe(
                        'SELECT * FROM "prefix_users"'
                    );
                } );

                it( "can parse column aliases with a table prefix", function() {
                    var builder = getBuilder();
                    builder.getGrammar().setTablePrefix( "prefix_" );
                    builder.select( "*" ).from( "users as people" );
                    expect( builder.toSql() ).toBe(
                        'SELECT * FROM "prefix_users" AS "prefix_people"'
                    );
                } );
            } );

            describe( "wheres", function() {
                describe( "basic wheres", function() {
                    it( "can add a where statement", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).where( "id", "=", 1 );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" = ?'
                        );
                        expect( builder.getBindings() ).toBe( [ 1 ] );
                    } );

                    it( "can add or where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "id", "=", 1 ).orWhere( "email", "foo" );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" = ? OR "email" = ?'
                        );
                        expect( builder.getBindings() ).toBe( [ 1, "foo" ] );
                    } );

                    it( "can add raw where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereRaw( "id = ? or email = ?", [ 1, "foo" ] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" = ? OR "email" = ?'
                        );
                        expect( builder.getBindings() ).toBe( [ 1, "foo" ] );
                    } );

                    it( "can add raw or where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "id", "=", 1 ).orWhereRaw( "email = ?", [ "foo" ] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" = ? OR "email" = ?'
                        );
                        expect( builder.getBindings() ).toBe( [ 1, "foo" ] );
                    } );

                    it( "can specify a where between two columns", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereColumn( "first_name", "last_name" )
                            .orWhereColumn( "updated_date", ">", "created_date" );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "first_name" = "last_name" OR "updated_date" > "created_date"'
                        );
                        expect( builder.getBindings() ).toBe( [] );
                    } );
                } );

                describe( "where between", function() {
                    it( "can add where between statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereBetween( "id", [ 1, 2 ]);
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" BETWEEN ? AND ?'
                        );
                        expect( builder.getBindings() ).toBe( [ 1, 2 ] );
                    } );

                    it( "can add where not between statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereNotBetween( "id", [ 1, 2 ] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" NOT BETWEEN ? AND ?'
                        );
                        expect( builder.getBindings() ).toBe( [ 1, 2 ] );
                    } );
                } );

                describe( "where in", function() {
                    it( "can add where in statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereIn( "id", [ 1, 2, 3 ] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" IN (?, ?, ?)'
                        );
                        expect( builder.getBindings() ).toBe( [ 1, 2, 3 ] );
                    } );

                    it( "can add or where in statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "email", "foo" )
                            .whereIn( "id", [ 1, 2, 3 ] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "email" = ? OR "id" IN (?, ?, ?)'
                        );
                        expect( builder.getBindings() ).toBe( [ "foo", 1, 2, 3 ] );
                    } );

                    it( "can add raw where in statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereIn( "id", [ builder.raw( 1 ) ] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE "id" IN (1)'
                        );
                        expect( builder.getBindings() ).toBe( [] );
                    } );

                    it( "correctly handles empty where ins", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereIn( "id", [] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE 0 = 1'
                        );
                        expect( builder.getBindings() ).toBe( [] );
                    } );

                    it( "correctly handles empty where not ins", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereNotIn( "id", [] );
                        expect( builder.toSql() ).toBe(
                            'SELECT * FROM "users" WHERE 1 = 1'
                        );
                        expect( builder.getBindings() ).toBe( [] );
                    } );
                } );
            } );

            describe( '"when" callbacks', function() {
                it( "executes the callback when the condition is true", function() {
                    var callback = function( query ) {
                        return query.where( "id", "=", 1 );
                    };

                    var builder = getBuilder();
                    builder.select( "*" )
                        .from( "users" )
                        .when( true, callback )
                        .where( "email", "foo" );
                    expect( builder.toSql() ).toBe(
                        'SELECT * FROM "users" WHERE "id" = ? AND "email" = ?'
                    );
                    expect( builder.getBindings() ).toBe( [ 1, "foo" ] );
                } );

                it( "does not execute the callback when the condition is false", function() {
                    var callback = function( query ) {
                        return query.where( "id", "=", 1 );
                    };

                    var builder = getBuilder();
                    builder.select( "*" )
                        .from( "users" )
                        .when( false, callback )
                        .where( "email", "foo" );
                    expect( builder.toSql() ).toBe(
                        'SELECT * FROM "users" WHERE "email" = ?'
                    );
                    expect( builder.getBindings() ).toBe( [ "foo" ] );
                } );

                it( "executes the default callback when the condition is false", function() {
                    var callback = function( query ) {
                        return query.where( "id", "=", 1 );
                    };

                    var default = function( query ) {
                        return query.where( "id", "=", 2 );
                    };

                    var builder = getBuilder();
                    builder.select( "*" )
                        .from( "users" )
                        .when( false, callback, default )
                        .where( "email", "foo" );
                    expect( builder.toSql() ).toBe(
                        'SELECT * FROM "users" WHERE "id" = ? AND "email" = ?'
                    );
                    expect( builder.getBindings() ).toBe( [ 2, "foo" ] );
                } );

                it( "does not execute the default callback when the condition is true", function() {
                    var callback = function( query ) {
                        return query.where( "id", "=", 1 );
                    };

                    var default = function( query ) {
                        return query.where( "id", "=", 2 );
                    };

                    var builder = getBuilder();
                    builder.select( "*" )
                        .from( "users" )
                        .when( true, callback, default )
                        .where( "email", "foo" );
                    expect( builder.toSql() ).toBe(
                        'SELECT * FROM "users" WHERE "id" = ? AND "email" = ?'
                    );
                    expect( builder.getBindings() ).toBe( [ 1, "foo" ] );
                } );
            } );
        } );
    }

    private Builder function getBuilder() {
        var builder = getMockBox()
            .createMock( "Quick.models.Query.Builder" ).init();
        var grammar = getMockBox()
            .createMock( "Quick.models.Query.Grammars.Grammar" );
        var queryUtils = getMockBox()
            .createMock( "Quick.models.Query.QueryUtils" );
        builder.$property( propertyName = "grammar", mock = grammar );
        builder.$property( propertyName = "utils", mock = queryUtils );
        return builder;
    }

}