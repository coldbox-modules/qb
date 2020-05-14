component extends="tests.resources.AbstractSchemaBuilderSpec" {

    function emptyTable() {
        return [ "CREATE TABLE `users` ()" ];
    }

    function simpleTable() {
        return [ "CREATE TABLE `users` (`username` NVARCHAR(255) NOT NULL, `password` NVARCHAR(255) NOT NULL)" ];
    }

    function complicatedTable() {
        return [
            "CREATE TABLE `users` (`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT, `username` NVARCHAR(255) NOT NULL, `first_name` NVARCHAR(255) NOT NULL, `last_name` NVARCHAR(255) NOT NULL, `password` NVARCHAR(100) NOT NULL, `country_id` INTEGER UNSIGNED NOT NULL, `created_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `modified_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT `pk_users_id` PRIMARY KEY (`id`), CONSTRAINT `fk_users_country_id` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)"
        ];
    }

    function bigIncrements() {
        return [
            "CREATE TABLE `users` (`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, CONSTRAINT `pk_users_id` PRIMARY KEY (`id`))"
        ];
    }

    function bigInteger() {
        return [ "CREATE TABLE `weather_reports` (`temperature` BIGINT NOT NULL)" ];
    }

    function bigIntegerWithPrecision() {
        return [ "CREATE TABLE `weather_reports` (`temperature` BIGINT(5) NOT NULL)" ];
    }

    function bit() {
        return [ "CREATE TABLE `users` (`active` BIT(1) NOT NULL)" ];
    }

    function bitWithLength() {
        return [ "CREATE TABLE `users` (`something` BIT(4) NOT NULL)" ];
    }

    function boolean() {
        return [ "CREATE TABLE `users` (`active` TINYINT(1) NOT NULL)" ];
    }

    function char() {
        return [ "CREATE TABLE `classifications` (`level` NCHAR(1) NOT NULL)" ];
    }

    function charWithLength() {
        return [ "CREATE TABLE `classifications` (`abbreviation` NCHAR(3) NOT NULL)" ];
    }

    function date() {
        return [ "CREATE TABLE `posts` (`posted_date` DATE NOT NULL)" ];
    }

    function datetime() {
        return [ "CREATE TABLE `posts` (`posted_date` DATETIME NOT NULL)" ];
    }

    function datetimeTz() {
        return [ "CREATE TABLE `posts` (`posted_date` DATETIME NOT NULL)" ];
    }

    function decimal() {
        return [ "CREATE TABLE `employees` (`salary` DECIMAL(10,0) NOT NULL)" ];
    }

    function decimalWithLength() {
        return [ "CREATE TABLE `employees` (`salary` DECIMAL(3,0) NOT NULL)" ];
    }

    function decimalWithPrecision() {
        return [ "CREATE TABLE `employees` (`salary` DECIMAL(10,2) NOT NULL)" ];
    }

    function decimalWithLengthAndPrecision() {
        return [ "CREATE TABLE `employees` (`salary` DECIMAL(3,2) NOT NULL)" ];
    }

    function enum() {
        return [ "CREATE TABLE `employees` (`tshirt_size` ENUM('S', 'M', 'L', 'XL', 'XXL') NOT NULL)" ];
    }

    function float() {
        return [ "CREATE TABLE `employees` (`salary` FLOAT(10,0) NOT NULL)" ];
    }

    function floatWithLength() {
        return [ "CREATE TABLE `employees` (`salary` FLOAT(3,0) NOT NULL)" ];
    }

    function floatWithPrecision() {
        return [ "CREATE TABLE `employees` (`salary` FLOAT(10,2) NOT NULL)" ];
    }

    function floatWithLengthAndPrecision() {
        return [ "CREATE TABLE `employees` (`salary` FLOAT(3,2) NOT NULL)" ];
    }

    function increments() {
        return [
            "CREATE TABLE `users` (`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT, CONSTRAINT `pk_users_id` PRIMARY KEY (`id`))"
        ];
    }

    function integer() {
        return [ "CREATE TABLE `users` (`age` INTEGER NOT NULL)" ];
    }

    function integerWithPrecision() {
        return [ "CREATE TABLE `users` (`age` INTEGER(2) NOT NULL)" ];
    }

    function json() {
        return [ "CREATE TABLE `users` (`personalizations` TEXT NOT NULL)" ];
    }

    function lineString() {
        return [ "CREATE TABLE `users` (`positions` LINESTRING NOT NULL)" ];
    }

    function longText() {
        return [ "CREATE TABLE `posts` (`body` TEXT NOT NULL)" ];
    }

    function UnicodeLongText() {
        return [ "CREATE TABLE `posts` (`body` TEXT NOT NULL)" ];
    }

    function mediumIncrements() {
        return [
            "CREATE TABLE `users` (`id` MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT, CONSTRAINT `pk_users_id` PRIMARY KEY (`id`))"
        ];
    }

    function mediumInteger() {
        return [ "CREATE TABLE `users` (`age` MEDIUMINT NOT NULL)" ];
    }

    function mediumIntegerWithPrecision() {
        return [ "CREATE TABLE `users` (`age` MEDIUMINT(5) NOT NULL)" ];
    }

    function mediumText() {
        return [ "CREATE TABLE `posts` (`body` TEXT NOT NULL)" ];
    }

    function money() {
        return [ "CREATE TABLE `transactions` (`amount` INTEGER NOT NULL)" ];
    }

    function smallMoney() {
        return [ "CREATE TABLE `transactions` (`amount` INTEGER NOT NULL)" ];
    }

    function morphs() {
        return [
            "CREATE TABLE `tags` (`taggable_id` INTEGER UNSIGNED NOT NULL, `taggable_type` VARCHAR(255) NOT NULL, INDEX `taggable_index` (`taggable_id`, `taggable_type`))"
        ];
    }

    function nullableMorphs() {
        return [
            "CREATE TABLE `tags` (`taggable_id` INTEGER UNSIGNED, `taggable_type` VARCHAR(255), INDEX `taggable_index` (`taggable_id`, `taggable_type`))"
        ];
    }

    function nullableTimestamps() {
        return [ "CREATE TABLE `posts` (`createdDate` TIMESTAMP, `modifiedDate` TIMESTAMP)" ];
    }

    function point() {
        return [ "CREATE TABLE `users` (`position` POINT NOT NULL)" ];
    }

    function polygon() {
        return [ "CREATE TABLE `users` (`positions` POLYGON NOT NULL)" ];
    }

    function raw() {
        return [ "CREATE TABLE `users` (id BLOB NOT NULL)" ];
    }

    function rawInAlter() {
        return [
            "ALTER TABLE `registrars` ADD HasDNSSecAPI bit NOT NULL CONSTRAINT DF_registrars_HasDNSSecAPI DEFAULT (0)"
        ];
    }

    function smallIncrements() {
        return [
            "CREATE TABLE `users` (`id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT, CONSTRAINT `pk_users_id` PRIMARY KEY (`id`))"
        ];
    }

    function smallInteger() {
        return [ "CREATE TABLE `users` (`age` SMALLINT NOT NULL)" ];
    }

    function smallIntegerWithPrecision() {
        return [ "CREATE TABLE `users` (`age` SMALLINT(5) NOT NULL)" ];
    }

    function softDeletes() {
        return [ "CREATE TABLE `posts` (`deletedDate` TIMESTAMP)" ];
    }

    function softDeletesTz() {
        return [ "CREATE TABLE `posts` (`deletedDate` TIMESTAMP)" ];
    }

    function string() {
        return [ "CREATE TABLE `users` (`username` VARCHAR(255) NOT NULL)" ];
    }

    function stringWithLength() {
        return [ "CREATE TABLE `users` (`password` VARCHAR(50) NOT NULL)" ];
    }

    function unicodeString() {
        return [ "CREATE TABLE `users` (`username` NVARCHAR(255) NOT NULL)" ];
    }

    function text() {
        return [ "CREATE TABLE `posts` (`body` TEXT NOT NULL)" ];
    }

    function unicodeText() {
        return [ "CREATE TABLE `posts` (`body` TEXT NOT NULL)" ];
    }

    function time() {
        return [ "CREATE TABLE `recurring_tasks` (`fire_time` TIME NOT NULL)" ];
    }

    function timeTz() {
        return [ "CREATE TABLE `recurring_tasks` (`fire_time` TIME NOT NULL)" ];
    }

    function timestamp() {
        return [ "CREATE TABLE `posts` (`posted_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)" ];
    }

    function timestamps() {
        return [
            "CREATE TABLE `posts` (`createdDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `modifiedDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function timestampTz() {
        return [ "CREATE TABLE `posts` (`posted_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)" ];
    }

    function timestampsTz() {
        return [
            "CREATE TABLE `posts` (`createdDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `modifiedDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)"
        ];
    }

    function tinyIncrements() {
        return [
            "CREATE TABLE `users` (`id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT, CONSTRAINT `pk_users_id` PRIMARY KEY (`id`))"
        ];
    }

    function tinyInteger() {
        return [ "CREATE TABLE `users` (`active` TINYINT NOT NULL)" ];
    }

    function tinyIntegerWithPrecision() {
        return [ "CREATE TABLE `users` (`active` TINYINT(3) NOT NULL)" ];
    }

    function unsignedBigInteger() {
        return [ "CREATE TABLE `employees` (`salary` BIGINT UNSIGNED NOT NULL)" ];
    }

    function unsignedBigIntegerWithPrecision() {
        return [ "CREATE TABLE `employees` (`salary` BIGINT(5) UNSIGNED NOT NULL)" ];
    }

    function unsignedInteger() {
        return [ "CREATE TABLE `users` (`age` INTEGER UNSIGNED NOT NULL)" ];
    }

    function unsignedIntegerWithPrecision() {
        return [ "CREATE TABLE `users` (`age` INTEGER(5) UNSIGNED NOT NULL)" ];
    }

    function unsignedMediumInteger() {
        return [ "CREATE TABLE `users` (`age` MEDIUMINT UNSIGNED NOT NULL)" ];
    }

    function unsignedMediumIntegerWithPrecision() {
        return [ "CREATE TABLE `users` (`age` MEDIUMINT(5) UNSIGNED NOT NULL)" ];
    }

    function unsignedSmallInteger() {
        return [ "CREATE TABLE `users` (`age` SMALLINT UNSIGNED NOT NULL)" ];
    }

    function unsignedSmallIntegerWithPrecision() {
        return [ "CREATE TABLE `users` (`age` SMALLINT(5) UNSIGNED NOT NULL)" ];
    }

    function unsignedTinyInteger() {
        return [ "CREATE TABLE `users` (`age` TINYINT UNSIGNED NOT NULL)" ];
    }

    function unsignedTinyIntegerWithPrecision() {
        return [ "CREATE TABLE `users` (`age` TINYINT(5) UNSIGNED NOT NULL)" ];
    }

    function uuid() {
        return [ "CREATE TABLE `users` (`id` NCHAR(36) NOT NULL)" ];
    }

    function comment() {
        return [ "CREATE TABLE `users` (`active` TINYINT(1) NOT NULL COMMENT 'This is a comment')" ];
    }

    function defaultForChar() {
        return [ "CREATE TABLE `users` (`active` NCHAR(1) NOT NULL DEFAULT 'Y')" ];
    }

    function defaultForBoolean() {
        return [ "CREATE TABLE `users` (`active` TINYINT(1) NOT NULL DEFAULT 1)" ];
    }

    function defaultForNumber() {
        return [ "CREATE TABLE `users` (`experience` INTEGER NOT NULL DEFAULT 100)" ];
    }

    function defaultForString() {
        return [ "CREATE TABLE `users` (`country` VARCHAR(255) NOT NULL DEFAULT 'USA')" ];
    }

    function timestampWithCurrent() {
        return [ "CREATE TABLE `posts` (`posted_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)" ];
    }

    function nullable() {
        return [ "CREATE TABLE `users` (`id` NCHAR(36))" ];
    }

    function unsigned() {
        return [ "CREATE TABLE `users` (`age` INTEGER UNSIGNED NOT NULL)" ];
    }

    function columnUnique() {
        return [ "CREATE TABLE `users` (`username` NVARCHAR(255) NOT NULL UNIQUE)" ];
    }

    function tableUnique() {
        return [
            "CREATE TABLE `users` (`username` NVARCHAR(255) NOT NULL, CONSTRAINT `unq_users_username` UNIQUE (`username`))"
        ];
    }

    function uniqueOverridingName() {
        return [
            "CREATE TABLE `users` (`username` NVARCHAR(255) NOT NULL, CONSTRAINT `unq_uname` UNIQUE (`username`))"
        ];
    }

    function uniqueMultipleColumns() {
        return [
            "CREATE TABLE `users` (`first_name` NVARCHAR(255) NOT NULL, `last_name` NVARCHAR(255) NOT NULL, CONSTRAINT `unq_users_first_name_last_name` UNIQUE (`first_name`, `last_name`))"
        ];
    }

    function addConstraint() {
        return [ "ALTER TABLE `users` ADD CONSTRAINT `unq_users_username` UNIQUE (`username`)" ];
    }

    function addMultipleConstraints() {
        return [
            "ALTER TABLE `users` ADD CONSTRAINT `unq_users_username` UNIQUE (`username`)",
            "ALTER TABLE `users` ADD CONSTRAINT `unq_users_email` UNIQUE (`email`)"
        ];
    }

    function renameConstraint() {
        return [ "ALTER TABLE `users` RENAME INDEX `unq_users_first_name_last_name` TO `unq_users_full_name`" ];
    }

    function dropConstraintFromName() {
        return [ "ALTER TABLE `users` DROP INDEX `unique_username`" ];
    }

    function dropConstraintFromIndex() {
        return [ "ALTER TABLE `users` DROP INDEX `unq_users_username`" ];
    }

    function dropForeignKey() {
        return [ "ALTER TABLE `users` DROP FOREIGN KEY `fk_posts_author_id`" ];
    }

    function basicIndex() {
        return [
            "CREATE TABLE `users` (`published_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, INDEX `idx_users_published_date` (`published_date`))"
        ];
    }

    function compositeIndex() {
        return [
            "CREATE TABLE `users` (`first_name` NVARCHAR(255) NOT NULL, `last_name` NVARCHAR(255) NOT NULL, INDEX `idx_users_first_name_last_name` (`first_name`, `last_name`))"
        ];
    }

    function overrideIndexName() {
        return [
            "CREATE TABLE `users` (`first_name` NVARCHAR(255) NOT NULL, `last_name` NVARCHAR(255) NOT NULL, INDEX `index_full_name` (`first_name`, `last_name`))"
        ];
    }

    function columnPrimaryKey() {
        return [
            "CREATE TABLE `users` (`uuid` VARCHAR(255) NOT NULL, CONSTRAINT `pk_users_uuid` PRIMARY KEY (`uuid`))"
        ];
    }

    function tablePrimaryKey() {
        return [
            "CREATE TABLE `users` (`uuid` VARCHAR(255) NOT NULL, CONSTRAINT `pk_users_uuid` PRIMARY KEY (`uuid`))"
        ];
    }

    function compositePrimaryKey() {
        return [
            "CREATE TABLE `users` (`first_name` NVARCHAR(255) NOT NULL, `last_name` NVARCHAR(255) NOT NULL, CONSTRAINT `pk_users_first_name_last_name` PRIMARY KEY (`first_name`, `last_name`))"
        ];
    }

    function overridePrimaryKeyIndexName() {
        return [
            "CREATE TABLE `users` (`first_name` NVARCHAR(255) NOT NULL, `last_name` NVARCHAR(255) NOT NULL, CONSTRAINT `pk_full_name` PRIMARY KEY (`first_name`, `last_name`))"
        ];
    }

    function columnForeignKey() {
        return [
            "CREATE TABLE `posts` (`author_id` INTEGER UNSIGNED NOT NULL, CONSTRAINT `fk_posts_author_id` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function tableForeignKey() {
        return [
            "CREATE TABLE `posts` (`author_id` INTEGER UNSIGNED NOT NULL, CONSTRAINT `fk_posts_author_id` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideColumnForeignKeyIndexName() {
        return [
            "CREATE TABLE `posts` (`author_id` INTEGER UNSIGNED NOT NULL, CONSTRAINT `fk_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function overrideTableForeignKeyIndexName() {
        return [
            "CREATE TABLE `posts` (`author_id` INTEGER UNSIGNED NOT NULL, CONSTRAINT `fk_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)"
        ];
    }

    function renameTable() {
        return [ "RENAME TABLE `workers` TO `employees`" ];
    }

    function renameColumn() {
        return [ "ALTER TABLE `users` CHANGE `name` `username` NVARCHAR(255) NOT NULL" ];
    }

    function renameMultipleColumns() {
        return [
            "ALTER TABLE `users` CHANGE `name` `username` NVARCHAR(255) NOT NULL",
            "ALTER TABLE `users` CHANGE `purchase_date` `purchased_at` TIMESTAMP"
        ];
    }

    function modifyColumn() {
        return [ "ALTER TABLE `users` CHANGE `name` `name` TEXT NOT NULL" ];
    }

    function modifyMultipleColumns() {
        return [
            "ALTER TABLE `users` CHANGE `name` `name` TEXT NOT NULL",
            "ALTER TABLE `users` CHANGE `purchase_date` `purchased_date` TIMESTAMP"
        ];
    }

    function addColumn() {
        return [ "ALTER TABLE `users` ADD `tshirt_size` ENUM('S', 'M', 'L', 'XL', 'XXL') NOT NULL" ];
    }

    function addMultiple() {
        return [
            "ALTER TABLE `users` ADD `tshirt_size` ENUM('S', 'M', 'L', 'XL', 'XXL') NOT NULL",
            "ALTER TABLE `users` ADD `is_active` TINYINT(1) NOT NULL"
        ];
    }

    function complicatedModify() {
        return [
            "ALTER TABLE `users` DROP COLUMN `is_active`",
            "ALTER TABLE `users` ADD `tshirt_size` ENUM('S', 'M', 'L', 'XL', 'XXL') NOT NULL",
            "ALTER TABLE `users` CHANGE `name` `username` NVARCHAR(255) NOT NULL",
            "ALTER TABLE `users` CHANGE `purchase_date` `purchase_date` TIMESTAMP",
            "ALTER TABLE `users` ADD CONSTRAINT `unq_users_username` UNIQUE (`username`)",
            "ALTER TABLE `users` ADD CONSTRAINT `unq_users_email` UNIQUE (`email`)",
            "ALTER TABLE `users` DROP INDEX `idx_users_created_date`",
            "ALTER TABLE `users` DROP INDEX `idx_users_modified_date`"
        ];
    }

    function dropTable() {
        return [ "DROP TABLE `users`" ];
    }

    function dropIfExists() {
        return [ "DROP TABLE IF EXISTS `users`" ];
    }

    function dropColumn() {
        return [ "ALTER TABLE `users` DROP COLUMN `username`" ];
    }

    function dropColumnWithColumn() {
        return [ "ALTER TABLE `users` DROP COLUMN `username`" ];
    }

    function dropsMultipleColumns() {
        return [ "ALTER TABLE `users` DROP COLUMN `username`", "ALTER TABLE `users` DROP COLUMN `password`" ];
    }

    function dropColumnWithConstraint() {
        return [ "ALTER TABLE `users` DROP COLUMN `someFlag`" ];
    }

    function hasTable() {
        return [ "SELECT 1 FROM `information_schema`.`tables` WHERE `table_name` = ?" ];
    }

    function hasTableInSchema() {
        return [ "SELECT 1 FROM `information_schema`.`tables` WHERE `table_name` = ? AND `table_schema` = ?" ];
    }

    function hasColumn() {
        return [ "SELECT 1 FROM `information_schema`.`columns` WHERE `table_name` = ? AND `column_name` = ?" ];
    }

    function hasColumnInSchema() {
        return [
            "SELECT 1 FROM `information_schema`.`columns` WHERE `table_name` = ? AND `column_name` = ? AND `table_schema` = ?"
        ];
    }

    function createView() {
        return [ "CREATE VIEW `active_users` AS (SELECT * FROM `users` WHERE `active` = ?)" ];
    }

    function alterView() {
        return [
            "DROP VIEW `active_users`",
            "CREATE VIEW `active_users` AS (SELECT * FROM `users` WHERE `active` = ?)"
        ];
    }

    function dropView() {
        return [ "DROP VIEW `active_users`" ];
    }

    private function getBuilder( mockGrammar ) {
        var utils = getMockBox().createMock( "qb.models.Query.QueryUtils" );
        arguments.mockGrammar = isNull( arguments.mockGrammar ) ? getMockBox()
            .createMock( "qb.models.Grammars.MySQLGrammar" )
            .init( utils ) : arguments.mockGrammar;
        var builder = getMockBox()
            .createMock( "qb.models.Schema.SchemaBuilder" )
            .init( arguments.mockGrammar );
        variables.mockGrammar = arguments.mockGrammar;
        return builder;
    }

}
