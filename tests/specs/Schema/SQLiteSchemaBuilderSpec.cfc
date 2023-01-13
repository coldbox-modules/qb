component extends="tests.resources.AbstractSchemaBuilderSpec" {

    function emptyTable() {
        return [ "CREATE TABLE ""users"" ()" ];
    }

    function complicatedTable() {
        return [
            "CREATE TABLE ""users"" (""id"" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ""username"" TEXT NOT NULL, ""first_name"" TEXT NOT NULL, ""last_name"" TEXT NOT NULL, ""password"" TEXT NOT NULL, ""country_id"" INTEGER NOT NULL, ""created_date"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modified_date"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (""country_id"") REFERENCES ""countries"" (""id"") ON UPDATE NO ACTION ON DELETE CASCADE)"
        ];
    }

    function complicatedModify() {
        return { exception: "UnsupportedOperation" };
    }

    function columnPrimaryKey() {
        return [ "CREATE TABLE ""users"" (""uuid"" TEXT NOT NULL, PRIMARY KEY (""uuid""))" ];
    }

    function tablePrimaryKey() {
        return [ "CREATE TABLE ""users"" (""uuid"" TEXT NOT NULL, PRIMARY KEY (""uuid""))" ];
    }

    function simpleTable() {
        return [ "CREATE TABLE ""users"" (""username"" TEXT NOT NULL, ""password"" TEXT NOT NULL)" ];
    }

    function hasTable() {
        return [
            "SELECT 1 FROM ""pragma_table_list"" WHERE ""type"" = 'table' AND ""name"" = ? AND ""schema"" = 'main'"
        ];
    }

    function hasTableInSchema() {
        return [ "SELECT 1 FROM ""pragma_table_list"" WHERE ""type"" = 'table' AND ""name"" = ? AND ""schema"" = ?" ];
    }

    function hasColumn() {
        return [
            "SELECT 1 FROM ""pragma_table_list"" tl JOIN pragma_table_info(tl.name) ti WHERE tl.""type"" = 'table' AND tl.""name"" = ? AND ti.""name"" = ? AND tl.""schema"" = 'main'"
        ];
    }

    function hasColumnInSchema() {
        return [
            "SELECT 1 FROM ""pragma_table_list"" tl JOIN pragma_table_info(tl.name) ti WHERE tl.""type"" = 'table' AND tl.""name"" = ? AND ti.""name"" = ? AND tl.""schema"" = ?"
        ];
    }

    // Column Types

    function bigIncrements() {
        return [ "CREATE TABLE ""users"" (""id"" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)" ];
    }

    function bigInteger() {
        return [ "CREATE TABLE ""weather_reports"" (""temperature"" BIGINT NOT NULL)" ];
    }

    function bigIntegerWithPrecision() {
        return [ "CREATE TABLE ""weather_reports"" (""temperature"" BIGINT NOT NULL)" ];
    }

    function bit() {
        return [ "CREATE TABLE ""users"" (""active"" BOOLEAN NOT NULL)" ];
    }

    function bitWithLength() {
        return [ "CREATE TABLE ""users"" (""something"" BOOLEAN NOT NULL)" ];
    }

    function boolean() {
        return [ "CREATE TABLE ""users"" (""active"" BOOLEAN NOT NULL)" ];
    }

    function char() {
        return [ "CREATE TABLE ""classifications"" (""level"" VARCHAR(1) NOT NULL)" ];
    }

    function charWithLength() {
        return [ "CREATE TABLE ""classifications"" (""abbreviation"" VARCHAR(3) NOT NULL)" ];
    }

    function computedStored() {
        return [
            "CREATE TABLE ""products"" (""price"" INTEGER NOT NULL, ""tax"" INTEGER GENERATED ALWAYS AS (price * 0.0675) STORED NOT NULL)"
        ];
    }

    function computedVirtual() {
        return [
            "CREATE TABLE ""products"" (""price"" INTEGER NOT NULL, ""tax"" INTEGER GENERATED ALWAYS AS (price * 0.0675) VIRTUAL NOT NULL)"
        ];
    }

    function date() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" DATE NOT NULL)" ];
    }

    function datetime() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" DATETIME NOT NULL)" ];
    }

    function datetimetz() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" DATETIME NOT NULL)" ];
    }

    function decimal() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(10,0) NOT NULL)" ];
    }

    function decimalWithLength() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(3,0) NOT NULL)" ];
    }

    function decimalWithPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(10,2) NOT NULL)" ];
    }

    function decimalWithLengthAndPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(3,2) NOT NULL)" ];
    }

    function enum() {
        return [
            "CREATE TABLE ""employees"" (""tshirt_size"" TEXT NOT NULL CHECK (""tshirt_size"" IN ('S', 'M', 'L', 'XL', 'XXL')))"
        ];
    }

    function float() {
        return [ "CREATE TABLE ""employees"" (""salary"" FLOAT(10,0) NOT NULL)" ];
    }

    function floatWithLength() {
        return [ "CREATE TABLE ""employees"" (""salary"" FLOAT(3,0) NOT NULL)" ];
    }

    function floatWithPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" FLOAT(10,2) NOT NULL)" ];
    }

    function floatWithLengthAndPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" FLOAT(3,2) NOT NULL)" ];
    }

    function increments() {
        return [ "CREATE TABLE ""users"" (""id"" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)" ];
    }

    function integer() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function integerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function json() {
        return [ "CREATE TABLE ""users"" (""personalizations"" TEXT NOT NULL)" ];
    }

    function lineString() {
        return [ "CREATE TABLE ""users"" (""positions"" TEXT NOT NULL)" ];
    }

    function longText() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function UnicodeLongText() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function mediumIncrements() {
        return [ "CREATE TABLE ""users"" (""id"" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)" ];
    }

    function mediumInteger() {
        return [ "CREATE TABLE ""users"" (""age"" MEDIUMINT NOT NULL)" ];
    }

    function mediumIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" MEDIUMINT NOT NULL)" ];
    }

    function mediumText() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function money() {
        return [ "CREATE TABLE ""transactions"" (""amount"" INTEGER NOT NULL)" ];
    }

    function smallMoney() {
        return [ "CREATE TABLE ""transactions"" (""amount"" INTEGER NOT NULL)" ];
    }


    function morphs() {
        return [
            "CREATE TABLE ""tags"" (""taggable_id"" INTEGER NOT NULL, ""taggable_type"" TEXT NOT NULL)",
            "CREATE INDEX ""taggable_index"" ON ""tags"" (""taggable_id"", ""taggable_type"")"
        ];
    }

    function nullableMorphs() {
        return [
            "CREATE TABLE ""tags"" (""taggable_id"" INTEGER, ""taggable_type"" TEXT)",
            "CREATE INDEX ""taggable_index"" ON ""tags"" (""taggable_id"", ""taggable_type"")"
        ];
    }

    function nullableTimestamps() {
        return [ "CREATE TABLE ""posts"" (""createdDate"" TEXT, ""modifiedDate"" TEXT)" ];
    }

    function point() {
        return [ "CREATE TABLE ""users"" (""position"" TEXT NOT NULL)" ];
    }

    function polygon() {
        return [ "CREATE TABLE ""users"" (""positions"" TEXT NOT NULL)" ];
    }

    function raw() {
        return [ "CREATE TABLE ""users"" (id BLOB NOT NULL)" ];
    }

    function rawInAlter() {
        return [
            "ALTER TABLE ""registrars"" ADD COLUMN HasDNSSecAPI bit NOT NULL CONSTRAINT DF_registrars_HasDNSSecAPI DEFAULT (0)"
        ];
    }

    function smallIncrements() {
        return [ "CREATE TABLE ""users"" (""id"" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)" ];
    }

    function smallInteger() {
        return [ "CREATE TABLE ""users"" (""age"" SMALLINT NOT NULL)" ];
    }

    function smallIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" SMALLINT NOT NULL)" ];
    }

    function softDeletes() {
        return [ "CREATE TABLE ""posts"" (""deletedDate"" TEXT)" ];
    }

    function softDeletesTz() {
        return [ "CREATE TABLE ""posts"" (""deletedDate"" TEXT)" ];
    }

    function string() {
        return [ "CREATE TABLE ""users"" (""username"" TEXT NOT NULL)" ];
    }

    function unicodeString() {
        return [ "CREATE TABLE ""users"" (""username"" TEXT NOT NULL)" ];
    }

    function stringWithLength() {
        return [ "CREATE TABLE ""users"" (""password"" TEXT NOT NULL)" ];
    }

    function text() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function unicodeText() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function time() {
        return [ "CREATE TABLE ""recurring_tasks"" (""fire_time"" TEXT NOT NULL)" ];
    }

    function timeTz() {
        return [ "CREATE TABLE ""recurring_tasks"" (""fire_time"" TEXT NOT NULL)" ];
    }

    function timestamp() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)" ];
    }

    function timestampWithNullable() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TEXT)" ];
    }

    function timestamps() {
        return [
            "CREATE TABLE ""posts"" (""createdDate"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modifiedDate"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function timestampTz() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)" ];
    }

    function timestampsTz() {
        return [
            "CREATE TABLE ""posts"" (""createdDate"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modifiedDate"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function tinyIncrements() {
        return [ "CREATE TABLE ""users"" (""id"" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)" ];
    }

    function tinyInteger() {
        return [ "CREATE TABLE ""users"" (""active"" TINYINT NOT NULL)" ];
    }

    function tinyIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""active"" TINYINT NOT NULL)" ];
    }

    function unsignedBigInteger() {
        return [ "CREATE TABLE ""employees"" (""salary"" BIGINT NOT NULL)" ];
    }

    function unsignedBigIntegerWithPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" BIGINT NOT NULL)" ];
    }

    function unsignedinteger() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function unsignedintegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function unsignedMediumInteger() {
        return [ "CREATE TABLE ""users"" (""age"" MEDIUMINT NOT NULL)" ];
    }

    function unsignedMediumIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" MEDIUMINT NOT NULL)" ];
    }

    function unsignedSmallInteger() {
        return [ "CREATE TABLE ""users"" (""age"" SMALLINT NOT NULL)" ];
    }

    function unsignedSmallIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" SMALLINT NOT NULL)" ];
    }

    function unsignedTinyInteger() {
        return [ "CREATE TABLE ""users"" (""age"" TINYINT NOT NULL)" ];
    }

    function unsignedTinyIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" TINYINT NOT NULL)" ];
    }

    function uuid() {
        return [ "CREATE TABLE ""users"" (""id"" VARCHAR(35) NOT NULL)" ];
    }

    function guid() {
        return [ "CREATE TABLE ""users"" (""id"" VARCHAR(36) NOT NULL)" ];
    }

    function comment() {
        return [ "CREATE TABLE ""users"" (""active"" BOOLEAN NOT NULL)" ];
    }

    function defaultForChar() {
        return [ "CREATE TABLE ""users"" (""active"" VARCHAR(1) NOT NULL DEFAULT 'Y')" ];
    }

    function defaultForBoolean() {
        return [ "CREATE TABLE ""users"" (""active"" BOOLEAN NOT NULL DEFAULT 1)" ];
    }

    function defaultForNumber() {
        return [ "CREATE TABLE ""users"" (""experience"" INTEGER NOT NULL DEFAULT 100)" ];
    }

    function defaultForString() {
        return [ "CREATE TABLE ""users"" (""country"" TEXT NOT NULL DEFAULT 'USA')" ];
    }

    function timestampWithCurrent() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)" ];
    }

    function nullable() {
        return [ "CREATE TABLE ""users"" (""id"" VARCHAR(36))" ];
    }

    function unsigned() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function columnUnique() {
        return [ "CREATE TABLE ""users"" (""username"" TEXT NOT NULL UNIQUE)" ];
    }

    function tableUnique() {
        return [
            "CREATE TABLE ""users"" (""username"" TEXT NOT NULL, CONSTRAINT ""unq_users_username"" UNIQUE (""username""))"
        ];
    }

    function uniqueOverridingName() {
        return [ "CREATE TABLE ""users"" (""username"" TEXT NOT NULL, CONSTRAINT ""unq_uname"" UNIQUE (""username""))" ];
    }

    function uniqueMultipleColumns() {
        return [
            "CREATE TABLE ""users"" (""first_name"" TEXT NOT NULL, ""last_name"" TEXT NOT NULL, CONSTRAINT ""unq_users_first_name_last_name"" UNIQUE (""first_name"", ""last_name""))"
        ];
    }

    function addConstraint() {
        return [ "CREATE UNIQUE INDEX ""unq_users_username"" ON ""users""(""username"")" ];
    }

    function addMultipleConstraints() {
        return [
            "CREATE UNIQUE INDEX ""unq_users_username"" ON ""users""(""username"")",
            "CREATE UNIQUE INDEX ""unq_users_email"" ON ""users""(""email"")"
        ];
    }
    function renameConstraint() {
        return { exception: "UnsupportedOperation" };
    }

    function dropConstraintFromName() {
        return [ "DROP INDEX ""unique_username""" ];
    }

    function dropConstraintFromIndex() {
        return [ "DROP INDEX ""unq_users_username""" ];
    }

    function dropForeignKey() {
        return { exception: "UnsupportedOperation" };
    }

    function dropIndexFromName() {
        return [ "DROP INDEX ""idx_username""" ];
    }

    function dropIndexFromIndex() {
        return [ "DROP INDEX ""idx_users_username""" ];
    }

    function basicIndex() {
        return [
            "CREATE TABLE ""users"" (""published_date"" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)",
            "CREATE INDEX ""idx_users_published_date"" ON ""users"" (""published_date"")"
        ];
    }

    function compositeIndex() {
        return [
            "CREATE TABLE ""users"" (""first_name"" TEXT NOT NULL, ""last_name"" TEXT NOT NULL)",
            "CREATE INDEX ""idx_users_first_name_last_name"" ON ""users"" (""first_name"", ""last_name"")"
        ];
    }

    function overrideIndexName() {
        return [
            "CREATE TABLE ""users"" (""first_name"" TEXT NOT NULL, ""last_name"" TEXT NOT NULL)",
            "CREATE INDEX ""index_full_name"" ON ""users"" (""first_name"", ""last_name"")"
        ];
    }

    function compositePrimaryKey() {
        return [
            "CREATE TABLE ""users"" (""first_name"" TEXT NOT NULL, ""last_name"" TEXT NOT NULL, PRIMARY KEY (""first_name"", ""last_name""))"
        ];
    }
    function overridePrimaryKeyIndexName() {
        return [
            "CREATE TABLE ""users"" (""first_name"" TEXT NOT NULL, ""last_name"" TEXT NOT NULL, PRIMARY KEY (""first_name"", ""last_name""))"
        ];
    }

    function columnForeignKey() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function tableForeignKey() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideColumnForeignKeyIndexName() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideTableForeignKeyIndexName() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function renameTable() {
        return [ "ALTER TABLE ""workers"" RENAME TO ""employees""" ];
    }

    function renameColumn() {
        return [ "ALTER TABLE ""users"" RENAME COLUMN ""name"" TO ""username""" ];
    }

    function renameMultipleColumns() {
        return [
            "ALTER TABLE ""users"" RENAME COLUMN ""name"" TO ""username""",
            "ALTER TABLE ""users"" RENAME COLUMN ""purchase_date"" TO ""purchased_at"""
        ];
    }

    function modifyColumn() {
        return { exception: "UnsupportedOperation" };
    }

    function modifyMultipleColumns() {
        return { exception: "UnsupportedOperation" };
    }

    function addColumn() {
        return [
            "ALTER TABLE ""users"" ADD COLUMN ""tshirt_size"" TEXT NOT NULL CHECK (""tshirt_size"" IN ('S', 'M', 'L', 'XL', 'XXL'))"
        ];
    }

    function addMultiple() {
        return [
            "ALTER TABLE ""users"" ADD COLUMN ""tshirt_size"" TEXT NOT NULL CHECK (""tshirt_size"" IN ('S', 'M', 'L', 'XL', 'XXL'))",
            "ALTER TABLE ""users"" ADD COLUMN ""is_active"" BOOLEAN NOT NULL"
        ];
    }

    function dropTable() {
        return [ "DROP TABLE ""users""" ];
    }

    function dropIfExists() {
        return [ "DROP TABLE IF EXISTS ""users""" ];
    }

    function dropColumn() {
        return [ "ALTER TABLE ""users"" DROP COLUMN ""username""" ];
    }

    function dropColumnWithColumn() {
        return [ "ALTER TABLE ""users"" DROP COLUMN ""username""" ];
    }

    function dropsMultipleColumns() {
        return [ "ALTER TABLE ""users"" DROP COLUMN ""username""", "ALTER TABLE ""users"" DROP COLUMN ""password""" ];
    }

    function dropColumnWithConstraint() {
        return [ "ALTER TABLE ""users"" DROP COLUMN ""someFlag""" ];
    }

    function createView() {
        return [ "CREATE VIEW ""active_users"" AS SELECT * FROM ""users"" WHERE ""active"" = ?" ];
    }

    function alterView() {
        return [
            "DROP VIEW ""active_users""",
            "CREATE VIEW ""active_users"" AS SELECT * FROM ""users"" WHERE ""active"" = ?"
        ];
    }

    function dropView() {
        return [ "DROP VIEW ""active_users""" ];
    }



    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ? getMockBox()
            .createMock( "qb.models.Grammars.SQLiteGrammar" )
            .init( utils ) : arguments.mockGrammar;
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" ).init( arguments.mockGrammar );
        variables.mockGrammar = arguments.mockGrammar;
        return builder;
    }

}
