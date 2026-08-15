component extends="tests.resources.AbstractSchemaBuilderSpec" {

    function run() {
        super.run();

        describe( "SQL Server column modifications", function() {
            it( "replaces a default constraint when modifying a column", function() {
                testCase(
                    function( schema ) {
                        return schema.alter(
                            "mars_in_wash_sales",
                            function( table ) {
                                table.modifyColumn( "shares", table.smallinteger( "shares" ).default( -999 ) );
                            },
                            {},
                            false
                        );
                    },
                    [
                        "DECLARE @objectId INT = OBJECT_ID(N'[mars_in_wash_sales]'), @constraintName SYSNAME, @schemaName SYSNAME, @tableName SYSNAME; SELECT @constraintName = [dc].[name], @schemaName = OBJECT_SCHEMA_NAME([dc].[parent_object_id]), @tableName = OBJECT_NAME([dc].[parent_object_id]) FROM [sys].[default_constraints] AS [dc] INNER JOIN [sys].[columns] AS [c] ON [c].[default_object_id] = [dc].[object_id] WHERE [dc].[parent_object_id] = @objectId AND [c].[name] = N'shares'; IF @constraintName IS NOT NULL EXEC(N'ALTER TABLE ' + QUOTENAME(@schemaName) + N'.' + QUOTENAME(@tableName) + N' DROP CONSTRAINT ' + QUOTENAME(@constraintName))",
                        "ALTER TABLE [mars_in_wash_sales] ALTER COLUMN [shares] SMALLINT NOT NULL",
                        "ALTER TABLE [mars_in_wash_sales] ADD CONSTRAINT [df_mars_in_wash_sales_shares] DEFAULT -999 FOR [shares]"
                    ]
                );
            } );

            it( "does not interpolate caller-provided identifiers into dynamic SQL", function() {
                testCase(
                    function( schema ) {
                        return schema.alter(
                            "odd]name'",
                            function( table ) {
                                table.modifyColumn( "sha]res'", table.smallinteger( "sha]res'" ).default( -999 ) );
                            },
                            {},
                            false
                        );
                    },
                    [
                        "DECLARE @objectId INT = OBJECT_ID(N'[odd]]name'']'), @constraintName SYSNAME, @schemaName SYSNAME, @tableName SYSNAME; SELECT @constraintName = [dc].[name], @schemaName = OBJECT_SCHEMA_NAME([dc].[parent_object_id]), @tableName = OBJECT_NAME([dc].[parent_object_id]) FROM [sys].[default_constraints] AS [dc] INNER JOIN [sys].[columns] AS [c] ON [c].[default_object_id] = [dc].[object_id] WHERE [dc].[parent_object_id] = @objectId AND [c].[name] = N'sha]res'''; IF @constraintName IS NOT NULL EXEC(N'ALTER TABLE ' + QUOTENAME(@schemaName) + N'.' + QUOTENAME(@tableName) + N' DROP CONSTRAINT ' + QUOTENAME(@constraintName))",
                        "ALTER TABLE [odd]]name'] ALTER COLUMN [sha]]res'] SMALLINT NOT NULL",
                        "ALTER TABLE [odd]]name'] ADD CONSTRAINT [df_odd]]name'_sha]]res'] DEFAULT -999 FOR [sha]]res']"
                    ]
                );
            } );
        } );

        describe( "SQL Server rename literals", function() {
            it( "escapes apostrophes in object names", function() {
                var statements = getBuilder().rename( "worker's", "employee's", {}, false ).toSQL();

                expect( statements ).toBe( [ "EXEC sp_rename N'worker''s', N'employee''s'" ] );
            } );
        } );

        describe( "SQL Server drop all objects", function() {
            it( "scopes foreign keys and qualifies tables in the requested schema", function() {
                var schema = getBuilder();
                variables.mockGrammar.$(
                    "runQuery",
                    queryNew(
                        "table_name,table_schema",
                        "varchar,varchar",
                        [ { table_name: "users", table_schema: "tenant" } ]
                    )
                );

                var statements = schema.dropAllObjects( {}, false, "tenant" );

                expect( statements[ 1 ] ).toInclude( "QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))" );
                expect( statements[ 1 ] ).toInclude( "WHERE OBJECT_SCHEMA_NAME(parent_object_id) = N'tenant'" );
                expect( statements[ 2 ] ).toBeWithCase( "DROP TABLE [tenant].[users]" );
                expect( variables.mockGrammar.$callLog().runQuery[ 1 ][ 1 ] ).toInclude(
                    "WHERE [table_schema] = ? AND [table_type] = 'BASE TABLE'"
                );
            } );
        } );

        describe( "SQL Server CTE-backed schema queries", function() {
            it( "creates views with a statement-level common table expression", function() {
                var statements = getBuilder()
                    .createView(
                        "active_users",
                        function( query ) {
                            query
                                .with( "filtered_users", function( cte ) {
                                    cte.from( "users" ).where( "active", 1 );
                                } )
                                .from( "filtered_users" );
                        },
                        {},
                        false
                    )
                    .toSQL();

                expect( statements ).toBe( [
                    "CREATE VIEW [active_users] AS WITH [filtered_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * FROM [filtered_users]"
                ] );
            } );

            it( "adds SELECT INTO to the outer query after a common table expression", function() {
                var statements = getBuilder()
                    .createAs(
                        "active_users",
                        function( query ) {
                            query
                                .with( "filtered_users", function( cte ) {
                                    cte.from( "users" ).where( "active", 1 );
                                } )
                                .from( "filtered_users" );
                        },
                        {},
                        false
                    )
                    .toSQL();

                expect( statements ).toBe( [
                    ";WITH [filtered_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * INTO [active_users] FROM [filtered_users]"
                ] );
            } );
        } );

        describe( "SQL Server view execution", function() {
            it( "only binds the CREATE statement when altering a view", function() {
                var schema = getBuilder();
                schema.getGrammar().$( "runQuery", {} );

                schema.alterView( "active_users", function( query ) {
                    query.from( "users" ).where( "active", 1 );
                } );

                var calls = schema.getGrammar().$callLog().runQuery;
                expect( calls ).toHaveLength( 2 );
                expect( calls[ 1 ][ 2 ] ).toBeEmpty();
                expect( calls[ 2 ][ 2 ].map( ( binding ) => binding.value ) ).toBe( [ 1 ] );
            } );
        } );
    }

    function emptyTable() {
        return [ "CREATE TABLE [users] ()" ];
    }

    function simpleTable() {
        return [ "CREATE TABLE [users] ([username] NVARCHAR(255) NOT NULL, [password] NVARCHAR(255) NOT NULL)" ];
    }

    function complicatedTable() {
        return [
            "CREATE TABLE [users] ([id] INTEGER NOT NULL IDENTITY, [username] NVARCHAR(255) NOT NULL, [first_name] NVARCHAR(255) NOT NULL, [last_name] NVARCHAR(255) NOT NULL, [password] NVARCHAR(100) NOT NULL, [country_id] INTEGER NOT NULL, [created_date] DATETIME2 NOT NULL CONSTRAINT [df_users_created_date] DEFAULT CURRENT_TIMESTAMP, [modified_date] DATETIME2 NOT NULL CONSTRAINT [df_users_modified_date] DEFAULT CURRENT_TIMESTAMP, CONSTRAINT [pk_users_id] PRIMARY KEY ([id]), CONSTRAINT [fk_users_country_id] FOREIGN KEY ([country_id]) REFERENCES [countries] ([id]) ON UPDATE NO ACTION ON DELETE CASCADE)"
        ];
    }

    function bigIncrements() {
        return [ "CREATE TABLE [users] ([id] BIGINT NOT NULL IDENTITY, CONSTRAINT [pk_users_id] PRIMARY KEY ([id]))" ];
    }

    function bigInteger() {
        return [ "CREATE TABLE [weather_reports] ([temperature] BIGINT NOT NULL)" ];
    }

    function bigIntegerWithPrecision() {
        return [ "CREATE TABLE [weather_reports] ([temperature] NUMERIC(5) NOT NULL)" ];
    }

    function bit() {
        return [ "CREATE TABLE [users] ([active] BIT NOT NULL)" ];
    }

    function bitWithLength() {
        return [ "CREATE TABLE [users] ([something] BIT NOT NULL)" ];
    }

    function boolean() {
        return [ "CREATE TABLE [users] ([active] BIT NOT NULL)" ];
    }

    function char() {
        return [ "CREATE TABLE [classifications] ([level] NCHAR(1) NOT NULL)" ];
    }

    function charWithLength() {
        return [ "CREATE TABLE [classifications] ([abbreviation] NCHAR(3) NOT NULL)" ];
    }

    function computedStored() {
        return [ "CREATE TABLE [products] ([price] INTEGER NOT NULL, [tax] AS (price * 0.0675) PERSISTED)" ];
    }

    function computedVirtual() {
        return [ "CREATE TABLE [products] ([price] INTEGER NOT NULL, [tax] AS (price * 0.0675))" ];
    }

    function date() {
        return [ "CREATE TABLE [posts] ([posted_date] DATE NOT NULL)" ];
    }

    function datetime() {
        return [ "CREATE TABLE [posts] ([posted_date] DATETIME2 NOT NULL)" ];
    }

    function datetimeTz() {
        return [ "CREATE TABLE [posts] ([posted_date] DATETIMEOFFSET NOT NULL)" ];
    }

    function decimal() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(10,0) NOT NULL)" ];
    }

    function decimalWithLength() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(3,0) NOT NULL)" ];
    }

    function decimalWithPrecision() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(10,2) NOT NULL)" ];
    }

    function decimalWithLengthAndPrecision() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(3,2) NOT NULL)" ];
    }

    function enum() {
        return [
            "CREATE TABLE [employees] ([tshirt_size] NVARCHAR(255) NOT NULL, CONSTRAINT [enum_employees_tshirt_size] CHECK ([tshirt_size] IN ('S''s', 'M', 'L', 'XL', 'XXL')))"
        ];
    }

    function float() {
        return [ "CREATE TABLE [employees] ([salary] FLOAT NOT NULL)" ];
    }

    function floatWithLength() {
        return [ "CREATE TABLE [employees] ([salary] FLOAT NOT NULL)" ];
    }

    function floatWithPrecision() {
        return [ "CREATE TABLE [employees] ([salary] FLOAT(2) NOT NULL)" ];
    }

    function floatWithLengthAndPrecision() {
        return [ "CREATE TABLE [employees] ([salary] FLOAT(2) NOT NULL)" ];
    }

    function guid() {
        return [ "CREATE TABLE [users] ([id] uniqueidentifier NOT NULL)" ];
    }

    function increments() {
        return [ "CREATE TABLE [users] ([id] INTEGER NOT NULL IDENTITY, CONSTRAINT [pk_users_id] PRIMARY KEY ([id]))" ];
    }

    function integer() {
        return [ "CREATE TABLE [users] ([age] INTEGER NOT NULL)" ];
    }

    function integerWithPrecision() {
        return [ "CREATE TABLE [users] ([age] NUMERIC(2) NOT NULL)" ];
    }

    function json() {
        return [ "CREATE TABLE [users] ([personalizations] NVARCHAR(MAX) NOT NULL)" ];
    }

    function jsonb() {
        return [ "CREATE TABLE [users] ([personalizations] NVARCHAR(MAX) NOT NULL)" ];
    }

    function lineString() {
        return [ "CREATE TABLE [users] ([positions] GEOGRAPHY NOT NULL)" ];
    }

    function longText() {
        return [ "CREATE TABLE [posts] ([body] VARCHAR(MAX) NOT NULL)" ];
    }

    function unicodeLongText() {
        return [ "CREATE TABLE [posts] ([body] NVARCHAR(MAX) NOT NULL)" ];
    }

    function mediumIncrements() {
        return [ "CREATE TABLE [users] ([id] INTEGER NOT NULL IDENTITY, CONSTRAINT [pk_users_id] PRIMARY KEY ([id]))" ];
    }

    function mediumInteger() {
        return [ "CREATE TABLE [users] ([age] INTEGER NOT NULL)" ];
    }

    function mediumIntegerWithPrecision() {
        return [ "CREATE TABLE [users] ([age] NUMERIC(5) NOT NULL)" ];
    }

    function mediumText() {
        return [ "CREATE TABLE [posts] ([body] VARCHAR(MAX) NOT NULL)" ];
    }

    function mediumUnicodeText() {
        return [ "CREATE TABLE [posts] ([body] NVARCHAR(MAX) NOT NULL)" ];
    }

    function money() {
        return [ "CREATE TABLE [transactions] ([amount] MONEY NOT NULL)" ];
    }

    function smallMoney() {
        return [ "CREATE TABLE [transactions] ([amount] SMALLMONEY NOT NULL)" ];
    }

    function morphs() {
        return [
            "CREATE TABLE [tags] ([taggable_id] INTEGER NOT NULL, [taggable_type] VARCHAR(255) NOT NULL, INDEX [taggable_index] ([taggable_id], [taggable_type]))"
        ];
    }

    function nullableMorphs() {
        return [
            "CREATE TABLE [tags] ([taggable_id] INTEGER, [taggable_type] VARCHAR(255), INDEX [taggable_index] ([taggable_id], [taggable_type]))"
        ];
    }

    function nullableTimestamps() {
        return [ "CREATE TABLE [posts] ([createdDate] DATETIME2, [modifiedDate] DATETIME2)" ];
    }

    function point() {
        return [ "CREATE TABLE [users] ([position] GEOGRAPHY NOT NULL)" ];
    }

    function polygon() {
        return [ "CREATE TABLE [users] ([positions] GEOGRAPHY NOT NULL)" ];
    }

    function raw() {
        return [ "CREATE TABLE [users] (id BLOB NOT NULL)" ];
    }

    function rawInAlter() {
        return [
            "ALTER TABLE [registrars] ADD HasDNSSecAPI bit NOT NULL CONSTRAINT DF_registrars_HasDNSSecAPI DEFAULT (0)"
        ];
    }

    function smallIncrements() {
        return [ "CREATE TABLE [users] ([id] SMALLINT NOT NULL IDENTITY, CONSTRAINT [pk_users_id] PRIMARY KEY ([id]))" ];
    }

    function smallInteger() {
        return [ "CREATE TABLE [users] ([age] SMALLINT NOT NULL)" ];
    }

    function smallIntegerWithPrecision() {
        return [ "CREATE TABLE [users] ([age] NUMERIC(5) NOT NULL)" ];
    }

    function softDeletes() {
        return [ "CREATE TABLE [posts] ([deletedDate] DATETIME2)" ];
    }

    function softDeletesTz() {
        return [ "CREATE TABLE [posts] ([deletedDate] DATETIMEOFFSET)" ];
    }

    function string() {
        return [ "CREATE TABLE [users] ([username] VARCHAR(255) NOT NULL)" ];
    }

    function unicodeString() {
        return [ "CREATE TABLE [users] ([username] NVARCHAR(255) NOT NULL)" ];
    }

    function stringWithLength() {
        return [ "CREATE TABLE [users] ([password] VARCHAR(50) NOT NULL)" ];
    }

    function text() {
        return [ "CREATE TABLE [posts] ([body] VARCHAR(MAX) NOT NULL)" ];
    }

    function unicodeText() {
        return [ "CREATE TABLE [posts] ([body] NVARCHAR(MAX) NOT NULL)" ];
    }

    function time() {
        return [ "CREATE TABLE [recurring_tasks] ([fire_time] TIME NOT NULL)" ];
    }

    function timeTz() {
        return [ "CREATE TABLE [recurring_tasks] ([fire_time] TIME NOT NULL)" ];
    }

    function timestamp() {
        return [ "CREATE TABLE [posts] ([posted_date] DATETIME2 NOT NULL)" ];
    }

    function timestampPrecision() {
        return [ "CREATE TABLE [posts] ([posted_date] DATETIME2(6) NOT NULL)" ];
    }

    function timestampTz() {
        return [ "CREATE TABLE [posts] ([posted_date] DATETIMEOFFSET NOT NULL)" ];
    }

    function timestamps() {
        return [
            "CREATE TABLE [posts] ([createdDate] DATETIME2 NOT NULL CONSTRAINT [df_posts_createdDate] DEFAULT CURRENT_TIMESTAMP, [modifiedDate] DATETIME2 NOT NULL CONSTRAINT [df_posts_modifiedDate] DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function timestampsTz() {
        return [
            "CREATE TABLE [posts] ([createdDate] DATETIMEOFFSET NOT NULL CONSTRAINT [df_posts_createdDate] DEFAULT CURRENT_TIMESTAMP, [modifiedDate] DATETIMEOFFSET NOT NULL CONSTRAINT [df_posts_modifiedDate] DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function tinyIncrements() {
        return [ "CREATE TABLE [users] ([id] TINYINT NOT NULL IDENTITY, CONSTRAINT [pk_users_id] PRIMARY KEY ([id]))" ];
    }

    function tinyInteger() {
        return [ "CREATE TABLE [users] ([active] TINYINT NOT NULL)" ];
    }

    function tinyIntegerWithPrecision() {
        return [ "CREATE TABLE [users] ([active] NUMERIC(3) NOT NULL)" ];
    }

    function unsignedBigInteger() {
        return [ "CREATE TABLE [employees] ([salary] BIGINT NOT NULL)" ];
    }

    function unsignedBigIntegerWithPrecision() {
        return [ "CREATE TABLE [employees] ([salary] NUMERIC(5) NOT NULL)" ];
    }

    function unsignedInteger() {
        return [ "CREATE TABLE [users] ([age] INTEGER NOT NULL)" ];
    }

    function unsignedIntegerWithPrecision() {
        return [ "CREATE TABLE [users] ([age] NUMERIC(5) NOT NULL)" ];
    }

    function unsignedMediumInteger() {
        return [ "CREATE TABLE [users] ([age] INTEGER NOT NULL)" ];
    }

    function unsignedMediumIntegerWithPrecision() {
        return [ "CREATE TABLE [users] ([age] NUMERIC(5) NOT NULL)" ];
    }

    function unsignedSmallInteger() {
        return [ "CREATE TABLE [users] ([age] SMALLINT NOT NULL)" ];
    }

    function unsignedSmallIntegerWithPrecision() {
        return [ "CREATE TABLE [users] ([age] NUMERIC(5) NOT NULL)" ];
    }

    function unsignedTinyInteger() {
        return [ "CREATE TABLE [users] ([age] TINYINT NOT NULL)" ];
    }

    function unsignedTinyIntegerWithPrecision() {
        return [ "CREATE TABLE [users] ([age] NUMERIC(5) NOT NULL)" ];
    }

    function uuid() {
        return [ "CREATE TABLE [users] ([id] NCHAR(35) NOT NULL)" ];
    }

    function comment() {
        return [ "CREATE TABLE [users] ([active] BIT NOT NULL)" ];
    }

    function defaultForChar() {
        return [ "CREATE TABLE [users] ([active] NCHAR(1) NOT NULL CONSTRAINT [df_users_active] DEFAULT 'Y')" ];
    }

    function defaultForBoolean() {
        return [ "CREATE TABLE [users] ([active] BIT NOT NULL CONSTRAINT [df_users_active] DEFAULT 1)" ];
    }

    function timestampWithCurrent() {
        return [
            "CREATE TABLE [posts] ([posted_date] DATETIME2 NOT NULL CONSTRAINT [df_posts_posted_date] DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function timestampWithNullable() {
        return [ "CREATE TABLE [posts] ([posted_date] DATETIME2)" ];
    }

    function defaultForNumber() {
        return [ "CREATE TABLE [users] ([experience] INTEGER NOT NULL CONSTRAINT [df_users_experience] DEFAULT 100)" ];
    }

    function defaultForString() {
        return [
            "CREATE TABLE [users] ([country] VARCHAR(255) NOT NULL CONSTRAINT [df_users_country] DEFAULT 'O''Brien')"
        ];
    }

    function defaultForEmptyString() {
        return [ "CREATE TABLE [users] ([nickname] VARCHAR(255) NOT NULL CONSTRAINT [df_users_nickname] DEFAULT '')" ];
    }

    function defaultForUnicodeString() {
        return [
            "CREATE TABLE [users] ([nickname] NVARCHAR(255) NOT NULL CONSTRAINT [df_users_nickname] DEFAULT 'O''Brien')"
        ];
    }

    function nullable() {
        return [ "CREATE TABLE [users] ([id] uniqueidentifier)" ];
    }

    function unsigned() {
        return [ "CREATE TABLE [users] ([age] INTEGER NOT NULL)" ];
    }

    function columnUnique() {
        return [ "CREATE TABLE [users] ([username] NVARCHAR(255) NOT NULL UNIQUE)" ];
    }

    function tableUnique() {
        return [
            "CREATE TABLE [users] ([username] NVARCHAR(255) NOT NULL, CONSTRAINT [unq_users_username] UNIQUE ([username]))"
        ];
    }

    function uniqueOverridingName() {
        return [
            "CREATE TABLE [users] ([username] NVARCHAR(255) NOT NULL, CONSTRAINT [unq_uname] UNIQUE ([username]))"
        ];
    }

    function uniqueMultipleColumns() {
        return [
            "CREATE TABLE [users] ([first_name] NVARCHAR(255) NOT NULL, [last_name] NVARCHAR(255) NOT NULL, CONSTRAINT [unq_users_first_name_last_name] UNIQUE ([first_name], [last_name]))"
        ];
    }

    function addConstraint() {
        return [ "ALTER TABLE [users] ADD CONSTRAINT [unq_users_username] UNIQUE ([username])" ];
    }

    function addMultipleConstraints() {
        return [
            "ALTER TABLE [users] ADD CONSTRAINT [unq_users_username] UNIQUE ([username])",
            "ALTER TABLE [users] ADD CONSTRAINT [unq_users_email] UNIQUE ([email])"
        ];
    }

    function renameConstraint() {
        return [ "EXEC sp_rename N'unq_users_first_name_last_name', N'unq_users_full_name'" ];
    }

    function dropConstraintFromName() {
        return [ "ALTER TABLE [users] DROP CONSTRAINT [unique_username]" ];
    }

    function dropConstraintFromIndex() {
        return [ "ALTER TABLE [users] DROP CONSTRAINT [unq_users_username]" ];
    }

    function dropForeignKey() {
        return [ "ALTER TABLE [users] DROP CONSTRAINT [fk_posts_author_id]" ];
    }

    function dropIndexFromName() {
        return [ "DROP INDEX [users].[idx_username]" ];
    }

    function dropIndexFromIndex() {
        return [ "DROP INDEX [users].[idx_users_username]" ];
    }

    function addIndexInAlter() {
        return [ "CREATE INDEX [idx_users_username] ON [users] ([username])" ];
    }

    function addIndexInAlterWithIndexObject() {
        return [ "CREATE INDEX [idx_users_username] ON [users] ([username])" ];
    }

    function addIndexInAlterCustomName() {
        return [ "CREATE INDEX [custom_index_name] ON [users] ([username])" ];
    }

    function basicIndex() {
        return [
            "CREATE TABLE [users] ([published_date] DATETIME2 NOT NULL, INDEX [idx_users_published_date] ([published_date]))"
        ];
    }

    function compositeIndex() {
        return [
            "CREATE TABLE [users] ([first_name] NVARCHAR(255) NOT NULL, [last_name] NVARCHAR(255) NOT NULL, INDEX [idx_users_first_name_last_name] ([first_name], [last_name]))"
        ];
    }

    function overrideIndexName() {
        return [
            "CREATE TABLE [users] ([first_name] NVARCHAR(255) NOT NULL, [last_name] NVARCHAR(255) NOT NULL, INDEX [index_full_name] ([first_name], [last_name]))"
        ];
    }

    function columnPrimaryKey() {
        return [
            "CREATE TABLE [users] ([uuid] VARCHAR(255) NOT NULL, CONSTRAINT [pk_users_uuid] PRIMARY KEY ([uuid]))"
        ];
    }

    function tablePrimaryKey() {
        return [
            "CREATE TABLE [users] ([uuid] VARCHAR(255) NOT NULL, CONSTRAINT [pk_users_uuid] PRIMARY KEY ([uuid]))"
        ];
    }

    function compositePrimaryKey() {
        return [
            "CREATE TABLE [users] ([first_name] NVARCHAR(255) NOT NULL, [last_name] NVARCHAR(255) NOT NULL, CONSTRAINT [pk_users_first_name_last_name] PRIMARY KEY ([first_name], [last_name]))"
        ];
    }

    function overridePrimaryKeyIndexName() {
        return [
            "CREATE TABLE [users] ([first_name] NVARCHAR(255) NOT NULL, [last_name] NVARCHAR(255) NOT NULL, CONSTRAINT [pk_full_name] PRIMARY KEY ([first_name], [last_name]))"
        ];
    }

    function columnForeignKey() {
        return [
            "CREATE TABLE [posts] ([author_id] INTEGER NOT NULL, CONSTRAINT [fk_posts_author_id] FOREIGN KEY ([author_id]) REFERENCES [users] ([id]) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function tableForeignKey() {
        return [
            "CREATE TABLE [posts] ([author_id] INTEGER NOT NULL, CONSTRAINT [fk_posts_author_id] FOREIGN KEY ([author_id]) REFERENCES [users] ([id]) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideColumnForeignKeyIndexName() {
        return [
            "CREATE TABLE [posts] ([author_id] INTEGER NOT NULL, CONSTRAINT [fk_author] FOREIGN KEY ([author_id]) REFERENCES [users] ([id]) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideTableForeignKeyIndexName() {
        return [
            "CREATE TABLE [posts] ([author_id] INTEGER NOT NULL, CONSTRAINT [fk_author] FOREIGN KEY ([author_id]) REFERENCES [users] ([id]) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function renameTable() {
        return [ "EXEC sp_rename N'workers', N'employees'" ];
    }

    function renameColumn() {
        return [ "EXEC sp_rename N'users.name', N'username', N'COLUMN'" ];
    }

    function renameMultipleColumns() {
        return [
            "EXEC sp_rename N'users.name', N'username', N'COLUMN'",
            "EXEC sp_rename N'users.purchase_date', N'purchased_at', N'COLUMN'"
        ];
    }

    function modifyColumn() {
        return [ "ALTER TABLE [users] ALTER COLUMN [name] NVARCHAR(MAX) NOT NULL" ];
    }

    function modifyMultipleColumns() {
        return [
            "ALTER TABLE [users] ALTER COLUMN [name] NVARCHAR(MAX) NOT NULL",
            "ALTER TABLE [users] ALTER COLUMN [purchased_date] DATETIME2"
        ];
    }

    function addColumn() {
        return [
            "ALTER TABLE [users] ADD [tshirt_size] NVARCHAR(255) NOT NULL, CONSTRAINT [enum_users_tshirt_size] CHECK ([tshirt_size] IN ('S', 'M', 'L', 'XL', 'XXL'))"
        ];
    }

    function addTimestamps() {
        return [
            "ALTER TABLE [users] ADD [createdDate] DATETIME2 NOT NULL CONSTRAINT [df_users_createdDate] DEFAULT CURRENT_TIMESTAMP",
            "ALTER TABLE [users] ADD [modifiedDate] DATETIME2 NOT NULL CONSTRAINT [df_users_modifiedDate] DEFAULT CURRENT_TIMESTAMP"
        ];
    }

    function addMultiple() {
        return [
            "ALTER TABLE [users] ADD [tshirt_size] NVARCHAR(255) NOT NULL, CONSTRAINT [enum_users_tshirt_size] CHECK ([tshirt_size] IN ('S', 'M', 'L', 'XL', 'XXL'))",
            "ALTER TABLE [users] ADD [is_active] BIT NOT NULL"
        ];
    }

    function complicatedModify() {
        return [
            "ALTER TABLE [users] DROP COLUMN [is_active]",
            "ALTER TABLE [users] ADD [tshirt_size] NVARCHAR(255) NOT NULL, CONSTRAINT [enum_users_tshirt_size] CHECK ([tshirt_size] IN ('S', 'M', 'L', 'XL', 'XXL'))",
            "EXEC sp_rename N'users.name', N'username', N'COLUMN'",
            "ALTER TABLE [users] ALTER COLUMN [purchase_date] DATETIME2",
            "ALTER TABLE [users] ADD CONSTRAINT [unq_users_username] UNIQUE ([username])",
            "ALTER TABLE [users] ADD CONSTRAINT [unq_users_email] UNIQUE ([email])",
            "ALTER TABLE [users] DROP CONSTRAINT [idx_users_created_date]",
            "ALTER TABLE [users] DROP CONSTRAINT [idx_users_modified_date]"
        ];
    }

    function dropTable() {
        return [ "DROP TABLE [users]" ];
    }

    function truncateTable() {
        return [ "TRUNCATE TABLE [users]" ];
    }

    function dropIfExists() {
        return [ "DROP TABLE IF EXISTS [users]" ];
    }

    function dropColumn() {
        return [ "ALTER TABLE [users] DROP COLUMN [username]" ];
    }

    function dropColumnWithColumn() {
        return [ "ALTER TABLE [users] DROP COLUMN [username]" ];
    }

    function dropsMultipleColumns() {
        return [ "ALTER TABLE [users] DROP COLUMN [username]", "ALTER TABLE [users] DROP COLUMN [password]" ];
    }

    function dropColumnWithConstraint() {
        return [
            "ALTER TABLE [users] DROP CONSTRAINT [df_users_someFlag]",
            "ALTER TABLE [users] DROP COLUMN [someFlag]"
        ];
    }

    function hasTable() {
        return [ "SELECT 1 FROM [information_schema].[tables] WHERE [table_name] = ?" ];
    }

    function hasTableInSchema() {
        return [ "SELECT 1 FROM [information_schema].[tables] WHERE [table_name] = ? AND [table_schema] = ?" ];
    }

    function hasColumn() {
        return [ "SELECT 1 FROM [information_schema].[columns] WHERE [table_name] = ? AND [column_name] = ?" ];
    }

    function hasColumnInSchema() {
        return [
            "SELECT 1 FROM [information_schema].[columns] WHERE [table_name] = ? AND [column_name] = ? AND [table_schema] = ?"
        ];
    }

    function createView() {
        return [ "CREATE VIEW [active_users] AS (SELECT * FROM [users] WHERE [active] = ?)" ];
    }

    function alterView() {
        return [
            "DROP VIEW [active_users]",
            "CREATE VIEW [active_users] AS (SELECT * FROM [users] WHERE [active] = ?)"
        ];
    }

    function dropView() {
        return [ "DROP VIEW [active_users]" ];
    }

    function createTableAs() {
        return [ "SELECT * INTO [active_users] FROM [users] WHERE [active] = ?" ];
    }

    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ? getMockBox()
            .createMock( "qb.models.Grammars.SqlServerGrammar" )
            .init( utils ) : arguments.mockGrammar;
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" ).init( arguments.mockGrammar );
        variables.mockGrammar = arguments.mockGrammar;
        return builder;
    }

}
