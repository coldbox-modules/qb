component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "builder alias", () => {
            describe( "columns", () => {
                it( "it renames aliases in the select clause", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users AS u" ).select( [ "u.id", "u.name" ] );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "u.id", "u.name" ] );
                    qb.withAlias( "u1" );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "u1.id", "u1.name" ] );
                } );

                it( "renames aliases in subselects", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "RMME_C" ).select( [ "RMME_C.ID_B", "RMME_C.ID_C", "RMME_C.ID_D" ] );
                    qb.subselect( "inlined_dValue", ( q ) => {
                        q.from( "RMME_D" )
                            .select( [ "RMME_D.dValue" ] )
                            .whereColumn( "RMME_C.ID_D", "RMME_D.ID_D" )
                            .limit( 1 );
                    } );
                    expect( qb.toSQL() ).toBe( "SELECT ""RMME_C"".""ID_B"", ""RMME_C"".""ID_C"", ""RMME_C"".""ID_D"", (SELECT ""RMME_D"".""dValue"" FROM ""RMME_D"" WHERE ""RMME_C"".""ID_D"" = ""RMME_D"".""ID_D"" LIMIT 1) AS ""inlined_dValue"" FROM ""RMME_C""" );
                    qb.withAlias( "C_2" );
                    expect( qb.toSQL() ).toBe( "SELECT ""C_2"".""ID_B"", ""C_2"".""ID_C"", ""C_2"".""ID_D"", (SELECT ""RMME_D"".""dValue"" FROM ""RMME_D"" WHERE ""C_2"".""ID_D"" = ""RMME_D"".""ID_D"" LIMIT 1) AS ""inlined_dValue"" FROM ""RMME_C"" AS ""C_2""" );
                } );

                it( "renames the base table name if used in column declarations", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" ).select( [ "users.id", "users.name" ] );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "users.id", "users.name" ] );
                    qb.withAlias( "u" );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "u.id", "u.name" ] );
                } );

                it( "renames aliases with multiple periods", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "MyServer.dbo.users" ).select( [ "MyServer.dbo.users.id", "MyServer.dbo.users.name" ] );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "MyServer.dbo.users.id", "MyServer.dbo.users.name" ] );
                    qb.withAlias( "u1" );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "u1.id", "u1.name" ] );
                } );

                it( "renames aliases with schema shortcut periods", () => {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "MyServer..users" ).select( [ "MyServer..users.id", "MyServer..users.name" ] );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "MyServer..users.id", "MyServer..users.name" ] );
                    qb.withAlias( "u1" );
                    expect( qb.getColumns().map( ( c ) => c.value ) ).toBe( [ "u1.id", "u1.name" ] );
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

                it( "renames the columns used in bulk and subquery where in clauses", () => {
                    var bulkQuery = new qb.models.Query.QueryBuilder();
                    bulkQuery
                        .from( "users" )
                        .whereInBulk( "users.id", [ 1, 2, 3 ] )
                        .withAlias( "u" );
                    expect( bulkQuery.getWheres()[ 1 ].column.value ).toBe( "u.id" );

                    var inSubQuery = new qb.models.Query.QueryBuilder();
                    inSubQuery
                        .from( "users" )
                        .whereIn( "users.id", function( query ) {
                            query.from( "members" ).select( "members.userId" );
                        } )
                        .withAlias( "u" );
                    expect( inSubQuery.getWheres()[ 1 ].column.value ).toBe( "u.id" );

                    var notInSubQuery = new qb.models.Query.QueryBuilder();
                    notInSubQuery
                        .from( "users" )
                        .whereNotIn( "users.id", function( query ) {
                            query.from( "members" ).select( "members.userId" );
                        } )
                        .withAlias( "u" );
                    expect( notInSubQuery.getWheres()[ 1 ].column.value ).toBe( "u.id" );
                } );

                it( "renames aliases inside JSON path columns for every supported where shape", () => {
                    var queries = [];
                    queries.append(
                        new qb.models.Query.QueryBuilder().from( "users" ).whereIn( "users.profile->id", [ 1 ] )
                    );
                    queries.append(
                        new qb.models.Query.QueryBuilder().from( "users" ).whereNull( "users.profile->id" )
                    );
                    queries.append(
                        new qb.models.Query.QueryBuilder().from( "users" ).whereBetween( "users.profile->id", 1, 2 )
                    );

                    queries.each( function( query ) {
                        arguments.query.withAlias( "u" );
                        expect( arguments.query.getWheres()[ 1 ].column.value.column ).toBe( "u.profile" );
                    } );

                    var columnQuery = new qb.models.Query.QueryBuilder()
                        .from( "users" )
                        .whereColumn( "users.profile->id", "users.settings->profileId" )
                        .withAlias( "u" );
                    expect( columnQuery.getWheres()[ 1 ].first.value.column ).toBe( "u.profile" );
                    expect( columnQuery.getWheres()[ 1 ].second.value.column ).toBe( "u.settings" );

                    var subQuery = new qb.models.Query.QueryBuilder()
                        .from( "users" )
                        .where(
                            "users.profile->id",
                            "=",
                            function( query ) {
                                query.from( "members" ).select( "members.userId" );
                            }
                        )
                        .withAlias( "u" );
                    expect( subQuery.getWheres()[ 1 ].column.value.column ).toBe( "u.profile" );
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

                it( "renames correlated aliases inside where between subqueries", function() {
                    var qb = new qb.models.Query.QueryBuilder();
                    qb.from( "users" )
                        .whereBetween(
                            "users.score",
                            function( lowerBound ) {
                                lowerBound
                                    .selectRaw( "MIN(score)" )
                                    .from( "scores" )
                                    .whereColumn( "scores.userId", "users.id" );
                            },
                            function( upperBound ) {
                                upperBound
                                    .selectRaw( "MAX(score)" )
                                    .from( "scores" )
                                    .whereColumn( "scores.userId", "users.id" );
                            }
                        )
                        .withAlias( "u" );

                    expect( qb.toSQL() ).notToInclude( """users"".""id""" );
                    expect( qb.toSQL() ).toInclude( """u"".""id""" );
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

                it( "supports random and subquery orders while renaming aliases", () => {
                    var randomQuery = new qb.models.Query.QueryBuilder()
                        .from( "users" )
                        .orderByRandom()
                        .withAlias( "u" );
                    expect( randomQuery.toSQL() ).toBe( "SELECT * FROM ""users"" AS ""u"" ORDER BY RANDOM()" );

                    var subQuery = new qb.models.Query.QueryBuilder()
                        .from( "users" )
                        .orderBy( function( query ) {
                            query.from( "logins" ).selectRaw( "MAX(logins.createdDate)" );
                        } )
                        .withAlias( "u" );
                    expect( subQuery.toSQL() ).toBe(
                        "SELECT * FROM ""users"" AS ""u"" ORDER BY (SELECT MAX(logins.createdDate) FROM ""logins"") ASC"
                    );
                } );
            } );

            it( "does not rewrite aliases that only share a prefix", () => {
                var qb = new qb.models.Query.QueryBuilder()
                    .from( "users" )
                    .select( "usersArchive.id" )
                    .withAlias( "u" );

                expect( qb.toSQL() ).toBe( "SELECT ""usersArchive"".""id"" FROM ""users"" AS ""u""" );
            } );

            it( "renames correlated aliases inside union branches", function() {
                var qb = new qb.models.Query.QueryBuilder();
                qb.from( "users" )
                    .whereExists( function( existsQuery ) {
                        existsQuery
                            .selectRaw( "1" )
                            .from( "logins" )
                            .whereColumn( "logins.userId", "users.id" )
                            .union( function( unionQuery ) {
                                unionQuery
                                    .selectRaw( "1" )
                                    .from( "archived_logins" )
                                    .whereColumn( "archived_logins.userId", "users.id" );
                            } );
                    } )
                    .withAlias( "u" );

                expect( qb.toSQL() ).notToInclude( """users"".""id""" );
                expect( qb.toSQL() ).toInclude( """u"".""id""" );
            } );

            it( "does not rename aliases shadowed by a union branch table", function() {
                var qb = new qb.models.Query.QueryBuilder();
                qb.from( "users" )
                    .select( "users.id" )
                    .union( function( unionQuery ) {
                        unionQuery.from( "users" ).select( "users.id" );
                    } )
                    .withAlias( "u" );

                expect( qb.toSQL() ).toBe(
                    "SELECT ""u"".""id"" FROM ""users"" AS ""u"" UNION SELECT ""users"".""id"" FROM ""users"""
                );
            } );

            it( "renames correlated aliases inside common table expressions", function() {
                var qb = new qb.models.Query.QueryBuilder();
                qb.from( "users" )
                    .whereExists( function( existsQuery ) {
                        existsQuery
                            .with( "recent_logins", function( cte ) {
                                cte.from( "logins" ).whereColumn( "logins.userId", "users.id" );
                            } )
                            .from( "recent_logins" );
                    } )
                    .withAlias( "u" );

                expect( qb.toSQL() ).notToInclude( """users"".""id""" );
                expect( qb.toSQL() ).toInclude( """u"".""id""" );
            } );

            it( "does not rename aliases shadowed by a common table expression table", function() {
                var qb = new qb.models.Query.QueryBuilder();
                qb.with( "local_users", function( cte ) {
                        cte.from( "users" ).select( "users.id" );
                    } )
                    .from( "users" )
                    .select( "users.id" )
                    .withAlias( "u" );

                expect( qb.toSQL() ).toBe(
                    "WITH ""local_users"" AS (SELECT ""users"".""id"" FROM ""users"") SELECT ""u"".""id"" FROM ""users"" AS ""u"""
                );
            } );
        } );
    }

}
