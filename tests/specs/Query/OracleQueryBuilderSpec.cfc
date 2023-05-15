component extends="tests.resources.AbstractQueryBuilderSpec" {

    function selectAllColumns() {
        return "SELECT * FROM ""USERS""";
    }

    function selectSpecificColumn() {
        return "SELECT ""NAME"" FROM ""USERS""";
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

    function parseColumnAliasWithQuotes() {
        return "SELECT ""FOO"" AS ""bar"" FROM ""USERS""";
    }

    function parseColumnAliasInWhere() {
        return { "sql": "SELECT ""USERS"".""FOO"" FROM ""USERS"" WHERE ""USERS"".""FOO"" = ?", "bindings": [ "bar" ] };
    }

    function parseColumnAliasInWhereSubselect() {
        return {
            "sql": "SELECT ""U"".*, ""USER_ROLES"".""ROLEID"", ""ROLES"".""ROLECODE"" FROM ""USERS"" ""U"" INNER JOIN ""USER_ROLES"" ON ""USER_ROLES"".""USERID"" = ""U"".""USERID"" LEFT JOIN ""ROLES"" ON ""USER_ROLES"".""ROLEID"" = ""ROLES"".""ROLEID"" WHERE ""USER_ROLES"".""ROLEID"" = (SELECT ""ROLEID"" FROM ""ROLES"" WHERE ""ROLECODE"" = ?)",
            "bindings": [ "SYSADMIN" ]
        };
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

    function selectRawArray() {
        return "SELECT substr( foo, 6 ), trim( bar ) FROM ""USERS""";
    }

    function selectConcat() {
        return "SELECT CONCAT(a,b,c,d) AS ""MY_ALIAS"" FROM ""USERS""";
    }

    function selectConcatArray() {
        return "SELECT CONCAT(a,b,c,d) AS ""MY_ALIAS"" FROM ""USERS""";
    }

    function clearSelect() {
        return "SELECT * FROM ""USERS""";
    }

    function reselect() {
        return "SELECT ""BAZ"" FROM ""USERS""";
    }

    function reselectRaw() {
        return "SELECT substr( foo, 6 ), trim( bar ) FROM ""USERS""";
    }

    function subSelect() {
        return "SELECT ""NAME"", (SELECT MAX(updated_date) FROM ""POSTS"" WHERE ""POSTS"".""USER_ID"" = ""USERS"".""ID"") ""LATESTUPDATEDDATE"" FROM ""USERS""";
    }

    function subSelectQueryObject() {
        return "SELECT ""NAME"", (SELECT MAX(updated_date) FROM ""POSTS"" WHERE ""POSTS"".""USER_ID"" = ""USERS"".""ID"") ""LATESTUPDATEDDATE"" FROM ""USERS""";
    }

    function subSelectWithBindings() {
        return {
            sql: "SELECT ""NAME"", (SELECT MAX(updated_date) FROM ""POSTS"" WHERE ""POSTS"".""USER_ID"" = ?) ""LATESTUPDATEDDATE"" FROM ""USERS""",
            bindings: [ 1 ]
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
            sql: "SELECT * FROM (SELECT ""ID"", ""NAME"" FROM ""USERS"" WHERE ""AGE"" >= ?) ""U""",
            bindings: [ 21 ]
        };
    }

    function fromSubBindings() {
        return {
            sql: "SELECT ""ACCOUNTS"".""ID"" FROM (SELECT ""ID"", ""NAME"" FROM ""USERS"" WHERE ""AGE"" >= ?) ""U"" INNER JOIN ""ACCOUNTS"" ON ""ACCOUNTS"".""USERID"" = ""U"".""ID"" AND ""ACCOUNTS"".""ACTIVE"" = ?",
            bindings: [ 21, 1 ]
        };
    }

    function noLock() {
        return { "sql": "SELECT * FROM ""USERS"" WHERE ""ID"" = ?", "bindings": [ 1 ] };
    }

    function sharedLock() {
        return {
            "sql": "LOCK TABLE ""USERS"" IN SHARE MODE NOWAIT; SELECT * FROM ""USERS"" WHERE ""ID"" = ?",
            "bindings": [ 1 ]
        };
    }

    function lockForUpdate() {
        return { "sql": "SELECT * FROM ""USERS"" WHERE ""ID"" = ? FOR UPDATE", "bindings": [ 1 ] };
    }

    function lockForUpdateSkipLocked() {
        return { "sql": "SELECT * FROM ""USERS"" WHERE ""ID"" = ? FOR UPDATE SKIP LOCKED", "bindings": [ 1 ] };
    }

    function lockArbitraryString() {
        return {
            "sql": "LOCK TABLE ""USERS"" IN foobar MODE NOWAIT; SELECT * FROM ""USERS"" WHERE ""ID"" = ?",
            "bindings": [ 1 ]
        };
    }

    function table() {
        return "SELECT * FROM ""USERS""";
    }

    function tablePrefix() {
        return "SELECT * FROM ""PREFIX_USERS""";
    }

    function tablePrefixWithAlias() {
        return "SELECT * FROM ""PREFIX_USERS"" ""PREFIX_PEOPLE""";
    }

    function columnAliasWithAs() {
        return "SELECT ""ID"" AS ""USER_ID"" FROM ""USERS""";
    }

    function columnAliasWithoutAs() {
        return "SELECT ""ID"" AS ""USER_ID"" FROM ""USERS""";
    }

    function tableAliasWithAs() {
        return "SELECT * FROM ""USERS"" ""PEOPLE""";
    }

    function tableAliasWithoutAs() {
        return "SELECT * FROM ""USERS"" ""PEOPLE""";
    }

    function basicWhere() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" = ?", bindings: [ 1 ] };
    }

    function basicWhereWithQueryParamStruct() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""CREATEDDATE"" >= ?", bindings: [ "01/01/2019" ] };
    }

    function orWhere() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR ""EMAIL"" = ?", bindings: [ 1, "foo" ] };
    }

    function andWhere() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" = ? AND ""EMAIL"" = ?", bindings: [ 1, "foo" ] };
    }

    function whereRaw() {
        return { sql: "SELECT * FROM ""USERS"" WHERE id = ? OR email = ?", bindings: [ 1, "foo" ] };
    }

    function orWhereRaw() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR email = ?", bindings: [ 1, "foo" ] };
    }

    function whereColumn() {
        return "SELECT * FROM ""USERS"" WHERE ""FIRST_NAME"" = ""LAST_NAME""";
    }

    function orWhereColumn() {
        return "SELECT * FROM ""USERS"" WHERE ""FIRST_NAME"" = ""LAST_NAME"" OR ""UPDATED_DATE"" > ""CREATED_DATE""";
    }

    function whereNested() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""EMAIL"" = ? OR (""NAME"" = ? AND ""AGE"" >= ?)",
            bindings: [ "foo", "bar", 21 ]
        };
    }

    function whereSubselect() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""EMAIL"" = ? OR ""ID"" = (SELECT MAX(id) FROM ""USERS"" WHERE ""EMAIL"" = ?)",
            bindings: [ "foo", "bar" ]
        };
    }

    function whereExists() {
        return "SELECT * FROM ""ORDERS"" WHERE EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = ""ORDERS"".""ID"")";
    }

    function orWhereExists() {
        return {
            sql: "SELECT * FROM ""ORDERS"" WHERE ""ID"" = ? OR EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = ""ORDERS"".""ID"")",
            bindings: [ 1 ]
        };
    }

    function whereNotExists() {
        return "SELECT * FROM ""ORDERS"" WHERE NOT EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = ""ORDERS"".""ID"")";
    }

    function orWhereNotExists() {
        return {
            sql: "SELECT * FROM ""ORDERS"" WHERE ""ID"" = ? OR NOT EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = ""ORDERS"".""ID"")",
            bindings: [ 1 ]
        };
    }

    function whereNull() {
        return "SELECT * FROM ""USERS"" WHERE ""ID"" IS NULL";
    }

    function orWhereNull() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR ""ID"" IS NULL", bindings: [ 1 ] };
    }

    function whereNotNull() {
        return "SELECT * FROM ""USERS"" WHERE ""ID"" IS NOT NULL";
    }

    function orWhereNotNull() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" = ? OR ""ID"" IS NOT NULL", bindings: [ 1 ] };
    }

    function whereBetween() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" BETWEEN ? AND ?", bindings: [ 1, 2 ] };
    }

    function whereBetweenWithQueryParamStructs() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""CREATEDDATE"" BETWEEN ? AND ?",
            bindings: [ "1/1/2019", "12/31/2019" ]
        };
    }

    function whereNotBetween() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" NOT BETWEEN ? AND ?", bindings: [ 1, 2 ] };
    }

    function whereInList() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" IN (?, ?, ?)", bindings: [ 1, 2, 3 ] };
    }

    function whereInArray() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" IN (?, ?, ?)", bindings: [ 1, 2, 3 ] };
    }

    function whereInArrayOfQueryParamStructs() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""ID"" IN (?, ?, ?)", bindings: [ 1, 2, 3 ] };
    }

    function orWhereIn() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""EMAIL"" = ? OR ""ID"" IN (?, ?, ?)",
            bindings: [ "foo", 1, 2, 3 ]
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
            sql: "SELECT * FROM ""USERS"" WHERE ""ID"" IN (SELECT ""ID"" FROM ""USERS"" WHERE ""AGE"" > ?)",
            bindings: [ 25 ]
        };
    }

    function whereLike() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""USERNAME"" LIKE ?", bindings: [ "Jo%" ] };
    }

    function whereNotLike() {
        return { sql: "SELECT * FROM ""USERS"" WHERE ""USERNAME"" NOT LIKE ?", bindings: [ "Jo%" ] };
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
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" INNER JOIN ""ADDRESSES"" ""A"" ON ""A"".""CONTACT_ID"" = ""CONTACTS"".""ID""";
    }

    function joinWithWhere() {
        return {
            sql: "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""CONTACTS"".""BALANCE"" < ?",
            bindings: [ 100 ]
        };
    }

    function leftJoin() {
        return "SELECT * FROM ""USERS"" LEFT JOIN ""ORDERS"" ON ""USERS"".""ID"" = ""ORDERS"".""USER_ID""";
    }

    function leftJoinTruncatingText() {
        return "SELECT * FROM ""TEST"" LEFT JOIN ""LAST_TEAM_TASKS_QUEUE_RECORD"" ON ""LAST_TEAM_TASKS_QUEUE_RECORD"".""TASK_TERRITORY_ID"" = ""TEAM_TASKS_QUEUE"".""TASK_TERRITORY_ID"" AND (""LAST_TEAM_TASKS_QUEUE_RECORD"".""WHEN_CREATED"" IS NULL OR ""LAST_TEAM_TASKS_QUEUE_RECORD"".""WHEN_CREATED"" <= ""TEAM_TASKS_QUEUE"".""WHEN_CREATED"")";
    }

    function leftJoinRaw() {
        return "SELECT * FROM ""USERS"" LEFT JOIN contacts (nolock) ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function leftJoinNested() {
        return "SELECT * FROM ""USERS"" LEFT JOIN ""ORDERS"" ON ""USERS"".""ID"" = ""ORDERS"".""USER_ID""";
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
            sql: "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""USERS"".""NAME"" = ""CONTACTS"".""NAME"" OR ""USERS"".""ADMIN"" = ?",
            bindings: [ 1 ]
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
            sql: "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" AND ""CONTACTS"".""ID"" IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereIn() {
        return {
            sql: "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""CONTACTS"".""ID"" IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinWithWhereNotIn() {
        return {
            sql: "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" AND ""CONTACTS"".""ID"" NOT IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinWithOrWhereNotIn() {
        return {
            sql: "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" OR ""CONTACTS"".""ID"" NOT IN (?, ?, ?)",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinSub() {
        return {
            sql: "SELECT * FROM ""USERS"" ""U"" INNER JOIN (SELECT ""ID"" FROM ""CONTACTS"" WHERE ""ID"" NOT IN (?, ?, ?)) ""C"" ON ""U"".""ID"" = ""C"".""ID""",
            bindings: [ 1, 2, 3 ]
        };
    }

    function leftJoinSub() {
        return {
            sql: "SELECT * FROM ""USERS"" ""U"" LEFT JOIN (SELECT ""ID"" FROM ""CONTACTS"" WHERE ""ID"" NOT IN (?, ?, ?)) ""C"" ON ""U"".""ID"" = ""C"".""ID""",
            bindings: [ 1, 2, 3 ]
        };
    }

    function rightJoinSub() {
        return {
            sql: "SELECT * FROM ""USERS"" ""U"" RIGHT JOIN (SELECT ""ID"" FROM ""CONTACTS"" WHERE ""ID"" NOT IN (?, ?, ?)) ""C"" ON ""U"".""ID"" = ""C"".""ID""",
            bindings: [ 1, 2, 3 ]
        };
    }

    function crossJoinSub() {
        return {
            sql: "SELECT * FROM ""USERS"" ""U"" CROSS JOIN (SELECT ""ID"" FROM ""CONTACTS"" WHERE ""ID"" NOT IN (?, ?, ?)) ""C""",
            bindings: [ 1, 2, 3 ]
        };
    }

    function joinSubBindings() {
        return {
            sql: "SELECT * FROM ""A"" INNER JOIN (SELECT * FROM ""B"" WHERE ""B"".""B"" = ?) ""B"" ON ""A"".""A"" = ""B"".""B"" WHERE ""A"".""A"" = ? AND ""A"".""C"" = ?",
            bindings: [ "B", "A", "C" ]
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
        return { sql: "SELECT * FROM ""USERS"" HAVING ""EMAIL"" > ?", bindings: [ 1 ] };
    }

    function havingRawColumn() {
        return { sql: "SELECT * FROM ""USERS"" GROUP BY ""EMAIL"" HAVING COUNT(email) > ?", bindings: [ 1 ] };
    }

    function havingRawExpression() {
        return { sql: "SELECT * FROM ""USERS"" GROUP BY ""EMAIL"" HAVING COUNT(email) > ?", bindings: [ 1 ] };
    }

    function havingRawColumnWithBindings() {
        return {
            sql: "SELECT * FROM ""USERS"" GROUP BY ""EMAIL"" HAVING CASE WHEN active = ? THEN COUNT(email) ELSE 0 END > ?",
            bindings: [ 1, 2 ]
        };
    }

    function havingRawValue() {
        return {
            sql: "SELECT COUNT(*) AS ""total"" FROM ""ITEMS"" WHERE ""DEPARTMENT"" = ? GROUP BY ""CATEGORY"" HAVING ""TOTAL"" > 3",
            bindings: [ "popular" ]
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

    function orderByRawWithBindings() {
        return { "sql": "SELECT * FROM ""USERS"" ORDER BY CASE WHEN id = ? THEN 1 ELSE 0 END DESC", "bindings": [ 1 ] };
    }

    function orderByWithRawBindings() {
        return { "sql": "SELECT * FROM ""USERS"" ORDER BY CASE WHEN id = ? THEN 1 ELSE 0 END DESC", "bindings": [ 1 ] };
    }

    function orderByArray() {
        return "SELECT * FROM ""USERS"" ORDER BY ""LAST_NAME"" ASC, ""AGE"" ASC, ""FAVORITE_COLOR"" ASC";
    }

    function orderByClearOrders() {
        return "SELECT * FROM ""USERS""";
    }

    function reorder() {
        return "SELECT * FROM ""USERS"" ORDER BY ""AGE"" ASC";
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
            sql: "SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ?",
            bindings: [ 1, 2, 3 ]
        };
    }

    function unionOrderBy() {
        return {
            sql: "SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? ORDER BY ""NAME"" ASC",
            bindings: [ 1, 2, 3 ]
        };
    }

    function unionAll() {
        return {
            sql: "SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION ALL SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION ALL SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ?",
            bindings: [ 1, 2, 3 ]
        };
    }

    function unionCount() {
        return {
            sql: "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM (SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ? UNION SELECT ""NAME"" FROM ""USERS"" WHERE ""ID"" = ?) ""QB_AGGREGATE_SOURCE""",
            bindings: [ 1, 2 ]
        };
    }

    function commonTableExpression() {
        return {
            sql: "WITH ""USERSCTE"" AS (SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" WHERE ""USERS"".""AGE"" > ?) SELECT * FROM ""USERSCTE"" WHERE ""USER"".""ID"" NOT IN (?, ?)",
            bindings: [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionWithRecursive() {
        return {
            sql: "WITH ""USERSCTE"" AS (SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" WHERE ""USERS"".""AGE"" > ?) SELECT * FROM ""USERSCTE"" WHERE ""USER"".""ID"" NOT IN (?, ?)",
            bindings: [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionWithRecursiveWithColumns() {
        return {
            sql: "WITH ""USERSCTE"" ""USERSID"",""CONTACTSID"" AS (SELECT ""USERS"".""ID"" AS ""USERSID"", ""CONTACTS"".""ID"" AS ""CONTACTSID"" FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" WHERE ""USERS"".""AGE"" > ?) SELECT * FROM ""USERSCTE"" WHERE ""USER"".""ID"" NOT IN (?, ?)",
            bindings: [ 25, 1, 2 ]
        };
    }

    function commonTableExpressionMultipleCTEsWithRecursive() {
        return {
            sql: "WITH ""USERSCTE"" AS (SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" WHERE ""USERS"".""AGE"" > ?), ""ORDERCTE"" AS (SELECT * FROM ""ORDERS"" WHERE ""CREATED"" > ?) SELECT * FROM ""USERSCTE"" WHERE ""USER"".""ID"" NOT IN (?, ?)",
            bindings: [ 25, "2018-04-30", 1, 2 ]
        };
    }

    function commonTableExpressionBindingOrder() {
        return {
            sql: "WITH ""ORDERCTE"" AS (SELECT * FROM ""ORDERS"" WHERE ""CREATED"" > ?), ""USERSCTE"" AS (SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID"" WHERE ""USERS"".""AGE"" > ?) SELECT * FROM ""USERSCTE"" WHERE ""USER"".""ID"" NOT IN (?, ?)",
            bindings: [ "2018-04-30", 25, 1, 2 ]
        };
    }

    function cteInsertUsing() {
        return {
            sql: "WITH ""USERSCTE"" AS (SELECT * FROM ""USERS"" WHERE ""USERS"".""AGE"" > ?) INSERT INTO ""OLDUSERS"" (""FNAME"", ""LNAME"", ""USERNAME"", ""AGE"") SELECT ""FNAME"", ""LNAME"", ""USERNAME"", ""AGE"" FROM ""USERSCTE""",
            bindings: [ 25 ]
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
        return { sql: "INSERT INTO ""USERS"" (""EMAIL"") VALUES (?)", bindings: [ "foo" ] };
    }

    function insertMultipleColumns() {
        return { sql: "INSERT INTO ""USERS"" (""EMAIL"", ""NAME"") VALUES (?, ?)", bindings: [ "foo", "bar" ] };
    }

    function batchInsert() {
        return {
            sql: "INSERT ALL INTO ""USERS"" (""EMAIL"", ""NAME"") VALUES (?, ?) INTO ""USERS"" (""EMAIL"", ""NAME"") VALUES (?, ?) SELECT 1 FROM dual",
            bindings: [ "foo", "bar", "baz", "bleh" ]
        };
    }

    function insertWithRaw() {
        return {
            sql: "INSERT INTO ""USERS"" (""CREATED_DATE"", ""EMAIL"") VALUES (now(), ?)",
            bindings: [ "john@example.com" ]
        };
    }

    function insertWithNull() {
        return {
            sql: "INSERT INTO ""USERS"" (""EMAIL"", ""OPTIONAL_FIELD"") VALUES (?, ?)",
            bindings: [ "john@example.com", "NULL" ]
        };
    }

    function insertUsingSelectCallback() {
        return {
            sql: "INSERT INTO ""USERS"" (""EMAIL"", ""CREATEDDATE"") SELECT ""EMAIL"", ""CREATEDDATE"" FROM ""ACTIVEDIRECTORYUSERS"" WHERE ""ACTIVE"" = ?",
            bindings: [ 1 ]
        };
    }

    function insertUsingSelectBuilder() {
        return {
            SQL: "INSERT INTO ""USERS"" (""EMAIL"", ""CREATEDDATE"") SELECT ""EMAIL"", ""CREATEDDATE"" FROM ""ACTIVEDIRECTORYUSERS"" WHERE ""ACTIVE"" = ?",
            bindings: [ 1 ]
        };
    }

    function insertUsingDerivingColumnNames() {
        return {
            SQL: "INSERT INTO ""USERS"" (""EMAIL"", ""CREATEDDATE"") SELECT ""EMAIL"", ""MODIFIEDDATE"" AS ""CREATEDDATE"" FROM ""ACTIVEDIRECTORYUSERS"" WHERE ""ACTIVE"" = ?",
            bindings: [ 1 ]
        };
    }

    function insertUsingDerivedColumnNamesFromRawStatements() {
        return {
            SQL: "INSERT INTO ""USERS"" (""EMAIL"", ""CREATEDDATE"") SELECT ""EMAIL"", COALESCE(modifiedDate, NOW()) AS createdDate FROM ""ACTIVEDIRECTORYUSERS"" WHERE ""ACTIVE"" = ?",
            bindings: [ 1 ]
        };
    }

    function insertIgnore() {
        return {
            sql: "MERGE INTO ""USERS"" ""QB_TARGET"" USING (SELECT ?, ? FROM dual UNION ALL SELECT ?, ? FROM dual) ""QB_SRC"" ON ""QB_TARGET"".""EMAIL"" = ""QB_SRC"".""EMAIL"" WHEN NOT MATCHED THEN INSERT (""EMAIL"", ""NAME"") VALUES (""QB_SRC"".""EMAIL"", ""QB_SRC"".""NAME"")",
            bindings: [ "foo", "bar", "baz", "bleh" ]
        };
    }

    function returning() {
        return { exception: "UnsupportedOperation" };
    }

    function returningIgnoresTableQualifiers() {
        return { exception: "UnsupportedOperation" };
    }

    function updateAllRecords() {
        return { sql: "UPDATE ""USERS"" SET ""EMAIL"" = ?, ""NAME"" = ?", bindings: [ "foo", "bar" ] };
    }

    function updateWithWhere() {
        return {
            sql: "UPDATE ""USERS"" SET ""EMAIL"" = ?, ""NAME"" = ? WHERE ""ID"" = ?",
            bindings: [ "foo", "bar", 1 ]
        };
    }

    function updateWithRaw() {
        return { sql: "UPDATE ""HITS"" SET ""COUNT"" = count + 1 WHERE ""PAGE"" = ?", bindings: [ "someUrl" ] };
    }

    function updateWithRawTable() {
        return {
            sql: "UPDATE LogFiles..Browsers SET ""USERAGENT"" = ? WHERE ""ID"" = ?",
            bindings: [ "Mozilla/5.0", 1 ]
        };
    }

    function addUpdate() {
        return {
            sql: "UPDATE ""USERS"" SET ""EMAIL"" = ?, ""FOO"" = ?, ""NAME"" = ? WHERE ""ID"" = ?",
            bindings: [ "foo", "yes", "bar", 1 ]
        };
    }

    function updateWithJoin() {
        return { exception: "UnsupportedOperation" };
    }

    function updateWithJoinAndAliases() {
        return { exception: "UnsupportedOperation" };
    }

    function updateWithJoinAndWhere() {
        return { exception: "UnsupportedOperation" };
    }

    function updateWithSubselect() {
        return "UPDATE ""EMPLOYEES"" SET ""DEPARTMENTNAME"" = (SELECT ""NAME"" FROM ""DEPARTMENTS"" WHERE ""EMPLOYEES"".""DEPARTMENTID"" = ""DEPARTMENTS"".""ID"")";
    }

    function updateWithBuilder() {
        return "UPDATE ""EMPLOYEES"" SET ""DEPARTMENTNAME"" = (SELECT ""NAME"" FROM ""DEPARTMENTS"" WHERE ""EMPLOYEES"".""DEPARTMENTID"" = ""DEPARTMENTS"".""ID"")";
    }

    function updateReturning() {
        return { exception: "UnsupportedOperation" };
    }

    function updateReturningRaw() {
        return { exception: "UnsupportedOperation" };
    }

    function updateReturningIgnoresTableQualifiers() {
        return { exception: "UnsupportedOperation" };
    }

    function updateOrInsertNotExists() {
        return { sql: "INSERT INTO ""USERS"" (""NAME"") VALUES (?)", bindings: [ "baz" ] };
    }

    function updateOrInsertExists() {
        return { sql: "UPDATE ""USERS"" SET ""NAME"" = ? WHERE ""EMAIL"" = ?", bindings: [ "baz", "foo" ] };
    }

    function upsert() {
        return {
            sql: "MERGE INTO ""USERS"" ""QB_TARGET"" USING (SELECT ?, ?, ?, ? FROM dual) ""QB_SRC"" ON ""QB_TARGET"".""USERNAME"" = ""QB_SRC"".""USERNAME"" WHEN MATCHED THEN UPDATE SET ""ACTIVE"" = ""QB_SRC"".""ACTIVE"", ""MODIFIEDDATE"" = ""QB_SRC"".""MODIFIEDDATE"" WHEN NOT MATCHED THEN INSERT (""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"", ""USERNAME"") VALUES (""QB_SRC"".""ACTIVE"", ""QB_SRC"".""CREATEDDATE"", ""QB_SRC"".""MODIFIEDDATE"", ""QB_SRC"".""USERNAME"")",
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
            sql: "MERGE INTO ""USERS"" ""QB_TARGET"" USING (SELECT ?, ?, ?, ? FROM dual) ""QB_SRC"" ON ""QB_TARGET"".""USERNAME"" = ""QB_SRC"".""USERNAME"" WHEN MATCHED THEN UPDATE SET ""ACTIVE"" = ""QB_SRC"".""ACTIVE"", ""CREATEDDATE"" = ""QB_SRC"".""CREATEDDATE"", ""MODIFIEDDATE"" = ""QB_SRC"".""MODIFIEDDATE"", ""USERNAME"" = ""QB_SRC"".""USERNAME"" WHEN NOT MATCHED THEN INSERT (""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"", ""USERNAME"") VALUES (""QB_SRC"".""ACTIVE"", ""QB_SRC"".""CREATEDDATE"", ""QB_SRC"".""MODIFIEDDATE"", ""QB_SRC"".""USERNAME"")",
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
            sql: "INSERT INTO ""USERS"" (""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"", ""USERNAME"") VALUES (?, ?, ?, ?)",
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
            sql: "MERGE INTO ""STATS"" ""QB_TARGET"" USING (SELECT ?, ?, ? FROM dual UNION ALL SELECT ?, ?, ? FROM dual) ""QB_SRC"" ON ""QB_TARGET"".""POSTID"" = ""QB_SRC"".""POSTID"" AND ""QB_TARGET"".""VIEWEDDATE"" = ""QB_SRC"".""VIEWEDDATE"" WHEN MATCHED THEN UPDATE SET ""VIEWS"" = stats.views + 1 WHEN NOT MATCHED THEN INSERT (""POSTID"", ""VIEWEDDATE"", ""VIEWS"") VALUES (""QB_SRC"".""POSTID"", ""QB_SRC"".""VIEWEDDATE"", ""QB_SRC"".""VIEWS"")",
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
            sql: "MERGE INTO ""USERS"" ""QB_TARGET"" USING (SELECT ?, ?, ?, ? FROM dual) ""QB_SRC"" ON ""QB_TARGET"".""USERNAME"" = ""QB_SRC"".""USERNAME"" WHEN MATCHED THEN UPDATE SET ""ACTIVE"" = ""QB_SRC"".""ACTIVE"", ""MODIFIEDDATE"" = ""QB_SRC"".""MODIFIEDDATE"" WHEN NOT MATCHED THEN INSERT (""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"", ""USERNAME"") VALUES (""QB_SRC"".""ACTIVE"", ""QB_SRC"".""CREATEDDATE"", ""QB_SRC"".""MODIFIEDDATE"", ""QB_SRC"".""USERNAME"")",
            bindings: [
                1,
                "2021-09-08 12:00:00",
                "2021-09-08 12:00:00",
                "foo"
            ]
        };
    }

    function upsertFromClosure() {
        return {
            sql: "MERGE INTO ""USERS"" ""QB_TARGET"" USING (SELECT ""USERNAME"", ""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"" FROM ""ACTIVEDIRECTORYUSERS"" WHERE ""ACTIVE"" = ?) ""QB_SRC"" ON ""QB_TARGET"".""USERNAME"" = ""QB_SRC"".""USERNAME"" WHEN MATCHED THEN UPDATE SET ""ACTIVE"" = ""QB_SRC"".""ACTIVE"", ""MODIFIEDDATE"" = ""QB_SRC"".""MODIFIEDDATE"" WHEN NOT MATCHED THEN INSERT (""USERNAME"", ""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"") VALUES (""QB_SRC"".""USERNAME"", ""QB_SRC"".""ACTIVE"", ""QB_SRC"".""CREATEDDATE"", ""QB_SRC"".""MODIFIEDDATE"")",
            bindings: [ 1 ]
        };
    }

    function upsertFromBuilder() {
        return {
            sql: "MERGE INTO ""USERS"" ""QB_TARGET"" USING (SELECT ""USERNAME"", ""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"" FROM ""ACTIVEDIRECTORYUSERS"" WHERE ""ACTIVE"" = ?) ""QB_SRC"" ON ""QB_TARGET"".""USERNAME"" = ""QB_SRC"".""USERNAME"" WHEN MATCHED THEN UPDATE SET ""ACTIVE"" = ""QB_SRC"".""ACTIVE"", ""MODIFIEDDATE"" = ""QB_SRC"".""MODIFIEDDATE"" WHEN NOT MATCHED THEN INSERT (""USERNAME"", ""ACTIVE"", ""CREATEDDATE"", ""MODIFIEDDATE"") VALUES (""QB_SRC"".""USERNAME"", ""QB_SRC"".""ACTIVE"", ""QB_SRC"".""CREATEDDATE"", ""QB_SRC"".""MODIFIEDDATE"")",
            bindings: [ 1 ]
        };
    }

    function upsertWithDelete() {
        return { exception: "UnsupportedOperation" };
    }

    function deleteAll() {
        return "DELETE FROM ""USERS""";
    }

    function deleteById() {
        return { sql: "DELETE FROM ""USERS"" WHERE ""ID"" = ?", bindings: [ 1 ] };
    }

    function deleteWhere() {
        return { sql: "DELETE FROM ""USERS"" WHERE ""EMAIL"" = ?", bindings: [ "foo" ] };
    }

    function deleteReturning() {
        return { exception: "UnsupportedOperation" };
    }

    function deleteReturningIgnoresTableQualifiers() {
        return { exception: "UnsupportedOperation" };
    }

    function whereBuilderInstance() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""EMAIL"" = ? OR ""ID"" = (SELECT MAX(id) FROM ""USERS"" WHERE ""EMAIL"" = ?)",
            bindings: [ "foo", "bar" ]
        };
    }

    function whereNullSubselect() {
        return "SELECT * FROM ""USERS"" WHERE (SELECT MAX(created_date) FROM ""LOGINS"" WHERE ""LOGINS"".""USER_ID"" = ""USERS"".""ID"") IS NULL";
    }

    function whereNullSubquery() {
        return "SELECT * FROM ""USERS"" WHERE (SELECT MAX(created_date) FROM ""LOGINS"" WHERE ""LOGINS"".""USER_ID"" = ""USERS"".""ID"") IS NULL";
    }

    function whereBetweenClosures() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""ID"" BETWEEN (SELECT MIN(id) FROM ""USERS"" WHERE ""EMAIL"" = ?) AND (SELECT MAX(id) FROM ""USERS"" WHERE ""EMAIL"" = ?)",
            bindings: [ "bar", "bar" ]
        };
    }

    function whereExistsBuilderInstance() {
        return {
            sql: "SELECT * FROM ""ORDERS"" WHERE EXISTS (SELECT 1 FROM ""PRODUCTS"" WHERE ""PRODUCTS"".""ID"" = ""ORDERS"".""ID"")",
            bindings: []
        };
    }

    function whereBetweenBuilderInstances() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""ID"" BETWEEN (SELECT MIN(id) FROM ""USERS"" WHERE ""EMAIL"" = ?) AND (SELECT MAX(id) FROM ""USERS"" WHERE ""EMAIL"" = ?)",
            bindings: [ "bar", "bar" ]
        };
    }

    function whereBetweenMixed() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""ID"" BETWEEN (SELECT MIN(id) FROM ""USERS"" WHERE ""EMAIL"" = ?) AND (SELECT MAX(id) FROM ""USERS"" WHERE ""EMAIL"" = ?)",
            bindings: [ "bar", "bar" ]
        };
    }

    function whereInBuilderInstance() {
        return {
            sql: "SELECT * FROM ""USERS"" WHERE ""ID"" IN (SELECT ""ID"" FROM ""USERS"" WHERE ""AGE"" > ?)",
            bindings: [ 25 ]
        };
    }

    function innerJoinCallback() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function innerJoinWithJoinInstance() {
        return "SELECT * FROM ""USERS"" INNER JOIN ""CONTACTS"" ON ""USERS"".""ID"" = ""CONTACTS"".""ID""";
    }

    function orderBySubselect() {
        return "SELECT * FROM ""USERS"" ORDER BY (SELECT MAX(created_date) FROM ""LOGINS"" WHERE ""USERS"".""ID"" = ""LOGINS"".""USER_ID"") ASC";
    }

    function orderBySubselectDescending() {
        return "SELECT * FROM ""USERS"" ORDER BY (SELECT MAX(created_date) FROM ""LOGINS"" WHERE ""USERS"".""ID"" = ""LOGINS"".""USER_ID"") DESC";
    }

    function orderByBuilderInstance() {
        return "SELECT * FROM ""USERS"" ORDER BY (SELECT MAX(created_date) FROM ""LOGINS"" WHERE ""USERS"".""ID"" = ""LOGINS"".""USER_ID"") ASC";
    }

    function orderByBuilderInstanceDescending() {
        return "SELECT * FROM ""USERS"" ORDER BY (SELECT MAX(created_date) FROM ""LOGINS"" WHERE ""USERS"".""ID"" = ""LOGINS"".""USER_ID"") DESC";
    }

    function orderByBuilderWithBindings() {
        return {
            sql: "SELECT * FROM ""USERS"" ORDER BY (SELECT MAX(created_date) FROM ""LOGINS"" WHERE ""USERS"".""ID"" = ""LOGINS"".""USER_ID"" AND ""CREATED_DATE"" > ?) ASC",
            bindings: [ "2020-01-01 00:00:00" ]
        };
    }

    function reset() {
        return "SELECT * FROM ""OTHERTABLE""";
    }

    private function getBuilder() {
        variables.utils = getMockBox().createMock( "qb.models.Query.QueryUtils" ).init();
        variables.grammar = getMockBox().createMock( "qb.models.Grammars.OracleGrammar" ).init( variables.utils );
        var builder = new qb.models.Query.QueryBuilder( variables.grammar );
        return builder;
    }

}
