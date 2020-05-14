component extends="tests.resources.AbstractSchemaBuilderSpec" {

    function emptyTable() {
        return [ "CREATE TABLE ""USERS"" ()" ];
    }

    function simpleTable() {
        return [ "CREATE TABLE ""USERS"" (""USERNAME"" VARCHAR2(255) NOT NULL, ""PASSWORD"" VARCHAR2(255) NOT NULL)" ];
    }

    function complicatedTable() {
        return [
            "CREATE TABLE ""USERS"" (""ID"" NUMBER(10, 0) NOT NULL, ""USERNAME"" VARCHAR2(255) NOT NULL, ""FIRST_NAME"" VARCHAR2(255) NOT NULL, ""LAST_NAME"" VARCHAR2(255) NOT NULL, ""PASSWORD"" VARCHAR2(100) NOT NULL, ""COUNTRY_ID"" NUMBER(10, 0) NOT NULL, ""CREATED_DATE"" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, ""MODIFIED_DATE"" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, CONSTRAINT ""PK_USERS_ID"" PRIMARY KEY (""ID""), CONSTRAINT ""FK_USERS_COUNTRY_ID"" FOREIGN KEY (""COUNTRY_ID"") REFERENCES ""COUNTRIES"" (""ID"") ON DELETE CASCADE)",
            "CREATE SEQUENCE ""SEQ_USERS""",
            "CREATE OR REPLACE TRIGGER ""TRG_USERS"" BEFORE INSERT ON ""USERS"" FOR EACH ROW WHEN (new.""ID"" IS NULL) BEGIN SELECT ""SEQ_USERS"".NEXTVAL INTO :new.""ID"" FROM dual; END"
        ];
    }

    function bigIncrements() {
        return [
            "CREATE TABLE ""USERS"" (""ID"" NUMBER(19, 0) NOT NULL, CONSTRAINT ""PK_USERS_ID"" PRIMARY KEY (""ID""))",
            "CREATE SEQUENCE ""SEQ_USERS""",
            "CREATE OR REPLACE TRIGGER ""TRG_USERS"" BEFORE INSERT ON ""USERS"" FOR EACH ROW WHEN (new.""ID"" IS NULL) BEGIN SELECT ""SEQ_USERS"".NEXTVAL INTO :new.""ID"" FROM dual; END"
        ];
    }

    function bigInteger() {
        return [ "CREATE TABLE ""WEATHER_REPORTS"" (""TEMPERATURE"" NUMBER(19, 0) NOT NULL)" ];
    }

    function bigIntegerWithPrecision() {
        return [ "CREATE TABLE ""WEATHER_REPORTS"" (""TEMPERATURE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function bit() {
        return [ "CREATE TABLE ""USERS"" (""ACTIVE"" RAW NOT NULL)" ];
    }

    function bitWithLength() {
        return [ "CREATE TABLE ""USERS"" (""SOMETHING"" RAW NOT NULL)" ];
    }

    function boolean() {
        return [ "CREATE TABLE ""USERS"" (""ACTIVE"" NUMBER(1, 0) NOT NULL)" ];
    }

    function char() {
        return [ "CREATE TABLE ""CLASSIFICATIONS"" (""LEVEL"" CHAR(1) NOT NULL)" ];
    }

    function charWithLength() {
        return [ "CREATE TABLE ""CLASSIFICATIONS"" (""ABBREVIATION"" CHAR(3) NOT NULL)" ];
    }

    function date() {
        return [ "CREATE TABLE ""POSTS"" (""POSTED_DATE"" DATE NOT NULL)" ];
    }

    function datetime() {
        return [ "CREATE TABLE ""POSTS"" (""POSTED_DATE"" DATE NOT NULL)" ];
    }

    function datetimeTz() {
        return [ "CREATE TABLE ""POSTS"" (""POSTED_DATE"" TIMESTAMP WITH TIME ZONE NOT NULL)" ];
    }

    function decimal() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function decimalWithLength() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function decimalWithPrecision() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function decimalWithLengthAndPrecision() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function enum() {
        return [
            "CREATE TABLE ""EMPLOYEES"" (""TSHIRT_SIZE"" VARCHAR2(255) NOT NULL, CONSTRAINT ""ENUM_EMPLOYEES_TSHIRT_SIZE"" CHECK (""TSHIRT_SIZE"" IN ('S', 'M', 'L', 'XL', 'XXL')))"
        ];
    }

    function float() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function floatWithLength() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function floatWithPrecision() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function floatWithLengthAndPrecision() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" FLOAT NOT NULL)" ];
    }

    function increments() {
        return [
            "CREATE TABLE ""USERS"" (""ID"" NUMBER(10, 0) NOT NULL, CONSTRAINT ""PK_USERS_ID"" PRIMARY KEY (""ID""))",
            "CREATE SEQUENCE ""SEQ_USERS""",
            "CREATE OR REPLACE TRIGGER ""TRG_USERS"" BEFORE INSERT ON ""USERS"" FOR EACH ROW WHEN (new.""ID"" IS NULL) BEGIN SELECT ""SEQ_USERS"".NEXTVAL INTO :new.""ID"" FROM dual; END"
        ];
    }

    function integer() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(10, 0) NOT NULL)" ];
    }

    function integerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(2, 0) NOT NULL)" ];
    }

    function json() {
        return [ "CREATE TABLE ""USERS"" (""PERSONALIZATIONS"" CLOB NOT NULL)" ];
    }

    function lineString() {
        return [ "CREATE TABLE ""USERS"" (""POSITIONS"" SDO_GEOMETRY NOT NULL)" ];
    }

    function longText() {
        return [ "CREATE TABLE ""POSTS"" (""BODY"" CLOB NOT NULL)" ];
    }

    function unicodeLongText() {
        return longText();
    }

    function mediumIncrements() {
        return [
            "CREATE TABLE ""USERS"" (""ID"" NUMBER(7, 0) NOT NULL, CONSTRAINT ""PK_USERS_ID"" PRIMARY KEY (""ID""))",
            "CREATE SEQUENCE ""SEQ_USERS""",
            "CREATE OR REPLACE TRIGGER ""TRG_USERS"" BEFORE INSERT ON ""USERS"" FOR EACH ROW WHEN (new.""ID"" IS NULL) BEGIN SELECT ""SEQ_USERS"".NEXTVAL INTO :new.""ID"" FROM dual; END"
        ];
    }

    function mediumInteger() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(7, 0) NOT NULL)" ];
    }

    function mediumIntegerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function mediumText() {
        return [ "CREATE TABLE ""POSTS"" (""BODY"" CLOB NOT NULL)" ];
    }

    function money() {
        return [ "CREATE TABLE ""TRANSACTIONS"" (""AMOUNT"" NUMBER(19, 4) NOT NULL)" ];
    }
    
    function smallMoney() {
        return [ "CREATE TABLE ""TRANSACTIONS"" (""AMOUNT"" NUMBER(10, 4) NOT NULL)" ];
    }

    function morphs() {
        return [
            "CREATE TABLE ""TAGS"" (""TAGGABLE_ID"" NUMBER(10, 0) NOT NULL, ""TAGGABLE_TYPE"" VARCHAR2(255) NOT NULL)",
            "CREATE INDEX ""TAGGABLE_INDEX"" ON ""TAGS"" (""TAGGABLE_ID"", ""TAGGABLE_TYPE"")"
        ];
    }

    function nullableMorphs() {
        return [
            "CREATE TABLE ""TAGS"" (""TAGGABLE_ID"" NUMBER(10, 0), ""TAGGABLE_TYPE"" VARCHAR2(255))",
            "CREATE INDEX ""TAGGABLE_INDEX"" ON ""TAGS"" (""TAGGABLE_ID"", ""TAGGABLE_TYPE"")"
        ];
    }

    function nullableTimestamps() {
        return [ "CREATE TABLE ""POSTS"" (""CREATEDDATE"" DATE, ""MODIFIEDDATE"" DATE)" ];
    }

    function point() {
        return [ "CREATE TABLE ""USERS"" (""POSITION"" SDO_GEOMETRY NOT NULL)" ];
    }

    function polygon() {
        return [ "CREATE TABLE ""USERS"" (""POSITIONS"" SDO_GEOMETRY NOT NULL)" ];
    }

    function softDeletes() {
        return [ "CREATE TABLE ""POSTS"" (""DELETEDDATE"" DATE)" ];
    }

    function softDeletesTz() {
        return [ "CREATE TABLE ""POSTS"" (""DELETEDDATE"" TIMESTAMP WITH TIME ZONE)" ];
    }

    function raw() {
        return [ "CREATE TABLE ""USERS"" (id BLOB NOT NULL)" ];
    }

    function rawInAlter() {
        return [
            "ALTER TABLE ""REGISTRARS"" ADD HasDNSSecAPI bit NOT NULL CONSTRAINT DF_registrars_HasDNSSecAPI DEFAULT (0)"
        ];
    }

    function smallIncrements() {
        return [
            "CREATE TABLE ""USERS"" (""ID"" NUMBER(5, 0) NOT NULL, CONSTRAINT ""PK_USERS_ID"" PRIMARY KEY (""ID""))",
            "CREATE SEQUENCE ""SEQ_USERS""",
            "CREATE OR REPLACE TRIGGER ""TRG_USERS"" BEFORE INSERT ON ""USERS"" FOR EACH ROW WHEN (new.""ID"" IS NULL) BEGIN SELECT ""SEQ_USERS"".NEXTVAL INTO :new.""ID"" FROM dual; END"
        ];
    }

    function smallInteger() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function smallIntegerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function string() {
        return [ "CREATE TABLE ""USERS"" (""USERNAME"" VARCHAR2(255) NOT NULL)" ];
    }

    function unicodeString() {
        return string();
    }

    function stringWithLength() {
        return [ "CREATE TABLE ""USERS"" (""PASSWORD"" VARCHAR2(50) NOT NULL)" ];
    }

    function text() {
        return [ "CREATE TABLE ""POSTS"" (""BODY"" CLOB NOT NULL)" ];
    }

    function unicodeText() {
        return text();
    }

    function time() {
        return [ "CREATE TABLE ""RECURRING_TASKS"" (""FIRE_TIME"" DATE NOT NULL)" ];
    }

    function timeTz() {
        return [ "CREATE TABLE ""RECURRING_TASKS"" (""FIRE_TIME"" TIMESTAMP WITH TIME ZONE NOT NULL)" ];
    }

    function timestamp() {
        return [ "CREATE TABLE ""POSTS"" (""POSTED_DATE"" DATE NOT NULL)" ];
    }

    function timestamps() {
        return [
            "CREATE TABLE ""POSTS"" (""CREATEDDATE"" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL, ""MODIFIEDDATE"" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL)"
        ];
    }

    function timestampTz() {
        return [ "CREATE TABLE ""POSTS"" (""POSTED_DATE"" TIMESTAMP WITH TIME ZONE NOT NULL)" ];
    }

    function timestampsTz() {
        return [
            "CREATE TABLE ""POSTS"" (""CREATEDDATE"" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL, ""MODIFIEDDATE"" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL)"
        ];
    }

    function tinyIncrements() {
        return [
            "CREATE TABLE ""USERS"" (""ID"" NUMBER(3, 0) NOT NULL, CONSTRAINT ""PK_USERS_ID"" PRIMARY KEY (""ID""))",
            "CREATE SEQUENCE ""SEQ_USERS""",
            "CREATE OR REPLACE TRIGGER ""TRG_USERS"" BEFORE INSERT ON ""USERS"" FOR EACH ROW WHEN (new.""ID"" IS NULL) BEGIN SELECT ""SEQ_USERS"".NEXTVAL INTO :new.""ID"" FROM dual; END"
        ];
    }

    function tinyInteger() {
        return [ "CREATE TABLE ""USERS"" (""ACTIVE"" NUMBER(3, 0) NOT NULL)" ];
    }

    function tinyIntegerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""ACTIVE"" NUMBER(3, 0) NOT NULL)" ];
    }

    function unsignedBigInteger() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" NUMBER(19, 0) NOT NULL)" ];
    }

    function unsignedBigIntegerWithPrecision() {
        return [ "CREATE TABLE ""EMPLOYEES"" (""SALARY"" NUMBER(5, 0) NOT NULL)" ];
    }

    function unsignedInteger() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(10, 0) NOT NULL)" ];
    }

    function unsignedIntegerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function unsignedMediumInteger() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(7, 0) NOT NULL)" ];
    }

    function unsignedMediumIntegerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function unsignedSmallInteger() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function unsignedSmallIntegerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function unsignedTinyInteger() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(3, 0) NOT NULL)" ];
    }

    function unsignedTinyIntegerWithPrecision() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(5, 0) NOT NULL)" ];
    }

    function uuid() {
        return [ "CREATE TABLE ""USERS"" (""ID"" CHAR(36) NOT NULL)" ];
    }

    function comment() {
        return [
            "CREATE TABLE ""USERS"" (""ACTIVE"" NUMBER(1, 0) NOT NULL)",
            "COMMENT ON COLUMN ""USERS"".""ACTIVE"" IS 'This is a comment'"
        ];
    }

    function defaultForChar() {
        return [ "CREATE TABLE ""USERS"" (""ACTIVE"" CHAR(1) DEFAULT 'Y' NOT NULL)" ];
    }

    function defaultForBoolean() {
        return [ "CREATE TABLE ""USERS"" (""ACTIVE"" NUMBER(1, 0) DEFAULT 1 NOT NULL)" ];
    }

    function defaultForNumber() {
        return [ "CREATE TABLE ""USERS"" (""EXPERIENCE"" NUMBER(10, 0) DEFAULT 100 NOT NULL)" ];
    }

    function defaultForString() {
        return [ "CREATE TABLE ""USERS"" (""COUNTRY"" VARCHAR2(255) DEFAULT 'USA' NOT NULL)" ];
    }

    function timestampWithCurrent() {
        return [ "CREATE TABLE ""POSTS"" (""POSTED_DATE"" DATE DEFAULT CURRENT_TIMESTAMP NOT NULL)" ];
    }

    function nullable() {
        return [ "CREATE TABLE ""USERS"" (""ID"" CHAR(36))" ];
    }

    function unsigned() {
        return [ "CREATE TABLE ""USERS"" (""AGE"" NUMBER(10, 0) NOT NULL)" ];
    }

    function columnUnique() {
        return [
            "CREATE TABLE ""USERS"" (""USERNAME"" VARCHAR2(255) NOT NULL, CONSTRAINT ""UNQ_USERS_USERNAME"" UNIQUE (""USERNAME""))"
        ];
    }

    function tableUnique() {
        return [
            "CREATE TABLE ""USERS"" (""USERNAME"" VARCHAR2(255) NOT NULL, CONSTRAINT ""UNQ_USERS_USERNAME"" UNIQUE (""USERNAME""))"
        ];
    }

    function uniqueOverridingName() {
        return [
            "CREATE TABLE ""USERS"" (""USERNAME"" VARCHAR2(255) NOT NULL, CONSTRAINT ""UNQ_UNAME"" UNIQUE (""USERNAME""))"
        ];
    }

    function uniqueMultipleColumns() {
        return [
            "CREATE TABLE ""USERS"" (""FIRST_NAME"" VARCHAR2(255) NOT NULL, ""LAST_NAME"" VARCHAR2(255) NOT NULL, CONSTRAINT ""UNQ_USERS_FIRST_NAME_LAST_NAME"" UNIQUE (""FIRST_NAME"", ""LAST_NAME""))"
        ];
    }

    function addConstraint() {
        return [ "ALTER TABLE ""USERS"" ADD CONSTRAINT ""UNQ_USERS_USERNAME"" UNIQUE (""USERNAME"")" ];
    }

    function addMultipleConstraints() {
        return [
            "ALTER TABLE ""USERS"" ADD CONSTRAINT ""UNQ_USERS_USERNAME"" UNIQUE (""USERNAME"")",
            "ALTER TABLE ""USERS"" ADD CONSTRAINT ""UNQ_USERS_EMAIL"" UNIQUE (""EMAIL"")"
        ];
    }

    function renameConstraint() {
        return [
            "ALTER TABLE ""USERS"" RENAME CONSTRAINT ""UNQ_USERS_FIRST_NAME_LAST_NAME"" TO ""UNQ_USERS_FULL_NAME"""
        ];
    }

    function dropConstraintFromName() {
        return [ "ALTER TABLE ""USERS"" DROP CONSTRAINT ""UNIQUE_USERNAME""" ];
    }

    function dropConstraintFromIndex() {
        return [ "ALTER TABLE ""USERS"" DROP CONSTRAINT ""UNQ_USERS_USERNAME""" ];
    }

    function dropForeignKey() {
        return [ "ALTER TABLE ""USERS"" DROP CONSTRAINT ""FK_POSTS_AUTHOR_ID""" ];
    }

    function basicIndex() {
        return [
            "CREATE TABLE ""USERS"" (""PUBLISHED_DATE"" DATE NOT NULL)",
            "CREATE INDEX ""IDX_USERS_PUBLISHED_DATE"" ON ""USERS"" (""PUBLISHED_DATE"")"
        ];
    }

    function compositeIndex() {
        return [
            "CREATE TABLE ""USERS"" (""FIRST_NAME"" VARCHAR2(255) NOT NULL, ""LAST_NAME"" VARCHAR2(255) NOT NULL)",
            "CREATE INDEX ""IDX_USERS_FIRST_NAME_LAST_NAME"" ON ""USERS"" (""FIRST_NAME"", ""LAST_NAME"")"
        ];
    }

    function overrideIndexName() {
        return [
            "CREATE TABLE ""USERS"" (""FIRST_NAME"" VARCHAR2(255) NOT NULL, ""LAST_NAME"" VARCHAR2(255) NOT NULL)",
            "CREATE INDEX ""INDEX_FULL_NAME"" ON ""USERS"" (""FIRST_NAME"", ""LAST_NAME"")"
        ];
    }

    function columnPrimaryKey() {
        return [
            "CREATE TABLE ""USERS"" (""UUID"" VARCHAR2(255) NOT NULL, CONSTRAINT ""PK_USERS_UUID"" PRIMARY KEY (""UUID""))"
        ];
    }

    function tablePrimaryKey() {
        return [
            "CREATE TABLE ""USERS"" (""UUID"" VARCHAR2(255) NOT NULL, CONSTRAINT ""PK_USERS_UUID"" PRIMARY KEY (""UUID""))"
        ];
    }

    function compositePrimaryKey() {
        return [
            "CREATE TABLE ""USERS"" (""FIRST_NAME"" VARCHAR2(255) NOT NULL, ""LAST_NAME"" VARCHAR2(255) NOT NULL, CONSTRAINT ""PK_USERS_FIRST_NAME_LAST_NAME"" PRIMARY KEY (""FIRST_NAME"", ""LAST_NAME""))"
        ];
    }

    function overridePrimaryKeyIndexName() {
        return [
            "CREATE TABLE ""USERS"" (""FIRST_NAME"" VARCHAR2(255) NOT NULL, ""LAST_NAME"" VARCHAR2(255) NOT NULL, CONSTRAINT ""PK_FULL_NAME"" PRIMARY KEY (""FIRST_NAME"", ""LAST_NAME""))"
        ];
    }

    function columnForeignKey() {
        return [
            "CREATE TABLE ""POSTS"" (""AUTHOR_ID"" NUMBER(10, 0) NOT NULL, CONSTRAINT ""FK_POSTS_AUTHOR_ID"" FOREIGN KEY (""AUTHOR_ID"") REFERENCES ""USERS"" (""ID"") ON DELETE NO ACTION)"
        ];
    }

    function tableForeignKey() {
        return [
            "CREATE TABLE ""POSTS"" (""AUTHOR_ID"" NUMBER(10, 0) NOT NULL, CONSTRAINT ""FK_POSTS_AUTHOR_ID"" FOREIGN KEY (""AUTHOR_ID"") REFERENCES ""USERS"" (""ID"") ON DELETE NO ACTION)"
        ];
    }

    function overrideColumnForeignKeyIndexName() {
        return [
            "CREATE TABLE ""POSTS"" (""AUTHOR_ID"" NUMBER(10, 0) NOT NULL, CONSTRAINT ""FK_AUTHOR"" FOREIGN KEY (""AUTHOR_ID"") REFERENCES ""USERS"" (""ID"") ON DELETE NO ACTION)"
        ];
    }

    function overrideTableForeignKeyIndexName() {
        return [
            "CREATE TABLE ""POSTS"" (""AUTHOR_ID"" NUMBER(10, 0) NOT NULL, CONSTRAINT ""FK_AUTHOR"" FOREIGN KEY (""AUTHOR_ID"") REFERENCES ""USERS"" (""ID"") ON DELETE NO ACTION)"
        ];
    }

    function renameTable() {
        return [ "ALTER TABLE ""WORKERS"" RENAME TO ""EMPLOYEES""" ];
    }

    function renameColumn() {
        return [ "ALTER TABLE ""USERS"" RENAME COLUMN ""NAME"" TO ""USERNAME""" ];
    }

    function renameMultipleColumns() {
        return [
            "ALTER TABLE ""USERS"" RENAME COLUMN ""NAME"" TO ""USERNAME""",
            "ALTER TABLE ""USERS"" RENAME COLUMN ""PURCHASE_DATE"" TO ""PURCHASED_AT"""
        ];
    }

    function modifyColumn() {
        return [ "ALTER TABLE ""USERS"" MODIFY (""NAME"" CLOB NOT NULL)" ];
    }

    function modifyMultipleColumns() {
        return [
            "ALTER TABLE ""USERS"" MODIFY (""NAME"" CLOB NOT NULL)",
            "ALTER TABLE ""USERS"" MODIFY (""PURCHASED_DATE"" DATE)"
        ];
    }

    function addColumn() {
        return [
            "ALTER TABLE ""USERS"" ADD ""TSHIRT_SIZE"" VARCHAR2(255) NOT NULL",
            "ALTER TABLE ""USERS"" ADD CONSTRAINT ""ENUM_USERS_TSHIRT_SIZE"" CHECK (""TSHIRT_SIZE"" IN ('S', 'M', 'L', 'XL', 'XXL'))"
        ];
    }

    function addMultiple() {
        return [
            "ALTER TABLE ""USERS"" ADD ""TSHIRT_SIZE"" VARCHAR2(255) NOT NULL",
            "ALTER TABLE ""USERS"" ADD ""IS_ACTIVE"" NUMBER(1, 0) NOT NULL",
            "ALTER TABLE ""USERS"" ADD CONSTRAINT ""ENUM_USERS_TSHIRT_SIZE"" CHECK (""TSHIRT_SIZE"" IN ('S', 'M', 'L', 'XL', 'XXL'))"
        ];
    }

    function complicatedModify() {
        return [
            "ALTER TABLE ""USERS"" DROP COLUMN ""IS_ACTIVE""",
            "ALTER TABLE ""USERS"" ADD ""TSHIRT_SIZE"" VARCHAR2(255) NOT NULL",
            "ALTER TABLE ""USERS"" RENAME COLUMN ""NAME"" TO ""USERNAME""",
            "ALTER TABLE ""USERS"" MODIFY (""PURCHASE_DATE"" DATE)",
            "ALTER TABLE ""USERS"" ADD CONSTRAINT ""UNQ_USERS_USERNAME"" UNIQUE (""USERNAME"")",
            "ALTER TABLE ""USERS"" ADD CONSTRAINT ""UNQ_USERS_EMAIL"" UNIQUE (""EMAIL"")",
            "ALTER TABLE ""USERS"" DROP CONSTRAINT ""IDX_USERS_CREATED_DATE""",
            "ALTER TABLE ""USERS"" DROP CONSTRAINT ""IDX_USERS_MODIFIED_DATE""",
            "ALTER TABLE ""USERS"" ADD CONSTRAINT ""ENUM_USERS_TSHIRT_SIZE"" CHECK (""TSHIRT_SIZE"" IN ('S', 'M', 'L', 'XL', 'XXL'))"
        ];
    }

    function dropTable() {
        return [ "DROP TABLE ""USERS""" ];
    }

    function dropIfExists() {
        return [ "DROP TABLE ""USERS""" ];
    }

    function dropColumn() {
        return [ "ALTER TABLE ""USERS"" DROP COLUMN ""USERNAME""" ];
    }

    function dropColumnWithColumn() {
        return [ "ALTER TABLE ""USERS"" DROP COLUMN ""USERNAME""" ];
    }

    function dropsMultipleColumns() {
        return [ "ALTER TABLE ""USERS"" DROP COLUMN ""USERNAME""", "ALTER TABLE ""USERS"" DROP COLUMN ""PASSWORD""" ];
    }

    function dropColumnWithConstraint() {
        return [ "ALTER TABLE ""USERS"" DROP COLUMN ""SOMEFLAG""" ];
    }

    function hasTable() {
        return [ "SELECT 1 FROM ""DBA_TABLES"" WHERE ""TABLE_NAME"" = ?" ];
    }

    function hasTableInSchema() {
        return [ "SELECT 1 FROM ""DBA_TABLES"" WHERE ""TABLE_NAME"" = ? AND ""OWNER"" = ?" ];
    }

    function hasColumn() {
        return [ "SELECT 1 FROM ""DBA_TAB_COLUMNS"" WHERE ""TABLE_NAME"" = ? AND ""COLUMN_NAME"" = ?" ];
    }

    function hasColumnInSchema() {
        return [
            "SELECT 1 FROM ""DBA_TAB_COLUMNS"" WHERE ""TABLE_NAME"" = ? AND ""COLUMN_NAME"" = ? AND ""OWNER"" = ?"
        ];
    }

    function createView() {
        return [ "CREATE VIEW ""ACTIVE_USERS"" AS (SELECT * FROM ""USERS"" WHERE ""ACTIVE"" = ?)" ];
    }

    function alterView() {
        return [
            "DROP VIEW ""ACTIVE_USERS""",
            "CREATE VIEW ""ACTIVE_USERS"" AS (SELECT * FROM ""USERS"" WHERE ""ACTIVE"" = ?)"
        ];
    }

    function dropView() {
        return [ "DROP VIEW ""ACTIVE_USERS""" ];
    }

    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ? getMockBox()
            .createMock( "qb.models.Grammars.OracleGrammar" )
            .init( utils ) : arguments.mockGrammar;
        var builder = getMockBox()
            .createMock( "qb.models.Schema.SchemaBuilder" )
            .init( arguments.mockGrammar );
        variables.mockGrammar = arguments.mockGrammar;
        return builder;
    }

}
