component extends="tests.resources.AbstractSchemaBuilderSpec" {

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
            "CREATE TABLE [employees] ([tshirt_size] NVARCHAR(255) NOT NULL, CONSTRAINT [enum_employees_tshirt_size] CHECK ([tshirt_size] IN ('S', 'M', 'L', 'XL', 'XXL')))"
        ];
    }

    function float() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(10,0) NOT NULL)" ];
    }

    function floatWithLength() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(3,0) NOT NULL)" ];
    }

    function floatWithPrecision() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(10,2) NOT NULL)" ];
    }

    function floatWithLengthAndPrecision() {
        return [ "CREATE TABLE [employees] ([salary] DECIMAL(3,2) NOT NULL)" ];
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
        return [ "CREATE TABLE [users] ([id] uniqueidentifier NOT NULL)" ];
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

    function defaultForNumber() {
        return [ "CREATE TABLE [users] ([experience] INTEGER NOT NULL CONSTRAINT [df_users_experience] DEFAULT 100)" ];
    }

    function defaultForString() {
        return [ "CREATE TABLE [users] ([country] VARCHAR(255) NOT NULL CONSTRAINT [df_users_country] DEFAULT 'USA')" ];
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
        return [ "EXEC sp_rename [unq_users_first_name_last_name], [unq_users_full_name]" ];
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
        return [ "EXEC sp_rename [workers], [employees]" ];
    }

    function renameColumn() {
        return [ "EXEC sp_rename [users.name], [username], [COLUMN]" ];
    }

    function renameMultipleColumns() {
        return [
            "EXEC sp_rename [users.name], [username], [COLUMN]",
            "EXEC sp_rename [users.purchase_date], [purchased_at], [COLUMN]"
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
            "EXEC sp_rename [users.name], [username], [COLUMN]",
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

    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ? getMockBox()
            .createMock( "qb.models.Grammars.SqlServerGrammar" )
            .init( utils ) : arguments.mockGrammar;
        var builder = getMockBox()
            .createMock( "qb.models.Schema.SchemaBuilder" )
            .init( arguments.mockGrammar );
        variables.mockGrammar = arguments.mockGrammar;
        return builder;
    }

}
