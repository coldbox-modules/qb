component extends="tests.resources.AbstractQueryBuilderSpec" {

    function selectAllColumns() {
        return "SELECT * FROM ""USERS""";
    }

    function selectSpecificColumn() {
        return "SELECT ""NAME"" FROM ""USERS""";
    }

    function selectMultipleVariadic() {
        return "SELECT ""ID"", ""NAME"" FROM ""USERS""";
    }

    function selectMultipleArray() {
        return "SELECT ""NAME"", COUNT(*) FROM ""USERS""";
    }

    function addSelect() {
        return "SELECT ""FOO"", ""BAR"", ""BAZ"", ""BOOM"" FROM ""USERS""";
    }

    function addSelectRemovesStar() {
        return "SELECT ""FOO"" FROM ""USERS""";
    }

    function selectDistinct() {
        return "SELECT DISTINCT ""FOO"", ""BAR"" FROM ""USERS""";
    }

    function parseColumnAlias() {
        return "SELECT ""FOO"" AS ""BAR"" FROM ""USERS""";
    }

    function wrapColumnsAndAliases() {
        return "SELECT ""X"".""Y"" AS ""FOO.BAR"" FROM ""PUBLIC"".""USERS""";
    }

    function selectWithRaw() {
        return "SELECT substr( foo, 6 ) FROM ""USERS""";
    }

    function selectRaw() {
        return "SELECT substr( foo, 6 ) FROM ""USERS""";
    }

    function subSelect() {
        return "SELECT ""NAME"", ( SELECT MAX(updated_date) FROM ""POSTS"" WHERE ""POSTS"".""USER_ID"" = ""USERS"".""ID"" ) AS ""LATESTUPDATEDDATE"" FROM ""USERS""";
    }

    function subSelectWithBindings() {
        return {
            sql = "SELECT ""NAME"", ( SELECT MAX(updated_date) FROM ""POSTS"" WHERE ""POSTS"".""USER_ID"" = ? ) AS ""LATESTUPDATEDDATE"" FROM ""USERS""",
            bindings = [ 1 ]
        };
    }

    function from() {
        return "SELECT * FROM ""USERS""";
    }

    function fromRaw() {
        return "SELECT * FROM Test (nolock)";
    }

    function fromDerivedTable() {
        return {
            sql = "SELECT * FROM (SELECT ""ID"", ""NAME"" FROM ""USERS"" WHERE ""AGE"" >= ?) as ""U""",
            bindings = [21]
        };
    }

    function table() {
        return "SELECT * FROM ""USERS""";
    }

    function tablePrefix() {
        return "SELECT * FROM ""PREFIX_USERS""";
    }

    function tablePrefixWithAlias() {
        return "SELECT * FROM ""PREFIX_USERS"" AS ""PREFIX_PEOPLE""";
    }

    function columnAliasWithAs() {
        return "SELECT ""ID"" AS ""USER_ID"" FROM ""USERS""";
    }

    function columnAliasWithoutAs() {
        return "SELECT ""ID"" AS ""USER_ID"" FROM ""USERS""";
    }

    function tableAliasWithAs() {
        return "SELECT * FROM ""USERS"" AS ""PEOPLE""";
    }

    function tableAliasWithoutAs() {
        return "SELECT * FROM ""USERS"" AS ""PEOPLE""";
    }

    function basicWhere() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" = ?",
            bindings = [ 1 ]
        };
    }

    function orWhere() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR ""EMAIL"" = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function andWhere() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" = ? AND ""EMAIL"" = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function whereRaw() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE id = ? OR email = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function orWhereRaw() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR email = ?",
            bindings = [ 1, "foo" ]
        };
    }

    function whereColumn() {
        return "SELECT * FROM ""USERS"" WHERE ""FIRST_NAME"" = ""LAST_NAME""";
    }

    function orWhereColumn() {
        return "SELECT * FROM ""USERS"" WHERE ""FIRST_NAME"" = ""LAST_NAME"" OR ""UPDATED_DATE"" > ""CREATED_DATE""";
    }

    function whereNested() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""EMAIL"" = ? OR (""NAME"" = ? AND ""AGE"" >= ?)",
            bindings = [ "foo", "bar", 21 ]
        };
    }

    function whereSubselect() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""EMAIL"" = ? OR ""ID"" = (SELECT MAX(id) FROM ""USERS"" WHERE ""EMAIL"" = ?)",
            bindings = [ "foo", "bar" ]
        };
    }

    function whereExists() {
        return "SELECT * FROM ""ORDERS"" WHERE EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = orders.id)";
    }

    function orWhereExists() {
        return {
            sql = "SELECT * FROM ""ORDERS"" WHERE ""ID"" = ? OR EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = orders.id)",
            bindings = [ 1 ]
        };
    }

    function whereNotExists() {
        return "SELECT * FROM ""ORDERS"" WHERE NOT EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = orders.id)";
    }

    function orWhereNotExists() {
        return {
            sql = "SELECT * FROM ""ORDERS"" WHERE ""ID"" = ? OR NOT EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = orders.id)",
            bindings = [ 1 ]
        };
    }

    function whereNull() {
        return "SELECT * FROM ""USERS"" WHERE ""ID"" IS NULL";
    }

    function orWhereNull() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR ""ID"" IS NULL",
            bindings = [ 1 ]
        };
    }

    function whereNotNull() {
        return "SELECT * FROM ""USERS"" WHERE ""ID"" IS NOT NULL";
    }

    function orWhereNotNull() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR ""ID"" IS NOT NULL",
            bindings = [ 1 ]
        };
    }

    function whereBetween() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" BETWEEN ? AND ?",
            bindings = [ 1, 2 ]
        };
    }

    function whereNotBetween() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" NOT BETWEEN ? AND ?",
            bindings = [ 1, 2 ]
        };
    }

    function whereInList() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function whereInArray() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function orWhereIn() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""EMAIL"" = ? OR ""ID"" IN (?, ?, ?)",
            bindings = [ "foo", 1, 2, 3 ]
        };
    }

    function whereInRaw() {
        return "SELECT * FROM ""USERS"" WHERE ""ID"" IN (1)";
    }

    function whereInEmpty() {
        return "SELECT * FROM ""USERS"" WHERE 0 = 1";
    }

    function whereNotInEmpty() {
        return "SELECT * FROM ""USERS"" WHERE 1 = 1";
    }

    function whereInSubSelect() {
        return {
            sql = "SELECT * FROM ""USERS"" WHERE ""ID"" IN (SELECT ""ID"" FROM ""USERS"" WHERE ""AGE"" > ?)",
            bindings = [ 25 ]
        };
    }

    function innerJoin() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function innerJoinRaw() {
        return "SELECT * FROM ""USERS"" INNER JOIN contacts (nolock) ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function innerJoinShorthand() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function multipleJoins() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" INNER JOIN ""ADDRESSES"" AS ""A"" ON ""A"".""CONTACT_ID"" = ""CONTACTS"".""ID""";
    }

    function joinWithWhere() {
        return {
            sql = "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""CONTACTS"".""BALANCE"" < ?",
            bindings = [ 100 ]
        };
    }

    function leftJoin() {
        return "SELECT * FROM ""USERS"" LEFT JOIN ""ORDERS"" ON ""USERS"".""ID"" = ""ORDERS"".""USER_ID""";
    }

    function leftJoinRaw() {
        return "SELECT * FROM ""USERS"" LEFT JOIN contacts (nolock) ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function rightJoin() {
        return "SELECT * FROM ""ORDERS"" RIGHT JOIN ""USERS"" ON ""ORDERS"".""USER_ID"" = ""USERS"".""ID""";
    }

    function rightJoinRaw() {
        return "SELECT * FROM ""USERS"" RIGHT JOIN contacts (nolock) ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function crossJoin() {
        return "SELECT * FROM ""SIZES"" CROSS JOIN ""COLORS""";
    }

    function crossJoinRaw() {
        return "SELECT * FROM ""USERS"" CROSS JOIN contacts (nolock)";
    }

    function complexJoin() {
        return {
            sql = "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""USERS"".""NAME"" = ""CONTACTS"".""NAME"" OR ""USERS"".""ADMIN"" = ?",
            bindings = [ 1 ]
        };
    }

    function joinWithWhereNull() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" AND ""CONTACTS"".""DELETED_DATE"" IS NULL";
    }

    function joinWithOrWhereNull() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""CONTACTS"".""DELETED_DATE"" IS NULL";
    }

    function joinWithWhereNotNull() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" AND ""CONTACTS"".""DELETED_DATE"" IS NOT NULL";
    }

    function joinWithOrWhereNotNull() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""CONTACTS"".""DELETED_DATE"" IS NOT NULL";
    }

    function joinWithWhereIn() {
        return {
            sql = "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" AND ""CONTACTS"".""ID"" IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereIn() {
        return {
            sql = "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""CONTACTS"".""ID"" IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinWithWhereNotIn() {
        return {
            sql = "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" AND ""CONTACTS"".""ID"" NOT IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereNotIn() {
        return {
            sql = "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""CONTACTS"".""ID"" NOT IN (?, ?, ?)",
            bindings = [ 1, 2, 3 ]
        };
    }

    function joinSub() {
        return {
            sql = 'SELECT * FROM "USERS" AS "U" INNER JOIN (SELECT "ID" FROM "CONTACTS" WHERE "ID" NOT IN (?, ?, ?)) as "C" ON "U"."ID" = "C"."ID"',
            bindings = [ 1, 2, 3 ]
        };
    }

    function leftJoinSub() {
        return {
            sql = 'SELECT * FROM "USERS" AS "U" LEFT JOIN (SELECT "ID" FROM "CONTACTS" WHERE "ID" NOT IN (?, ?, ?)) as "C" ON "U"."ID" = "C"."ID"',
            bindings = [ 1, 2, 3 ]
        };
    }

    function rightJoinSub() {
        return {
            sql = 'SELECT * FROM "USERS" AS "U" RIGHT JOIN (SELECT "ID" FROM "CONTACTS" WHERE "ID" NOT IN (?, ?, ?)) as "C" ON "U"."ID" = "C"."ID"',
            bindings = [ 1, 2, 3 ]
        };
    }

    function crossJoinSub() {
        return {
            sql = 'SELECT * FROM "USERS" AS "U" CROSS JOIN (SELECT "ID" FROM "CONTACTS" WHERE "ID" NOT IN (?, ?, ?)) as "C"',
            bindings = [ 1, 2, 3 ]
        };
    }

    function groupBy() {
        return "SELECT * FROM ""USERS"" GROUP BY ""EMAIL""";
    }

    function groupByArray() {
        return "SELECT * FROM ""USERS"" GROUP BY ""ID"", ""EMAIL""";
    }

    function groupByRaw() {
        return "SELECT * FROM ""USERS"" GROUP BY DATE(created_at)";
    }

    function havingBasic() {
        return {
            sql = "SELECT * FROM ""USERS"" HAVING ""EMAIL"" > ?",
            bindings = [ 1 ]
        };
    }

    function havingRawColumn() {
        return {
            sql = "SELECT * FROM ""USERS"" GROUP BY ""EMAIL"" HAVING COUNT(email) > ?",
            bindings = [ 1 ]
        };
    }

    function havingRawValue() {
        return {
            sql = "SELECT COUNT(*) AS ""total"" FROM ""ITEMS"" WHERE ""DEPARTMENT"" = ? GROUP BY ""CATEGORY"" HAVING ""TOTAL"" > 3",
            bindings = [ "popular" ]
        };
    }

    function orderBy() {
        return "SELECT * FROM ""USERS"" ORDER BY ""EMAIL"" ASC";
    }

    function orderByDesc() {
        return "SELECT * FROM ""USERS"" ORDER BY ""EMAIL"" DESC";
    }

    function combinesOrderBy() {
        return "SELECT * FROM ""USERS"" ORDER BY ""ID"" ASC, ""EMAIL"" DESC";
    }

    function orderByRaw() {
        return "SELECT * FROM ""USERS"" ORDER BY DATE(created_at)";
    }

    function orderByArray() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" ASC, ""AGE"" ASC, ""FAVORITE_COLOR"" ASC";
    }

    function orderByPipeDelimited() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" DESC, ""AGE"" ASC, ""FAVORITE_COLOR"" DESC";
    }

    function orderByArrayOfArrays() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" DESC, ""AGE"" ASC, ""FAVORITE_COLOR"" ASC";
    }

    function orderByArrayOfArraysIgnoringExtraValues() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" DESC, ""AGE"" ASC, ""FAVORITE_COLOR"" ASC, ""HEIGHT"" ASC";
    }

    function orderByComplex() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" DESC, ""AGE"" ASC, ""FAVORITE_COLOR"" ASC, ""FAVORITE_FOOD"" DESC, ""HEIGHT"" ASC, ""WEIGHT"" DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByRawInStruct() {
        return "SELECT * FROM ""USERS"" ORDER BY DATE(created_at), DATE(modified_at)";
    }

    function orderByMixSimpleAndPipeDelimited() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" ASC, ""AGE"" DESC, ""FAVORITE_COLOR"" ASC";
    }

    function orderByStruct() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" DESC, ""AGE"" ASC, ""FAVORITE_COLOR"" DESC";
    }

    function multipleOrderByCalls() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" ASC, ""AGE"" DESC, ""FAVORITE_COLOR"" DESC, ""HEIGHT"" DESC, ""WEIGHT"" ASC, ""EYE_COLOR"" DESC, ""IS_ATHLETIC"" DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByMixed() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" ASC, ""AGE"" DESC, ""EYE_COLOR"" DESC, ""HAIR_COLOR"" ASC, ""IS_MUSICAL"" ASC, ""IS_ATHLETIC"" DESC, DATE(created_at), DATE(modified_at)";
    }

    function orderByList() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" ASC, ""AGE"" ASC, ""FAVORITE_COLOR"" ASC";
    }

    function orderByListDefaultDirection() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" DESC, ""AGE"" DESC, ""FAVORITE_COLOR"" DESC";
    }

    function orderByListPipeDelimited() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" DESC, ""AGE"" DESC, ""FAVORITE_COLOR"" ASC";
    }

    function orderByListPipeDelimitedWithDefaultDirection() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" ASC, ""AGE"" DESC, ""FAVORITE_COLOR"" ASC";
    }

    function union() {
        return {
            sql = "SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ?",
            bindings = [ 1, 2, 3 ]
        };
    }

    function unionOrderBy() {
        return {
            sql = "SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? ORDER BY ""NAME"" ASC",
            bindings = [ 1, 2, 3 ]
        };
    }

    function unionAll() {
        return {
            sql = "SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION ALL SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION ALL SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ?",
            bindings = [ 1, 2, 3 ]
        };
    }

    function commonTableExpression() {
        return {
            sql='WITH "USERSCTE" AS (SELECT * FROM "USERS" INNER JOIN "CONTACTS" ON "USERS"."ID" = "CONTACTS"."ID" WHERE "USERS"."AGE" > ?) SELECT * FROM "USERSCTE" WHERE "USER"."ID" NOT IN (?, ?)',
            bindings= [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionWithRecursive() {
        return {
            sql='WITH "USERSCTE" AS (SELECT * FROM "USERS" INNER JOIN "CONTACTS" ON "USERS"."ID" = "CONTACTS"."ID" WHERE "USERS"."AGE" > ?) SELECT * FROM "USERSCTE" WHERE "USER"."ID" NOT IN (?, ?)',
            bindings= [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionMultipleCTEsWithRecursive() {
        return {
            sql='WITH "USERSCTE" AS (SELECT * FROM "USERS" INNER JOIN "CONTACTS" ON "USERS"."ID" = "CONTACTS"."ID" WHERE "USERS"."AGE" > ?), "ORDERCTE" AS (SELECT * FROM "ORDERS" WHERE "CREATED" > ?) SELECT * FROM "USERSCTE" WHERE "USER"."ID" NOT IN (?, ?)',
            bindings= [ 25, "2018-04-30", 1, 2 ]
        };
    }

    function commonTableExpressionBindingOrder() {
        return {
            sql='WITH "ORDERCTE" AS (SELECT * FROM "ORDERS" WHERE "CREATED" > ?), "USERSCTE" AS (SELECT * FROM "USERS" INNER JOIN "CONTACTS" ON "USERS"."ID" = "CONTACTS"."ID" WHERE "USERS"."AGE" > ?) SELECT * FROM "USERSCTE" WHERE "USER"."ID" NOT IN (?, ?)',
            bindings= [ "2018-04-30", 25, 1, 2 ]
        };
    }

    function limit() {
        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" <= 3";
    }

    function take() {
        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" <= 1";
    }

    function offset() {
        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" > 3";
    }

    function offsetWithOrderBy() {
        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"" ORDER BY ""ID"" ASC) results ) WHERE ""QB_RN"" > 3";
    }

    function forPage() {
        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" > 30 AND ""QB_RN"" <= 45";
    }

    function forPageWithLessThanZeroValues() {
        return "SELECT * FROM (SELECT results.*, ROWNUM AS ""QB_RN"" FROM (SELECT * FROM ""USERS"") results ) WHERE ""QB_RN"" > 0 AND ""QB_RN"" <= 0";
    }

    function insertSingleColumn() {
        return {
            sql = "INSERT ALL INTO ""USERS"" (""EMAIL"") VALUES (?) SELECT 1 FROM dual",
            bindings = [ "foo" ]
        };
    }

    function insertMultipleColumns() {
        return {
            sql = "INSERT ALL INTO ""USERS"" (""EMAIL"", ""NAME"") VALUES (?, ?) SELECT 1 FROM dual",
            bindings = [ "foo", "bar" ]
        };
    }

    function batchInsert() {
        return {
            sql = "INSERT ALL INTO ""USERS"" (""EMAIL"", ""NAME"") VALUES (?, ?) INTO ""USERS"" (""EMAIL"", ""NAME"") VALUES (?, ?) SELECT 1 FROM dual",
            bindings = [ "foo", "bar", "baz", "bleh" ]
        };
    }

    function updateAllRecords() {
        return {
            sql = "UPDATE ""USERS"" SET ""EMAIL"" = ?, ""NAME"" = ?",
            bindings = [ "foo", "bar" ]
        };
    }

    function updateWithWhere() {
        return {
            sql = "UPDATE ""USERS"" SET ""EMAIL"" = ?, ""NAME"" = ? WHERE ""ID"" = ?",
            bindings = [ "foo", "bar", 1 ]
        };
    }

    function updateOrInsertNotExists() {
        return {
            sql = "INSERT ALL INTO ""USERS"" (""NAME"") VALUES (?) SELECT 1 FROM dual",
            bindings = [ "baz" ]
        };
    }

    function updateOrInsertExists() {
        return {
            sql = "UPDATE ""USERS"" SET ""NAME"" = ? WHERE ""EMAIL"" = ?",
            bindings = [ "baz", "foo" ]
        };
    }

    function deleteAll() {
        return "DELETE FROM ""USERS""";
    }

    function deleteById() {
        return {
            sql = "DELETE FROM ""USERS"" WHERE ""ID"" = ?",
            bindings = [ 1 ]
        };
    }

    function deleteWhere() {
        return {
            sql = "DELETE FROM ""USERS"" WHERE ""EMAIL"" = ?",
            bindings = [ "foo" ]
        };
    }

    private function getBuilder() {
        variables.grammar = getMockBox()
            .createMock( "qb.models.Grammars.OracleGrammar" )
            .init();
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" )
            .init( grammar );
        return builder;
    }

}
