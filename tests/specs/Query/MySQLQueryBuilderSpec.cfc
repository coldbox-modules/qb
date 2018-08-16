component extends="tests.resources.AbstractQueryBuilderSpec" {

    function selectAllColumns() {
        return "SELECT * FROM `users`";
    }

    function selectSpecificColumn() {
        return "SELECT `name` FROM `users`";
    }

    function selectMultipleVariadic() {
        return "SELECT `id`, `name` FROM `users`";
    }

    function selectMultipleArray() {
        return "SELECT `name`, COUNT(*) FROM `users`";
    }

    function addSelect() {
        return "SELECT `foo`, `bar`, `baz`, `boom` FROM `users`";
    }

    function addSelectRemovesStar() {
        return "SELECT `foo` FROM `users`";
    }

    function selectDistinct() {
        return "SELECT DISTINCT `foo`, `bar` FROM `users`";
    }

    function parseColumnAlias() {
        return "SELECT `foo` AS `bar` FROM `users`";
    }

    function wrapColumnsAndAliases() {
        return "SELECT `x`.`y` AS `foo.bar` FROM `public`.`users`";
    }

    function selectWithRaw() {
        return "SELECT substr( foo, 6 ) FROM `users`";
    }

    function selectRaw() {
        return "SELECT substr( foo, 6 ) FROM `users`";
    }

    function subSelect() {
        return "SELECT `name`, ( SELECT MAX(updated_date) FROM `posts` WHERE `posts`.`user_id` = `users`.`id` ) AS ""latestUpdatedDate"" FROM `users`";
    }

    function subSelectWithBindings() {
        return {
            sql = "SELECT `name`, ( SELECT MAX(updated_date) FROM `posts` WHERE `posts`.`user_id` = ? ) AS ""latestUpdatedDate"" FROM `users`",
            bindings = [ 1 ]
        };
    }

    function from() {
        return "SELECT * FROM `users`";
    }

    function fromRaw() {
        return "SELECT * FROM Test (nolock)";
    }

    function fromDerivedTable() {
        return {
            sql = "SELECT * FROM (SELECT `id`, `name` FROM `users` WHERE `age` >= ?) as ""u""",
            bindings = [21]
        };
    }

    function table() {
        return "SELECT * FROM `users`";
    }

    function tablePrefix() {
        return "SELECT * FROM `prefix_users`";
    }

    function tablePrefixWithAlias() {
        return "SELECT * FROM `prefix_users` AS `prefix_people`";
    }

    function columnAliasWithAs() {
        return "SELECT `id` AS `user_id` FROM `users`";
    }

    function columnAliasWithoutAs() {
        return "SELECT `id` AS `user_id` FROM `users`";
    }

    function tableAliasWithAs() {
        return "SELECT * FROM `users` AS `people`";
    }

    function tableAliasWithoutAs() {
        return "SELECT * FROM `users` AS `people`";
    }

    function basicWhere() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` = ?",
            bindings = [ 1 ]
        };
    }

    function orWhere() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` = ? OR `email` = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function andWhere() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` = ? AND `email` = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function whereRaw() {
        return {
            sql = "SELECT * FROM `users` WHERE id = ? OR email = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function orWhereRaw() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` = ? OR email = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function whereColumn() {
        return "SELECT * FROM `users` WHERE `first_name` = `last_name`";
    }

    function orWhereColumn() {
        return "SELECT * FROM `users` WHERE `first_name` = `last_name` OR `updated_date` > `created_date`";
    }

    function whereNested() {
        return {
            sql = "SELECT * FROM `users` WHERE `email` = ? OR (`name` = ? AND `age` >= ?)",
            bindings = [ "foo", "bar", 21 ]
        };
    }

    function whereSubselect() {
        return {
            sql = "SELECT * FROM `users` WHERE `email` = ? OR `id` = (SELECT MAX(id) FROM `users` WHERE `email` = ?)",
            bindings = [ "foo", "bar" ]
        };
    }

    function whereExists() {
        return "SELECT * FROM `orders` WHERE EXISTS (SELECT 1 FROM `products` WHERE `products`.`id` = orders.id)";
    }

    function orWhereExists() {
        return {
            sql = "SELECT * FROM `orders` WHERE `id` = ? OR EXISTS (SELECT 1 FROM `products` WHERE `products`.`id` = orders.id)",
            bindings = [ 1 ]
        };
    }

    function whereNotExists() {
        return "SELECT * FROM `orders` WHERE NOT EXISTS (SELECT 1 FROM `products` WHERE `products`.`id` = orders.id)";
    }

    function orWhereNotExists() {
        return {
            sql = "SELECT * FROM `orders` WHERE `id` = ? OR NOT EXISTS (SELECT 1 FROM `products` WHERE `products`.`id` = orders.id)",
            bindings = [ 1 ]
        };
    }

    function whereNull() {
        return "SELECT * FROM `users` WHERE `id` IS NULL";
    }

    function orWhereNull() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` = ? OR `id` IS NULL",
            bindings = [ 1 ]
        };
    }

    function whereNotNull() {
        return "SELECT * FROM `users` WHERE `id` IS NOT NULL";
    }

    function orWhereNotNull() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` = ? OR `id` IS NOT NULL",
            bindings = [ 1 ]
        };
    }

    function whereBetween() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` BETWEEN ? AND ?",
            bindings = [ 1, 2 ]
        };
    }

    function whereNotBetween() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` NOT BETWEEN ? AND ?",
            bindings = [ 1, 2 ]
        };
    }

    function whereInList() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function whereInArray() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function orWhereIn() {
        return {
            sql = "SELECT * FROM `users` WHERE `email` = ? OR `id` IN (?, ?, ?)",
            bindings = [ "foo", 1, 2, 3 ]
        };
    }

    function whereInRaw() {
        return "SELECT * FROM `users` WHERE `id` IN (1)";
    }

    function whereInEmpty() {
        return "SELECT * FROM `users` WHERE 0 = 1";
    }

    function whereNotInEmpty() {
        return "SELECT * FROM `users` WHERE 1 = 1";
    }

    function whereInSubSelect() {
        return {
            sql = "SELECT * FROM `users` WHERE `id` IN (SELECT `id` FROM `users` WHERE `age` > ?)",
            bindings = [ 25 ]
        };
    }

    function innerJoin() {
        return "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id`";
    }

    function innerJoinRaw() {
        return "SELECT * FROM `users` INNER JOIN contacts (nolock) ON `users`.`id` = `contacts`.`id`";
    }

    function innerJoinShorthand() {
        return "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id`";
    }

    function multipleJoins() {
        return "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` INNER JOIN `addresses` AS `a` ON `a`.`contact_id` = `contacts`.`id`";
    }

    function joinWithWhere() {
        return {
            sql = "SELECT * FROM `users` INNER JOIN `contacts` ON `contacts`.`balance` < ?",
            bindings = [ 100 ]
        };
    }

    function leftJoin() {
        return "SELECT * FROM `users` LEFT JOIN `orders` ON `users`.`id` = `orders`.`user_id`";
    }

    function leftJoinRaw() {
        return "SELECT * FROM `users` LEFT JOIN contacts (nolock) ON `users`.`id` = `contacts`.`id`";
    }

    function rightJoin() {
        return "SELECT * FROM `orders` RIGHT JOIN `users` ON `orders`.`user_id` = `users`.`id`";
    }

    function rightJoinRaw() {
        return "SELECT * FROM `users` RIGHT JOIN contacts (nolock) ON `users`.`id` = `contacts`.`id`";
    }

    function crossJoin() {
        return "SELECT * FROM `sizes` CROSS JOIN `colors`";
    }

    function crossJoinRaw() {
        return "SELECT * FROM `users` CROSS JOIN contacts (nolock)";
    }

    function complexJoin() {
        return {
            sql = "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` OR `users`.`name` = `contacts`.`name` OR `users`.`admin` = ?",
            bindings = [ 1 ]
        };
    }

    function joinWithWhereNull() {
        return "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` AND `contacts`.`deleted_date` IS NULL";
    }

    function joinWithOrWhereNull() {
        return "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` OR `contacts`.`deleted_date` IS NULL";
    }

    function joinWithWhereNotNull() {
        return "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` AND `contacts`.`deleted_date` IS NOT NULL";
    }

    function joinWithOrWhereNotNull() {
        return "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` OR `contacts`.`deleted_date` IS NOT NULL";
    }

    function joinWithWhereIn() {
        return {
            sql = "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` AND `contacts`.`id` IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereIn() {
        return {
            sql = "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` OR `contacts`.`id` IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinWithWhereNotIn() {
        return {
            sql = "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` AND `contacts`.`id` NOT IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereNotIn() {
        return {
            sql = "SELECT * FROM `users` INNER JOIN `contacts` ON `users`.`id` = `contacts`.`id` OR `contacts`.`id` NOT IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinSub() {
        return {
            sql = 'SELECT * FROM `users` AS `u` INNER JOIN (SELECT `id` FROM `contacts` WHERE `id` NOT IN (?, ?, ?)) as "c" ON `u`.`id` = `c`.`id`',
            bindings = [ 1, 2, 3 ]
        };
    }

    function leftJoinSub() {
        return {
            sql = 'SELECT * FROM `users` AS `u` LEFT JOIN (SELECT `id` FROM `contacts` WHERE `id` NOT IN (?, ?, ?)) as "c" ON `u`.`id` = `c`.`id`',
            bindings = [ 1, 2, 3 ]
        };
    }

    function rightJoinSub() {
        return {
            sql = 'SELECT * FROM `users` AS `u` RIGHT JOIN (SELECT `id` FROM `contacts` WHERE `id` NOT IN (?, ?, ?)) as "c" ON `u`.`id` = `c`.`id`',
            bindings = [ 1, 2, 3 ]
        };
    }

    function crossJoinSub() {
        return {
            sql = 'SELECT * FROM `users` AS `u` CROSS JOIN (SELECT `id` FROM `contacts` WHERE `id` NOT IN (?, ?, ?)) as "c"',
            bindings = [ 1, 2, 3 ]
        };
    }

    function groupBy() {
        return "SELECT * FROM `users` GROUP BY `email`";
    }

    function groupByArray() {
        return "SELECT * FROM `users` GROUP BY `id`, `email`";
    }

    function groupByRaw() {
        return "SELECT * FROM `users` GROUP BY DATE(created_at)";
    }

    function havingBasic() {
        return {
            sql = "SELECT * FROM `users` HAVING `email` > ?",
            bindings = [ 1 ]
        };
    }

    function havingRawColumn() {
        return {
            sql = "SELECT * FROM `users` GROUP BY `email` HAVING COUNT(email) > ?",
            bindings = [ 1 ]
        };
    }

    function havingRawValue() {
        return {
            sql = "SELECT COUNT(*) AS ""total"" FROM `items` WHERE `department` = ? GROUP BY `category` HAVING `total` > 3",
            bindings = [ "popular" ]
        };
    }

    function orderBy() {
        return "SELECT * FROM `users` ORDER BY `email` ASC";
    }

    function orderByDesc() {
        return "SELECT * FROM `users` ORDER BY `email` DESC";
    }

    function combinesOrderBy() {
        return "SELECT * FROM `users` ORDER BY `id` ASC, `email` DESC";
    }

    function orderByRaw() {
        return "SELECT * FROM `users` ORDER BY DATE(created_at)";
    }

    function orderByArray() {
        return "SELECT * FROM `users` ORDER BY `last_name` ASC, `age` ASC, `favorite_color` ASC";
    }

    function orderByPipeDelimited() {
        return "SELECT * FROM `users` ORDER BY `last_name` DESC, `age` ASC, `favorite_color` DESC";
    }

    function orderByArrayOfArrays() {
        return "SELECT * FROM `users` ORDER BY `last_name` DESC, `age` ASC, `favorite_color` ASC";
    }

    function orderByArrayOfArraysIgnoringExtraValues() {
        return "SELECT * FROM `users` ORDER BY `last_name` DESC, `age` ASC, `favorite_color` ASC, `height` ASC";
    }

    function orderByComplex() {
        return "SELECT * FROM `users` ORDER BY `last_name` DESC, `age` ASC, `favorite_color` ASC, `favorite_food` DESC, `height` ASC, `weight` DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByRawInStruct() {
        return "SELECT * FROM `users` ORDER BY DATE(created_at), DATE(modified_at)";
    }

    function orderByMixSimpleAndPipeDelimited() {
        return "SELECT * FROM `users` ORDER BY `last_name` ASC, `age` DESC, `favorite_color` ASC";
    }

    function orderByStruct() {
        return "SELECT * FROM `users` ORDER BY `last_name` DESC, `age` ASC, `favorite_color` DESC";
    }

    function multipleOrderByCalls() {
        return "SELECT * FROM `users` ORDER BY `last_name` ASC, `age` DESC, `favorite_color` DESC, `height` DESC, `weight` ASC, `eye_color` DESC, `is_athletic` DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByMixed() {
        return "SELECT * FROM `users` ORDER BY `last_name` ASC, `age` DESC, `eye_color` DESC, `hair_color` ASC, `is_musical` ASC, `is_athletic` DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByList() {
        return "SELECT * FROM `users` ORDER BY `last_name` ASC, `age` ASC, `favorite_color` ASC";
    }

    function orderByListDefaultDirection() {
        return "SELECT * FROM `users` ORDER BY `last_name` DESC, `age` DESC, `favorite_color` DESC";
    }

    function orderByListPipeDelimited() {
        return "SELECT * FROM `users` ORDER BY `last_name` DESC, `age` DESC, `favorite_color` ASC";
    }

    function orderByListPipeDelimitedWithDefaultDirection() {
        return "SELECT * FROM `users` ORDER BY `last_name` ASC, `age` DESC, `favorite_color` ASC";
    }

    function union() {
        return {
            sql = "SELECT `name` FROM `users` WHERE `id` = ? UNION SELECT `name` FROM `users` WHERE `id` = ? UNION SELECT `name` FROM `users` WHERE `id` = ?",
            bindings = [ 1, 2, 3 ]
        };
    }

    function unionOrderBy() {
        return {
            sql = "SELECT `name` FROM `users` WHERE `id` = ? UNION SELECT `name` FROM `users` WHERE `id` = ? UNION SELECT `name` FROM `users` WHERE `id` = ? ORDER BY `name` ASC",
            bindings = [ 1, 2, 3 ]
        };
    }

    function unionAll() {
        return {
            sql = "SELECT `name` FROM `users` WHERE `id` = ? UNION ALL SELECT `name` FROM `users` WHERE `id` = ? UNION ALL SELECT `name` FROM `users` WHERE `id` = ?",
            bindings = [ 1, 2, 3 ]
        };
    }

    function limit() {
        return "SELECT * FROM `users` LIMIT 3";
    }

    function take() {
        return "SELECT * FROM `users` LIMIT 1";
    }

    function offset() {
        return "SELECT * FROM `users` OFFSET 3";
    }

    function offsetWithOrderBy() {
        return "SELECT * FROM `users` ORDER BY `id` ASC OFFSET 3";
    }

    function forPage() {
        return "SELECT * FROM `users` LIMIT 15 OFFSET 30";
    }

    function forPageWithLessThanZeroValues() {
        return "SELECT * FROM `users` LIMIT 0 OFFSET 0";
    }

    function insertSingleColumn() {
        return {
            sql = "INSERT INTO `users` (`email`) VALUES (?)",
            bindings = [ "foo" ]
        };
    }

    function insertMultipleColumns() {
        return {
            sql = "INSERT INTO `users` (`email`, `name`) VALUES (?, ?)",
            bindings = [ "foo", "bar" ]
        };
    }

    function batchInsert() {
        return {
            sql = "INSERT INTO `users` (`email`, `name`) VALUES (?, ?), (?, ?)",
            bindings = [ "foo", "bar", "baz", "bleh" ]
        };
    }

    function updateAllRecords() {
        return {
            sql = "UPDATE `users` SET `email` = ?, `name` = ?",
            bindings = [ "foo", "bar" ]
        };
    }

    function updateWithWhere() {
        return {
            sql = "UPDATE `users` SET `email` = ?, `name` = ? WHERE `Id` = ?",
            bindings = [ "foo", "bar", 1 ]
        };
    }

    function updateOrInsertNotExists() {
        return {
            sql = "INSERT INTO `users` (`name`) VALUES (?)",
            bindings = [ "baz" ]
        };
    }

    function updateOrInsertExists() {
        return {
            sql = "UPDATE `users` SET `name` = ? WHERE `email` = ? LIMIT 1",
            bindings = [ "baz", "foo" ]
        };
    }

    function deleteAll() {
        return "DELETE FROM `users`";
    }

    function deleteById() {
        return {
            sql = "DELETE FROM `users` WHERE `id` = ?",
            bindings = [ 1 ]
        };
    }

    function deleteWhere() {
        return {
            sql = "DELETE FROM `users` WHERE `email` = ?",
            bindings = [ "foo" ]
        };
    }

    private function getBuilder() {
        variables.grammar = getMockBox()
            .createMock( "qb.models.Grammars.MySQLGrammar" );
        var queryUtils = getMockBox()
            .createMock( "qb.models.Query.QueryUtils" );
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" )
            .init( grammar, queryUtils );
        return builder;
    }

}
