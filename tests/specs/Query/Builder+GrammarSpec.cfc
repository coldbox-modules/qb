component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query builder + grammar integration", function() {
            describe( "basic selects", function() {
                it( "can select all columns from a table", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" );
                    expect( builder.toSql() ).toBe( "SELECT * FROM ""users""" );
                } );

                it( "can specify the column to select", function() {
                    var builder = getBuilder();
                    builder.select( "name" ).from( "users" );
                    expect( builder.toSql() ).toBe( "SELECT ""name"" FROM ""users""" );
                } );

                it( "can select multiple columns using variadic parameters", function() {
                    var builder = getBuilder();
                    builder.select( "id", "name" ).from( "users" );
                    expect( builder.toSql() ).toBe( "SELECT ""id"", ""name"" FROM ""users""" );
                } );

                it( "can select multiple columns using an array", function() {
                    var builder = getBuilder();
                    builder.select( [ "name", builder.raw( "COUNT(*)" ) ] ).from( "users" );
                    expect( builder.toSql() ).toBe( "SELECT ""name"", COUNT(*) FROM ""users""" );
                } );

                it( "can add selects to a query", function() {
                    var builder = getBuilder();
                    builder.select( "foo" )
                        .addSelect( "bar" )
                        .addSelect( [ "baz", "boom" ] )
                        .addSelect( "fe", "fi", "fo" )
                        .from( "users" );
                    expect( builder.toSql() ).toBe(
                        "SELECT ""foo"", ""bar"", ""baz"", ""boom"", ""fe"", ""fi"", ""fo"" FROM ""users"""
                    );
                } );

                it( "can select distinct records", function() {
                    var builder = getBuilder();
                    builder.distinct().select( "foo", "bar" ).from( "users" );
                    expect( builder.toSql() ).toBe(
                        "SELECT DISTINCT ""foo"", ""bar"" FROM ""users"""
                    );
                } );

                it( "can parse column aliases", function() {
                    var builder = getBuilder();
                    builder.select( "foo as bar" ).from( "users" );
                    expect( builder.toSql() ).toBe(
                        "SELECT ""foo"" AS ""bar"" from ""users"""
                    );
                } );

                it( "wraps columns and aliases correctly", function() {
                    var builder = getBuilder();
                    builder.select( "x.y as foo.bar" ).from( "public.users" );
                    expect( builder.toSql() ).toBe(
                        "SELECT ""x"".""y"" AS ""foo.bar"" from ""public"".""users"""
                    );
                } );
            } );

            describe( "using table prefixes", function() {
                it( "can perform a basic select with a table prefix", function() {
                    var builder = getBuilder();
                    builder.getGrammar().setTablePrefix( "prefix_" );
                    builder.select( "*" ).from( "users" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""prefix_users"""
                    );
                } );

                it( "can parse column aliases with a table prefix", function() {
                    var builder = getBuilder();
                    builder.getGrammar().setTablePrefix( "prefix_" );
                    builder.select( "*" ).from( "users as people" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""prefix_users"" AS ""prefix_people"""
                    );
                } );
            } );

            describe( "wheres", function() {
                describe( "basic wheres", function() {
                    it( "can add a where statement", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).where( "id", "=", 1 );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );

                    it( "can add or where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "id", "=", 1 ).orWhere( "email", "foo" );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" = ? OR ""email"" = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                    } );

                    it( "can add raw where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereRaw( "id = ? or email = ?", [ 1, "foo" ] );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE id = ? OR email = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                    } );

                    it( "can add raw or where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "id", "=", 1 ).orWhereRaw( "email = ?", [ "foo" ] );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" = ? OR email = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                    } );

                    it( "can specify a where between two columns", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereColumn( "first_name", "last_name" );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""first_name"" = ""last_name"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can specify an or where between two columns", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereColumn( "first_name", "last_name" )
                            .orWhereColumn( "updated_date", ">", "created_date" );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""first_name"" = ""last_name"" OR ""updated_date"" > ""created_date"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can add nested where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).where( "email", "foo" )
                            .orWhere( function( q ) {
                                q.where( "name", "bar" ).where( "age", ">=", "21" );
                            } );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""email"" = ? OR (""name"" = ? AND ""age"" >= ?)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ "foo", "bar", 21 ] );
                    } );

                    it( "can have full sub-selects in where statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).where( "email", "foo" )
                            .orWhere( "id", "=", function( q ) {
                                q.select( q.raw( "MAX(id)" ) ).from( "users" )
                                    .where( "email", "bar" );
                            } );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""email"" = ? OR ""id"" = (SELECT MAX(id) FROM ""users"" WHERE ""email"" = ?)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ "foo", "bar" ] );
                    } );
                } );

                describe( "where exists", function() {
                    it( "can add a where exists clause", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "orders" )
                            .whereExists( function( q ) {
                                q.select( q.raw( 1 ) ).from( "products" )
                                    .where( "products.id", "=", q.raw( """orders"".""id""" ) );
                            } );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""orders"" WHERE EXISTS (SELECT 1 FROM ""products"" WHERE ""products"".""id"" = ""orders"".""id"")"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can add an or where exists clause", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "orders" )
                            .where( "id", 1 )
                            .orWhereExists( function( q ) {
                                q.select( q.raw( 1 ) ).from( "products" )
                                    .where( "products.id", "=", q.raw( """orders"".""id""" ) );
                            } );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""orders"" WHERE ""id"" = ? OR EXISTS (SELECT 1 FROM ""products"" WHERE ""products"".""id"" = ""orders"".""id"")"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );

                    it( "can add a where not exists clause", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "orders" )
                            .whereNotExists( function( q ) {
                                q.select( q.raw( 1 ) ).from( "products" )
                                    .where( "products.id", "=", q.raw( """orders"".""id""" ) );
                            } );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""orders"" WHERE NOT EXISTS (SELECT 1 FROM ""products"" WHERE ""products"".""id"" = ""orders"".""id"")"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can add an or where not exists clause", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "orders" )
                            .where( "id", 1 )
                            .orWhereNotExists( function( q ) {
                                q.select( q.raw( 1 ) ).from( "products" )
                                    .where( "products.id", "=", q.raw( """orders"".""id""" ) );
                            } );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""orders"" WHERE ""id"" = ? OR NOT EXISTS (SELECT 1 FROM ""products"" WHERE ""products"".""id"" = ""orders"".""id"")"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );
                } );

                describe( "where null", function() {
                    it( "can add where null statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereNull( "id" );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" IS NULL"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can add or where null statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "id", 1 ).orWhereNull( "id" );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" = ? OR ""id"" IS NULL"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );

                    it( "can add where not null statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereNotNull( "id" );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" IS NOT NULL"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can add or where not null statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "id", 1 ).orWhereNotNull( "id" );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" = ? OR ""id"" IS NOT NULL"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );
                } );

                describe( "where between", function() {
                    it( "can add where between statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereBetween( "id", 1, 2 );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" BETWEEN ? AND ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, 2 ] );
                    } );

                    it( "can add where not between statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereNotBetween( "id", 1, 2 );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" NOT BETWEEN ? AND ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, 2 ] );
                    } );
                } );

                describe( "where in", function() {
                    it( "can add where in statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereIn( "id", [ 1, 2, 3 ] );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" IN (?, ?, ?)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                    } );

                    it( "can add or where in statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .where( "email", "foo" )
                            .orWhereIn( "id", [ 1, 2, 3 ] );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""email"" = ? OR ""id"" IN (?, ?, ?)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ "foo", 1, 2, 3 ] );
                    } );

                    it( "can add raw where in statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereIn( "id", [ builder.raw( 1 ) ] );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" IN (1)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "correctly handles empty where ins", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereIn( "id", [] );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE 0 = 1"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "correctly handles empty where not ins", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .whereNotIn( "id", [] );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE 1 = 1"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "handles sub selects in 'in' statements", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).whereIn( "id", function( q ) {
                            q.select( "id" ).from( "users" ).where( "age", ">", 25 );
                        } );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" IN (SELECT ""id"" FROM ""users"" WHERE ""age"" > ?)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 25 ] );
                    } );
                } );
            } );

            describe( "joins", function() {
                it( "can inner join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", "users.id", "=", "contacts.id" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can inner join using the shorthand", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", "users.id", "contacts.id" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can specify multiple joins", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", "users.id", "contacts.id" )
                        .join( "addresses as a", "a.contact_id", "contacts.id" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" INNER JOIN ""addresses"" AS ""a"" ON ""a"".""contact_id"" = ""contacts"".""id"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can join with where bindings instead of columns", function() {
                    it( "can specify multiple joins", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .joinWhere( "contacts", "contacts.balance", "<", 100 );
                        expect( builder.toSql() ).toBe(
                            "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""contacts"".""balance"" < ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 100 ] );
                    } );
                } );

                it( "can left join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .leftJoin( "orders", "users.id", "orders.user_id" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" LEFT JOIN ""orders"" ON ""users"".""id"" = ""orders"".""user_id"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can right join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "orders" )
                        .rightJoin( "users", "orders.user_id", "users.id" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""orders"" LEFT JOIN ""users"" ON ""orders"".""user_id"" = ""users"".""id"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can cross join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "sizes" ).crossJoin( "colors" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""sizes"" CROSS JOIN ""colors"""
                    );
                } );

                it( "can accept a callback for complex joins", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .orOn( "users.name" = "contacts.name" )
                                .orWhere( "users.admin", 1 );
                        } );

                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" OR ""users"".""name"" = ""contacts"".""name"" OR ""users"".""admin"" = ?"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                } );

                it( "can specify where null in a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .whereNull( "contacts.deleted_date" );
                        } );

                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" AND ""contacts"".""deleted_date"" IS NULL"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can specify or where null in a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .orWhereNull( "contacts.deleted_date" );
                        } );

                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" OR ""contacts"".""deleted_date"" IS NULL"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can specify where not null in a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .whereNotNull( "contacts.deleted_date" );
                        } );

                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" AND ""contacts"".""deleted_date"" IS NOT NULL"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can specify or where not null in a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .orWhereNotNull( "contacts.deleted_date" );
                        } );

                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" OR ""contacts"".""deleted_date"" IS NOT NULL"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can specify where in inside a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .whereIn( "contacts.id", [ 1, 2, 3 ] );
                        } );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" AND ""contacts"".""id"" IN (?, ?, ?)"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                } );

                it( "can specify or where in inside a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .orWhereIn( "contacts.id", [ 1, 2, 3 ] );
                        } );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" OR ""contacts"".""id"" IN (?, ?, ?)"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                } );

                it( "can specify where not in inside a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .whereNotIn( "contacts.id", [ 1, 2, 3 ] );
                        } );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" AND ""contacts"".""id"" NOT IN (?, ?, ?)"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                } );

                it( "can specify or where not in inside a join", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .join( "contacts", function( j ) {
                            j.on( "users.id", "=", "contacts.id" )
                                .orWhereNotIn( "contacts.id", [ 1, 2, 3 ] );
                        } );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" OR ""contacts"".""id"" NOT IN (?, ?, ?)"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                } );
            } );

            describe( """when"" callbacks", function() {
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
                        "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
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
                        "SELECT * FROM ""users"" WHERE ""email"" = ?"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ "foo" ] );
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
                        "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 2, "foo" ] );
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
                        "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?"
                    );
                    expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                } );
            } );

            describe( "group bys", function() {
                it( "can add a simple group by", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" ).groupBy( "email" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" GROUP BY ""email"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can group by multiple fields using variadic parameters", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" ).groupBy( "id", "email" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" GROUP BY ""id"", ""email"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can group by multiple fields using an array", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" ).groupBy( [ "id", "email" ] );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" GROUP BY ""id"", ""email"""
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can group by multiple fields using raw sql", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .groupBy( builder.raw( "DATE(created_at)" ) );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" GROUP BY DATE(created_at)"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );
            } );

            describe( "order bys", function() {
                it( "can add a simple order by", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" ).orderBy( "email" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" ORDER BY ""email"" ASC"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can order in descending order", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" ).orderBy( "email", "desc" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" ORDER BY ""email"" DESC"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "combines all order by calls", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .orderBy( "id" ).orderBy( "email", "desc" );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" ORDER BY ""id"" ASC, ""email"" DESC"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can order by multiple fields using variadic parameters", function() {
                    var builder = getBuilder();
                    builder.select( "*" ).from( "users" )
                        .groupBy( builder.raw( "DATE(created_at)" ) );
                    expect( builder.toSql() ).toBe(
                        "SELECT * FROM ""users"" ORDER BY(created_at)"
                    );
                    expect( getTestBindings( builder ) ).toBe( [] );
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

    private array function getTestBindings( required Builder builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}