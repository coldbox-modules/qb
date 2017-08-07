import qb.models.Query.QueryBuilder;

component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "basic selects", function() {
                    it( "can select all columns from a table", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase( "SELECT * FROM ""users""" );
                    } );

                    it( "can specify the column to select", function() {
                        var builder = getBuilder();
                        builder.select( "name" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase( "SELECT ""name"" FROM ""users""" );
                    } );

                    it( "can select multiple columns using variadic parameters", function() {
                        var builder = getBuilder();
                        builder.select( "id", "name" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase( "SELECT ""id"", ""name"" FROM ""users""" );
                    } );

                    it( "can select multiple columns using an array", function() {
                        var builder = getBuilder();
                        builder.select( [ "name", builder.raw( "COUNT(*)" ) ] ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase( "SELECT ""name"", COUNT(*) FROM ""users""" );
                    } );

                    it( "can add selects to a query", function() {
                        var builder = getBuilder();
                        builder.select( "foo" )
                            .addSelect( "bar" )
                            .addSelect( [ "baz", "boom" ] )
                            .from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT ""foo"", ""bar"", ""baz"", ""boom"" FROM ""users"""
                        );
                    } );

                    it( "adding a select to a * query gets rid of the star", function() {
                        var builder = getBuilder();
                        builder.addSelect( "foo" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT ""foo"" FROM ""users"""
                        );
                    } );

                    it( "can select distinct records", function() {
                        var builder = getBuilder();
                        builder.distinct().select( "foo", "bar" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT DISTINCT ""foo"", ""bar"" FROM ""users"""
                        );
                    } );

                    it( "can parse column aliases", function() {
                        var builder = getBuilder();
                        builder.select( "foo as bar" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT ""foo"" AS ""bar"" FROM ""users"""
                        );
                    } );

                    it( "wraps columns and aliases correctly", function() {
                        var builder = getBuilder();
                        builder.select( "x.y as foo.bar" ).from( "public.users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT ""x"".""y"" AS ""foo.bar"" FROM ""public"".""users"""
                        );
                    } );

                    it( "selects raw values correctly", function() {
                        var builder = getBuilder();
                        builder.select( builder.raw( "substr( foo, 6 )" ) ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT substr( foo, 6 ) FROM ""users"""
                        );
                    } );

                    it( "can easily select raw values with `selectRaw`", function() {
                        var builder = getBuilder();
                        builder.selectRaw( "substr( foo, 6 )" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT substr( foo, 6 ) FROM ""users"""
                        );
                    } );
                } );

                describe( "sub-selects", function() {
                    it( "can execute sub-selects", function() {
                        var builder = getBuilder();
                        builder
                            .from( "users" )
                            .select( "name" )
                            .subSelect( "latestUpdatedDate", function( q ) {
                                return q.from( "posts" )
                                    .selectRaw( "MAX(updated_date)" )
                                    .whereColumn( "posts.user_id", "users.id" );
                            } );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT ""name"", ( SELECT MAX(updated_date) FROM ""posts"" WHERE ""posts"".""user_id"" = ""users"".""id"" ) AS ""latestUpdatedDate"" FROM ""users"""
                        );
                    } );

                    it( "can execute sub-selects with bindings", function() {
                        var builder = getBuilder();
                        builder
                            .from( "users" )
                            .select( "name" )
                            .subSelect( "latestUpdatedDate", function( q ) {
                                return q.from( "posts" )
                                    .selectRaw( "MAX(updated_date)" )
                                    .where( "posts.user_id", 1 );
                            } );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT ""name"", ( SELECT MAX(updated_date) FROM ""posts"" WHERE ""posts"".""user_id"" = ? ) AS ""latestUpdatedDate"" FROM ""users"""
                        );

                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );
                } );

                describe( "from", function() {
                    it( "can specify the table to select from", function() {
                        var builder = getBuilder();
                        builder.from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"""
                        );
                    } );

                    it( "can use `table` as an alias for from", function() {
                        var builder = getBuilder();
                        builder.table( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"""
                        );
                    } );
                } );

                describe( "using table prefixes", function() {
                    it( "can perform a basic select with a table prefix", function() {
                        var builder = getBuilder();
                        builder.getGrammar().setTablePrefix( "prefix_" );
                        builder.select( "*" ).from( "users" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""prefix_users"""
                        );
                    } );

                    it( "can parse column aliases with a table prefix", function() {
                        var builder = getBuilder();
                        builder.getGrammar().setTablePrefix( "prefix_" );
                        builder.select( "*" ).from( "users as people" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""prefix_users"" AS ""prefix_people"""
                        );
                    } );
                } );

                describe( "aliases", function() {
                    describe( "column aliases", function() {
                        it( "can parse column aliases with AS in them", function() {
                            var builder = getBuilder();
                            builder.select( "id AS user_id" ).from( "users" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT ""id"" AS ""user_id"" FROM ""users"""
                            );
                        } );

                        it( "can parse column aliases without AS in them", function() {
                            var builder = getBuilder();
                            builder.select( "id user_id" ).from( "users" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT ""id"" AS ""user_id"" FROM ""users"""
                            );
                        } );
                    } );
                    describe( "table aliases", function() {
                        it( "can parse table aliases with AS in them", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users as people" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" AS ""people"""
                            );
                        } );

                        it( "can parse table aliases without AS in them", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users people" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" AS ""people"""
                            );
                        } );
                    } );
                } );

                describe( "wheres", function() {
                    describe( "basic wheres", function() {
                        it( "can add a where statement", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" ).where( "id", "=", 1 );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" = ?"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                        } );

                        it( "can add or where statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .where( "id", "=", 1 ).orWhere( "email", "foo" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" = ? OR ""email"" = ?"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                        } );

                        it( "can add raw where statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" ).whereRaw( "id = ? OR email = ?", [ 1, "foo" ] );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE id = ? OR email = ?"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                        } );

                        it( "can add raw or where statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .where( "id", "=", 1 ).orWhereRaw( "email = ?", [ "foo" ] );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" = ? OR email = ?"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                        } );

                        it( "can specify a where between two columns", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .whereColumn( "first_name", "last_name" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""first_name"" = ""last_name"""
                            );
                            expect( getTestBindings( builder ) ).toBe( [] );
                        } );

                        it( "can specify an or where between two columns", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .whereColumn( "first_name", "last_name" )
                                .orWhereColumn( "updated_date", ">", "created_date" );
                            expect( builder.toSql() ).toBeWithCase(
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
                            expect( builder.toSql() ).toBeWithCase(
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
                            expect( builder.toSql() ).toBeWithCase(
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
                            expect( builder.toSql() ).toBeWithCase(
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
                            expect( builder.toSql() ).toBeWithCase(
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
                            expect( builder.toSql() ).toBeWithCase(
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
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""orders"" WHERE ""id"" = ? OR NOT EXISTS (SELECT 1 FROM ""products"" WHERE ""products"".""id"" = ""orders"".""id"")"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                        } );
                    } );

                    describe( "where null", function() {
                        it( "can add where null statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" ).whereNull( "id" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" IS NULL"
                            );
                            expect( getTestBindings( builder ) ).toBe( [] );
                        } );

                        it( "can add or where null statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .where( "id", 1 ).orWhereNull( "id" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" = ? OR ""id"" IS NULL"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                        } );

                        it( "can add where not null statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" ).whereNotNull( "id" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" IS NOT NULL"
                            );
                            expect( getTestBindings( builder ) ).toBe( [] );
                        } );

                        it( "can add or where not null statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .where( "id", 1 ).orWhereNotNull( "id" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" = ? OR ""id"" IS NOT NULL"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                        } );
                    } );

                    describe( "where between", function() {
                        it( "can add where between statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" ).whereBetween( "id", 1, 2 );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" BETWEEN ? AND ?"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1, 2 ] );
                        } );

                        it( "can add where not between statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" ).whereNotBetween( "id", 1, 2 );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" NOT BETWEEN ? AND ?"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1, 2 ] );
                        } );
                    } );

                    describe( "where in", function() {
                        it( "can add where in statements from a list", function() {
                            var builder = getBuilder();
                            builder.from( "users" )
                                .whereIn( "id", "1,2,3" );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" IN (?, ?, ?)"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                        } );

                        it( "can add where in statements from an array", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .whereIn( "id", [ 1, 2, 3 ] );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" IN (?, ?, ?)"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                        } );

                        it( "can add or where in statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .where( "email", "foo" )
                                .orWhereIn( "id", [ 1, 2, 3 ] );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""email"" = ? OR ""id"" IN (?, ?, ?)"
                            );
                            expect( getTestBindings( builder ) ).toBe( [ "foo", 1, 2, 3 ] );
                        } );

                        it( "can add raw where in statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .whereIn( "id", [ builder.raw( 1 ) ] );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE ""id"" IN (1)"
                            );
                            expect( getTestBindings( builder ) ).toBe( [] );
                        } );

                        it( "correctly handles empty where ins", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .whereIn( "id", [] );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE 0 = 1"
                            );
                            expect( getTestBindings( builder ) ).toBe( [] );
                        } );

                        it( "correctly handles empty where not ins", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" )
                                .whereNotIn( "id", [] );
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" WHERE 1 = 1"
                            );
                            expect( getTestBindings( builder ) ).toBe( [] );
                        } );

                        it( "handles sub selects in 'in' statements", function() {
                            var builder = getBuilder();
                            builder.select( "*" ).from( "users" ).whereIn( "id", function( q ) {
                                q.select( "id" ).from( "users" ).where( "age", ">", 25 );
                            } );
                            expect( builder.toSql() ).toBeWithCase(
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
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can inner join using the shorthand", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .join( "contacts", "users.id", "contacts.id" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can specify multiple joins", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .join( "contacts", "users.id", "contacts.id" )
                            .join( "addresses AS a", "a.contact_id", "contacts.id" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" INNER JOIN ""addresses"" AS ""a"" ON ""a"".""contact_id"" = ""contacts"".""id"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can join with where bindings instead of columns", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .joinWhere( "contacts", "contacts.balance", "<", 100 );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""contacts"".""balance"" < ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 100 ] );
                    } );

                    it( "can left join", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .leftJoin( "orders", "users.id", "orders.user_id" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" LEFT JOIN ""orders"" ON ""users"".""id"" = ""orders"".""user_id"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can right join", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "orders" )
                            .rightJoin( "users", "orders.user_id", "users.id" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""orders"" RIGHT JOIN ""users"" ON ""orders"".""user_id"" = ""users"".""id"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can cross join", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "sizes" ).crossJoin( "colors" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""sizes"" CROSS JOIN ""colors"""
                        );
                    } );

                    it( "can accept a callback for complex joins", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .join( "contacts", function( j ) {
                                j.on( "users.id", "=", "contacts.id" )
                                    .orOn( "users.name", "=", "contacts.name" )
                                    .orWhere( "users.admin", 1 );
                            } );

                        expect( builder.toSql() ).toBeWithCase(
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

                        expect( builder.toSql() ).toBeWithCase(
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

                        expect( builder.toSql() ).toBeWithCase(
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

                        expect( builder.toSql() ).toBeWithCase(
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

                        expect( builder.toSql() ).toBeWithCase(
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
                        expect( builder.toSql() ).toBeWithCase(
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
                        expect( builder.toSql() ).toBeWithCase(
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
                        expect( builder.toSql() ).toBeWithCase(
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
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" OR ""contacts"".""id"" NOT IN (?, ?, ?)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                    } );
                } );

                describe( "group bys", function() {
                    it( "can add a simple group by", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).groupBy( "email" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" GROUP BY ""email"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can group by multiple fields using variadic parameters", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).groupBy( "id", "email" );

                        // Variadic parameters are not consistent between engines, so test for both options
                        try {
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" GROUP BY ""email"", ""id"""
                            );
                        }
                        catch ( any e ) {
                            expect( builder.toSql() ).toBeWithCase(
                                "SELECT * FROM ""users"" GROUP BY ""id"", ""email"""
                            );
                        }

                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can group by multiple fields using an array", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).groupBy( [ "id", "email" ] );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" GROUP BY ""id"", ""email"""
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can group by multiple fields using raw sql", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .groupBy( builder.raw( "DATE(created_at)" ) );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" GROUP BY DATE(created_at)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );
                } );

                describe( "havings", function() {
                    it( "can add a basic having clause", function() {
                        var builder = getBuilder();

                        builder.from( "users" )
                            .having( "email", ">", 1 );

                        expect( builder.toSQL() ).toBeWithCase(
                            "SELECT * FROM ""users"" HAVING ""email"" > ?"
                        );

                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );

                    it( "can add a having clause with a raw column", function() {
                        var builder = getBuilder();

                        builder.from( "users" )
                            .groupBy( "email" )
                            .having( builder.raw( "COUNT(email)" ), ">", 1 );

                        expect( builder.toSQL() ).toBeWithCase(
                            "SELECT * FROM ""users"" GROUP BY ""email"" HAVING COUNT(email) > ?"
                        );

                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                    } );

                    it( "can add a having clause with a raw value", function() {
                        var builder = getBuilder();

                        builder
                            .select( builder.raw( "COUNT(*) AS ""total""" ) )
                            .from( "items" )
                            .where( "department", "=", "popular" )
                            .groupBy( "category" )
                            .having( "total", ">", builder.raw( 3 ) );

                        expect( builder.toSQL() ).toBeWithCase(
                            "SELECT COUNT(*) AS ""total"" FROM ""items"" WHERE ""department"" = ? GROUP BY ""category"" HAVING ""total"" > 3"
                        );

                        expect( getTestBindings( builder ) ).toBe( [ "popular" ] );
                    } );
                } );

                describe( "order bys", function() {
                    it( "can add a simple order by", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).orderBy( "email" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" ORDER BY ""email"" ASC"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can order in descending order", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).orderBy( "email", "desc" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" ORDER BY ""email"" DESC"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "combines all order by calls", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .orderBy( "id" ).orderBy( "email", "desc" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" ORDER BY ""id"" ASC, ""email"" DESC"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "can order by a raw expression", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" )
                            .orderBy( builder.raw( "DATE(created_at)" ) );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" ORDER BY DATE(created_at)"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    describe( "can accept an array for the column argument", function(){

                        describe( "with the array values", function() {

                            it( "as simple strings", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [ "last_name", "age", "favorite_color" ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" ASC, ""age"" ASC, ""favorite_color"" ASC"
                                );
                            });

                            it( "as pipe delimited strings", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [ "last_name|desc", "age|asc", "favorite_color|desc" ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" DESC, ""age"" ASC, ""favorite_color"" DESC"
                                );
                            });

                            it( "as a nested positional array", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [ [ "last_name", "desc" ], [ "age", "asc" ], [ "favorite_color" ] ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" DESC, ""age"" ASC, ""favorite_color"" ASC"
                                );
                            });

                            it( "as a nested positional array with leniency for arrays of length 1 or longer than 2 which assumes position 1 is column name and position 2 is the direction and ignores other entries in the nested array", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [ [ "last_name", "desc" ], [ "age", "asc" ], [ "favorite_color" ], [ "height", "asc", "will", "be", "ignored" ] ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" DESC, ""age"" ASC, ""favorite_color"" ASC, ""height"" ASC"
                                );
                            });

                            it( "as a any combo of values and ignores then inherits the direction's argument value if an invalid direction is supplied (anything other than (asc|desc)", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [
                                        [ "last_name", "desc" ],
                                        [ "age", "forward" ],
                                        "favorite_color|backward",
                                        "favorite_food|desc",
                                        { column = "height", direction = "tallest" },
                                        { column = "weight", direction = "desc" },
                                        builder.raw( "DATE(created_at)" ),
                                        { column = builder.raw( "DATE(modified_at)" ), direction = "desc" } //desc will be ignored in this case because it's an expression
                                    ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" DESC, ""age"" ASC, ""favorite_color"" ASC, ""favorite_food"" DESC, ""height"" ASC, ""weight"" DESC, DATE(created_at), DATE(modified_at)"
                                );
                            });

                            it( "as raw expressions", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [
                                        builder.raw( "DATE(created_at)" ),
                                        { column = builder.raw( "DATE(modified_at)" ) }
                                    ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY DATE(created_at), DATE(modified_at)"
                                );
                            });

                            it( "as simple strings OR pipe delimited strings intermingled", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [ "last_name", "age|desc", "favorite_color" ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" ASC, ""age"" DESC, ""favorite_color"" ASC"
                                );
                            });

                            it( "can accept a struct with a column key and optionally the direction key", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [
                                        { column = "last_name" },
                                        { column = "age", direction = "asc" },
                                        { column = "favorite_color", direction = "desc" }
                                    ], "desc" );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" DESC, ""age"" ASC, ""favorite_color"" DESC"
                                );
                            });

                            it( "as values that when additional orderBy() calls are chained the chained calls preserve the order of the calls", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [
                                        "last_name",
                                        "age|desc"
                                    ] )
                                    .orderBy( "favorite_color", "desc" )
                                    .orderBy( column = [ { column = "height" }, { column = "weight", direction = "asc" } ], direction = "desc" )
                                    .orderBy( column = "eye_color", direction = "desc" )
                                    .orderBy( [
                                        { column = "is_athletic", direction = "desc", extraKey = "ignored" },
                                        builder.raw( "DATE(created_at)" )
                                    ] )
                                    .orderBy( builder.raw( "DATE(modified_at)" ) );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" ASC, ""age"" DESC, ""favorite_color"" DESC, ""height"" DESC, ""weight"" ASC, ""eye_color"" DESC, ""is_athletic"" DESC, DATE(created_at), DATE(modified_at)"
                                );
                            });

                            it( "as any combo of any valid values intermingled", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( [
                                        "last_name",
                                        "age|desc",
                                        [ "eye_color", "desc" ],
                                        [ "hair_color" ],
                                        { column = "is_musical" },
                                        { column = "is_athletic", direction = "desc", extraKey = "ignored" },
                                        builder.raw( "DATE(created_at)" ),
                                        { column = builder.raw( "DATE(modified_at)" ), direction = "desc" } // direction is ignored because it should be RAW
                                    ] );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" ASC, ""age"" DESC, ""eye_color"" DESC, ""hair_color"" ASC, ""is_musical"" ASC, ""is_athletic"" DESC, DATE(created_at), DATE(modified_at)"
                                );
                            });

                        });

                    });

                    describe( "can accept a comma delimited list for the column argument", function(){

                        describe( "with the list values", function() {

                            it( "as simple column names that inherit the default direction", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( "last_name,age,favorite_color");

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" ASC, ""age"" ASC, ""favorite_color"" ASC"
                                );
                            });

                            it( "as simple column names while inheriting the direction argument's supplied value", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( "last_name,age,favorite_color", "desc" );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" DESC, ""age"" DESC, ""favorite_color"" DESC"
                                );
                            });

                            it( "as column names with secondary piped delimited value representing the direction for each column", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( "last_name|desc,age|desc,favorite_color|asc" );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" DESC, ""age"" DESC, ""favorite_color"" ASC"
                                );
                            });

                            it( "as column names with optional secondary piped delimited value representing the direction for that column and inherits the direction argument's value when supplied", function(){
                                var builder = getBuilder();
                                builder.select( "*").from( "users" )
                                    .orderBy( "last_name|asc,age,favorite_color|asc", "desc" );

                                expect( builder.toSql() ).toBeWithCase(
                                    "SELECT * FROM ""users"" ORDER BY ""last_name"" ASC, ""age"" DESC, ""favorite_color"" ASC"
                                );
                            });

                        });

                    });

                } );

                describe( "limits", function() {
                    it( "can limit the record set returned", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).limit( 3 );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" LIMIT 3"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "has an alias of ""take""", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).take( 1 );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" LIMIT 1"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );
                } );

                describe( "offsets", function() {
                    it( "can offset the record set returned", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).offset( 3 );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" OFFSET 3"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );
                } );

                describe( "forPage", function() {
                    it( "combines limits and offsets for easy pagination", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).forPage( 3, 15 );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" LIMIT 15 OFFSET 30"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );

                    it( "returns zeros values less than zero", function() {
                        var builder = getBuilder();
                        builder.select( "*" ).from( "users" ).forPage( 0, -2 );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" LIMIT 0 OFFSET 0"
                        );
                        expect( getTestBindings( builder ) ).toBe( [] );
                    } );
                } );
            } );

            describe( "control flow", function() {
                describe( "when", function() {
                    it( "executes the callback when the condition is true", function() {
                        var callback = function( query ) {
                            query.where( "id", "=", 1 );
                        };

                        var builder = getBuilder();
                        builder.select( "*" )
                            .from( "users" )
                            .when( true, callback )
                            .where( "email", "foo" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                    } );

                    it( "does not execute the callback when the condition is false", function() {
                        var callback = function( query ) {
                            query.where( "id", "=", 1 );
                        };

                        var builder = getBuilder();
                        builder.select( "*" )
                            .from( "users" )
                            .when( false, callback )
                            .where( "email", "foo" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" WHERE ""email"" = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ "foo" ] );
                    } );

                    it( "executes the default callback when the condition is false", function() {
                        var callback = function( query ) {
                            query.where( "id", "=", 1 );
                        };

                        var defaultCallback = function( query ) {
                            query.where( "id", "=", 2 );
                        };

                        var builder = getBuilder();
                        builder.select( "*" )
                            .from( "users" )
                            .when( false, callback, defaultCallback )
                            .where( "email", "foo" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 2, "foo" ] );
                    } );

                    it( "does not execute the default callback when the condition is true", function() {
                        var callback = function( query ) {
                            query.where( "id", "=", 1 );
                        };

                        var defaultCallback = function( query ) {
                            query.where( "id", "=", 2 );
                        };

                        var builder = getBuilder();
                        builder.select( "*" )
                            .from( "users" )
                            .when( true, callback, defaultCallback )
                            .where( "email", "foo" );
                        expect( builder.toSql() ).toBeWithCase(
                            "SELECT * FROM ""users"" WHERE ""id"" = ? AND ""email"" = ?"
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1, "foo" ] );
                    } );
                } );

                describe( "tap", function() {
                    it( "runs a callback that gets passed the query. without modifying the query", function() {
                        var builder = getBuilder();
                        var count = 0;
                        builder.from( "users" )
                            .tap( function( q ) {
                                count++;
                                expect( q.toSQL() ).toBe( "SELECT * FROM ""users""" );
                                expect( getTestBindings( builder ) ).toBe( [] );
                            } )
                            .where( "id", 1 )
                            .tap( function( q ) {
                                count++;
                                expect( q.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""id"" = ?" );
                                expect( getTestBindings( q ) ).toBe( [ 1 ] );
                            } )
                            .tap( function( q ) {
                                count++;
                                // attempts to modify the query should not work
                                return q.where( "foo", "bar" );
                            } );

                        expect( builder.toSQL() ).toBe(
                            "SELECT * FROM ""users"" WHERE ""id"" = ?",
                            "The query should not be modified from the last `tap` call."
                        );
                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                        expect( count ).toBe( 3, "Three different tap functions should have been called." );
                    } );
                } );
            } );

            describe( "insert statements", function() {
                it( "can insert a struct of data into a table", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" ).insert( values = { "email" = "foo" }, toSql = true );
                    expect( sql ).toBe( "INSERT INTO ""users"" (""email"") VALUES (?)" );
                    expect( getTestBindings( builder ) ).toBe( [ "foo" ] );
                } );

                it( "can insert a struct of data with multiple columns into a table", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" ).insert( values = { "email" = "foo", "name" = "bar" }, toSql = true );
                    expect( sql ).toBe( "INSERT INTO ""users"" (""email"", ""name"") VALUES (?, ?)" );
                    expect( getTestBindings( builder ) ).toBe( [ "foo", "bar" ] );
                } );

                it( "can batch insert multiple records", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" ).insert( values = [
                        { "email" = "foo", "name" = "bar" },
                        { "email" = "baz", "name" = "bleh" }
                    ], toSql = true );
                    expect( sql ).toBe( "INSERT INTO ""users"" (""email"", ""name"") VALUES (?, ?), (?, ?)" );
                    expect( getTestBindings( builder ) ).toBe( [ "foo", "bar", "baz", "bleh" ] );
                } );
            } );

            describe( "update statements", function() {
                it( "can update all records in a table", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" )
                        .update( values = {
                            "email" = "foo",
                            "name" = "bar"
                        }, toSql = true );
                    expect( sql ).toBe( "UPDATE ""users"" SET ""email"" = ?, ""name"" = ?" );
                    expect( getTestBindings( builder ) ).toBe( [ "foo", "bar" ] );
                } );

                it( "can be constrained by a where statement", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" )
                        .whereId( 1 )
                        .update( values = {
                            "email" = "foo",
                            "name" = "bar"
                        }, toSql = true );
                    expect( sql ).toBe( "UPDATE ""users"" SET ""email"" = ?, ""name"" = ? WHERE ""id"" = ?" );
                    expect( getTestBindings( builder ) ).toBe( [ "foo", "bar", 1 ] );
                } );
            } );

            describe( "updateOrInsert statements", function() {
                it( "inserts a new record when the where clause does not bring back any records", function() {
                    var builder = getBuilder();
                    builder.$( "exists", false );
                    var sql = builder.from( "users" )
                        .where( "email", "foo" )
                        .updateOrInsert(
                            values = { "name" = "baz" },
                            toSql = true
                        );
                    expect( sql ).toBe( "INSERT INTO ""users"" (""name"") VALUES (?)" );

                    var bindings = builder.getRawBindings();
                    expect( bindings.insert ).toBeArray();
                    expect( bindings.insert ).toHaveLength( 1 );
                    expect( bindings.insert[ 1 ].value ).toBe( "baz" );

                    expect( builder.getBindings() ).toBeArray();
                    expect( builder.getBindings() ).toHaveLength( 1 );
                } );

                it( "updates an existing record when the where clause brings back at least one record", function() {
                    var builder = getBuilder();
                    builder.$( "exists", true );
                    var sql = builder.from( "users" )
                        .where( "email", "foo" )
                        .updateOrInsert(
                            values = { "name" = "baz" },
                            toSql = true
                        );
                    expect( sql ).toBe( "UPDATE ""users"" SET ""name"" = ? WHERE ""email"" = ? LIMIT 1" );

                    var bindings = builder.getRawBindings();
                    expect( bindings.update ).toBeArray();
                    expect( bindings.update ).toHaveLength( 1 );
                    expect( bindings.update[ 1 ].value ).toBe( "baz" );

                    expect( bindings.where ).toBeArray();
                    expect( bindings.where ).toHaveLength( 1 );
                    expect( bindings.where[ 1 ].value ).toBe( "foo" );

                    expect( builder.getBindings() ).toBeArray();
                    expect( builder.getBindings() ).toHaveLength( 2 );
                } );
            } );

            describe( "delete statements", function() {
                it( "can delete an entire table", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" ).delete( toSql = true );
                    expect( sql ).toBe( "DELETE FROM ""users""" );
                    expect( getTestBindings( builder ) ).toBe( [] );
                } );

                it( "can delete a specific id quickly", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" ).delete( id = 1, toSql = true );
                    expect( sql ).toBe( "DELETE FROM ""users"" WHERE ""id"" = ?" );
                    expect( getTestBindings( builder ) ).toBe( [ 1 ] );
                } );

                it( "can be constrained with a where statement", function() {
                    var builder = getBuilder();
                    var sql = builder.from( "users" )
                        .where( "email", "foo" )
                        .delete( toSql = true );
                    expect( sql ).toBe( "DELETE FROM ""users"" WHERE ""email"" = ?" );
                    expect( getTestBindings( builder ) ).toBe( [ "foo" ] );
                } );
            } );

            describe( "retrieval shortcuts", function() {
                describe( "get", function() {
                    it( "executes the query when calling `get`", function() {
                        var builder = getBuilder();
                        builder.setReturnFormat( "query" );
                        var expectedQuery = queryNew( "id", "integer", [ { id = 1 } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""id"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.select( "id" ).from( "users" ).get();

                        expect( results ).toBe( expectedQuery );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT ""id"" FROM ""users""",
                            options = {}
                        } );
                    } );

                    it( "can pass in an array of columns to retrieve for the single query execution", function() {
                        var builder = getBuilder();
                        builder.setReturnFormat( "query" );
                        var expectedGetQuery = queryNew( "id,name", "integer,varchar", [ { id = 1, name = "foo" } ] );
                        var expectedNormalQuery = queryNew( "id,name,age", "integer,varchar,integer", [ { id = 1, name = "foo", age = 24 } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""id"", ""name"" FROM ""users""",
                            options = {}
                        ).$results( expectedGetQuery );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT * FROM ""users""",
                            options = {}
                        ).$results( expectedNormalQuery );

                        expect( builder.from( "users" ).get( [ "id", "name" ] ) )
                            .toBe( expectedGetQuery );
                        expect( builder.from( "users" ).get() )
                            .toBe( expectedNormalQuery );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 2, "runQuery should have been called twice" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT ""id"", ""name"" FROM ""users""",
                            options = {}
                        } );
                        expect( runQueryLog[ 2 ] ).toBe( {
                            sql = "SELECT * FROM ""users""",
                            options = {}
                        } );
                    } );

                    it( "can get a single column for a single query execution", function() {
                        var builder = getBuilder();
                        builder.setReturnFormat( "query" );
                        var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        expect( builder.from( "users" ).get( "name" ) )
                            .toBe( expectedQuery );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        } );
                    } );

                    it( "preserves original columns after executing a get with columns", function() {
                        var builder = getBuilder();
                        builder.setReturnFormat( "query" );
                        var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        builder.select( "id" ).from( "users" );
                        builder.get( "name" );
                        expect( builder.getColumns() ).toBe( [ "id" ] );
                    } );
                } );

                describe( "first", function() {
                    it( "retrieves the first record when calling `first`", function() {
                        var builder = getBuilder();
                        var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id = 1, name = "foo" } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).whereName( "foo" ).first();

                        expect( results ).toBeStruct();
                        expect( results ).toBe( { id = 1, name = "foo" } );
                        expect( getTestBindings( builder ) ).toBe( [ "foo" ] );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1",
                            options = {}
                        } );
                    } );
                } );

                describe( "find", function() {
                    it( "returns the first result by id when calling `find`", function() {
                        var builder = getBuilder();
                        builder.setReturnFormat( "query" );
                        var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id = 1, name = "foo" } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).find( 1 );

                        expect( results ).toBeStruct();
                        expect( results ).toBe( { id = 1, name = "foo" } );
                        expect( getTestBindings( builder ) ).toBe( [ 1 ] );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1",
                            options = {}
                        } );
                    } );
                } );

                describe( "value", function() {
                    it( "returns the first value when calling value", function() {
                        var builder = getBuilder();
                        var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""name"" FROM ""users"" LIMIT 1",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).value( "name" );

                        expect( results ).toBe( "foo" );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT ""name"" FROM ""users"" LIMIT 1",
                            options = {}
                        } );
                    } );
                } );

                describe( "values", function() {
                    it( "returns an array of values for a column", function() {
                        var builder = getBuilder();
                        var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" }, { name = "bar" } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).values( "name" );

                        expect( results ).toBe( [ "foo", "bar" ] );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        } );
                    } );
                } );

                describe( "implode", function() {
                    it( "can join the values of all columns together in to a single value", function() {
                        var builder = getBuilder();
                        var expectedQuery = queryNew( "name", "varchar", [
                            { name = "foo" },
                            { name = "bar" },
                            { name = "baz" }
                        ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).implode( "name" );

                        expect( results ).toBe( "foobarbaz" );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        } );
                    } );

                    it( "can specify a custom glue string when imploding", function() {
                        var builder = getBuilder();
                        var expectedQuery = queryNew( "name", "varchar", [
                            { name = "foo" },
                            { name = "bar" },
                            { name = "baz" }
                        ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).implode( "name", "-" );

                        expect( results ).toBe( "foo-bar-baz" );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT ""name"" FROM ""users""",
                            options = {}
                        } );
                    } );
                } );
            } );

            describe( "aggregate functions", function() {
                describe( "count", function() {
                    it( "can count all the records on a table", function() {
                        var builder = getBuilder();
                        var expectedCount = 1;
                        var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedCount } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).count();

                        expect( results ).toBe( expectedCount );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                            options = {}
                        } );
                    } );

                    it( "can count a specific column", function() {
                        var builder = getBuilder();
                        var expectedCount = 1;
                        var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedCount } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT COUNT(""name"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).count( "name" );

                        expect( results ).toBe( expectedCount );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT COUNT(""name"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        } );
                    } );

                    it( "should maintain selected columns after an aggregate has been executed", function() {
                        var builder = getBuilder();
                        var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = 1 } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        builder.select( [ "id", "name" ] ).from( "users" );
                        builder.from( "users" ).count();

                        expect( builder.getColumns() ).toBe( [ "id", "name" ] );
                    } );

                    it( "should clear out the aggregate properties after an aggregate has been executed", function() {
                        var builder = getBuilder();
                        var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = 1 } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        builder.from( "users" ).count();

                        expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                    } );
                } );

                describe( "max", function() {
                    it( "can return the max record of a table", function() {
                        var builder = getBuilder();
                        var expectedMax = 54;
                        var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedMax } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT MAX(""age"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).max( "age" );

                        expect( results ).toBe( expectedMax );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT MAX(""age"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        } );

                        expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                    } );
                } );

                describe( "min", function() {
                    it( "can return the min record of a table", function() {
                        var builder = getBuilder();
                        var expectedMin = 3;
                        var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedMin } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT MIN(""age"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).min( "age" );

                        expect( results ).toBe( expectedMin );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT MIN(""age"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        } );

                        expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                    } );
                } );

                describe( "sum", function() {
                    it( "can return the sum of a column in a table", function() {
                        var builder = getBuilder();
                        var expectedSum = 42;
                        var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedSum } ] );
                        builder.$( "runQuery" ).$args(
                            sql = "SELECT SUM(""answers"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        ).$results( expectedQuery );

                        var results = builder.from( "users" ).sum( "answers" );

                        expect( results ).toBe( expectedSum );

                        var runQueryLog = builder.$callLog().runQuery;
                        expect( runQueryLog ).toBeArray();
                        expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                        expect( runQueryLog[ 1 ] ).toBe( {
                            sql = "SELECT SUM(""answers"") AS ""aggregate"" FROM ""users""",
                            options = {}
                        } );

                        expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                    } );
                } );

                describe( "exists", function() {
                    it( "returns true if any records come back from the query", function() {
                        var builder = getBuilder();
                        builder.$( "runQuery", queryNew( "name,email", "CF_SQL_VARCHAR,CF_SQL_VARCHAR", [
                            { name = "foo", email = "bar" }
                        ] ) );
                        expect( builder.select( "*" ).from( "users" ).exists() ).toBe( true );

                        expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                    } );

                    it( "returns false if no records come back from the query", function() {
                        var builder = getBuilder();
                        builder.$( "runQuery", queryNew( "name,email", "CF_SQL_VARCHAR,CF_SQL_VARCHAR", [] ) );
                        expect( builder.select( "*" ).from( "users" ).exists() ).toBe( false );
                    } );
                } );
            } );

            describe( "returnFormat", function() {
                it( "has a default return value of array", function() {
                    var builder = getBuilder();
                    var data = [ { id = 1 } ];
                    var expectedQuery = queryNew( "id", "integer", data );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.select( "id" ).from( "users" ).get();

                    expect( results ).toBe( data );
                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "can return an array of structs", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "array" );
                    var data = [ { id = 1 } ];
                    var expectedQuery = queryNew( "id", "integer", data );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.select( "id" ).from( "users" ).get();

                    expect( results ).toBe( data );
                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "can return a query", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var data = [ { id = 1 } ];
                    var expectedQuery = queryNew( "id", "integer", data );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.select( "id" ).from( "users" ).get();

                    expect( results ).toBe( expectedQuery );
                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "can return the results of a closure", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( function( q ) {
                        var results = [];
                        for ( var row in q ) {
                            row.id *= 2;
                            arrayAppend( results, row );
                        }
                        return results;
                    } );
                    var data = [ { id = 1 }, { id = 2 } ];
                    var expectedQuery = queryNew( "id", "integer", data );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.select( "id" ).from( "users" ).get();

                    expect( results ).toBe( [ { id = 2 }, { id = 4 } ] );
                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    } );
                } );
            } );

            describe( "compiling the same builder multiple times", function() {
                it( "can call toSql many times and get the same output", function() {
                    var builder = getBuilder();
                    builder.from( "users" ).whereId( 10 );
                    var sql = builder.toSql();
                    var sqlAgain = builder.toSql();
                    expect( sql ).toBe( sqlAgain );
                } );
            } );
        } );

    }

    private function getBuilder() {
        var grammar = getMockBox()
            .createMock( "qb.models.Grammars.Grammar" );
        var queryUtils = getMockBox()
            .createMock( "qb.models.Query.QueryUtils" );
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" )
            .init( grammar, queryUtils );
        return builder;
    }

    private array function getTestBindings( required QueryBuilder builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}
