component extends="tests.resources.AbstractSchemaBuilderSpec" {

    function emptyTable() {
        return [ "CREATE TABLE ""users"" ()" ];
    }

    function simpleTable() {
        return [ "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL, ""password"" VARCHAR(255) NOT NULL)" ];
    }

    function complicatedTable() {
        return [
            "CREATE TABLE ""users"" (""id"" SERIAL NOT NULL, ""username"" VARCHAR(255) NOT NULL, ""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL, ""password"" VARCHAR(100) NOT NULL, ""country_id"" INTEGER NOT NULL, ""created_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modified_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT ""pk_users_id"" PRIMARY KEY (""id""), CONSTRAINT ""fk_users_country_id"" FOREIGN KEY (""country_id"") REFERENCES ""countries"" (""id"") ON UPDATE NO ACTION ON DELETE CASCADE)"
        ];
    }

    function bigIncrements() {
        return [ "CREATE TABLE ""users"" (""id"" BIGSERIAL NOT NULL, CONSTRAINT ""pk_users_id"" PRIMARY KEY (""id""))" ];
    }

    function bigInteger() {
        return [ "CREATE TABLE ""weather_reports"" (""temperature"" BIGINT NOT NULL)" ];
    }

    function bigIntegerWithPrecision() {
        return [ "CREATE TABLE ""weather_reports"" (""temperature"" NUMERIC(5) NOT NULL)" ];
    }

    function bit() {
        return [ "CREATE TABLE ""users"" (""active"" BIT(1) NOT NULL)" ];
    }

    function bitWithLength() {
        return [ "CREATE TABLE ""users"" (""something"" BIT(4) NOT NULL)" ];
    }

    function boolean() {
        return [ "CREATE TABLE ""users"" (""active"" BOOLEAN NOT NULL)" ];
    }

    function char() {
        return [ "CREATE TABLE ""classifications"" (""level"" CHAR(1) NOT NULL)" ];
    }

    function charWithLength() {
        return [ "CREATE TABLE ""classifications"" (""abbreviation"" CHAR(3) NOT NULL)" ];
    }

    function computedStored() {
        return [
            "CREATE TABLE ""products"" (""price"" INTEGER NOT NULL, ""tax"" INTEGER NOT NULL GENERATED ALWAYS AS (price * 0.0675) STORED)"
        ];
    }

    function computedVirtual() {
        return [
            "CREATE TABLE ""products"" (""price"" INTEGER NOT NULL, ""tax"" INTEGER NOT NULL GENERATED ALWAYS AS (price * 0.0675) STORED)"
        ];
    }

    function date() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" DATE NOT NULL)" ];
    }

    function datetime() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP NOT NULL)" ];
    }

    function datetimeTz() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP WITH TIME ZONE NOT NULL)" ];
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
            "CREATE TYPE ""tshirt_size"" AS ENUM ('S', 'M', 'L', 'XL', 'XXL')",
            "CREATE TABLE ""employees"" (""tshirt_size"" tshirt_size NOT NULL)"
        ];
    }

    function float() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(10,0) NOT NULL)" ];
    }

    function floatWithLength() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(3,0) NOT NULL)" ];
    }

    function floatWithPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(10,2) NOT NULL)" ];
    }

    function floatWithLengthAndPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" DECIMAL(3,2) NOT NULL)" ];
    }

    function guid() {
        return [ "CREATE TABLE ""users"" (""id"" UUID NOT NULL)" ];
    }

    function increments() {
        return [ "CREATE TABLE ""users"" (""id"" SERIAL NOT NULL, CONSTRAINT ""pk_users_id"" PRIMARY KEY (""id""))" ];
    }

    function integer() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function integerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" NUMERIC(2) NOT NULL)" ];
    }

    function json() {
        return [ "CREATE TABLE ""users"" (""personalizations"" JSON NOT NULL)" ];
    }

    function longText() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function unicodeLongText() {
        return longText();
    }

    function lineString() {
        return [ "CREATE TABLE ""users"" (""positions"" GEOGRAPHY(LINESTRING, 4326) NOT NULL)" ];
    }

    function mediumIncrements() {
        return [ "CREATE TABLE ""users"" (""id"" SERIAL NOT NULL, CONSTRAINT ""pk_users_id"" PRIMARY KEY (""id""))" ];
    }

    function mediumInteger() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function mediumIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" NUMERIC(5) NOT NULL)" ];
    }

    function mediumText() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function money() {
        return [ "CREATE TABLE ""transactions"" (""amount"" MONEY NOT NULL)" ];
    }

    function smallMoney() {
        return [ "CREATE TABLE ""transactions"" (""amount"" MONEY NOT NULL)" ];
    }

    function morphs() {
        return [
            "CREATE TABLE ""tags"" (""taggable_id"" INTEGER NOT NULL, ""taggable_type"" VARCHAR(255) NOT NULL)",
            "CREATE INDEX ""taggable_index"" ON ""tags"" (""taggable_id"", ""taggable_type"")"
        ];
    }

    function nullableMorphs() {
        return [
            "CREATE TABLE ""tags"" (""taggable_id"" INTEGER, ""taggable_type"" VARCHAR(255))",
            "CREATE INDEX ""taggable_index"" ON ""tags"" (""taggable_id"", ""taggable_type"")"
        ];
    }

    function nullableTimestamps() {
        return [ "CREATE TABLE ""posts"" (""createdDate"" TIMESTAMP, ""modifiedDate"" TIMESTAMP)" ];
    }

    function point() {
        return [ "CREATE TABLE ""users"" (""position"" GEOGRAPHY(POINT, 4326) NOT NULL)" ];
    }

    function polygon() {
        return [ "CREATE TABLE ""users"" (""positions"" GEOGRAPHY(POLYGON, 4326) NOT NULL)" ];
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
        return [ "CREATE TABLE ""users"" (""id"" SERIAL NOT NULL, CONSTRAINT ""pk_users_id"" PRIMARY KEY (""id""))" ];
    }

    function smallInteger() {
        return [ "CREATE TABLE ""users"" (""age"" SMALLINT NOT NULL)" ];
    }

    function smallIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" NUMERIC(5) NOT NULL)" ];
    }

    function softDeletes() {
        return [ "CREATE TABLE ""posts"" (""deletedDate"" TIMESTAMP)" ];
    }

    function softDeletesTz() {
        return [ "CREATE TABLE ""posts"" (""deletedDate"" TIMESTAMP WITH TIME ZONE)" ];
    }

    function string() {
        return [ "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL)" ];
    }

    function unicodeString() {
        return string();
    }

    function stringWithLength() {
        return [ "CREATE TABLE ""users"" (""password"" VARCHAR(50) NOT NULL)" ];
    }

    function text() {
        return [ "CREATE TABLE ""posts"" (""body"" TEXT NOT NULL)" ];
    }

    function unicodeText() {
        return text();
    }

    function time() {
        return [ "CREATE TABLE ""recurring_tasks"" (""fire_time"" TIME NOT NULL)" ];
    }

    function timeTz() {
        return [ "CREATE TABLE ""recurring_tasks"" (""fire_time"" TIME WITH TIME ZONE NOT NULL)" ];
    }

    function timestamp() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP NOT NULL)" ];
    }

    function timestampPrecision() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP(6) NOT NULL)" ];
    }


    function timestamps() {
        return [
            "CREATE TABLE ""posts"" (""createdDate"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modifiedDate"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function timestampTz() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP WITH TIME ZONE NOT NULL)" ];
    }

    function timestampsTz() {
        return [
            "CREATE TABLE ""posts"" (""createdDate"" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, ""modifiedDate"" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function tinyIncrements() {
        return [ "CREATE TABLE ""users"" (""id"" SERIAL NOT NULL, CONSTRAINT ""pk_users_id"" PRIMARY KEY (""id""))" ];
    }

    function tinyInteger() {
        return [ "CREATE TABLE ""users"" (""active"" SMALLINT NOT NULL)" ];
    }

    function tinyIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""active"" NUMERIC(3) NOT NULL)" ];
    }

    function unsignedBigInteger() {
        return [ "CREATE TABLE ""employees"" (""salary"" BIGINT NOT NULL)" ];
    }

    function unsignedBigIntegerWithPrecision() {
        return [ "CREATE TABLE ""employees"" (""salary"" NUMERIC(5) NOT NULL)" ];
    }

    function unsignedInteger() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function unsignedIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" NUMERIC(5) NOT NULL)" ];
    }

    function unsignedMediumInteger() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function unsignedMediumIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" NUMERIC(5) NOT NULL)" ];
    }

    function unsignedSmallInteger() {
        return [ "CREATE TABLE ""users"" (""age"" SMALLINT NOT NULL)" ];
    }

    function unsignedSmallIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" NUMERIC(5) NOT NULL)" ];
    }

    function unsignedTinyInteger() {
        return [ "CREATE TABLE ""users"" (""age"" SMALLINT NOT NULL)" ];
    }

    function unsignedTinyIntegerWithPrecision() {
        return [ "CREATE TABLE ""users"" (""age"" NUMERIC(5) NOT NULL)" ];
    }

    function uuid() {
        return [ "CREATE TABLE ""users"" (""id"" CHAR(35) NOT NULL)" ];
    }

    function comment() {
        return [
            "CREATE TABLE ""users"" (""active"" BOOLEAN NOT NULL)",
            "COMMENT ON COLUMN ""users"".""active"" IS 'This is a comment'"
        ];
    }

    function defaultForChar() {
        return [ "CREATE TABLE ""users"" (""active"" CHAR(1) NOT NULL DEFAULT 'Y')" ];
    }

    function defaultForBoolean() {
        return [ "CREATE TABLE ""users"" (""active"" BOOLEAN NOT NULL DEFAULT TRUE)" ];
    }

    function defaultForNumber() {
        return [ "CREATE TABLE ""users"" (""experience"" INTEGER NOT NULL DEFAULT 100)" ];
    }

    function defaultForString() {
        return [ "CREATE TABLE ""users"" (""country"" VARCHAR(255) NOT NULL DEFAULT 'USA')" ];
    }

    function timestampWithCurrent() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)" ];
    }

    function timestampWithNullable() {
        return [ "CREATE TABLE ""posts"" (""posted_date"" TIMESTAMP)" ];
    }

    function nullable() {
        return [ "CREATE TABLE ""users"" (""id"" UUID)" ];
    }

    function unsigned() {
        return [ "CREATE TABLE ""users"" (""age"" INTEGER NOT NULL)" ];
    }

    function columnUnique() {
        return [ "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL UNIQUE)" ];
    }

    function tableUnique() {
        return [
            "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL, CONSTRAINT ""unq_users_username"" UNIQUE (""username""))"
        ];
    }

    function uniqueOverridingName() {
        return [
            "CREATE TABLE ""users"" (""username"" VARCHAR(255) NOT NULL, CONSTRAINT ""unq_uname"" UNIQUE (""username""))"
        ];
    }

    function uniqueMultipleColumns() {
        return [
            "CREATE TABLE ""users"" (""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL, CONSTRAINT ""unq_users_first_name_last_name"" UNIQUE (""first_name"", ""last_name""))"
        ];
    }

    function addConstraint() {
        return [ "ALTER TABLE ""users"" ADD CONSTRAINT ""unq_users_username"" UNIQUE (""username"")" ];
    }

    function addMultipleConstraints() {
        return [
            "ALTER TABLE ""users"" ADD CONSTRAINT ""unq_users_username"" UNIQUE (""username"")",
            "ALTER TABLE ""users"" ADD CONSTRAINT ""unq_users_email"" UNIQUE (""email"")"
        ];
    }

    function renameConstraint() {
        return [
            "ALTER TABLE ""users"" RENAME CONSTRAINT ""unq_users_first_name_last_name"" TO ""unq_users_full_name"""
        ];
    }

    function dropConstraintFromName() {
        return [ "ALTER TABLE ""users"" DROP CONSTRAINT ""unique_username""" ];
    }

    function dropConstraintFromIndex() {
        return [ "ALTER TABLE ""users"" DROP CONSTRAINT ""unq_users_username""" ];
    }

    function dropForeignKey() {
        return [ "ALTER TABLE ""users"" DROP CONSTRAINT ""fk_posts_author_id""" ];
    }

    function dropIndexFromName() {
        return [ "DROP INDEX ""idx_username""" ];
    }

    function dropIndexFromIndex() {
        return [ "DROP INDEX ""idx_users_username""" ];
    }

    function addIndexInAlter() {
        return [ "CREATE INDEX ""idx_users_username"" ON ""users"" (""username"")" ];
    }

    function addIndexInAlterWithIndexObject() {
        return [ "CREATE INDEX ""idx_users_username"" ON ""users"" (""username"")" ];
    }

    function addIndexInAlterCustomName() {
        return [ "CREATE INDEX ""custom_index_name"" ON ""users"" (""username"")" ];
    }

    function basicIndex() {
        return [
            "CREATE TABLE ""users"" (""published_date"" TIMESTAMP NOT NULL)",
            "CREATE INDEX ""idx_users_published_date"" ON ""users"" (""published_date"")"
        ];
    }

    function compositeIndex() {
        return [
            "CREATE TABLE ""users"" (""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL)",
            "CREATE INDEX ""idx_users_first_name_last_name"" ON ""users"" (""first_name"", ""last_name"")"
        ];
    }

    function overrideIndexName() {
        return [
            "CREATE TABLE ""users"" (""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL)",
            "CREATE INDEX ""index_full_name"" ON ""users"" (""first_name"", ""last_name"")"
        ];
    }

    function columnPrimaryKey() {
        return [
            "CREATE TABLE ""users"" (""uuid"" VARCHAR(255) NOT NULL, CONSTRAINT ""pk_users_uuid"" PRIMARY KEY (""uuid""))"
        ];
    }

    function tablePrimaryKey() {
        return [
            "CREATE TABLE ""users"" (""uuid"" VARCHAR(255) NOT NULL, CONSTRAINT ""pk_users_uuid"" PRIMARY KEY (""uuid""))"
        ];
    }

    function compositePrimaryKey() {
        return [
            "CREATE TABLE ""users"" (""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL, CONSTRAINT ""pk_users_first_name_last_name"" PRIMARY KEY (""first_name"", ""last_name""))"
        ];
    }

    function overridePrimaryKeyIndexName() {
        return [
            "CREATE TABLE ""users"" (""first_name"" VARCHAR(255) NOT NULL, ""last_name"" VARCHAR(255) NOT NULL, CONSTRAINT ""pk_full_name"" PRIMARY KEY (""first_name"", ""last_name""))"
        ];
    }

    function columnForeignKey() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, CONSTRAINT ""fk_posts_author_id"" FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function tableForeignKey() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, CONSTRAINT ""fk_posts_author_id"" FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideColumnForeignKeyIndexName() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, CONSTRAINT ""fk_author"" FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideTableForeignKeyIndexName() {
        return [
            "CREATE TABLE ""posts"" (""author_id"" INTEGER NOT NULL, CONSTRAINT ""fk_author"" FOREIGN KEY (""author_id"") REFERENCES ""users"" (""id"") ON UPDATE NO ACTION ON DELETE NO ACTION)"
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
        return [ "ALTER TABLE ""users"" ALTER COLUMN ""name"" TYPE TEXT, ALTER COLUMN ""name"" SET NOT NULL" ];
    }

    function modifyMultipleColumns() {
        return [
            "ALTER TABLE ""users"" ALTER COLUMN ""name"" TYPE TEXT, ALTER COLUMN ""name"" SET NOT NULL",
            "ALTER TABLE ""users"" ALTER COLUMN ""purchased_date"" TYPE TIMESTAMP, ALTER COLUMN ""purchased_date"" DROP NOT NULL"
        ];
    }

    function addColumn() {
        return [
            "CREATE TYPE ""tshirt_size"" AS ENUM ('S', 'M', 'L', 'XL', 'XXL')",
            "ALTER TABLE ""users"" ADD COLUMN ""tshirt_size"" tshirt_size NOT NULL"
        ];
    }

    function addMultiple() {
        return [
            "CREATE TYPE ""tshirt_size"" AS ENUM ('S', 'M', 'L', 'XL', 'XXL')",
            "ALTER TABLE ""users"" ADD COLUMN ""tshirt_size"" tshirt_size NOT NULL",
            "ALTER TABLE ""users"" ADD COLUMN ""is_active"" BOOLEAN NOT NULL"
        ];
    }

    function complicatedModify() {
        return [
            "CREATE TYPE ""tshirt_size"" AS ENUM ('S', 'M', 'L', 'XL', 'XXL')",
            "ALTER TABLE ""users"" DROP COLUMN ""is_active"" CASCADE",
            "ALTER TABLE ""users"" ADD COLUMN ""tshirt_size"" tshirt_size NOT NULL",
            "ALTER TABLE ""users"" RENAME COLUMN ""name"" TO ""username""",
            "ALTER TABLE ""users"" ALTER COLUMN ""purchase_date"" TYPE TIMESTAMP, ALTER COLUMN ""purchase_date"" DROP NOT NULL",
            "ALTER TABLE ""users"" ADD CONSTRAINT ""unq_users_username"" UNIQUE (""username"")",
            "ALTER TABLE ""users"" ADD CONSTRAINT ""unq_users_email"" UNIQUE (""email"")",
            "ALTER TABLE ""users"" DROP CONSTRAINT ""idx_users_created_date""",
            "ALTER TABLE ""users"" DROP CONSTRAINT ""idx_users_modified_date"""
        ];
    }

    function dropTable() {
        return [ "DROP TABLE ""users"" CASCADE" ];
    }

    function truncateTable() {
        return [ "TRUNCATE TABLE ""users""" ];
    }

    function dropIfExists() {
        return [ "DROP TABLE IF EXISTS ""users"" CASCADE" ];
    }

    function dropColumn() {
        return [ "ALTER TABLE ""users"" DROP COLUMN ""username"" CASCADE" ];
    }

    function dropColumnWithColumn() {
        return [ "ALTER TABLE ""users"" DROP COLUMN ""username"" CASCADE" ];
    }

    function dropsMultipleColumns() {
        return [
            "ALTER TABLE ""users"" DROP COLUMN ""username"" CASCADE",
            "ALTER TABLE ""users"" DROP COLUMN ""password"" CASCADE"
        ];
    }

    function dropColumnWithConstraint() {
        return [ "ALTER TABLE ""users"" DROP COLUMN ""someFlag"" CASCADE" ];
    }

    function hasTable() {
        return [ "SELECT 1 FROM ""information_schema"".""tables"" WHERE ""table_name"" = ?" ];
    }

    function hasTableInSchema() {
        return [ "SELECT 1 FROM ""information_schema"".""tables"" WHERE ""table_name"" = ? AND ""table_schema"" = ?" ];
    }

    function hasColumn() {
        return [ "SELECT 1 FROM ""information_schema"".""columns"" WHERE ""table_name"" = ? AND ""column_name"" = ?" ];
    }

    function hasColumnInSchema() {
        return [
            "SELECT 1 FROM ""information_schema"".""columns"" WHERE ""table_name"" = ? AND ""column_name"" = ? AND ""table_schema"" = ?"
        ];
    }

    function createView() {
        return [ "CREATE VIEW ""active_users"" AS (SELECT * FROM ""users"" WHERE ""active"" = ?)" ];
    }

    function alterView() {
        return [
            "DROP VIEW ""active_users""",
            "CREATE VIEW ""active_users"" AS (SELECT * FROM ""users"" WHERE ""active"" = ?)"
        ];
    }

    function dropView() {
        return [ "DROP VIEW ""active_users""" ];
    }

    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ? getMockBox()
            .createMock( "qb.models.Grammars.PostgresGrammar" )
            .init( utils ) : arguments.mockGrammar;
        var builder = getMockBox().createMock( "qb.models.Schema.SchemaBuilder" ).init( arguments.mockGrammar );
        variables.mockGrammar = arguments.mockGrammar;
        return builder;
    }

}
