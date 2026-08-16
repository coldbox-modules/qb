component extends="tests.resources.AbstractQueryBuilderSpec" {

    function run() {
        super.run();

        describe( "SQL Server bulk inserts", function() {
            it( "inserts all rows from one JSON parameter", function() {
                var builder = getBuilder();
                var sql = builder
                    .from( "users" )
                    .insertBulk( values = [ { "id": 1, "name": "One" }, { "id": 2, "name": "Two" } ], toSql = true );

                expect( sql ).toBe( [
                    "INSERT INTO [users] ([id], [name]) SELECT [id], [name] FROM OPENJSON(?) WITH ([id] INTEGER '$.""id""', [name] NVARCHAR(MAX) '$.""name""')"
                ] );
                expect( builder.getBindings() ).toHaveLength( 1 );
                expect( deserializeJSON( builder.getBindings()[ 1 ].value ) ).toBe( [ { "id": 1, "name": "One" }, { "id": 2, "name": "Two" } ] );
            } );

            it( "supports explicit SQL types", function() {
                var builder = getBuilder();
                var sql = builder
                    .from( "measurements" )
                    .insertBulk(
                        values = [ { "reading": 1.5 } ],
                        sqlTypes = { "reading": "DECIMAL(10, 2)" },
                        toSql = true
                    );

                expect( sql ).toBe( [
                    "INSERT INTO [measurements] ([reading]) SELECT [reading] FROM OPENJSON(?) WITH ([reading] DECIMAL(10, 2) '$.""reading""')"
                ] );
            } );

            it( "infers bulk SQL types from negative and nullable values", function() {
                var insertValues = [ { "reading": -1 }, { "reading": javacast( "null", "" ) } ];
                var insertBuilder = getBuilder().from( "measurements" );
                var insertSql = insertBuilder.insertBulk( values = insertValues, toSql = true );
                var whereSql = getBuilder()
                    .from( "measurements" )
                    .whereInBulk( "reading", [ -1, javacast( "null", "" ), 2 ] )
                    .toSQL();

                expect( insertSql[ 1 ] ).toInclude( "[reading] INTEGER" );
                expect( whereSql ).toInclude( "WITH ([value] INTEGER '$')" );
            } );

            it( "escapes apostrophes in bulk insert JSON paths", function() {
                var sql = getBuilder()
                    .from( "records" )
                    .insertBulk( values = [ { "author's_note": "value" } ], toSql = true );

                expect( sql ).toBe( [
                    "INSERT INTO [records] ([author's_note]) SELECT [author's_note] FROM OPENJSON(?) WITH ([author's_note] NVARCHAR(MAX) '$.""author''s_note""')"
                ] );
            } );

            it( "applies returning columns to bulk inserts", function() {
                var sql = getBuilder()
                    .from( "users" )
                    .returning( "id" )
                    .insertBulk( values = [ { "name": "One" } ], toSql = true );

                expect( sql ).toBe( [
                    "INSERT INTO [users] ([name]) OUTPUT INSERTED.[id] SELECT [name] FROM OPENJSON(?) WITH ([name] NVARCHAR(MAX) '$.""name""')"
                ] );
            } );

            it( "applies raw returning expressions to bulk inserts", function() {
                var sql = getBuilder()
                    .from( "users" )
                    .returningRaw( "INSERTED.id AS insertedId" )
                    .insertBulk( values = [ { "name": "One" } ], toSql = true );

                expect( sql ).toBe( [
                    "INSERT INTO [users] ([name]) OUTPUT INSERTED.id AS insertedId SELECT [name] FROM OPENJSON(?) WITH ([name] NVARCHAR(MAX) '$.""name""')"
                ] );
            } );

            it( "applies raw returning expressions to regular inserts and upserts", function() {
                var insertSql = getBuilder()
                    .from( "users" )
                    .returningRaw( "INSERTED.id AS insertedId" )
                    .insert( values = { "name": "One" }, toSql = true );
                var upsertSql = getBuilder()
                    .from( "users" )
                    .returningRaw( "INSERTED.id AS insertedId" )
                    .upsert(
                        values = [ { "id": 1, "name": "One" } ],
                        target = [ "id" ],
                        update = [ "name" ],
                        toSql = true
                    );

                expect( insertSql ).toInclude( "OUTPUT INSERTED.id AS insertedId" );
                expect( upsertSql ).toInclude( "OUTPUT INSERTED.id AS insertedId" );
            } );
        } );

        describe( "SQL Server ordered unions", function() {
            it( "can limit independently ordered union branches", function() {
                var sql = getBuilder()
                    .select( "*" )
                    .fromSub( "t", function( q ) {
                        q.select( "id, name, modifiedDate" )
                            .selectRaw( "'Page' AS typeName" )
                            .from( "page" )
                            .orderBy( "modifiedDate", "DESC" )
                            .limit( 5 )
                            .unionAll( function( q ) {
                                q.select( "id, name, modifiedDate" )
                                    .selectRaw( "'Document' AS typeName" )
                                    .from( "document" )
                                    .orderBy( "modifiedDate", "DESC" )
                                    .limit( 5 );
                            } );
                    } )
                    .limit( 5 )
                    .orderBy( "modifiedDate", "DESC" )
                    .toSql();

                expect( sql ).toBe(
                    "SELECT TOP (5) * FROM (SELECT * FROM (SELECT TOP (5) [id], [name], [modifiedDate], 'Page' AS typeName FROM [page] ORDER BY [modifiedDate] DESC) AS [qb_union_0] UNION ALL SELECT * FROM (SELECT TOP (5) [id], [name], [modifiedDate], 'Document' AS typeName FROM [document] ORDER BY [modifiedDate] DESC) AS [qb_union_1]) AS [t] ORDER BY [modifiedDate] DESC"
                );
            } );

            it( "can limit an ordered union branch without ordering the root branch", function() {
                var sql = getBuilder()
                    .select( "id" )
                    .from( "users" )
                    .unionAll( function( q ) {
                        q.select( "id" )
                            .from( "archivedUsers" )
                            .orderByDesc( "id" )
                            .limit( 5 );
                    } )
                    .toSQL();

                expect( sql ).toBe(
                    "SELECT * FROM (SELECT [id] FROM [users]) AS [qb_union_0] UNION ALL SELECT * FROM (SELECT TOP (5) [id] FROM [archivedUsers] ORDER BY [id] DESC) AS [qb_union_1]"
                );
            } );

            it( "keeps root order bindings before independently ordered union branches", function() {
                var builder = getBuilder()
                    .select( "id" )
                    .from( "users" )
                    .where( "status", "current" )
                    .orderByRaw( "CASE WHEN id = ? THEN 0 ELSE 1 END", [ 10 ] )
                    .unionAll( function( unionQuery ) {
                        unionQuery
                            .select( "id" )
                            .from( "archivedUsers" )
                            .where( "status", "archived" )
                            .orderByRaw( "CASE WHEN id = ? THEN 0 ELSE 1 END", [ 20 ] )
                            .limit( 5 );
                    } );

                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ "current", 10, "archived", 20 ] );
            } );
        } );

        describe( "SQL Server data modification CTEs", function() {
            it( "compiles CTEs before update statements", function() {
                var builder = getBuilder()
                    .with( "active_users", function( cte ) {
                        cte.from( "users" ).where( "active", 1 );
                    } )
                    .from( "active_users" )
                    .where( "id", 42 );

                var sql = builder.update( values = { "name": "changed" }, toSQL = true );

                expect( sql ).toMatch( "^;?WITH" );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1, "changed", 42 ] );
            } );

            it( "compiles CTEs before delete statements", function() {
                var builder = getBuilder()
                    .with( "inactive_users", function( cte ) {
                        cte.from( "users" ).where( "active", 0 );
                    } )
                    .from( "inactive_users" )
                    .where( "id", 42 );

                var sql = builder.delete( toSQL = true );

                expect( sql ).toMatch( "^;?WITH" );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 0, 42 ] );
            } );
        } );

        describe( "SQL Server nested CTE queries", function() {
            it( "hoists common table expressions outside the EXISTS subquery", function() {
                var builder = getBuilder()
                    .with( "active_users", function( cte ) {
                        cte.from( "users" ).where( "active", 1 );
                    } )
                    .from( "active_users" )
                    .where( "id", 42 );

                expect( builder.exists( toSQL = true ) ).toBe(
                    ";WITH [active_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT CASE WHEN EXISTS (SELECT TOP (1) * FROM [active_users] WHERE [id] = ?) THEN 1 ELSE 0 END AS aggregate"
                );
            } );

            it( "hoists common table expressions outside derived tables", function() {
                var builder = getBuilder().fromSub( "active_users", function( source ) {
                    source
                        .with( "filtered_users", function( cte ) {
                            cte.from( "users" ).where( "active", 1 );
                        } )
                        .from( "filtered_users" )
                        .where( "id", 42 );
                } );

                expect( builder.toSQL() ).toBe(
                    ";WITH [filtered_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * FROM (SELECT * FROM [filtered_users] WHERE [id] = ?) AS [active_users]"
                );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1, 42 ] );
            } );

            it( "hoists common table expressions outside predicate subqueries", function() {
                var builder = getBuilder()
                    .from( "accounts" )
                    .whereExists( function( source ) {
                        source
                            .with( "active_users", function( cte ) {
                                cte.from( "users" ).where( "active", 1 );
                            } )
                            .from( "active_users" )
                            .whereColumn( "active_users.id", "accounts.userId" );
                    } );

                expect( builder.toSQL() ).toBe(
                    ";WITH [active_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * FROM [accounts] WHERE EXISTS (SELECT * FROM [active_users] WHERE [active_users].[id] = [accounts].[userId])"
                );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1 ] );
            } );

            it( "hoists common table expressions outside derived joins", function() {
                var builder = getBuilder()
                    .from( "accounts" )
                    .joinSub(
                        "active_users",
                        function( source ) {
                            source
                                .with( "filtered_users", function( cte ) {
                                    cte.from( "users" ).where( "active", 1 );
                                } )
                                .from( "filtered_users" );
                        },
                        "accounts.userId",
                        "=",
                        "active_users.id"
                    );

                expect( builder.toSQL() ).toBe(
                    ";WITH [filtered_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * FROM [accounts] INNER JOIN (SELECT * FROM [filtered_users]) AS [active_users] ON [accounts].[userId] = [active_users].[id]"
                );
            } );

            it( "rolls back hoisted CTEs when a derived join is deduplicated", function() {
                var builder = getBuilder().setPreventDuplicateJoins( true ).from( "accounts" );
                var addActiveUsers = function() {
                    builder.joinSub(
                        "active_users",
                        function( source ) {
                            source
                                .with( "filtered_users", function( cte ) {
                                    cte.from( "users" ).where( "active", 1 );
                                } )
                                .from( "filtered_users" );
                        },
                        "accounts.userId",
                        "=",
                        "active_users.id"
                    );
                };

                addActiveUsers();
                addActiveUsers();

                expect( builder.getCommonTables() ).toHaveLength( 1 );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1 ] );
            } );

            it( "hoists common table expressions outside cross joins", function() {
                var builder = getBuilder()
                    .from( "accounts" )
                    .crossJoinSub( "active_users", function( source ) {
                        source
                            .with( "filtered_users", function( cte ) {
                                cte.from( "users" ).where( "active", 1 );
                            } )
                            .from( "filtered_users" );
                    } );

                expect( builder.toSQL() ).toBe(
                    ";WITH [filtered_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * FROM [accounts] CROSS JOIN (SELECT * FROM [filtered_users]) AS [active_users]"
                );
            } );

            it( "hoists common table expressions outside APPLY sources", function() {
                var builder = getBuilder()
                    .from( "accounts" )
                    .crossApply( "active_users", function( source ) {
                        source
                            .with( "filtered_users", function( cte ) {
                                cte.from( "users" ).where( "active", 1 );
                            } )
                            .from( "filtered_users" );
                    } );

                expect( builder.toSQL() ).toBe(
                    ";WITH [filtered_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * FROM [accounts] CROSS APPLY (SELECT * FROM [filtered_users]) AS [active_users]"
                );
            } );

            it( "hoists common table expressions outside insert sources", function() {
                var builder = getBuilder().from( "archived_users" );
                var sql = builder.insertUsing(
                    columns = [ "id" ],
                    source = function( source ) {
                        source
                            .with( "active_users", function( cte ) {
                                cte.from( "users" ).where( "active", 1 );
                            } )
                            .select( "id" )
                            .from( "active_users" );
                    },
                    toSQL = true
                );

                expect( sql ).toBe(
                    ";WITH [active_users] AS (SELECT * FROM [users] WHERE [active] = ?) INSERT INTO [archived_users] ([id]) SELECT [id] FROM [active_users]"
                );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1 ] );
            } );

            it( "hoists common table expressions outside upsert sources", function() {
                var builder = getBuilder().from( "users" );
                var sql = builder.upsert(
                    values = [ "id", "name" ],
                    target = [ "id" ],
                    update = [ "name" ],
                    source = function( source ) {
                        source
                            .with( "incoming_users", function( cte ) {
                                cte.from( "staged_users" ).where( "active", 1 );
                            } )
                            .select( "id, name" )
                            .from( "incoming_users" );
                    },
                    toSQL = true
                );

                expect( sql ).toStartWith(
                    ";WITH [incoming_users] AS (SELECT * FROM [staged_users] WHERE [active] = ?) MERGE [users] AS [qb_target] USING (SELECT [id], [name] FROM [incoming_users]) AS [qb_src]"
                );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1 ] );
            } );

            it( "hoists common table expressions outside scalar update subqueries", function() {
                var builder = getBuilder().from( "users" );
                var sql = builder.update(
                    values = {
                        status: function( source ) {
                            source
                                .with( "latest_status", function( cte ) {
                                    cte.from( "statuses" ).where( "active", 1 );
                                } )
                                .select( "name" )
                                .from( "latest_status" )
                                .limit( 1 );
                        }
                    },
                    toSQL = true
                );

                expect( sql ).toBe(
                    ";WITH [latest_status] AS (SELECT * FROM [statuses] WHERE [active] = ?) UPDATE [users] SET [STATUS] = (SELECT TOP (1) [name] FROM [latest_status])"
                );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1 ] );
            } );

            it( "hoists common table expressions from upsert delete restrictions", function() {
                var builder = getBuilder().from( "users" );
                var sql = builder.upsert(
                    values = { id: 42, name: "Jane" },
                    target = [ "id" ],
                    update = [ "name" ],
                    deleteUnmatched = function( restrictions ) {
                        restrictions.whereExists( function( source ) {
                            source
                                .with( "protected_users", function( cte ) {
                                    cte.from( "user_flags" ).where( "user_flags.protected", 1 );
                                } )
                                .from( "protected_users" )
                                .whereColumn( "protected_users.userId", "qb_target.id" );
                        } );
                    },
                    toSQL = true
                );

                expect( sql ).toStartWith(
                    ";WITH [protected_users] AS (SELECT * FROM [user_flags] WHERE [user_flags].[protected] = ?) MERGE [users] AS [qb_target]"
                );
                expect( sql ).toInclude(
                    "WHEN NOT MATCHED BY SOURCE AND EXISTS (SELECT * FROM [protected_users] WHERE [protected_users].[userId] = [qb_target].[id]) THEN DELETE"
                );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1, 42, "Jane" ] );
            } );
        } );
    }

    function selectAllColumns() {
        return "SELECT * FROM [users]";
    }

    function selectSpecificColumn() {
        return "SELECT [name] FROM [users]";
    }

    function selectMultipleArray() {
        return "SELECT [name], COUNT(*) FROM [users]";
    }

    function addSelect() {
        return "SELECT [foo], [bar], [baz], [boom] FROM [users]";
    }

    function addSelectRemovesStar() {
        return "SELECT [foo] FROM [users]";
    }

    function selectDistinct() {
        return "SELECT DISTINCT [foo], [bar] FROM [users]";
    }

    function parseColumnAlias() {
        return "SELECT [foo] AS [bar] FROM [users]";
    }

    function parseColumnAliasWithQuotes() {
        return "SELECT [foo] AS [bar] FROM [users]";
    }

    function parseColumnAliasInWhere() {
        return { "sql": "SELECT [users].[foo] FROM [users] WHERE [users].[foo] = ?", "bindings": [ "bar" ] };
    }

    function dynamicWhere() {
        return { "sql": "SELECT [ID] FROM [users] WHERE [ID] = ?", "bindings": [ 1 ] };
    }

    function parseOperatorsWithDynamicWhere() {
        return { "sql": "SELECT [ID] FROM [users] WHERE [ID] > ?", "bindings": [ 1 ] };
    }

    function parseOperatorsWithDynamicAndWhere() {
        return { "sql": "SELECT [ID] FROM [users] WHERE [ID] > ? AND [ID] < ?", "bindings": [ 1, 10 ] };
    }

    function parseOperatorsWithDynamicOrWhere() {
        return { "sql": "SELECT [ID] FROM [users] WHERE [ID] > ? OR [ID] < ?", "bindings": [ 1, 0 ] };
    }

    function parseColumnAliasInWhereSubselect() {
        return {
            "sql": "SELECT [u].*, [user_roles].[roleid], [roles].[rolecode] FROM [users] AS [u] INNER JOIN [user_roles] ON [user_roles].[userid] = [u].[userid] LEFT JOIN [roles] ON [user_roles].[roleid] = [roles].[roleid] WHERE [user_roles].[roleid] = (SELECT [roleid] FROM [roles] WHERE [rolecode] = ?)",
            "bindings": [ "SYSADMIN" ]
        };
    }

    function wrapColumnsAndAliases() {
        return "SELECT [x].[y] AS [foo.bar] FROM [public].[users]";
    }

    function selectWithRaw() {
        return "SELECT substr( foo, 6 ) FROM [users]";
    }

    function selectRaw() {
        return "SELECT substr( foo, 6 ) FROM [users]";
    }

    function selectRawArray() {
        return "SELECT substr( foo, 6 ), trim( bar ) FROM [users]";
    }

    function selectConcat() {
        return "SELECT CONCAT(a,b,c,d) AS [my_alias] FROM [users]";
    }

    function selectConcatArray() {
        return "SELECT CONCAT(a,b,c,d) AS [my_alias] FROM [users]";
    }

    function clearSelect() {
        return "SELECT * FROM [users]";
    }

    function reselect() {
        return "SELECT [baz] FROM [users]";
    }

    function reselectRaw() {
        return "SELECT substr( foo, 6 ), trim( bar ) FROM [users]";
    }

    function wrappingDefault() {
        return "SELECT [foo], [bar] FROM [users]";
    }

    function wrappingGrammarOff() {
        return "SELECT foo, bar FROM users";
    }

    function wrappingBuilderOverride() {
        return "SELECT foo, bar FROM users";
    }

    function subSelect() {
        return "SELECT [name], (SELECT MAX(updated_date) FROM [posts] WHERE [posts].[user_id] = [users].[id]) AS [latestUpdatedDate] FROM [users]";
    }

    function subSelectQueryObject() {
        return "SELECT [name], (SELECT MAX(updated_date) FROM [posts] WHERE [posts].[user_id] = [users].[id]) AS [latestUpdatedDate] FROM [users]";
    }

    function subSelectWithBindings() {
        return {
            sql: "SELECT [name], (SELECT MAX(updated_date) FROM [posts] WHERE [posts].[user_id] = ?) AS [latestUpdatedDate] FROM [users]",
            bindings: [ 1 ]
        };
    }

    function from() {
        return "SELECT * FROM [users]";
    }

    function fromRaw() {
        return "SELECT * FROM Test (nolock)";
    }

    function fromDerivedTable() {
        return { sql: "SELECT * FROM (SELECT [id], [name] FROM [users] WHERE [age] >= ?) AS [u]", bindings: [ 21 ] };
    }

    function fromSubBindings() {
        return {
            sql: "SELECT [accounts].[id] FROM (SELECT [id], [name] FROM [users] WHERE [age] >= ?) AS [u] INNER JOIN [accounts] ON [accounts].[userId] = [u].[id] AND [accounts].[active] = ?",
            bindings: [ 21, 1 ]
        };
    }

    function fromEmpty() {
        return "SELECT 1 + 1";
    }

    function clearFrom() {
        return "SELECT 1 + 1";
    }

    function forRaw() {
        return "SELECT [id], [name] FROM [users] FOR JSON AUTO";
    }

    function noLock() {
        return { "sql": "SELECT * FROM [users] WITH (NOLOCK) WHERE [id] = ?", "bindings": [ 1 ] };
    }

    function sharedLock() {
        return { "sql": "SELECT * FROM [users] WITH (ROWLOCK,HOLDLOCK) WHERE [id] = ?", "bindings": [ 1 ] };
    }

    function lockForUpdate() {
        return { "sql": "SELECT * FROM [users] WITH (ROWLOCK,UPDLOCK,HOLDLOCK) WHERE [id] = ?", "bindings": [ 1 ] };
    }

    function lockForUpdateSkipLocked() {
        return { "sql": "SELECT * FROM [users] WITH (ROWLOCK,UPDLOCK,READPAST) WHERE [id] = ?", "bindings": [ 1 ] };
    }

    function lockArbitraryString() {
        return { "sql": "SELECT * FROM [users] foobar WHERE [id] = ?", "bindings": [ 1 ] };
    }

    function table() {
        return "SELECT * FROM [users]";
    }

    function tablePrefix() {
        return "SELECT * FROM [prefix_users]";
    }

    function tablePrefixWithAlias() {
        return "SELECT * FROM [prefix_users] AS [prefix_people]";
    }

    function columnAliasWithAs() {
        return "SELECT [id] AS [user_id] FROM [users]";
    }

    function columnAliasWithoutAs() {
        return "SELECT [id] AS [user_id] FROM [users]";
    }

    function tableAliasWithAs() {
        return "SELECT * FROM [users] AS [people]";
    }

    function tableAliasWithoutAs() {
        return "SELECT * FROM [users] AS [people]";
    }

    function basicWhere() {
        return { sql: "SELECT * FROM [users] WHERE [id] = ?", bindings: [ 1 ] };
    }

    function basicWhereWithQueryParamStruct() {
        return { sql: "SELECT * FROM [users] WHERE [createdDate] >= ?", bindings: [ "2019-01-01" ] };
    }

    function orWhere() {
        return { sql: "SELECT * FROM [users] WHERE [id] = ? OR [email] = ?", bindings: [ 1, "foo" ] };
    }

    function andWhere() {
        return { sql: "SELECT * FROM [users] WHERE [id] = ? AND [email] = ?", bindings: [ 1, "foo" ] };
    }

    function whereRaw() {
        return { sql: "SELECT * FROM [users] WHERE id = ? OR email = ?", bindings: [ 1, "foo" ] };
    }

    function orWhereRaw() {
        return { sql: "SELECT * FROM [users] WHERE [id] = ? OR email = ?", bindings: [ 1, "foo" ] };
    }

    function whereColumn() {
        return "SELECT * FROM [users] WHERE [first_name] = [last_name]";
    }

    function orWhereColumn() {
        return "SELECT * FROM [users] WHERE [first_name] = [last_name] OR [updated_date] > [created_date]";
    }

    function whereNested() {
        return {
            sql: "SELECT * FROM [users] WHERE [email] = ? OR ([name] = ? AND [age] >= ?)",
            bindings: [ "foo", "bar", 21 ]
        };
    }

    function whereSubselect() {
        return {
            sql: "SELECT * FROM [users] WHERE [email] = ? OR [id] = (SELECT MAX(id) FROM [users] WHERE [email] = ?)",
            bindings: [ "foo", "bar" ]
        };
    }

    function whereBoolean() {
        return {
            sql: "SELECT * FROM [users] WHERE [active] = ?",
            bindings: [
                {
                    "cfsqltype": "BIT",
                    "value": 1,
                    "list": false,
                    "null": false
                }
            ]
        };
    }

    function nullWhere() {
        return { sql: "SELECT * FROM [users] WHERE [id] = ?", bindings: [ "NULL" ] };
    }

    function whereExists() {
        return "SELECT * FROM [orders] WHERE EXISTS (SELECT 1 FROM [products] WHERE [products].[id] = [orders].[id])";
    }

    function orWhereExists() {
        return {
            sql: "SELECT * FROM [orders] WHERE [id] = ? OR EXISTS (SELECT 1 FROM [products] WHERE [products].[id] = [orders].[id])",
            bindings: [ 1 ]
        };
    }

    function whereNotExists() {
        return "SELECT * FROM [orders] WHERE NOT EXISTS (SELECT 1 FROM [products] WHERE [products].[id] = [orders].[id])";
    }

    function orWhereNotExists() {
        return {
            sql: "SELECT * FROM [orders] WHERE [id] = ? OR NOT EXISTS (SELECT 1 FROM [products] WHERE [products].[id] = [orders].[id])",
            bindings: [ 1 ]
        };
    }

    function whereNull() {
        return "SELECT * FROM [users] WHERE [id] IS NULL";
    }

    function orWhereNull() {
        return { sql: "SELECT * FROM [users] WHERE [id] = ? OR [id] IS NULL", bindings: [ 1 ] };
    }

    function whereNotNull() {
        return "SELECT * FROM [users] WHERE [id] IS NOT NULL";
    }

    function orWhereNotNull() {
        return { sql: "SELECT * FROM [users] WHERE [id] = ? OR [id] IS NOT NULL", bindings: [ 1 ] };
    }

    function whereBetween() {
        return { sql: "SELECT * FROM [users] WHERE [id] BETWEEN ? AND ?", bindings: [ 1, 2 ] };
    }

    function whereBetweenRaw() {
        return { sql: "SELECT * FROM [users] WHERE [createdDate] BETWEEN GETDATE() - 7 AND GETDATE()", bindings: [] };
    }

    function whereBetweenWithQueryParamStructs() {
        return {
            sql: "SELECT * FROM [users] WHERE [createdDate] BETWEEN ? AND ?",
            bindings: [ "2019-01-01", "2019-12-31" ]
        };
    }

    function whereNotBetween() {
        return { sql: "SELECT * FROM [users] WHERE [id] NOT BETWEEN ? AND ?", bindings: [ 1, 2 ] };
    }

    function whereInList() {
        return { sql: "SELECT * FROM [users] WHERE [id] IN (?, ?, ?)", bindings: [ 1, 2, 3 ] };
    }

    function whereInArray() {
        return { sql: "SELECT * FROM [users] WHERE [id] IN (?, ?, ?)", bindings: [ 1, 2, 3 ] };
    }

    function whereInArrayOfQueryParamStructs() {
        return { sql: "SELECT * FROM [users] WHERE [id] IN (?, ?, ?)", bindings: [ 1, 2, 3 ] };
    }

    function whereInBulk() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] IN (SELECT [value] FROM OPENJSON(?) WITH ([value] INTEGER '$'))",
            bindings: [ "[1,2,3]" ]
        };
    }

    function whereInBulkStrings() {
        return {
            sql: "SELECT * FROM [users] WHERE [status] IN (SELECT [value] FROM OPENJSON(?) WITH ([value] NVARCHAR(MAX) '$'))",
            bindings: [ "[""active"",""pending""]" ]
        };
    }

    function whereInBulkMixed() {
        return {
            sql: "SELECT * FROM [users] WHERE [externalId] IN (SELECT [value] FROM OPENJSON(?) WITH ([value] NVARCHAR(MAX) '$'))",
            bindings: [ "[1,""two""]" ]
        };
    }

    function whereInBulkBooleans() {
        return {
            sql: "SELECT * FROM [users] WHERE [active] IN (SELECT [value] FROM OPENJSON(?) WITH ([value] BIT '$'))",
            bindings: [ "[1,0]" ]
        };
    }

    function whereInBulkBigInt() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] IN (SELECT [value] FROM OPENJSON(?) WITH ([value] BIGINT '$'))",
            bindings: [ "[1,2]" ]
        };
    }

    function whereInBulkExplicitType() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] IN (SELECT [value] FROM OPENJSON(?) WITH ([value] BIGINT '$'))",
            bindings: [ "[1,2,3]" ]
        };
    }

    function bulkTimestampSqlType() {
        return "DATETIME2";
    }

    function orWhereInBulk() {
        return {
            sql: "SELECT * FROM [users] WHERE [active] = ? OR [id] IN (SELECT [value] FROM OPENJSON(?) WITH ([value] INTEGER '$'))",
            bindings: [ 1, "[1,2,3]" ]
        };
    }

    function whereNotInBulk() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] NOT IN (SELECT [value] FROM OPENJSON(?) WITH ([value] INTEGER '$'))",
            bindings: [ "[1,2,3]" ]
        };
    }

    function whereInBulkEmpty() {
        return "SELECT * FROM [users] WHERE 0 = 1";
    }

    function whereNotInBulkEmpty() {
        return "SELECT * FROM [users] WHERE 1 = 1";
    }

    function orWhereIn() {
        return { sql: "SELECT * FROM [users] WHERE [email] = ? OR [id] IN (?, ?, ?)", bindings: [ "foo", 1, 2, 3 ] };
    }

    function whereInRaw() {
        return "SELECT * FROM [users] WHERE [id] IN (1)";
    }

    function whereInEmpty() {
        return "SELECT * FROM [users] WHERE 0 = 1";
    }

    function whereNotInEmpty() {
        return "SELECT * FROM [users] WHERE 1 = 1";
    }

    function whereInSubSelect() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] IN (SELECT [id] FROM [users] WHERE [age] > ?)",
            bindings: [ 25 ]
        };
    }

    function whereLike() {
        return { sql: "SELECT * FROM [users] WHERE [username] LIKE ?", bindings: [ "Jo%" ] };
    }

    function whereNotLike() {
        return { sql: "SELECT * FROM [users] WHERE [username] NOT LIKE ?", bindings: [ "Jo%" ] };
    }

    function innerJoin() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id]";
    }

    function innerJoinRaw() {
        return "SELECT * FROM [users] INNER JOIN contacts (nolock) ON [users].[id] = [contacts].[id]";
    }

    function innerJoinShorthand() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id]";
    }

    function multipleJoins() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] INNER JOIN [addresses] AS [a] ON [a].[contact_id] = [contacts].[id]";
    }

    function joinWithWhere() {
        return { sql: "SELECT * FROM [users] INNER JOIN [contacts] ON [contacts].[balance] < ?", bindings: [ 100 ] };
    }

    function fullJoin() {
        return "SELECT * FROM [users] FULL JOIN [orders] ON [users].[id] = [orders].[user_id]";
    }

    function fullOuterJoin() {
        return "SELECT * FROM [users] FULL OUTER JOIN [orders] ON [users].[id] = [orders].[user_id]";
    }

    function leftJoin() {
        return "SELECT * FROM [users] LEFT JOIN [orders] ON [users].[id] = [orders].[user_id]";
    }

    function leftOuterJoin() {
        return "SELECT * FROM [users] LEFT OUTER JOIN [orders] ON [users].[id] = [orders].[user_id]";
    }

    function leftJoinTruncatingText() {
        return "SELECT * FROM [test] LEFT JOIN [last_team_tasks_queue_record] ON [last_team_tasks_queue_record].[task_territory_id] = [team_tasks_queue].[task_territory_id] AND ([last_team_tasks_queue_record].[when_created] IS NULL OR [last_team_tasks_queue_record].[when_created] <= [team_tasks_queue].[when_created])";
    }

    function leftJoinRaw() {
        return "SELECT * FROM [users] LEFT JOIN contacts (nolock) ON [users].[id] = [contacts].[id]";
    }

    function leftJoinNested() {
        return "SELECT * FROM [users] LEFT JOIN [orders] ON [users].[id] = [orders].[user_id]";
    }

    function rightJoin() {
        return "SELECT * FROM [orders] RIGHT JOIN [users] ON [orders].[user_id] = [users].[id]";
    }

    function rightOuterJoin() {
        return "SELECT * FROM [orders] RIGHT OUTER JOIN [users] ON [orders].[user_id] = [users].[id]";
    }

    function rightJoinRaw() {
        return "SELECT * FROM [users] RIGHT JOIN contacts (nolock) ON [users].[id] = [contacts].[id]";
    }

    function crossJoin() {
        return "SELECT * FROM [sizes] CROSS JOIN [colors]";
    }

    function crossJoinRaw() {
        return "SELECT * FROM [users] CROSS JOIN contacts (nolock)";
    }

    function complexJoin() {
        return {
            sql: "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] OR [users].[name] = [contacts].[name] OR [users].[admin] = ?",
            bindings: [ 1 ]
        };
    }

    function joinWithWhereNull() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] AND [contacts].[deleted_date] IS NULL";
    }

    function joinWithOrWhereNull() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] OR [contacts].[deleted_date] IS NULL";
    }

    function joinWithWhereNotNull() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] AND [contacts].[deleted_date] IS NOT NULL";
    }

    function joinWithOrWhereNotNull() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] OR [contacts].[deleted_date] IS NOT NULL";
    }

    function joinWithWhereIn() {
        return {
            sql: "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] AND [contacts].[id] IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereIn() {
        return {
            sql: "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] OR [contacts].[id] IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinWithWhereNotIn() {
        return {
            sql: "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] AND [contacts].[id] NOT IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereNotIn() {
        return {
            sql: "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] OR [contacts].[id] NOT IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinSub() {
        return {
            sql: "SELECT * FROM [users] AS [u] INNER JOIN (SELECT [id] FROM [contacts] WHERE [id] NOT IN (?, ?, ?)) AS [c] ON [u].[id] = [c].[id]",
            bindings: [ 1, 2, 3 ]
        };
    }

    function leftJoinSub() {
        return {
            sql: "SELECT * FROM [users] AS [u] LEFT JOIN (SELECT [id] FROM [contacts] WHERE [id] NOT IN (?, ?, ?)) AS [c] ON [u].[id] = [c].[id]",
            bindings: [ 1, 2, 3 ]
        };
    }

    function rightJoinSub() {
        return {
            sql: "SELECT * FROM [users] AS [u] RIGHT JOIN (SELECT [id] FROM [contacts] WHERE [id] NOT IN (?, ?, ?)) AS [c] ON [u].[id] = [c].[id]",
            bindings: [ 1, 2, 3 ]
        };
    }

    function crossJoinSub() {
        return {
            sql: "SELECT * FROM [users] AS [u] CROSS JOIN (SELECT [id] FROM [contacts] WHERE [id] NOT IN (?, ?, ?)) AS [c]",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinSubBindings() {
        return {
            sql: "SELECT * FROM [A] INNER JOIN (SELECT * FROM [B] WHERE [B].[B] = ?) AS [B] ON [A].[A] = [B].[B] WHERE [A].[A] = ? AND [A].[C] = ?",
            bindings: [ "B", "A", "C" ]
        };
    }

    function groupBy() {
        return "SELECT * FROM [users] GROUP BY [email]";
    }

    function groupByArray() {
        return "SELECT * FROM [users] GROUP BY [id], [email]";
    }

    function groupByRaw() {
        return "SELECT * FROM [users] GROUP BY DATE(created_at)";
    }

    function havingBasic() {
        return { sql: "SELECT * FROM [users] HAVING [email] > ?", bindings: [ 1 ] };
    }

    function havingRawExpression() {
        return { sql: "SELECT * FROM [users] GROUP BY [email] HAVING COUNT(email) > ?", bindings: [ 1 ] };
    }

    function havingRawColumnWithBindings() {
        return {
            sql: "SELECT * FROM [users] GROUP BY [email] HAVING CASE WHEN active = ? THEN COUNT(email) ELSE 0 END > ?",
            bindings: [ 1, 2 ]
        };
    }

    function havingRawColumn() {
        return { sql: "SELECT * FROM [users] GROUP BY [email] HAVING COUNT(email) > ?", bindings: [ 1 ] };
    }

    function havingRawValue() {
        return {
            sql: "SELECT COUNT(*) AS ""total"" FROM [items] WHERE [department] = ? GROUP BY [category] HAVING [total] > 3",
            bindings: [ "popular" ]
        };
    }

    function havingRawWhereIn() {
        return {
            sql: "SELECT [h].[account_id], [security_id] FROM [holdings] AS [h] INNER JOIN [accounts] AS [a] ON [h].[account_id] = [a].[account_id] WHERE [shares] <> ? AND [investment_type] = ? AND [security_id] NOT LIKE ? AND [h].[account_id] IN (SELECT [portfolioCode] FROM [accounts] WHERE [id] IN (?)) GROUP BY [h].[account_id], [security_id] HAVING COUNT(security_id) > ? ORDER BY [h].[account_id] ASC, [security_id] ASC",
            bindings: [ -999, "taxable", "*%", 662, 1 ]
        };
    }

    function orderBy() {
        return "SELECT * FROM [users] ORDER BY [email] ASC";
    }

    function orderByRandom() {
        return "SELECT * FROM [users] ORDER BY NEWID()";
    }

    function orderByDesc() {
        return "SELECT * FROM [users] ORDER BY [email] DESC";
    }

    function combinesOrderBy() {
        return "SELECT * FROM [users] ORDER BY [id] ASC, [email] DESC";
    }

    function orderByRaw() {
        return "SELECT * FROM [users] ORDER BY DATE(created_at)";
    }

    function orderByRawWithBindings() {
        return { "sql": "SELECT * FROM [users] ORDER BY CASE WHEN id = ? THEN 1 ELSE 0 END DESC", "bindings": [ 1 ] };
    }

    function orderByWithRawBindings() {
        return { "sql": "SELECT * FROM [users] ORDER BY CASE WHEN id = ? THEN 1 ELSE 0 END DESC", "bindings": [ 1 ] };
    }

    function orderByArray() {
        return "SELECT * FROM [users] ORDER BY [last_name] ASC, [age] ASC, [favorite_color] ASC";
    }

    function orderByClearOrders() {
        return "SELECT * FROM [users]";
    }

    function reorder() {
        return "SELECT * FROM [users] ORDER BY [age] ASC";
    }

    function orderByPipeDelimited() {
        return "SELECT * FROM [users] ORDER BY [last_name] DESC, [age] ASC, [favorite_color] DESC";
    }

    function orderByArrayOfArrays() {
        return "SELECT * FROM [users] ORDER BY [last_name] DESC, [age] ASC, [favorite_color] ASC";
    }

    function orderByArrayOfArraysIgnoringExtraValues() {
        return "SELECT * FROM [users] ORDER BY [last_name] DESC, [age] ASC, [favorite_color] ASC, [height] ASC";
    }

    function orderByComplex() {
        return "SELECT * FROM [users] ORDER BY [last_name] DESC, [age] ASC, [favorite_color] ASC, [favorite_food] DESC, [height] ASC, [weight] DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByRawInStruct() {
        return "SELECT * FROM [users] ORDER BY DATE(created_at), DATE(modified_at)";
    }

    function orderByMixSimpleAndPipeDelimited() {
        return "SELECT * FROM [users] ORDER BY [last_name] ASC, [age] DESC, [favorite_color] ASC";
    }

    function orderByStruct() {
        return "SELECT * FROM [users] ORDER BY [last_name] DESC, [age] ASC, [favorite_color] DESC";
    }

    function multipleOrderByCalls() {
        return "SELECT * FROM [users] ORDER BY [last_name] ASC, [age] DESC, [favorite_color] DESC, [height] DESC, [weight] ASC, [eye_color] DESC, [is_athletic] DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByMixed() {
        return "SELECT * FROM [users] ORDER BY [last_name] ASC, [age] DESC, [eye_color] DESC, [hair_color] ASC, [is_musical] ASC, [is_athletic] DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByList() {
        return "SELECT * FROM [users] ORDER BY [last_name] ASC, [age] ASC, [favorite_color] ASC";
    }

    function orderByListDefaultDirection() {
        return "SELECT * FROM [users] ORDER BY [last_name] DESC, [age] DESC, [favorite_color] DESC";
    }

    function orderByListPipeDelimited() {
        return "SELECT * FROM [users] ORDER BY [last_name] DESC, [age] DESC, [favorite_color] ASC";
    }

    function orderByListPipeDelimitedWithDefaultDirection() {
        return "SELECT * FROM [users] ORDER BY [last_name] ASC, [age] DESC, [favorite_color] ASC";
    }

    function union() {
        return {
            sql: "SELECT [name] FROM [users] WHERE [id] = ? UNION SELECT [name] FROM [users] WHERE [id] = ? UNION SELECT [name] FROM [users] WHERE [id] = ?",
            bindings: [ 1, 2, 3 ]
        };
    }

    function unionOrderBy() {
        return {
            sql: "SELECT [name] FROM [users] WHERE [id] = ? UNION SELECT [name] FROM [users] WHERE [id] = ? UNION SELECT [name] FROM [users] WHERE [id] = ? ORDER BY [name] ASC",
            bindings: [ 1, 2, 3 ]
        };
    }

    function unionAll() {
        return {
            sql: "SELECT [name] FROM [users] WHERE [id] = ? UNION ALL SELECT [name] FROM [users] WHERE [id] = ? UNION ALL SELECT [name] FROM [users] WHERE [id] = ?",
            bindings: [ 1, 2, 3 ]
        };
    }

    function unionCount() {
        return {
            sql: "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM (SELECT [name] FROM [users] WHERE [id] = ? UNION SELECT [name] FROM [users] WHERE [id] = ?) AS [qb_aggregate_source]",
            bindings: [ 1, 2 ]
        };
    }

    function commonTableExpression() {
        return {
            sql: ";WITH [UsersCTE] AS (SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] WHERE [users].[age] > ?) SELECT * FROM [UsersCTE] WHERE [user].[id] NOT IN (?, ?)",
            bindings: [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionWithRecursive() {
        return {
            sql: ";WITH [UsersCTE] AS (SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] WHERE [users].[age] > ?) SELECT * FROM [UsersCTE] WHERE [user].[id] NOT IN (?, ?)",
            bindings: [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionWithRecursiveWithColumns() {
        return {
            sql: ";WITH [UsersCTE] ([usersId],[contactsId]) AS (SELECT [users].[id] AS [usersId], [contacts].[id] AS [contactsId] FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] WHERE [users].[age] > ?) SELECT * FROM [UsersCTE] WHERE [user].[id] NOT IN (?, ?)",
            bindings: [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionMultipleCTEsWithRecursive() {
        return {
            sql: ";WITH [UsersCTE] AS (SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] WHERE [users].[age] > ?), [OrderCTE] AS (SELECT * FROM [orders] WHERE [created] > ?) SELECT * FROM [UsersCTE] WHERE [user].[id] NOT IN (?, ?)",
            bindings: [ 25, "2018-04-30", 1, 2 ]
        };
    }

    function commonTableExpressionBindingOrder() {
        return {
            sql: ";WITH [OrderCTE] AS (SELECT * FROM [orders] WHERE [created] > ?), [UsersCTE] AS (SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id] WHERE [users].[age] > ?) SELECT * FROM [UsersCTE] WHERE [user].[id] NOT IN (?, ?)",
            bindings: [ "2018-04-30", 25, 1, 2 ]
        };
    }

    function cteInsertUsing() {
        return {
            sql: ";WITH [UsersCTE] AS (SELECT * FROM [users] WHERE [users].[age] > ?) INSERT INTO [oldUsers] ([fname], [lname], [username], [age]) SELECT [fname], [lname], [username], [age] FROM [UsersCTE]",
            bindings: [ 25 ]
        };
    }

    function limit() {
        return "SELECT TOP (3) * FROM [users]";
    }

    function take() {
        return "SELECT TOP (1) * FROM [users]";
    }

    function offset() {
        return "SELECT * FROM [users] ORDER BY 1 OFFSET 3 ROWS";
    }

    function offsetWithOrderBy() {
        return "SELECT * FROM [users] ORDER BY [id] ASC OFFSET 3 ROWS";
    }

    function forPage() {
        return "SELECT * FROM [users] ORDER BY 1 OFFSET 30 ROWS FETCH NEXT 15 ROWS ONLY";
    }

    function forPageWithLessThanZeroValues() {
        return "SELECT * FROM [users] ORDER BY 1 OFFSET 0 ROWS FETCH NEXT 0 ROWS ONLY";
    }

    function insertSingleColumn() {
        return { sql: "INSERT INTO [users] ([email]) VALUES (?)", bindings: [ "foo" ] };
    }

    function insertBoolean() {
        return {
            sql: "INSERT INTO [users] ([active]) VALUES (?)",
            bindings: [
                {
                    "value": 1,
                    "cfsqltype": "BIT",
                    "null": false,
                    "list": false
                }
            ]
        };
    }

    function insertBooleanExplicitSqlType() {
        return {
            sql: "INSERT INTO [users] ([active]) VALUES (?)",
            bindings: [
                {
                    "value": true,
                    "cfsqltype": "BOOLEAN",
                    "null": false,
                    "list": false
                }
            ]
        };
    }

    function insertMultipleColumns() {
        return { sql: "INSERT INTO [users] ([email], [name]) VALUES (?, ?)", bindings: [ "foo", "bar" ] };
    }

    function batchInsert() {
        return {
            sql: "INSERT INTO [users] ([email], [name]) VALUES (?, ?), (?, ?)",
            bindings: [ "foo", "bar", "baz", "bleh" ]
        };
    }

    function insertWithRaw() {
        return {
            sql: "INSERT INTO [users] ([created_date], [email]) VALUES (now(), ?)",
            bindings: [ "john@example.com" ]
        };
    }

    function insertWithNull() {
        return {
            sql: "INSERT INTO [users] ([email], [optional_field]) VALUES (?, ?)",
            bindings: [ "john@example.com", "NULL" ]
        };
    }

    function insertUsingSelectCallback() {
        return {
            sql: "INSERT INTO [users] ([email], [createdDate]) SELECT [email], [createdDate] FROM [activeDirectoryUsers] WHERE [active] = ?",
            bindings: [ 1 ]
        };
    }

    function insertUsingSelectBuilder() {
        return {
            sql: "INSERT INTO [users] ([email], [createdDate]) SELECT [email], [createdDate] FROM [activeDirectoryUsers] WHERE [active] = ?",
            bindings: [ 1 ]
        };
    }

    function insertUsingDerivingColumnNames() {
        return {
            sql: "INSERT INTO [users] ([email], [createdDate]) SELECT [email], [modifiedDate] AS [createdDate] FROM [activeDirectoryUsers] WHERE [active] = ?",
            bindings: [ 1 ]
        };
    }

    function insertUsingDerivedColumnNamesFromRawStatements() {
        return {
            sql: "INSERT INTO [users] ([email], [createdDate]) SELECT [email], COALESCE(modifiedDate, NOW()) AS createdDate FROM [activeDirectoryUsers] WHERE [active] = ?",
            bindings: [ 1 ]
        };
    }

    function insertIgnore() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (VALUES (?, ?), (?, ?)) AS [qb_src] ([email], [name]) ON [qb_target].[email] = [qb_src].[email] WHEN NOT MATCHED BY TARGET THEN INSERT ([email], [name]) VALUES ([email], [name]);",
            bindings: [ "foo", "bar", "baz", "bleh" ]
        };
    }

    function returning() {
        return {
            sql: "INSERT INTO [users] ([email], [name]) OUTPUT INSERTED.[id] VALUES (?, ?)",
            bindings: [ "foo", "bar" ]
        };
    }

    function returningAll() {
        return {
            sql: "INSERT INTO [users] ([email], [name]) OUTPUT INSERTED.* VALUES (?, ?)",
            bindings: [ "foo", "bar" ]
        };
    }

    function returningIgnoresTableQualifiers() {
        return {
            sql: "INSERT INTO [users] ([email], [name]) OUTPUT INSERTED.[id] VALUES (?, ?)",
            bindings: [ "foo", "bar" ]
        };
    }

    function updateAllRecords() {
        return { sql: "UPDATE [users] SET [email] = ?, [name] = ?", bindings: [ "foo", "bar" ] };
    }

    function updateWithWhere() {
        return { sql: "UPDATE [users] SET [email] = ?, [name] = ? WHERE [Id] = ?", bindings: [ "foo", "bar", 1 ] };
    }

    function updateWithRaw() {
        return { sql: "UPDATE [hits] SET [count] = count + 1 WHERE [page] = ?", bindings: [ "someUrl" ] };
    }

    function updateWithRawTable() {
        return { sql: "UPDATE LogFiles..Browsers SET [UserAgent] = ? WHERE [ID] = ?", bindings: [ "Mozilla/5.0", 1 ] };
    }

    function addUpdate() {
        return {
            sql: "UPDATE [users] SET [email] = ?, [foo] = ?, [name] = ? WHERE [Id] = ?",
            bindings: [ "foo", "yes", "bar", 1 ]
        };
    }

    function updateWithJoin() {
        return "UPDATE [employees] SET [departmentName] = departments.name FROM [employees] INNER JOIN [departments] ON [departments].[id] = [employees].[departmentId]";
    }

    function updateWithJoinAndAliases() {
        return "UPDATE [e] SET [departmentName] = d.name FROM [employees] AS [e] INNER JOIN [departments] AS [d] ON [d].[id] = [e].[departmentId]";
    }

    function updateWithJoinAndWhere() {
        return {
            sql: "UPDATE [employees] SET [departmentName] = departments.name FROM [employees] INNER JOIN [departments] ON [departments].[id] = [employees].[departmentId] WHERE [departments].[active] = ?",
            bindings: [ 1 ]
        };
    }

    function updateWithSubselect() {
        return "UPDATE [employees] SET [departmentName] = (SELECT [name] FROM [departments] WHERE [employees].[departmentId] = [departments].[id])";
    }

    function updateWithBuilder() {
        return "UPDATE [employees] SET [departmentName] = (SELECT [name] FROM [departments] WHERE [employees].[departmentId] = [departments].[id])";
    }

    function updateReturning() {
        return {
            "sql": "UPDATE [users] SET [email] = ? OUTPUT INSERTED.[modifiedDate] WHERE [id] = ?",
            "bindings": [ "john@example.com", 1 ]
        };
    }

    function updateReturningRaw() {
        return {
            "sql": "UPDATE [users] SET [email] = ? OUTPUT DELETED.modifiedDate AS oldModifiedDate, INSERTED.modifiedDate AS newModifiedDate WHERE [id] = ?",
            "bindings": [ "john@example.com", 1 ]
        };
    }

    function updateReturningWithJoin() {
        return {
            "sql": "UPDATE [zzz] SET [created] = ?, [user_id] = ? OUTPUT INSERTED.[xxx] FROM [zzz] INNER JOIN [aaa] ON [aaa].[ddd] = [zzz].[ddd] WHERE [aaa].[id] IN (?, ?, ?)",
            "bindings": [ "2025-01-01 00:00:00", 1, 1, 2, 3 ]
        }
    }

    function updateReturningIgnoresTableQualifiers() {
        return {
            "sql": "UPDATE [users] SET [email] = ? OUTPUT INSERTED.[modifiedDate] WHERE [tablePrefix].[id] = ?",
            "bindings": [ "john@example.com", 1 ]
        };
    }

    function updateOrInsertNotExists() {
        return { sql: "INSERT INTO [users] ([name]) VALUES (?)", bindings: [ "baz" ] };
    }

    function updateOrInsertExists() {
        return { sql: "UPDATE TOP (1) [users] SET [name] = ? WHERE [email] = ?", bindings: [ "baz", "foo" ] };
    }

    function upsert() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (VALUES (?, ?, ?, ?)) AS [qb_src] ([active], [createdDate], [modifiedDate], [username]) ON [qb_target].[username] = [qb_src].[username] WHEN MATCHED THEN UPDATE SET [active] = [qb_src].[active], [modifiedDate] = [qb_src].[modifiedDate] WHEN NOT MATCHED BY TARGET THEN INSERT ([active], [createdDate], [modifiedDate], [username]) VALUES ([active], [createdDate], [modifiedDate], [username]);",
            bindings: [
                1,
                "2021-09-08 12:00:00",
                "2021-09-08 12:00:00",
                "foo"
            ]
        };
    }

    function upsertAllValues() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (VALUES (?, ?, ?, ?)) AS [qb_src] ([active], [createdDate], [modifiedDate], [username]) ON [qb_target].[username] = [qb_src].[username] WHEN MATCHED THEN UPDATE SET [active] = [qb_src].[active], [createdDate] = [qb_src].[createdDate], [modifiedDate] = [qb_src].[modifiedDate], [username] = [qb_src].[username] WHEN NOT MATCHED BY TARGET THEN INSERT ([active], [createdDate], [modifiedDate], [username]) VALUES ([active], [createdDate], [modifiedDate], [username]);",
            bindings: [
                1,
                "2021-09-08 12:00:00",
                "2021-09-08 12:00:00",
                "foo"
            ]
        };
    }

    function upsertEmptyUpdate() {
        return {
            sql: "INSERT INTO [users] ([active], [createdDate], [modifiedDate], [username]) VALUES (?, ?, ?, ?)",
            bindings: [
                1,
                "2021-09-08 12:00:00",
                "2021-09-08 12:00:00",
                "foo"
            ]
        };
    }

    function upsertWithInsertedValue() {
        return {
            sql: "MERGE [stats] AS [qb_target] USING (VALUES (?, ?, ?), (?, ?, ?)) AS [qb_src] ([postId], [viewedDate], [views]) ON [qb_target].[postId] = [qb_src].[postId] AND [qb_target].[viewedDate] = [qb_src].[viewedDate] WHEN MATCHED THEN UPDATE SET [views] = stats.views + 1 WHEN NOT MATCHED BY TARGET THEN INSERT ([postId], [viewedDate], [views]) VALUES ([postId], [viewedDate], [views]);",
            bindings: [
                1,
                "2021-09-08",
                1,
                2,
                "2021-09-08",
                1
            ]
        };
    }

    function upsertSingleTarget() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (VALUES (?, ?, ?, ?)) AS [qb_src] ([active], [createdDate], [modifiedDate], [username]) ON [qb_target].[username] = [qb_src].[username] WHEN MATCHED THEN UPDATE SET [active] = [qb_src].[active], [modifiedDate] = [qb_src].[modifiedDate] WHEN NOT MATCHED BY TARGET THEN INSERT ([active], [createdDate], [modifiedDate], [username]) VALUES ([active], [createdDate], [modifiedDate], [username]);",
            bindings: [
                1,
                "2021-09-08 12:00:00",
                "2021-09-08 12:00:00",
                "foo"
            ]
        };
    }

    function upsertMatchNulls() {
        return {
            sql: "MERGE [records] AS [qb_target] USING (VALUES (?, ?, ?), (?, ?, ?)) AS [qb_src] ([a], [b], [c]) ON ([qb_target].[a] = [qb_src].[a] OR ([qb_target].[a] IS NULL AND [qb_src].[a] IS NULL)) AND ([qb_target].[b] = [qb_src].[b] OR ([qb_target].[b] IS NULL AND [qb_src].[b] IS NULL)) WHEN MATCHED THEN UPDATE SET [c] = [qb_src].[c] WHEN NOT MATCHED BY TARGET THEN INSERT ([a], [b], [c]) VALUES ([a], [b], [c]);",
            bindings: [
                1,
                "NULL",
                "first",
                2,
                "value",
                "second"
            ]
        };
    }

    function upsertFromClosure() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (SELECT [username], [active], [createdDate], [modifiedDate] FROM [activeDirectoryUsers] WHERE [active] = ?) AS [qb_src] ON [qb_target].[username] = [qb_src].[username] WHEN MATCHED THEN UPDATE SET [active] = [qb_src].[active], [modifiedDate] = [qb_src].[modifiedDate] WHEN NOT MATCHED BY TARGET THEN INSERT ([username], [active], [createdDate], [modifiedDate]) VALUES ([username], [active], [createdDate], [modifiedDate]);",
            bindings: [ 1 ]
        };
    }

    function upsertFromBuilder() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (SELECT [username], [active], [createdDate], [modifiedDate] FROM [activeDirectoryUsers] WHERE [active] = ?) AS [qb_src] ON [qb_target].[username] = [qb_src].[username] WHEN MATCHED THEN UPDATE SET [active] = [qb_src].[active], [modifiedDate] = [qb_src].[modifiedDate] WHEN NOT MATCHED BY TARGET THEN INSERT ([username], [active], [createdDate], [modifiedDate]) VALUES ([username], [active], [createdDate], [modifiedDate]);",
            bindings: [ 1 ]
        };
    }

    function upsertWithDelete() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (SELECT [username], [active], [createdDate], [modifiedDate] FROM [activeDirectoryUsers] WHERE [active] = ?) AS [qb_src] ON [qb_target].[username] = [qb_src].[username] WHEN MATCHED THEN UPDATE SET [active] = [qb_src].[active], [modifiedDate] = [qb_src].[modifiedDate] WHEN NOT MATCHED BY TARGET THEN INSERT ([username], [active], [createdDate], [modifiedDate]) VALUES ([username], [active], [createdDate], [modifiedDate]) WHEN NOT MATCHED BY SOURCE THEN DELETE;",
            bindings: [ 1 ]
        };
    }

    function upsertWithDeleteRestricted() {
        return {
            sql: "MERGE [users] AS [qb_target] USING (SELECT [username], [active], [createdDate], [modifiedDate] FROM [activeDirectoryUsers] WHERE [active] = ?) AS [qb_src] ON [qb_target].[username] = [qb_src].[username] WHEN MATCHED THEN UPDATE SET [active] = [qb_src].[active], [modifiedDate] = [qb_src].[modifiedDate] WHEN NOT MATCHED BY TARGET THEN INSERT ([username], [active], [createdDate], [modifiedDate]) VALUES ([username], [active], [createdDate], [modifiedDate]) WHEN NOT MATCHED BY SOURCE AND [qb_target].[active] = ? THEN DELETE;",
            bindings: [
                {
                    "value": 1,
                    "cfsqltype": "INTEGER",
                    "null": false,
                    "list": false
                },
                {
                    "value": 0,
                    "cfsqltype": "INTEGER",
                    "null": false,
                    "list": false
                }
            ]
        };
    }

    function upsertUpdateToNull() {
        return {
            sql: "MERGE [vendors] AS [qb_target] USING (VALUES (?, ?, ?, ?)) AS [qb_src] ([code], [count], [name], [vendorCode]) ON [qb_target].[vendorCode] = [qb_src].[vendorCode] AND [qb_target].[code] = [qb_src].[code] WHEN MATCHED THEN UPDATE SET [count] = vendors.count + 1, [name] = ? WHEN NOT MATCHED BY TARGET THEN INSERT ([code], [count], [name], [vendorCode]) VALUES ([code], [count], [name], [vendorCode]);",
            bindings: [ "BB", 1, "NULL", "AA", "NULL" ]
        };
    }

    function upsertUpdateWithExplicitValue() {
        return {
            sql: "MERGE [vendors] AS [qb_target] USING (VALUES (?, ?, ?, ?)) AS [qb_src] ([code], [count], [name], [vendorCode]) ON [qb_target].[vendorCode] = [qb_src].[vendorCode] AND [qb_target].[code] = [qb_src].[code] WHEN MATCHED THEN UPDATE SET [count] = vendors.count + 1, [name] = ? WHEN NOT MATCHED BY TARGET THEN INSERT ([code], [count], [name], [vendorCode]) VALUES ([code], [count], [name], [vendorCode]);",
            bindings: [
                "BB",
                1,
                "New Name",
                "AA",
                "New Name"
            ]
        };
    }

    function deleteAll() {
        return "DELETE FROM [users]";
    }

    function deleteById() {
        return { sql: "DELETE FROM [users] WHERE [id] = ?", bindings: [ 1 ] };
    }

    function deleteWhere() {
        return { sql: "DELETE FROM [users] WHERE [email] = ?", bindings: [ "foo" ] };
    }

    function deleteReturning() {
        return { "sql": "DELETE FROM [users] OUTPUT DELETED.[id] WHERE [active] = ?", "bindings": [ 0 ] };
    }

    function deleteReturningIgnoresTableQualifiers() {
        return { "sql": "DELETE FROM [users] OUTPUT DELETED.[id] WHERE [tablePrefix].[active] = ?", "bindings": [ 0 ] };
    }

    function deleteWithJoins() {
        return {
            sql: "DELETE [users] FROM [users] INNER JOIN [warnings] ON [users].[id] = [warnings].[userId]",
            bindings: []
        };
    }

    function whereBuilderInstance() {
        return {
            sql: "SELECT * FROM [users] WHERE [email] = ? OR [id] = (SELECT MAX(id) FROM [users] WHERE [email] = ?)",
            bindings: [ "foo", "bar" ]
        };
    }

    function whereNullSubselect() {
        return "SELECT * FROM [users] WHERE (SELECT MAX(created_date) FROM [logins] WHERE [logins].[user_id] = [users].[id]) IS NULL";
    }

    function whereNullSubquery() {
        return "SELECT * FROM [users] WHERE (SELECT MAX(created_date) FROM [logins] WHERE [logins].[user_id] = [users].[id]) IS NULL";
    }

    function whereBetweenClosures() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] BETWEEN (SELECT MIN(id) FROM [users] WHERE [email] = ?) AND (SELECT MAX(id) FROM [users] WHERE [email] = ?)",
            bindings: [ "bar", "bar" ]
        };
    }

    function whereExistsBuilderInstance() {
        return {
            sql: "SELECT * FROM [orders] WHERE EXISTS (SELECT 1 FROM [products] WHERE [products].[id] = [orders].[id])",
            bindings: []
        };
    }

    function whereBetweenBuilderInstances() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] BETWEEN (SELECT MIN(id) FROM [users] WHERE [email] = ?) AND (SELECT MAX(id) FROM [users] WHERE [email] = ?)",
            bindings: [ "bar", "bar" ]
        };
    }

    function whereBetweenMixed() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] BETWEEN (SELECT MIN(id) FROM [users] WHERE [email] = ?) AND (SELECT MAX(id) FROM [users] WHERE [email] = ?)",
            bindings: [ "bar", "bar" ]
        };
    }

    function whereInBuilderInstance() {
        return {
            sql: "SELECT * FROM [users] WHERE [id] IN (SELECT [id] FROM [users] WHERE [age] > ?)",
            bindings: [ 25 ]
        };
    }

    function innerJoinCallback() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id]";
    }

    function innerJoinWithJoinInstance() {
        return "SELECT * FROM [users] INNER JOIN [contacts] ON [users].[id] = [contacts].[id]";
    }

    function orderBySubselect() {
        return "SELECT * FROM [users] ORDER BY (SELECT MAX(created_date) FROM [logins] WHERE [users].[id] = [logins].[user_id]) ASC";
    }

    function orderBySubselectDescending() {
        return "SELECT * FROM [users] ORDER BY (SELECT MAX(created_date) FROM [logins] WHERE [users].[id] = [logins].[user_id]) DESC";
    }

    function orderByBuilderInstance() {
        return "SELECT * FROM [users] ORDER BY (SELECT MAX(created_date) FROM [logins] WHERE [users].[id] = [logins].[user_id]) ASC";
    }

    function orderByBuilderInstanceDescending() {
        return "SELECT * FROM [users] ORDER BY (SELECT MAX(created_date) FROM [logins] WHERE [users].[id] = [logins].[user_id]) DESC";
    }

    function orderByBuilderWithBindings() {
        return {
            sql: "SELECT * FROM [users] ORDER BY (SELECT MAX(created_date) FROM [logins] WHERE [users].[id] = [logins].[user_id] AND [created_date] > ?) ASC",
            bindings: [ "2020-01-01 00:00:00" ]
        };
    }

    function reset() {
        return "SELECT * FROM [otherTable]";
    }

    function crossApply() {
        return {
            sql: "SELECT [u].[ID], [childCount].[c] FROM [users] AS [u] CROSS APPLY (SELECT count(*) c FROM [children] WHERE [children].[parentID] = [users].[ID] AND [children].[someCol] = ?) AS [childCount] WHERE [childCount].[c] > ?",
            bindings: [ 0, 1 ]
        }
    }

    function outerApply() {
        return {
            sql: "SELECT [u].[ID], [childCount].[c] FROM [users] AS [u] OUTER APPLY (SELECT count(*) c FROM [children] WHERE [children].[parentID] = [users].[ID] AND [children].[someCol] = ?) AS [childCount] WHERE [childCount].[c] > ?",
            bindings: [ 0, 1 ]
        }
    }

    function correctlyPositionsBindingsUsingCrossApply() {
        return {
            sql: "SELECT * FROM [A] CROSS APPLY (SELECT * FROM [x] WHERE [x].[x] = ? AND [x].[b] = [a].[b]) AS [B] OUTER APPLY (SELECT * FROM [y] WHERE [y].[y] = ? AND [y].[d] = [a].[d]) AS [D] WHERE [A].[A] = ? AND [A].[C] = ?",
            bindings: [ "B", "D", "A", "C" ]
        };
    }

    function duplicateCrossAndOuterAppliesEliminated() {
        return {
            sql: "SELECT * FROM [A] CROSS APPLY (SELECT [someColumn] FROM [crossapply_B]) AS [B] OUTER APPLY (SELECT [someColumn] FROM [outerapply_C]) AS [C] CROSS APPLY (SELECT [someColumn] FROM [crossapply_D]) AS [D] OUTER APPLY (SELECT [someColumn] FROM [outerapply_E]) AS [E]",
            bindings: []
        };
    }

    function joinCallbackWhereExists() {
        return {
            "sql": "SELECT * FROM [LeftTable] AS [lt] LEFT JOIN [RightTable] AS [rt] ON [rt].[id] = [lt].[id] AND EXISTS (SELECT 1 FROM [ExistsTable] AS [et] WHERE [et].[id] = [lt].[id])",
            "bindings": []
        };
    }

    private function getBuilder() {
        variables.utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
        variables.grammar = getMockBox().createMock( "qb.models.Grammars.SqlServerGrammar" ).init( variables.utils );
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
        return builder;
    }

    function jsonScalarSelect() {
        return "SELECT JSON_VALUE([profile], '$.""contacts""[0].""email""') AS [explicitName], JSON_VALUE([profile], '$.""contacts""[0].""email""') AS [shortcutName] FROM [users]";
    }

    function jsonScalarWhere() {
        return {
            sql: "SELECT * FROM [users] WHERE JSON_VALUE([profile], '$.""age""') >= ? AND JSON_VALUE([profile], '$.""age""') < ?",
            bindings: [ 21, 65 ]
        };
    }

    function jsonContains() {
        return {
            sql: "SELECT * FROM [users] WHERE ? IN (SELECT [value] FROM OPENJSON([profile], '$.""languages""')) AND ? IN (SELECT [value] FROM OPENJSON([profile], '$.""languages""'))",
            bindings: [ "en", "en" ]
        };
    }

    function jsonExists() {
        return "SELECT * FROM [users] WHERE 'name' IN (SELECT [key] FROM OPENJSON([profile])) AND 'name' IN (SELECT [key] FROM OPENJSON([profile]))";
    }

    function jsonLengthAndOrder() {
        return {
            sql: "SELECT * FROM [users] WHERE (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) > ? AND (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) > ? ORDER BY JSON_VALUE([profile], '$.""name""') ASC, JSON_VALUE([profile], '$.""name""') DESC",
            bindings: [ 1, 1 ]
        };
    }

    function jsonLengthEqualityShortcut() {
        return {
            sql: "SELECT * FROM [users] WHERE (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ? AND (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ? OR (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ? OR (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) = ?",
            bindings: [ 1, 1, 2, 2 ]
        };
    }

    function jsonCompoundContains() {
        return { exception: "UnsupportedOperation" };
    }

    function jsonNullContains() {
        return {
            sql: "SELECT * FROM [users] WHERE EXISTS (SELECT 1 FROM OPENJSON([profile], '$.""languages""') WHERE [type] = 0 AND ? IS NULL) AND EXISTS (SELECT 1 FROM OPENJSON([profile], '$.""languages""') WHERE [type] = 0 AND ? IS NULL)",
            bindings: [ "NULL", "NULL" ]
        };
    }

    function jsonNumericObjectKey() {
        return "SELECT JSON_VALUE([profile], '$.""0""') AS [explicitKey], JSON_VALUE([profile], '$[0]') AS [shortcutIndex] FROM [users]";
    }

    function jsonConveniencePredicates() {
        return {
            sql: "SELECT * FROM [users] WHERE NOT (? IN (SELECT [value] FROM OPENJSON([profile], '$.""languages""'))) OR NOT (? IN (SELECT [value] FROM OPENJSON([profile], '$.""languages""'))) OR ? IN (SELECT [value] FROM OPENJSON([profile], '$.""languages""')) AND NOT ('nickname' IN (SELECT [key] FROM OPENJSON([profile]))) OR 'name' IN (SELECT [key] FROM OPENJSON([profile])) OR NOT ('timezone' IN (SELECT [key] FROM OPENJSON([profile]))) OR (SELECT COUNT(*) FROM OPENJSON([profile], '$.""languages""')) > ?",
            bindings: [ "en", "fr", "de", 1 ]
        };
    }

    function aggregateExists() {
        return {
            "sql": "SELECT CASE WHEN EXISTS (SELECT TOP (1) * FROM [users] WHERE [id] = ?) THEN 1 ELSE 0 END AS aggregate",
            "bindings": [ 1 ]
        };
    }

}
