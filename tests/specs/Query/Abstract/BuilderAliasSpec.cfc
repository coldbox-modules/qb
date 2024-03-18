component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "builder alias", () => {
            describe( "columns", () => {
                it( "it renames aliases in the select clause", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users AS u" ).select( [ "u.id", "u.name" ] );
                    expect( qb.getColumns() ).toBe( [ "u.id", "u.name" ] );
                    qb.withAlias( "u1" );
                    expect( qb.getColumns() ).toBe( [ "u1.id", "u1.name" ] );
                } );

                it( "renames the base table name if used in column declarations", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).select( [ "users.id", "users.name" ] );
                    expect( qb.getColumns() ).toBe( [ "users.id", "users.name" ] );
                    qb.withAlias( "u" );
                    expect( qb.getColumns() ).toBe( [ "u.id", "u.name" ] );
                } );
            } );

            describe( "wheres", () => {
                it( "renames the columns used in where basic clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).where( "users.isActive", 1 );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""isActive"" = ?" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""isActive"" = ?" );
                } );

                it( "renames the columns used in where column clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).whereColumn( "users.createdDate", "users.modifiedDate" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""createdDate"" = ""users"".""modifiedDate""" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""createdDate"" = ""u"".""modifiedDate""" );
                } );

                it( "renames the columns used in where sub clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();

                    qb.from( "users u1" )
                        .where( "u1.email", "foo" )
                        .orWhere(
                            "u1.id",
                            "=",
                            function( q ) {
                                q.select( q.raw( "MAX(id)" ) )
                                    .from( "users u2" )
                                    .where( "u2.email", "bar" )
                                    .whereColumn( "u1.email", "<>", "u2.email" );
                            }
                        );

                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u1"" WHERE ""u1"".""email"" = ? OR ""u1"".""id"" = (SELECT MAX(id) FROM ""users"" AS ""u2"" WHERE ""u2"".""email"" = ? AND ""u1"".""email"" <> ""u2"".""email"")" );

                    qb.withAlias( "u3" );

                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u3"" WHERE ""u3"".""email"" = ? OR ""u3"".""id"" = (SELECT MAX(id) FROM ""users"" AS ""u2"" WHERE ""u2"".""email"" = ? AND ""u3"".""email"" <> ""u2"".""email"")" );
                } );

                it( "renames the columns used in where in clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).whereIn( "users.id", [ 1, 2, 3 ] );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""id"" IN (?, ?, ?)" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""id"" IN (?, ?, ?)" );
                } );

                it( "renames the columns used in where not in clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).whereNotIn( "users.id", [ 1, 2, 3 ] );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""id"" NOT IN (?, ?, ?)" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""id"" NOT IN (?, ?, ?)" );
                } );

                it( "renames the columns used in where exists clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .whereExists( ( q ) => {
                            return q
                                .selectRaw( 1 )
                                .from( "logins" )
                                .whereColumn( "logins.userId", "users.id" )
                                .andWhere( "logins.createdDate", ">=", "2024-03-15 00:00:00" );
                        } );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE EXISTS (SELECT 1 FROM ""logins"" WHERE ""logins"".""userId"" = ""users"".""id"" AND ""logins"".""createdDate"" >= ?)" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE EXISTS (SELECT 1 FROM ""logins"" WHERE ""logins"".""userId"" = ""u"".""id"" AND ""logins"".""createdDate"" >= ?)" );
                } );

                it( "renames the columns used in where not exists clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .whereNotExists( ( q ) => {
                            return q
                                .selectRaw( 1 )
                                .from( "logins" )
                                .whereColumn( "logins.userId", "users.id" )
                                .andWhere( "logins.createdDate", ">=", "2024-03-15 00:00:00" );
                        } );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE NOT EXISTS (SELECT 1 FROM ""logins"" WHERE ""logins"".""userId"" = ""users"".""id"" AND ""logins"".""createdDate"" >= ?)" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE NOT EXISTS (SELECT 1 FROM ""logins"" WHERE ""logins"".""userId"" = ""u"".""id"" AND ""logins"".""createdDate"" >= ?)" );
                } );

                it( "renames the columns used in nested where clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .where( ( q ) => {
                            q.where( "users.isActive", 1 );
                            q.andWhere( "users.isConfirmed", 1 );
                        } );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE (""users"".""isActive"" = ? AND ""users"".""isConfirmed"" = ?)" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE (""u"".""isActive"" = ? AND ""u"".""isConfirmed"" = ?)" );
                } );

                it( "renames the columns used in where null clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).whereNull( "users.canceledDate" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""canceledDate"" IS NULL" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""canceledDate"" IS NULL" );
                } );

                it( "renames the columns used in where not null clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).whereNotNull( "users.canceledDate" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""canceledDate"" IS NOT NULL" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""canceledDate"" IS NOT NULL" );
                } );

                it( "renames the columns used in where null sub clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .whereNull( function( q ) {
                            q.selectRaw( "MAX(created_date)" )
                                .from( "logins" )
                                .whereColumn( "logins.user_id", "users.id" );
                        } );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE (SELECT MAX(created_date) FROM ""logins"" WHERE ""logins"".""user_id"" = ""users"".""id"") IS NULL" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE (SELECT MAX(created_date) FROM ""logins"" WHERE ""logins"".""user_id"" = ""u"".""id"") IS NULL" );
                } );

                it( "renames the columns used in where not null sub clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .whereNotNull( function( q ) {
                            q.selectRaw( "MAX(created_date)" )
                                .from( "logins" )
                                .whereColumn( "logins.user_id", "users.id" );
                        } );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE (SELECT MAX(created_date) FROM ""logins"" WHERE ""logins"".""user_id"" = ""users"".""id"") IS NOT NULL" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE (SELECT MAX(created_date) FROM ""logins"" WHERE ""logins"".""user_id"" = ""u"".""id"") IS NOT NULL" );
                } );

                it( "renames the columns used in where between clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .whereBetween( "users.lastLoginDate", "2024-02-15 00:00:00", "2024-03-14 23:59:59" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""lastLoginDate"" BETWEEN ? AND ?" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""lastLoginDate"" BETWEEN ? AND ?" );
                } );

                it( "renames the columns used in where not between clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .whereNotBetween( "users.lastLoginDate", "2024-02-15 00:00:00", "2024-03-14 23:59:59" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" WHERE ""users"".""lastLoginDate"" NOT BETWEEN ? AND ?" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" WHERE ""u"".""lastLoginDate"" NOT BETWEEN ? AND ?" );
                } );
            } );

            describe( "joins", () => {
                it( "renames the columns used in join clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .join( "contacts", "users.id", "contacts.id" )
                        .join( "addresses AS a", "a.contact_id", "contacts.id" )
                        .leftJoin( "logins", ( j ) => {
                            j.on( "logins.user_id", "users.id" );
                        } );

                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" INNER JOIN ""contacts"" ON ""users"".""id"" = ""contacts"".""id"" INNER JOIN ""addresses"" AS ""a"" ON ""a"".""contact_id"" = ""contacts"".""id"" LEFT JOIN ""logins"" ON ""logins"".""user_id"" = ""users"".""id""" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" INNER JOIN ""contacts"" ON ""u"".""id"" = ""contacts"".""id"" INNER JOIN ""addresses"" AS ""a"" ON ""a"".""contact_id"" = ""contacts"".""id"" LEFT JOIN ""logins"" ON ""logins"".""user_id"" = ""u"".""id""" );
                } );
            } );

            describe( "groups", () => {
                it( "renames the columns used in group clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "logins" )
                        .select( "userId" )
                        .selectRaw( "MAX(createdDate) AS lastLoginDate" )
                        .groupBy( "logins.userId" );

                    expect( qb.toSQL() ).toBe( "SELECT ""userId"", MAX(createdDate) AS lastLoginDate FROM ""logins"" GROUP BY ""logins"".""userId""" );
                    qb.withAlias( "l" );
                    expect( qb.toSQL() ).toBe( "SELECT ""userId"", MAX(createdDate) AS lastLoginDate FROM ""logins"" AS ""l"" GROUP BY ""l"".""userId""" );
                } );
            } );

            describe( "orders", () => {
                it( "renames the columns used in orderBy clauses", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).orderByDesc( "users.lastLoginDate" );

                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" ORDER BY ""users"".""lastLoginDate"" DESC" );
                    qb.withAlias( "u" );
                    expect( qb.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" ORDER BY ""u"".""lastLoginDate"" DESC" );
                } );
            } );
        } );
    }

}
