# v8.7.7
## 24 Jan 2022 — 20:08:20 UTC

### fix

+ __QueryBuilder:__ Explicit arguments scoping ([b5c1070](https://github.com/coldbox-modules/qb/commit/b5c1070076bf1302c983434da2148fe754fb7b3f))


# v8.7.6
## 22 Jan 2022 — 20:49:41 UTC

### perf

+ __QueryBuilder:__ arrayEach is slow compared to merging arrays ([6f9a3e7](https://github.com/coldbox-modules/qb/commit/6f9a3e7876710f76e0006febaeb3e33790c0deac))


# v8.7.5
## 22 Dec 2021 — 17:19:08 UTC

### fix

+ __QueryBuilder:__ Fix wheres with joins in update statements
 ([fb98478](https://github.com/coldbox-modules/qb/commit/fb9847834c92124d68ab27bc14b2aa24d332e8db))


# v8.7.4
## 12 Oct 2021 — 22:26:26 UTC

### fix

+ __Null:__ Fixes for full null support
 ([963d79e](https://github.com/coldbox-modules/qb/commit/963d79ee642d44579ae99b5be1ee557a4d7b8de4))


# v8.7.3
## 06 Oct 2021 — 22:05:52 UTC

### fix

+ __QueryBuilder:__ Merge statements in SQL Server need a terminating semicolon
 ([32b5dec](https://github.com/coldbox-modules/qb/commit/32b5dec785fe29bde685a5cdba79e7601557e523))


# v8.7.2
## 29 Sep 2021 — 22:05:52 UTC

### fix

+ __QueryUtils:__ Add better null handling to inferSqlType
 ([1f11650](https://github.com/coldbox-modules/qb/commit/1f11650cfff88ce5cc03e21df1ce99913b60c398))


# v8.7.1
## 22 Sep 2021 — 02:17:56 UTC

### fix

+ __QueryBuilder:__ Correctly format columns being updated
 ([a32bfb5](https://github.com/coldbox-modules/qb/commit/a32bfb5e11706e171bf515804437ce1c68a1dae4))


# v8.7.0
## 21 Sep 2021 — 21:11:00 UTC

### chore

+ __Release:__ Fix artifact commit process during release
 ([2c7d3eb](https://github.com/coldbox-modules/qb/commit/2c7d3eb52c0d71fc0a720a044d9a84167167d5e2))
+ __CI:__ Remove ColdBox as a test dependency
 ([9fa95ca](https://github.com/coldbox-modules/qb/commit/9fa95caf21f2da1425d152384120afde285a5ea6))
+ __CI:__ Test with full null support ([98b0df9](https://github.com/coldbox-modules/qb/commit/98b0df9ff5935e1d79ddf93bf7dc8e39b9f9688a))

### feat

+ __QueryBuilder:__ Allow updates with subselects ([af82f71](https://github.com/coldbox-modules/qb/commit/af82f71807c19b1bc072c3b74335428d318a1859))
+ __QueryBuilder:__ Allow JOINS in UPDATE statements ([0a89175](https://github.com/coldbox-modules/qb/commit/0a8917508f233b03fc5d7ebe48d2c56d2763787f))
+ __QueryBuilder:__ Allow expressions in `value` and `values` ([60d131e](https://github.com/coldbox-modules/qb/commit/60d131e6ccfe93586f381540782b8448da695517))
+ __QueryBuilder:__ Add an upsert method ([13debdd](https://github.com/coldbox-modules/qb/commit/13debdd54d57f439d3fc05b5cf72646ed4be94b4))

### fix

+ __Expressions:__ Better Expression support in HAVING ([7b1096f](https://github.com/coldbox-modules/qb/commit/7b1096f36b05d30bb148d2261ce040f54882c003))
+ __Aggregates:__ Use default values via COALESCE ([ab181e2](https://github.com/coldbox-modules/qb/commit/ab181e2d4aa514dd12632f0ff0a3397771ca6ccd))
+ __Aggregates:__ Provide default values for sum and count if no records are returned ([4ce89ac](https://github.com/coldbox-modules/qb/commit/4ce89accf7972b46a382ae16cc3fff8225dcad21))
+ __Aggregates:__ Allow any value to be returned from withAggregate ([5323e39](https://github.com/coldbox-modules/qb/commit/5323e39e5d36b479ba3787e459c4e17bc0cad80a))
+ __Pagination:__ Handle group by and havings in pagination queries ([4a4428f](https://github.com/coldbox-modules/qb/commit/4a4428f757d5a078b2e310f31a6e517d18d0c642))

### other

+ __\*:__ v8.7.0-beta.2
 ([62705cd](https://github.com/coldbox-modules/qb/commit/62705cd47947326608909492d64bd6f82d442334))
+ __\*:__ v8.7.0-beta.1
 ([13feb20](https://github.com/coldbox-modules/qb/commit/13feb20970214be12481e89d6419559789b0cdf2))


# v8.3.0
## 29 Oct 2020 — 22:52:21 UTC

### feat

+ __QueryUtils:__ Introduce a setting to specify the default numeric sql type ([8f102c9](https://github.com/coldbox-modules/qb/commit/8f102c9a40cb1fc6918c106cb8c766102100124e))


# v8.2.2
## 01 Oct 2020 — 04:22:26 UTC

### fix

+ __QueryBuilder:__ Use html as the default dump format
 ([043ddb5](https://github.com/coldbox-modules/qb/commit/043ddb5538f174912d62a96fe0bf049286c8debd))


# v8.2.1
## 01 Oct 2020 — 04:04:03 UTC

### fix

+ __QueryUtils:__ Use strictDateDetection setting in constructor
 ([76ae59f](https://github.com/coldbox-modules/qb/commit/76ae59f0852a7356102a3692f192aec446cc2533))


# v8.2.0
## 27 Sep 2020 — 03:08:28 UTC

### feat

+ __QueryBuilder:__ Add a dump command to aid in debugging a query while chaining ([6fe518c](https://github.com/coldbox-modules/qb/commit/6fe518c86d108d7d34faf577251489b7a02af0a8))


# v8.1.0
## 24 Sep 2020 — 17:19:43 UTC

### feat

+ __QueryUtils:__ Introduce optional strict date detection ([827f2e8](https://github.com/coldbox-modules/qb/commit/827f2e807876b071b5b05a32d894eb362d647d3a))

### fix

+ __QueryBuilder:__ Allow for bindings in orderByRaw
 ([5a97a7f](https://github.com/coldbox-modules/qb/commit/5a97a7f97ed4c081f31d276d5c3e01ae1941e7b7))


# v8.0.3
## 17 Aug 2020 — 16:40:49 UTC

### fix

+ __QueryBuilder:__ Ignore select bindings for aggregate queries
 ([8a3a181](https://github.com/coldbox-modules/qb/commit/8a3a181ebac97c7f842c3900c9c050294895da78))
+ __BaseGrammer:__ Allow spaces in table aliases. ([b06d690](https://github.com/coldbox-modules/qb/commit/b06d6903cf57d1a34dd64ce1b4dd56d6d40919b5))
+ __SqlServerGrammar:__ Split FLOAT and DECIMAL column types ([82da682](https://github.com/coldbox-modules/qb/commit/82da682dbf8d8c8903e223df582939408cc83df5))


# v8.0.2
## 13 Aug 2020 — 19:46:21 UTC

### fix

+ __QueryBuilder:__ Clear order by bindings when calling clearOrders
 ([f1e941a](https://github.com/coldbox-modules/qb/commit/f1e941abd1263ff77558491b9a0c2bee9eb6c658))


# v8.0.1
## 28 Jul 2020 — 05:33:09 UTC

### fix

+ __QueryBuilder:__ Add bindings from orderBySub expressions
 ([77213a6](https://github.com/coldbox-modules/qb/commit/77213a6fcbd8800dea54d262c8b09adc7cf5cc8e))


# v8.0.0
## 22 Jul 2020 — 16:39:51 UTC

### BREAKING

+ __QueryBuilder:__ Automatic where scoping with OR clauses in when callbacks ([0d6292d](https://github.com/coldbox-modules/qb/commit/0d6292d3bc7d149bb5fbaa001c9a666826b016cd))

### feat

+ __QueryBuilder:__ Add reselect methods ([81d987d](https://github.com/coldbox-modules/qb/commit/81d987d837e0f51dee517b7f9095ecdf6288e77f))
+ __QueryBuilder:__ Add a reorder method ([69d6c5d](https://github.com/coldbox-modules/qb/commit/69d6c5d19c4fe53f88496bc270680cef403e382d))


# v7.10.0
## 22 Jul 2020 — 04:57:44 UTC

### feat

+ __QueryBuilder:__ Expose nested where functions ([71ca350](https://github.com/coldbox-modules/qb/commit/71ca350808db662f3636c8b56f0dc13df892a414))


# v7.9.9
## 21 Jul 2020 — 21:08:35 UTC

### fix

+ __OracleGrammar:__ Correcly wrap all subqueries and aliases ([3e9210f](https://github.com/coldbox-modules/qb/commit/3e9210fc7561011d6829e48972865e6c5e05198b))


# v7.9.8
## 17 Jul 2020 — 21:07:34 UTC

### fix

+ __MySQLGrammar:__ Allow nullable timestamps in MySQL ([ceb96a1](https://github.com/coldbox-modules/qb/commit/ceb96a17e1e3ac6e1bd9883813b77fb460efe186))


# v7.9.7
## 10 Jul 2020 — 05:50:14 UTC

### fix

+ __QueryBuilder:__ Return 0 on null aggregates
 ([ee10a67](https://github.com/coldbox-modules/qb/commit/ee10a675575a24c7b1f68604bef2f79b25ecc707))


# v7.9.6
## 08 Jul 2020 — 05:28:16 UTC

### fix

+ __QueryBuilder:__ Match type hints to documentation for join functions ([a23a1b6](https://github.com/coldbox-modules/qb/commit/a23a1b6b366e9657ccd2ef1b7370eb3c40a911c9))


# v7.9.5
## 07 Jul 2020 — 19:16:32 UTC

### fix

+ __QueryUtils:__ Handle numeric checks with Secure Profile enabled  ([a849525](https://github.com/coldbox-modules/qb/commit/a849525ccdcea579f794ad12a72fdd1a95cd0122))


# v7.9.4
## 29 Jun 2020 — 19:19:27 UTC

### fix

+ __QueryBuilder:__ Allow raw statements in basic where clauses
 ([18200ec](https://github.com/coldbox-modules/qb/commit/18200ec69899c1b383b12b098fb1759db74907ba))


# v7.9.3
## 27 Jun 2020 — 19:24:33 UTC

### fix

+ __QueryBuilder:__ Added options structure to count() method call in paginate ([99201fb](https://github.com/coldbox-modules/qb/commit/99201fbd7a8be4ca1e5d429faa921d2cd61f218a))


# v7.9.2
## 19 Jun 2020 — 03:52:35 UTC

### fix

+ __QueryBuilder:__ Allow for space-delimited sort directions ([5530679](https://github.com/coldbox-modules/qb/commit/55306795354717630e1dd442628cf4e993c4203e))
+ __QueryBuilder:__ Add helpful message when trying to use a closure with 'from'
 ([a8e7bb4](https://github.com/coldbox-modules/qb/commit/a8e7bb48af69cc7048f7ace45229fe5909a36c43))
+ __QueryBuilder:__ 'value' and 'values' now work with column formatters
 ([da60695](https://github.com/coldbox-modules/qb/commit/da60695efe17329634efb7d9922c202ed2919dd8))
+ __QueryBuilder:__ Correctly format RETURNING clauses ([977edcf](https://github.com/coldbox-modules/qb/commit/977edcf59e66052624e4c7ff59a882adb0bcb51a))


# v7.9.1
## 18 Jun 2020 — 22:37:57 UTC

### fix

+ __QueryUtils:__ Handle multi-word columns in queryRemoveColumns
 ([69d3058](https://github.com/coldbox-modules/qb/commit/69d30585828f99cf89d4b7cadebee27b67355fbd))
+ __QueryBuilder:__ Fix incorrect structAppend overwrites
 ([ad770d2](https://github.com/coldbox-modules/qb/commit/ad770d2e29a433315eb4c90d40533def4bf448ec))


# v7.9.0
## 11 Jun 2020 — 22:59:22 UTC

### chore

+ __Format:__ Format with cfformat
 ([77af3ee](https://github.com/coldbox-modules/qb/commit/77af3ee6cfe331d251278d37c7d920fa60d3e47d))
+ __format:__ Always use lf for new lines ([707a288](https://github.com/coldbox-modules/qb/commit/707a288eb6483236914f5ea3793e55966ebd6476))
+ __CI:__ Testing coldbox@be makes no sense as it's all unit tests
 ([8b335da](https://github.com/coldbox-modules/qb/commit/8b335da3ca1c5a4ed70256b7e1c9214b89b48876))
+ __CI:__ Add coldbox@be testing
 ([e14af28](https://github.com/coldbox-modules/qb/commit/e14af2833ddd38ed812d9d394a043e9557060d86))
+ __BaseGrammar:__ Inline null services
 ([4ccad99](https://github.com/coldbox-modules/qb/commit/4ccad998b63f6a75a0c3b04cf16ffe42a47f4cce))
+ __QueryBuilder:__ Fix tests on ACF 2016 due to @default metadata. ([29b31d0](https://github.com/coldbox-modules/qb/commit/29b31d0953c11eb73b563914c492786d695b7a04))

### feat

+ __SchemaBuilder:__ Add support for MONEY and SMALLMONEY data types ([24aadec](https://github.com/coldbox-modules/qb/commit/24aadec62b6121972d459bbb29b1ce5a7a2a296d))
+ __BaseGrammar:__ Add executionTime to the data output, including interceptors
 ([25d66d7](https://github.com/coldbox-modules/qb/commit/25d66d78bf84f254c824f701bde65bd739fb867e))
+ __Select:__ selectRaw now can take an array of expressions ([d5b00af](https://github.com/coldbox-modules/qb/commit/d5b00af9c5d86f331408d7293790711693ac3eeb))
+ __Orders:__ Add a clearOrders method ([507dfdb](https://github.com/coldbox-modules/qb/commit/507dfdb935ec3bbf722e6fddebb8001fc90b8722))
+ __Joins:__ Optionally prevent duplicate joins from being added ([40212ff](https://github.com/coldbox-modules/qb/commit/40212ff4463ea5a615dfda35ab9617513d9d4348))
+ __QueryBuilder:__ Enhance order by's with more direction options ([c767ac8](https://github.com/coldbox-modules/qb/commit/c767ac8764fab70d70dc77baa7bb9fb27c1d4eeb))

### fix

+ __OracleGrammar:__ Remove elvis operator due to ACF compatibility issues
 ([e4b27b8](https://github.com/coldbox-modules/qb/commit/e4b27b89515a617649dc780b43159aed20e11145))
+ __PostgresGrammar:__ Update enum tests for Postgres
 ([c50b00b](https://github.com/coldbox-modules/qb/commit/c50b00ba8282562c6375de02399c7383ce5b0c96))
+ __PostgresGrammar:__ Fix wrapping of enum types
 ([2d65e08](https://github.com/coldbox-modules/qb/commit/2d65e086893d7b5a3b039848614c5632cd9e123d))
+ __QueryBuilder:__ Compat fix for ACF 2018 and listLast parsing
 ([d30c8cd](https://github.com/coldbox-modules/qb/commit/d30c8cd6b06e100fcc63cf5f1405621659a7f18f))
+ __SchemaBuilder:__ Include current_timestamp default for timestamps
 ([9f9a6c9](https://github.com/coldbox-modules/qb/commit/9f9a6c9514975066afed14b2fb14e724a47538a6))
+ __QueryBuilder:__ Ignore table qualifiers for insert and update
 ([466d791](https://github.com/coldbox-modules/qb/commit/466d791aec08aabc61ce702439594dacff816fdf))
+ __JoinClause:__ Prevent duplicate joins when using closure syntax
 ([8f5028a](https://github.com/coldbox-modules/qb/commit/8f5028a038ef3a47c915b36ebb10bf5736a1c666))
+ __BaseGrammar:__ Fix a case where a column was not wrapped correctly
 ([e4fcff4](https://github.com/coldbox-modules/qb/commit/e4fcff4a2731ce3885b277bb5aeae8440f2e376b))
+ __QueryBuilder:__ Avoid duplicate due to Hibernate bugs ([ec429ba](https://github.com/coldbox-modules/qb/commit/ec429ba928e13483a92e1e0a2bfa394329e326b3))
+ __QueryBuilder:__ Upgrade cbpaginator to fix maxrows discrepency ([085c8a6](https://github.com/coldbox-modules/qb/commit/085c8a6b6a60f81cc216079e35946bfe36cea4cd))
+ __BaseGrammar:__ Fix using column formatters with updates and inserts
 ([e4fb585](https://github.com/coldbox-modules/qb/commit/e4fb58527c58dbc32a6948a2ee1fdee4a1f4eb67))
+ __QueryBuilder:__ Fix using  with query param structs
 ([07c9b72](https://github.com/coldbox-modules/qb/commit/07c9b728bdbad6bf02ccd9d21dbdf6968062c02e))
+ __QueryBuilder:__ Ignore orders in aggregate queries
 ([39e1338](https://github.com/coldbox-modules/qb/commit/39e1338a147838165e05225bd91ef7e6cde2319a))
+ __BaseGrammar:__ Improve column wrapping with trimming ([d98a5cb](https://github.com/coldbox-modules/qb/commit/d98a5cb65851c154b6755e90254d1a2c1df82833))
+ __QueryBuilder:__ Prefer the parent query over magic methods ([f9fd8d1](https://github.com/coldbox-modules/qb/commit/f9fd8d157cdc0d7480811c4659c130ee1d58888f))

### other

+ __\*:__ fix: Format with cfformat
 ([dc2a9b6](https://github.com/coldbox-modules/qb/commit/dc2a9b61503690d753a71c3b7bce002ebdf4ccda))
+ __\*:__ fix: Update gitignore to account for folder paths
 ([382c16b](https://github.com/coldbox-modules/qb/commit/382c16b3e144143edcc5e7e1de4dc133dc502d6f))
+ __\*:__ chore: Adjust ignore files
 ([e5702ed](https://github.com/coldbox-modules/qb/commit/e5702edcd5e00eab9502dee2854a49270a11f4c0))

### refactor

+ __QueryBuilder:__ Split off a whereBasic method ([36d87b3](https://github.com/coldbox-modules/qb/commit/36d87b3f5ce20d1424efa85c6673ded0640f74e6))


# v7.8.0
## 17 May 2020 — 13:31:14 UTC

### feat

+ __SchemaBuilder:__ Add support for MONEY and SMALLMONEY data types ([24aadec](https://github.com/coldbox-modules/qb/commit/24aadec62b6121972d459bbb29b1ce5a7a2a296d))


# v7.7.3
## 17 May 2020 — 07:33:29 UTC

### fix

+ __PostgresGrammar:__ Update enum tests for Postgres
 ([c50b00b](https://github.com/coldbox-modules/qb/commit/c50b00ba8282562c6375de02399c7383ce5b0c96))
+ __PostgresGrammar:__ Fix wrapping of enum types
 ([2d65e08](https://github.com/coldbox-modules/qb/commit/2d65e086893d7b5a3b039848614c5632cd9e123d))


# v7.7.2
## 08 May 2020 — 21:26:38 UTC

### fix

+ __QueryBuilder:__ Compat fix for ACF 2018 and listLast parsing
 ([d30c8cd](https://github.com/coldbox-modules/qb/commit/d30c8cd6b06e100fcc63cf5f1405621659a7f18f))
+ __SchemaBuilder:__ Include current_timestamp default for timestamps
 ([9f9a6c9](https://github.com/coldbox-modules/qb/commit/9f9a6c9514975066afed14b2fb14e724a47538a6))
+ __QueryBuilder:__ Ignore table qualifiers for insert and update
 ([466d791](https://github.com/coldbox-modules/qb/commit/466d791aec08aabc61ce702439594dacff816fdf))


# v7.7.1
## 04 May 2020 — 16:50:13 UTC

### fix

+ __JoinClause:__ Prevent duplicate joins when using closure syntax
 ([8f5028a](https://github.com/coldbox-modules/qb/commit/8f5028a038ef3a47c915b36ebb10bf5736a1c666))


# v7.7.0
## 03 May 2020 — 16:43:06 UTC

### feat

+ __BaseGrammar:__ Add executionTime to the data output, including interceptors
 ([25d66d7](https://github.com/coldbox-modules/qb/commit/25d66d78bf84f254c824f701bde65bd739fb867e))


# v7.6.2
## 30 Apr 2020 — 21:19:47 UTC

### fix

+ __BaseGrammar:__ Fix a case where a column was not wrapped correctly
 ([e4fcff4](https://github.com/coldbox-modules/qb/commit/e4fcff4a2731ce3885b277bb5aeae8440f2e376b))


# v7.6.1
## 28 Apr 2020 — 21:46:32 UTC

### fix

+ __QueryBuilder:__ Avoid duplicate due to Hibernate bugs ([ec429ba](https://github.com/coldbox-modules/qb/commit/ec429ba928e13483a92e1e0a2bfa394329e326b3))


# v7.6.0
## 31 Mar 2020 — 02:50:36 UTC

### chore

+ __format:__ Always use lf for new lines ([707a288](https://github.com/coldbox-modules/qb/commit/707a288eb6483236914f5ea3793e55966ebd6476))

### feat

+ __Select:__ selectRaw now can take an array of expressions ([d5b00af](https://github.com/coldbox-modules/qb/commit/d5b00af9c5d86f331408d7293790711693ac3eeb))
+ __Orders:__ Add a clearOrders method ([507dfdb](https://github.com/coldbox-modules/qb/commit/507dfdb935ec3bbf722e6fddebb8001fc90b8722))

### refactor

+ __QueryBuilder:__ Split off a whereBasic method ([36d87b3](https://github.com/coldbox-modules/qb/commit/36d87b3f5ce20d1424efa85c6673ded0640f74e6))


# v7.5.2
## 25 Mar 2020 — 15:10:13 UTC

### chore

+ __CI:__ Testing coldbox@be makes no sense as it's all unit tests
 ([8b335da](https://github.com/coldbox-modules/qb/commit/8b335da3ca1c5a4ed70256b7e1c9214b89b48876))

### fix

+ __QueryBuilder:__ Upgrade cbpaginator to fix maxrows discrepency ([085c8a6](https://github.com/coldbox-modules/qb/commit/085c8a6b6a60f81cc216079e35946bfe36cea4cd))


# v7.5.1
## 25 Mar 2020 — 01:57:21 UTC

### chore

+ __CI:__ Add coldbox@be testing
 ([e14af28](https://github.com/coldbox-modules/qb/commit/e14af2833ddd38ed812d9d394a043e9557060d86))

### fix

+ __BaseGrammar:__ Fix using column formatters with updates and inserts
 ([e4fb585](https://github.com/coldbox-modules/qb/commit/e4fb58527c58dbc32a6948a2ee1fdee4a1f4eb67))


# v7.5.0
## 12 Mar 2020 — 15:54:22 UTC

### feat

+ __Joins:__ Optionally prevent duplicate joins from being added ([40212ff](https://github.com/coldbox-modules/qb/commit/40212ff4463ea5a615dfda35ab9617513d9d4348))


# v7.4.0
## 12 Mar 2020 — 15:33:10 UTC

### feat

+ __QueryBuilder:__ Enhance order by's with more direction options ([c767ac8](https://github.com/coldbox-modules/qb/commit/c767ac8764fab70d70dc77baa7bb9fb27c1d4eeb))


# v7.3.15
## 04 Mar 2020 — 15:00:38 UTC

### fix

+ __QueryBuilder:__ Fix using  with query param structs
 ([07c9b72](https://github.com/coldbox-modules/qb/commit/07c9b728bdbad6bf02ccd9d21dbdf6968062c02e))


# v7.3.14
## 28 Feb 2020 — 18:38:25 UTC

### fix

+ __QueryBuilder:__ Ignore orders in aggregate queries
 ([39e1338](https://github.com/coldbox-modules/qb/commit/39e1338a147838165e05225bd91ef7e6cde2319a))


# v7.3.13
## 28 Feb 2020 — 07:59:08 UTC

### other

+ __\*:__ fix: Format with cfformat
 ([dc2a9b6](https://github.com/coldbox-modules/qb/commit/dc2a9b61503690d753a71c3b7bce002ebdf4ccda))


# v7.3.12
## 28 Feb 2020 — 05:37:32 UTC

### chore

+ __BaseGrammar:__ Inline null services
 ([4ccad99](https://github.com/coldbox-modules/qb/commit/4ccad998b63f6a75a0c3b04cf16ffe42a47f4cce))
+ __QueryBuilder:__ Fix tests on ACF 2016 due to @default metadata. ([29b31d0](https://github.com/coldbox-modules/qb/commit/29b31d0953c11eb73b563914c492786d695b7a04))

### fix

+ __BaseGrammar:__ Improve column wrapping with trimming ([d98a5cb](https://github.com/coldbox-modules/qb/commit/d98a5cb65851c154b6755e90254d1a2c1df82833))
+ __QueryBuilder:__ Prefer the parent query over magic methods ([f9fd8d1](https://github.com/coldbox-modules/qb/commit/f9fd8d157cdc0d7480811c4659c130ee1d58888f))


# v7.3.11
## 13 Feb 2020 — 19:45:42 UTC

### other

+ __\*:__ fix: Update gitignore to account for folder paths
 ([382c16b](https://github.com/coldbox-modules/qb/commit/382c16b3e144143edcc5e7e1de4dc133dc502d6f))


# v7.3.10
## 13 Feb 2020 — 19:35:23 UTC

### other

+ __\*:__ chore: Adjust ignore files
 ([e5702ed](https://github.com/coldbox-modules/qb/commit/e5702edcd5e00eab9502dee2854a49270a11f4c0))


# v7.3.9
## 13 Feb 2020 — 17:34:56 UTC

### other

+ __\*:__ chore: Use forgeboxStorage ([191c732](https://github.com/coldbox-modules/qb/commit/191c7323dc6607a67559b57a4b2148fae8820b5f))


# v7.3.8
## 07 Feb 2020 — 06:19:42 UTC

### fix

+ __Pagination:__ Allow passing query options in to paginate
 ([cdecfb3](https://github.com/coldbox-modules/qb/commit/cdecfb36f5acab87edd3a478c570f77d285df554))


# v7.3.7
## 30 Jan 2020 — 16:50:04 UTC

### fix

+ __QueryBuilder:__ Fix for inserting null values directly
 ([1de27a6](https://github.com/coldbox-modules/qb/commit/1de27a697f65bfdeed63442ad66be47cd0d30344))


# v7.3.6
## 27 Jan 2020 — 22:04:59 UTC

### fix

+ __formatting:__ Futher fixes with cfformat
 ([b4d74b3](https://github.com/coldbox-modules/qb/commit/b4d74b343c3d06668e13c97661c0e435989a5abb))


# v7.3.5
## 25 Jan 2020 — 08:09:54 UTC

### chore

+ __formatting:__ Use cfformat for automatic formatting ([119e434](https://github.com/coldbox-modules/qb/commit/119e434b307a2cc2323b857a214c20842cafbbd4))

### fix

+ __QueryBuilder:__ Add a type to the onMissingMethod exception ([90d1093](https://github.com/coldbox-modules/qb/commit/90d109312b2ea86c00db34020b12b5ab22bb377b))


# v7.3.4
## 13 Jan 2020 — 18:21:30 UTC

### fix

+ __MySQLGrammar:__ Use single quote for column comment ([7304202](https://github.com/coldbox-modules/qb/commit/7304202b2bc81b953ea79735dfec70833310f897))


# v7.3.3
## 09 Jan 2020 — 20:28:40 UTC

### chore

+ __build:__ Skip cleanup of working directory before uploading APIDocs
 ([1c2d0d3](https://github.com/coldbox-modules/qb/commit/1c2d0d38301abcd899591564c6e8f034e0147178))


# v7.3.2
## 09 Jan 2020 — 20:16:18 UTC

### chore

+ __build:__ Commit apidocs to Ortus artifacts
 ([636af8b](https://github.com/coldbox-modules/qb/commit/636af8b4812ab7b8eac6ea8421d23a8ef1a28e31))


# v7.3.1
## 07 Jan 2020 — 17:58:00 UTC

### other

+ __\*:__  fix(QueryUtils): Account for null values when checking for numeric values ([42f2eb4](https://github.com/coldbox-modules/qb/commit/42f2eb4028f8cea98f6fc5542109ceac8be644c2))


# v7.3.0
## 03 Jan 2020 — 06:06:16 UTC

### feat

+ __SqlServerGrammar:__ Add a parameterLimit public property ([155cd3c](https://github.com/coldbox-modules/qb/commit/155cd3ca31cc2f5375c6de0693144dcd8f4af243))


# v7.2.0
## 02 Jan 2020 — 06:11:35 UTC

### feat

+ __QueryBuilder:__ Add a parentQuery option ([f84de76](https://github.com/coldbox-modules/qb/commit/f84de76f16baa23f7cdac54cae84b2f4d52b3b43))


# v7.1.0
## 31 Dec 2019 — 01:40:01 UTC

### feat

+ __QueryBuilder:__ Fully-qualified columns can be used in `value` and `values` ([e4c16b8](https://github.com/coldbox-modules/qb/commit/e4c16b854b39a532e75394993d29f164ed4ff9d0))
+ __QueryBuilder:__ Add orderByRaw method ([67a9222](https://github.com/coldbox-modules/qb/commit/67a92228d5b791b95c17444fb757f3356d45afa3))

### fix

+ __QueryBuilder:__ Accept lambdas where closures are allowed. ([f88809b](https://github.com/coldbox-modules/qb/commit/f88809b80ba0b8f010dfdc7bb1cbd4a18f340d28))


# v7.0.0
## 20 Dec 2019 — 05:53:14 UTC

### BREAKING

+ __QueryUtils:__ Improve numeric sqltype detection ([74649bd](https://github.com/coldbox-modules/qb/commit/74649bde08500edc915878ae1e2453d119c4a13b))
+ __QueryBuilder:__ Add pagination collectors to qb ([4b2d85f](https://github.com/coldbox-modules/qb/commit/4b2d85fea749022f3093260d2ab912b5417e695e))
+ __MSSQLGrammar:__ Rename MSSQLGrammar to SqlServerGrammar ([ea94494](https://github.com/coldbox-modules/qb/commit/ea94494e0c8116dc7de0c34f709d45708f37f706))
+ __QueryBuilder:__ Rename callback to query for subSelect ([87b27f5](https://github.com/coldbox-modules/qb/commit/87b27f56bb13dae653419078ab3457b82b84bcae))
+ __QueryBuilder:__ Expand closure and builder argument options ([e002d94](https://github.com/coldbox-modules/qb/commit/e002d945fa31c555491b857aca0fed4fc839c14a))
+ __QueryBuilder:__ Add defaultValue and optional exception to value ([ec23bb7](https://github.com/coldbox-modules/qb/commit/ec23bb7d0f0a8ea3901eb93bf9d9b16cd4f9605d))
+ __ModuleConfig:__ Use full setting for WireBox mapping ([1e14099](https://github.com/coldbox-modules/qb/commit/1e140990ec4fc6eb91474317f4c735c2b507c577))
+ __QueryBuilder:__ Remove variadic parameter support ([8690fcf](https://github.com/coldbox-modules/qb/commit/8690fcf9a4078f220ed4a44082aca42cdf0e661b))
+ __\*:__ refactor: Drop support for ACF 11 and Lucee 4.5 ([9dbeaf3](https://github.com/coldbox-modules/qb/commit/9dbeaf3c9b45ade9994228f86a3dc6cd5e748120))

### chore

+ __tests:__ Add code coverage with FusionReactor
 ([6e6600f](https://github.com/coldbox-modules/qb/commit/6e6600f8365a065b8619f52df9ac58b8f9010b84))
+ __README:__ Remove unused all-contributors information
 ([e84addd](https://github.com/coldbox-modules/qb/commit/e84addd17753771bf56d73563170fa89bc5c1911))

### feat

+ __SchemaBuilder:__ Add methods to manage views ([1ef8f82](https://github.com/coldbox-modules/qb/commit/1ef8f828da1b18250bbc06939a08e7ee6140a301))
+ __QueryUtils:__ Preserve column case and order in conversion ([00cd691](https://github.com/coldbox-modules/qb/commit/00cd6915798e77d0ee1cbed29743bc54d8d887c9))
+ __QueryBuilder:__ Generate SQL strings with bindings ([2c84afb](https://github.com/coldbox-modules/qb/commit/2c84afb72e78e3367afc6517cc2bcf0182e8747d))
+ __QueryBuilder:__ Distinct can now be toggled off ([7255fa3](https://github.com/coldbox-modules/qb/commit/7255fa31de9139e03c48a15ef4b869c1596d8191))
+ __SchemaBuilder:__ Add more column types ([c9c4678](https://github.com/coldbox-modules/qb/commit/c9c4678ebe746a819d1d28c9fa5c3182cacbac6e))
+ __MSSQLGrammar:__ Remove default constraint when dropping columns
 ([88bfe81](https://github.com/coldbox-modules/qb/commit/88bfe81f2b15f78969ee892188ba71c3f81c2cde))
+ __SchemaBuilder:__ Add renameTable alias for rename
 ([e2c796e](https://github.com/coldbox-modules/qb/commit/e2c796ee090c515d3607f49994728d97a275637b))
+ __OracleGrammar:__ Add dropAllObjects and migrate fresh support
 ([7fe3429](https://github.com/coldbox-modules/qb/commit/7fe34294649a0422c3787074857a1a675fa9722f))
+ __MSSQLGrammar:__ Add support for dropAllObjects and migrate fresh
 ([719e264](https://github.com/coldbox-modules/qb/commit/719e2646de8dcf7fc2deefabc1226584a1cd4c70))
+ __QueryBuilder:__ Add database chunking ([2a20ba4](https://github.com/coldbox-modules/qb/commit/2a20ba401fd46635507acd2dd88221b6e5328ba1))
+ __QueryBuilder:__ Use addUpdate to progressively add columns to update ([65ad791](https://github.com/coldbox-modules/qb/commit/65ad7918efc44dd573a8656bb60f59efff70be80))
+ __QueryBuilder:__ Add whereLike method ([ec12a2a](https://github.com/coldbox-modules/qb/commit/ec12a2aa9fdfc60db11b2225aa51912038ca7d3b))
+ __QueryBuilder:__ Allow default options to be configured ([34db905](https://github.com/coldbox-modules/qb/commit/34db905eaf89970a73c5a1f75029a24e421c9a2c))
+ __QueryBuilder:__ Allow raw values in inserts ([bae3435](https://github.com/coldbox-modules/qb/commit/bae343554cae242fafeded137bb854f404511762))

### fix

+ __QueryBuilder:__ Better whitespace splitting for select lists
 ([6f771e3](https://github.com/coldbox-modules/qb/commit/6f771e3930cc56dbea1f02c974aadbd0a2f1af1e))
+ __QueryUtils:__ Fix array normalization to handle non-string inputs ([01613c4](https://github.com/coldbox-modules/qb/commit/01613c4d6a5c922dcfc3c93996b1c302dd9d748f))
+ __QueryBuilder:__ Trim select columns string before applying
 ([d6cbf36](https://github.com/coldbox-modules/qb/commit/d6cbf36ec89699d230ab66839b329d05313da14f))
+ __QueryBuilder:__ Fix cbpaginator instantiation path
 ([9a8f03a](https://github.com/coldbox-modules/qb/commit/9a8f03a224dfd601d8b4ff0b34037de289262de0))
+ __QueryBuilder:__ Fix typo in docblock
 ([97c8785](https://github.com/coldbox-modules/qb/commit/97c878588e56512f4dd4c1eb6230d85a2cdca720))
+ __QueryBuilder:__ Fix docblock name
 ([79b96c6](https://github.com/coldbox-modules/qb/commit/79b96c6c1f15cd02a65746f352e751c3e73e8a83))
+ __QueryBuilder:__ Pass paginationCollector and defaultOptions to newQuery
 ([bccbc40](https://github.com/coldbox-modules/qb/commit/bccbc40e2dbdbce835288d040451007194ad70b6))
+ __QueryBuilder:__ Explicitly set andWhere methods to use the 'and' combinator
 ([adce834](https://github.com/coldbox-modules/qb/commit/adce834a6c181793d008fce490e6124e6c8a1cf4))
+ __QueryBuilder:__ Allow any custom function for where
 ([fb01927](https://github.com/coldbox-modules/qb/commit/fb019276359851b8de415182953a97c7cb30bb64))
+ __SchemaBuilder:__ Allow raw in alter statements
 ([2202828](https://github.com/coldbox-modules/qb/commit/220282873ea7b58dbd07713939e8059b0569ee6a))
+ __QueryBuilder:__ Allow closures to be used with leftJoin and rightJoin ([e7ddf2f](https://github.com/coldbox-modules/qb/commit/e7ddf2f50fe4fe04134910ee81e4c6a5df98053d))

### other

+ __\*:__ refactor: Remove unneeded clearExcept argument
 ([0b90157](https://github.com/coldbox-modules/qb/commit/0b901573b3d7869ea237238332129a36fec3fcf2))

### perf

+ __QueryBuilder:__ Use count to determine exists instead of the full query
 ([d51ecf4](https://github.com/coldbox-modules/qb/commit/d51ecf43bed0b39cbe6c517a239783587e5b9d8d))

### refactor

+ __QueryBuilder:__ Handle all andWhere.* and orWhere.* methods dynamically ([cc560af](https://github.com/coldbox-modules/qb/commit/cc560af007f57414e380756830aaf12a4faec1c0))
+ __QueryBuilder:__ Remove unnecessary arguments from crossJoin methods
 ([f920d1b](https://github.com/coldbox-modules/qb/commit/f920d1b7a816b1cd073bec79de43f0bdb422ce09))


# v6.5.0
## 05 Sep 2019 — 18:45:38 UTC

### feat

+ __QueryBuilder:__ Add a performant clone method
 ([f1b367a](https://github.com/coldbox-modules/qb/commit/f1b367aca2912119ab98986d1e4716effd62b93e))

### fix

+ __Utils:__ Preserve column casing when removing columns
 ([433df5d](https://github.com/coldbox-modules/qb/commit/433df5dd4194a6832a135a1f5d68525fc02fd4d3))


# v6.4.1
## 04 Sep 2019 — 21:14:02 UTC

### build

+ __travis:__ Use openjdk for builds
 ([061e9d0](https://github.com/coldbox-modules/qb/commit/061e9d04af878af363a113dc6866d11cdec4f366))

### fix

+ __namespaces:__ Fix for ACF 11 namespaces
 ([784855c](https://github.com/coldbox-modules/qb/commit/784855cee789bc28e5d5ff40342a741e46c8255b))
+ __OracleGrammar:__ Fix for removing generated columns from insert and updates
 ([f4ab485](https://github.com/coldbox-modules/qb/commit/f4ab4852d8edb88bd59418f99105a80edd4e701c))


# v6.4.0
## 12 Jul 2019 — 03:46:03 UTC

### feat

+ __QueryBuilder:__ Allow raw values in updates ([5f287b9](https://github.com/coldbox-modules/qb/commit/5f287b91f502b537a5b5177a290e096e62033dc9))


# v6.3.4
## 12 Jun 2019 — 04:52:37 UTC

### fix

+ __QueryBuilder:__ Make operator and combinator checks case-insensitive ([a90b944](https://github.com/coldbox-modules/qb/commit/a90b94460f179d65070797f34c24ae4841038679))

### other

+ __\*:__ Updated API Docs
 ([fd68bcd](https://github.com/coldbox-modules/qb/commit/fd68bcd9f39e8c9d7b41dd4e6243464e85903d4b))


# v6.3.3
## 09 May 2019 — 19:51:30 UTC

### chore

+ __APIDocs:__ Don't nest API docs
 ([dc6bde8](https://github.com/coldbox-modules/qb/commit/dc6bde85cc0335d1818bfd25b641c56c246bc004))

### other

+ __\*:__ Updated API Docs
 ([3be8bc2](https://github.com/coldbox-modules/qb/commit/3be8bc23bbeba6f521c564d0078dcef9c0311a25))


# v6.3.2
## 06 May 2019 — 21:09:24 UTC

### fix

+ __PostgresGrammar:__ Only drop tables in the current schema
 ([0866f9a](https://github.com/coldbox-modules/qb/commit/0866f9aecbbb8df8bacfcbec93a208099df7fad3))

### other

+ __\*:__ Updated API Docs
 ([3d5cb30](https://github.com/coldbox-modules/qb/commit/3d5cb303c0b8ff0aee284ab50684a166931dcb56))


# v6.3.1
## 06 May 2019 — 19:50:34 UTC

### fix

+ __PostgresGrammar:__ Use correct detection of tables in schemas
 ([10408a1](https://github.com/coldbox-modules/qb/commit/10408a1a33cfd39124302f4b80ebe4ad5fd6c044))

### other

+ __\*:__ Updated API Docs
 ([46bc62f](https://github.com/coldbox-modules/qb/commit/46bc62ffe31def111789c77772602be202f70bde))


# v6.3.0
## 03 May 2019 — 15:59:35 UTC

### feat

+ __Subselect:__ Allow passing query objects to subselect ([d2fb971](https://github.com/coldbox-modules/qb/commit/d2fb971a78fa5722e7b7cea0a505da3ac5bd5ddb))

### other

+ __\*:__ Updated API Docs
 ([7b99db5](https://github.com/coldbox-modules/qb/commit/7b99db5dc65d689e8c3a99ca0890066853c15710))


# v6.2.1
## 30 Apr 2019 — 18:55:17 UTC

### fix

+ __QueryBuilder:__ Revery using array returntype where available ([d4fea1d](https://github.com/coldbox-modules/qb/commit/d4fea1db48f2e859994ad5a9608f51188a94d8c4))

### other

+ __\*:__ Updated API Docs
 ([b1e240b](https://github.com/coldbox-modules/qb/commit/b1e240be91b6d3c7a252282f7378cefa06335dd9))


# v6.2.0
## 30 Apr 2019 — 01:25:18 UTC

### feat

+ __QueryBuilder:__ Use array returntype where available
 ([2c45627](https://github.com/coldbox-modules/qb/commit/2c4562744bffaff7464a77d130992ba20ed3d8c0))

### other

+ __\*:__ Updated API Docs
 ([d61b361](https://github.com/coldbox-modules/qb/commit/d61b3617601cd1ea9bc71845c952c481c796c8c3))


# v6.1.0
## 10 Apr 2019 — 17:56:24 UTC

### feat

+ __QueryBuilder:__ Add a columnFormatter option ([984da75](https://github.com/coldbox-modules/qb/commit/984da75c8ab9a1bf8384b58fb882baa516bf79fd))

### other

+ __\*:__ Updated API Docs
 ([727c61c](https://github.com/coldbox-modules/qb/commit/727c61c9311490f6c0d4f3aded2c3fe4d1e39fe0))


# v6.0.4
## 20 Dec 2018 — 01:57:03 UTC

### fix

+ __QueryBuilder:__ Correctly keep where bindings for updateOrInsert ([fa9fab6](https://github.com/coldbox-modules/qb/commit/fa9fab65afdc2aef546c9db504d7cf21f323d723))

### other

+ __\*:__ Updated API Docs
 ([37e8ab3](https://github.com/coldbox-modules/qb/commit/37e8ab31feabe794f5c889e32d5a7756a7012e45))


# v6.0.3
## 11 Dec 2018 — 22:33:30 UTC

### other

+ __\*:__ Updated API Docs
 ([7a96e5e](https://github.com/coldbox-modules/qb/commit/7a96e5e5f8589ec548d7f166940f686d264e43ba))

### perf

+ __BaseGrammar:__ Remove the need for duplicate or structCopy calls
 ([89ea9fc](https://github.com/coldbox-modules/qb/commit/89ea9fc441aff7ed283aa60b0fb30c5cbde13f13))


# v6.0.2
## 30 Nov 2018 — 13:41:18 UTC

### fix

+ __BaseGrammar:__ Fix for when the query object is null ([efb3917](https://github.com/coldbox-modules/qb/commit/efb3917caebedcbca0cdc0905a8b3a613bcbf79f))

### other

+ __\*:__ Updated API Docs
 ([2d011ca](https://github.com/coldbox-modules/qb/commit/2d011ca8b8c3e93c5c3fe9b0c2f5cb7de281f373))


# v6.0.1
## 29 Nov 2018 — 22:51:44 UTC

### other

+ __\*:__ Updated API Docs
 ([1ee2608](https://github.com/coldbox-modules/qb/commit/1ee2608bb7e12f163057ad232709d6cbf5095f70))

### perf

+ __SchemaBuilder:__ Replace duplicate() with structCopy() ([d0237c8](https://github.com/coldbox-modules/qb/commit/d0237c8ad4e030c25efdf0aa56f6dc0df8774921))


# v6.0.0
## 28 Nov 2018 — 05:10:44 UTC

### BREAKING

+ __SchemaBuilder:__ Use uniqueidentifier for MSSQL uuid() ([1b2d456](https://github.com/coldbox-modules/qb/commit/1b2d456decd2080730901604064f46294a01f03f))

### feat

+ __QueryBuilder:__ Add returning functionality for compatible grammars ([7b12b02](https://github.com/coldbox-modules/qb/commit/7b12b021ea3d96d382761ac8a931885430ced3d0))

### fix

+ __SchemaBuilder:__ Default values respect column types ([ae2fc4b](https://github.com/coldbox-modules/qb/commit/ae2fc4b8e11a9dc05d525604c375155b93753a77))
+ __SchemaBuilder:__ Wrap enum values in single quotes
 ([89b58c4](https://github.com/coldbox-modules/qb/commit/89b58c4f251bf6322439c7fb5b992684fdc9882a))
+ __QueryBuilder:__ Add missing `andWhere` methods
 ([7273ce4](https://github.com/coldbox-modules/qb/commit/7273ce40345a682d419cf2e6463cf07f684fa2d4))

### other

+ __\*:__ Updated API Docs
 ([9747153](https://github.com/coldbox-modules/qb/commit/9747153a4fdef98e681a8acd9f0ece7b35e592fb))

### perf

+ __SchemaBuilder:__ Removed case of isInstanceOf because it is slow ([2d65d03](https://github.com/coldbox-modules/qb/commit/2d65d0398113a735bdbd3b2acb55f4d2281d12fd))


# v5.8.1
## 17 Sep 2018 — 21:14:15 UTC

### fix

+ __SchemaBuilder:__ Fix incorrect column name for hasTable and hasColumn ([292bc2a](https://github.com/coldbox-modules/qb/commit/292bc2a8017759bbb4526fd414361692060a66a7))

### other

+ __\*:__ Updated API Docs
 ([70b9b0f](https://github.com/coldbox-modules/qb/commit/70b9b0f6281ba7102845b66578afe759c8ea7437))


# v5.8.0
## 17 Sep 2018 — 19:23:06 UTC

### feat

+ __SchemaBuilder:__ Add unicode text functions ([1a5207e](https://github.com/coldbox-modules/qb/commit/1a5207e2fabda5305d3abd9584539d33b4d29ef3))
+ __Logging:__ Add debug logging for query sql and bindings. ([2928feb](https://github.com/coldbox-modules/qb/commit/2928feba712e92fd643570132721d6e4b17caa41))

### fix

+ __SchemaBuilder:__ Update UUID length to 36 characters ([2569f82](https://github.com/coldbox-modules/qb/commit/2569f82dd30ce22b1127bb9bf2923666e932faa1))
+ __MSSQLGrammar:__ Replace NTEXT with NVARCHAR(MAX) ([936b01d](https://github.com/coldbox-modules/qb/commit/936b01d4edd99365e1dc8821876879a580c013fd))

### other

+ __\*:__ Updated API Docs
 ([91e7ece](https://github.com/coldbox-modules/qb/commit/91e7ece5b6063d5e509430f736f9f6ee45663d69))

### perf

+ __QueryBuilder:__ Remove isInstanceOf for performance benefits ([33fe75c](https://github.com/coldbox-modules/qb/commit/33fe75c98f7deff321bcf218dd0210aced6a5455))

### refactor

+ __InterceptorService:__ Use a null interceptor service in the constructor ([5f3a3ec](https://github.com/coldbox-modules/qb/commit/5f3a3ecc4884d815d05e3fde4d0ccbf1a3c8a0e0))


# v5.7.0
## 18 Aug 2018 — 05:10:01 UTC

### chore

+ __README:__ Remove emoji until ForgeBox can handle it again ([70f2d45](https://github.com/coldbox-modules/qb/commit/70f2d4545a6f9d7418b09b3b4caf218fb6c6deab))
+ __Changelog:__ Fix Changelog to rerun build ([2b6aaa3](https://github.com/coldbox-modules/qb/commit/2b6aaa3f848a77f57497ba56a9f9860ae44aea27))

### feat

+ __QueryBuilder:__ Add support for Common Table Expressions ([3e10da6](https://github.com/coldbox-modules/qb/commit/3e10da635f0b70443b83521791af2a7c6e99a4c7))
+ __QueryBuilder:__ Derived and Sub Tables ([b3f0461](https://github.com/coldbox-modules/qb/commit/b3f0461f4b0a50e0614dca529983b8f1e823fca5))
+ __QueryBuilder:__ Unions ([59028a8](https://github.com/coldbox-modules/qb/commit/59028a8d63a314ddd7f640706272a58dde948d0b))

### fix

+ __QueryBuilder:__ Fix JoinClause return value ([5d113c7](https://github.com/coldbox-modules/qb/commit/5d113c7e9dc8c125d0caeb0ed27fb36deb5da8cd))

### other

+ __\*:__ Updated API Docs ([399293f](https://github.com/coldbox-modules/qb/commit/399293ff4e7301cec8e19da4466deb6cc9dbd3f5))


# v5.7.0
## 18 Aug 2018 — 04:28:41 UTC

### feat

+ __QueryBuilder:__ Add support for Common Table Expressions

Add CTE support for the `with CTE AS (...)` syntax ([3e10da6](https://github.com/coldbox-modules/qb/commit/3e10da635f0b70443b83521791af2a7c6e99a4c7))
+ __QueryBuilder:__ Derived and Sub Tables

* Fixed JoinClause.newQuery() to expect QueryBuilder object as return value
* Added support for derived tables
* Added derived table support
* Added fromRaw() method, which allows you to raw SQL "from" statements
* Added fromSub() to support derived tables
* Added joinRaw(), leftJoinRaw(), rightJoinRaw() and crossJoinRaw() for defining the raw SQL
* Added the joinSub(), leftJoinSub(), rightJoinSub() and crossJoinSub() for joining to a derived table
* Added mergeBindings() which is used for merging bindings from another QueryBuilder instance
 ([b3f0461](https://github.com/coldbox-modules/qb/commit/b3f0461f4b0a50e0614dca529983b8f1e823fca5))
+ __QueryBuilder:__ Unions

* Fixed JoinClause.newQuery() to expect QueryBuilder object as return value
* Added support for UNION/UNION ALL
* Union statement is not created until after ORDER BY validation
 ([59028a8](https://github.com/coldbox-modules/qb/commit/59028a8d63a314ddd7f640706272a58dde948d0b))

### fix

+ __QueryBuilder:__ Fix JoinClause return value

 Fixed JoinClause.newQuery() to expect QueryBuilder object as return value (#48) ([5d113c7](https://github.com/coldbox-modules/qb/commit/5d113c7e9dc8c125d0caeb0ed27fb36deb5da8cd))


# v5.8.0
## 17 Aug 2018 — 21:33:47 UTC

### chore

+ __ci:__ Fix flakey gpg keys
 ([51d8c27](https://github.com/coldbox-modules/qb/commit/51d8c2746f403ede80c6a054229fd3afd332b176))
+ __ci:__ Test on adobe@2018
 ([d928b4b](https://github.com/coldbox-modules/qb/commit/d928b4b39c415a9eb63ad727f87896db4bae45e6))
+ __README:__ Update references to elpete to coldbox-modules
 ([bc7c99c](https://github.com/coldbox-modules/qb/commit/bc7c99c5f32c71bd899321dc3909313c17beb853))
+ __build:__ Enable commandbox-semantic-release
 ([0fe689f](https://github.com/coldbox-modules/qb/commit/0fe689f77b19124271a68293baa6a22b157a3cfd))
+ __box.json:__ Update references to coldbox-modules repo
 ([7eb1a31](https://github.com/coldbox-modules/qb/commit/7eb1a31fc7ded69ce5dfddf10d35a69a19ca4ed5))
+ __build:__ Update Travis CI release process
 ([e743833](https://github.com/coldbox-modules/qb/commit/e743833431d6096c7ad99465e7924e688649f919))

### docs

+ __box.json:__ Remove extra period in description

Remove period as it is not needed for a single sentance
 ([87347c7](https://github.com/coldbox-modules/qb/commit/87347c75c458bd43ab2fec249e5b4d5c3ce33659))

### errors

+ __schema:__ Better error message when passing in a TableIndex to create column
 ([f91a3f7](https://github.com/coldbox-modules/qb/commit/f91a3f7f4f4ae1bd513139fbb1ccfc52eef4874a))

### feat

+ __QueryBuilder:__ Add support for Common Table Expressions

Add CTE support for the `with CTE AS (...)` syntax ([3e10da6](https://github.com/coldbox-modules/qb/commit/3e10da635f0b70443b83521791af2a7c6e99a4c7))
+ __QueryBuilder:__ Derived and Sub Tables

* Fixed JoinClause.newQuery() to expect QueryBuilder object as return value
* Added support for derived tables
* Added derived table support
* Added fromRaw() method, which allows you to raw SQL "from" statements
* Added fromSub() to support derived tables
* Added joinRaw(), leftJoinRaw(), rightJoinRaw() and crossJoinRaw() for defining the raw SQL
* Added the joinSub(), leftJoinSub(), rightJoinSub() and crossJoinSub() for joining to a derived table
* Added mergeBindings() which is used for merging bindings from another QueryBuilder instance
 ([b3f0461](https://github.com/coldbox-modules/qb/commit/b3f0461f4b0a50e0614dca529983b8f1e823fca5))
+ __QueryBuilder:__ Unions

* Fixed JoinClause.newQuery() to expect QueryBuilder object as return value
* Added support for UNION/UNION ALL
* Union statement is not created until after ORDER BY validation
 ([59028a8](https://github.com/coldbox-modules/qb/commit/59028a8d63a314ddd7f640706272a58dde948d0b))
+ __SchemaBuilder:__ Allow an optional schema to hasTable and hasColumn

Since some users have access to multiple schemas on the same database,
allow an optional schema parameter passed to `hasTable` and `hasColumn`
 ([9bfcd45](https://github.com/coldbox-modules/qb/commit/9bfcd458cdadc7ad196c4dd9761d5ef274476c49))
+ __QueryBuilder:__ Add andWhere method for more readable chains.

`andWhere` behaves exactly like `where`.  It is provided for
a more readable method chain if desired.
 ([309f4d8](https://github.com/coldbox-modules/qb/commit/309f4d85fa3ad7ef9d5a49008eec8fb4f7e1c44c))
+ __AutoDiscover:__ Allow for runtime discovery

Add AutoDiscover component to allow for database discovery at runtime
as opposed to just at module registration.
 ([700948a](https://github.com/coldbox-modules/qb/commit/700948a6ac503b7af59efb0e00894c211c3d8882))
+ __ModuleConfig:__ Auto discover grammar by default.

By default, we will auto discover the grammar for the user.  This only happens once
for ColdBox modules, so the database hit should be minimal.  If the user
specifies a grammar in their settings, we will use that and not even try
to detect the grammar.
 ([b2347ae](https://github.com/coldbox-modules/qb/commit/b2347aebae9ca5a42655b0f7ed5fd2ed6ec804fb))
+ __Grammar:__ Added official support for MSSQL, Oracle, and Postgres. (#34)

Full QueryBuilder and SchemaBuilder support for all four database grammars
(MSSQL, MySQL, Oracle, and Postgres).
Revamped test suite to have consistent grammar test coverage.
 ([733dae3](https://github.com/coldbox-modules/qb/commit/733dae3498814f49a829b604799824e9f755bb85))
+ __SchemaBuilder:__ Add dropAllObjects action. (#31)

compileDropAllObjects needs to be implemented in every Grammar.
By default, it throws an exception.  Only a MySQLGrammar implementation
currently exists. ([c3e23b5](https://github.com/coldbox-modules/qb/commit/c3e23b5c110fae3464d48d62ae80e357e8c38842))

### fix

+ __QueryBuilder:__ Fix JoinClause return value

 Fixed JoinClause.newQuery() to expect QueryBuilder object as return value (#48) ([5d113c7](https://github.com/coldbox-modules/qb/commit/5d113c7e9dc8c125d0caeb0ed27fb36deb5da8cd))
+ __Column:__ Explicitly name default constraint for MSSQL

* update MSSQL for DEFAULT constraint
 ([288bd66](https://github.com/coldbox-modules/qb/commit/288bd663350cca34bcbada43548a7de56e5309dd))
+ __PostgresGrammar:__ Fix typo in getAllTableNames
 ([91caf6a](https://github.com/coldbox-modules/qb/commit/91caf6a467fa585fdeef26e08171b59ff71b59e1))
+ __SchemaBuilder:__ Fix dropping foreign keys in MySQL
 ([8895447](https://github.com/coldbox-modules/qb/commit/8895447cf3a0c36c2579a2867f0510033a28b0b7))
+ __ModuleConfig:__ Fix logic for determining CommandBox vs ColdBox environment
 ([5c66466](https://github.com/coldbox-modules/qb/commit/5c66466b11707342265a9589fefe016df134cb48))
+ __ModuleConfig:__ Add PostgresGrammar alias to WireBox
 ([eca03f0](https://github.com/coldbox-modules/qb/commit/eca03f0594147c9323bc99ddd9505b8e7b4c6571))
+ __QueryBuilder:__ Preserve returnFormat when creating a new builder
 ([4538947](https://github.com/coldbox-modules/qb/commit/4538947807d3c33865281bdf7852b858c393dbfb))
+ __MySQLGrammar:__ Default to CURRENT_TIMESTAMP for timestamp columns (#32)

 ([680750a](https://github.com/coldbox-modules/qb/commit/680750a9894c56271cc7748a6dc501c2c266ea85))

### other

+ __\*:__ added `last()`
 ([5b0fe28](https://github.com/coldbox-modules/qb/commit/5b0fe282936c44f3cc17030d1a8b0c4efdaaea89))
+ __\*:__ Update references from Builder to QueryBuilder ([632e697](https://github.com/coldbox-modules/qb/commit/632e697c5b37d8e6ea522efc628f487dc4e14403))
+ __\*:__ Updated API Docs
 ([8325db5](https://github.com/coldbox-modules/qb/commit/8325db5d232c55f3b433e4d528a43b72d7622fd9))
+ __\*:__ 5.0.2 ([c8cab5d](https://github.com/coldbox-modules/qb/commit/c8cab5d7ec19ae4d61645f80909bc8e6f69ac75d))
+ __\*:__ 5.0.1 ([75def91](https://github.com/coldbox-modules/qb/commit/75def913d1e072b1e48078a8e9f284609871436a))
+ __\*:__ 5.0.0 ([d944eb7](https://github.com/coldbox-modules/qb/commit/d944eb75dbebd1cdb389eb990ee3cbaf835133cb))
+ __\*:__ Add @tonyjunkes as a contributor
 ([1adbbba](https://github.com/coldbox-modules/qb/commit/1adbbba4229674b4def6488aafe17cb91f8aaa73))
+ __\*:__ Updated API Docs
 ([e0ebc41](https://github.com/coldbox-modules/qb/commit/e0ebc414c10561756100d59e7ae8822c6b44be55))
+ __\*:__ 5.0.0 ([dbcaf8a](https://github.com/coldbox-modules/qb/commit/dbcaf8a50e374041ecca000da10ed8eb106490fc))
+ __\*:__ Updated API Docs
 ([dbc7eb5](https://github.com/coldbox-modules/qb/commit/dbc7eb58bfacd4884fa3a721b4665f51cd01ac7d))
+ __\*:__ 4.1.0 ([b014875](https://github.com/coldbox-modules/qb/commit/b014875fbf794c217c3829806c040fed2b5d567a))
+ __\*:__ renameConstraint can take TableIndex instances as well as strings to rename a constraint
 ([4e9476d](https://github.com/coldbox-modules/qb/commit/4e9476da8433c892d44cca90a29aa7be9545e59b))
+ __\*:__ Greatly simplify drop column
 ([3fd4c39](https://github.com/coldbox-modules/qb/commit/3fd4c39fed4bcf469130cc6b1c1b9f76310c5933))
+ __\*:__ Add rename index
 ([296cc43](https://github.com/coldbox-modules/qb/commit/296cc4323112e22495827cf7d2e2a1765992d5a7))
+ __\*:__ Rename removeConstraint to dropConstraint
 ([4cfbaff](https://github.com/coldbox-modules/qb/commit/4cfbaff433feb08b3edbd567df9972ba825bd66a))
+ __\*:__ Allowing adding multiple constraints in the same alter call
 ([1d60df4](https://github.com/coldbox-modules/qb/commit/1d60df489fabd8af8412c72982b2211818d1d341))
+ __\*:__ Organize code
 ([543eaa9](https://github.com/coldbox-modules/qb/commit/543eaa93ce7dd44f52323ade815ff077d0ae5597))
+ __\*:__ Add doc blocks for table constraint methods
 ([10fe437](https://github.com/coldbox-modules/qb/commit/10fe437888edfc716215e012539deb0b4300cc6b))
+ __\*:__ Alphabetize the table constraint methods
 ([06e5d1c](https://github.com/coldbox-modules/qb/commit/06e5d1c16bd83ccb2f3af052bfc3558335f37955))
+ __\*:__ Add docblocks to TableIndex
 ([60c7538](https://github.com/coldbox-modules/qb/commit/60c753850d2424f5e318ce5168f4937ee62c0802))
+ __\*:__ Change default onUpdate and onDelete actions to NO ACTION.
 ([3a8d7a5](https://github.com/coldbox-modules/qb/commit/3a8d7a57526087e2e25896e571a1747bb8880650))
+ __\*:__ Add docblocks to Column
 ([ad71086](https://github.com/coldbox-modules/qb/commit/ad710866c33e96c9dce33bda6832dc8677985f2a))
+ __\*:__ Remove hasPrecision file and do it manually for a cleaner Column class.
 ([e5fc961](https://github.com/coldbox-modules/qb/commit/e5fc9615350bfde3ef6998ed53b471d658cc88dd))
+ __\*:__ Streamline uuid type to be just CHAR(35)
 ([683cd36](https://github.com/coldbox-modules/qb/commit/683cd36f438d884d466d5420a0ffb2689914b9d4))
+ __\*:__ Refactor all the integers to have the same signature
 ([28d5b81](https://github.com/coldbox-modules/qb/commit/28d5b81964f1a7d5874f89dfc3438d9a75a8357a))
+ __\*:__ Add docblocks to SchemaBuilder
 ([64cecd5](https://github.com/coldbox-modules/qb/commit/64cecd5fdf5652c7e033179f4c471aab3d01f98a))
+ __\*:__ Rename build to execute
 ([cc09aaa](https://github.com/coldbox-modules/qb/commit/cc09aaaf51e69c4d3f54a96b9b3864f023f22f96))
+ __\*:__ Add missing semicolon
 ([d1d0066](https://github.com/coldbox-modules/qb/commit/d1d0066d85332bf4713cd0a1cd7f1cc7f4f18417))
+ __\*:__ CommandBox / ColdBox cross-compatibility updates
 ([7d06660](https://github.com/coldbox-modules/qb/commit/7d06660548eba807f10e6f97d9ffb6e993ab4ea2))
+ __\*:__ Fix typo in the sql method call
 ([c2295d6](https://github.com/coldbox-modules/qb/commit/c2295d65c25b5c4bb00aba26b59bb2e15b18b8bf))
+ __\*:__ Finish up foreign key dsl
 ([4cf869a](https://github.com/coldbox-modules/qb/commit/4cf869aa7ba8778aae1a56c024100ec08d4c9133))
+ __\*:__ Fix foreign key dynamic names
 ([7b0f9f0](https://github.com/coldbox-modules/qb/commit/7b0f9f05c1b3b4cc6b1e3959e4b05c4af8e434cb))
+ __\*:__ Add primary key dsl
 ([25ba4e7](https://github.com/coldbox-modules/qb/commit/25ba4e7dba668bf9b109e7cfc975145e41f98b93))
+ __\*:__ Fix spacing in basic indexes and enum lists
 ([4c2cf71](https://github.com/coldbox-modules/qb/commit/4c2cf71adfd08f219d843c7eb061fcf507ccf5d9))
+ __\*:__ Make index names more globally unique.
 ([b7b6636](https://github.com/coldbox-modules/qb/commit/b7b663680a90a69e64713d1f8a0eb06406d261c8))
+ __\*:__ Fix primary index names to include table names if no override provided
 ([d63a4ae](https://github.com/coldbox-modules/qb/commit/d63a4ae2f85a7cb433cf57721ecd3bf9da8c2730))
+ __\*:__ Add basic table index support
 ([f247e15](https://github.com/coldbox-modules/qb/commit/f247e1563eb537ccc671dabc7ddb784214e97b44))
+ __\*:__ Remove constraints by name or index object
 ([dffee36](https://github.com/coldbox-modules/qb/commit/dffee3697b75ed6bd2701b9a0fea48092a294230))
+ __\*:__ Add unique constraing for columns and tables.

Includes refactor for TableIndex to always deal with multiple columns.
 ([61306e0](https://github.com/coldbox-modules/qb/commit/61306e06b282fc691ca1a727774c1aa4172393b6))
+ __\*:__ Add hasTable and hasColumn support for MySQL and Oracle
 ([2c4e5d0](https://github.com/coldbox-modules/qb/commit/2c4e5d06950214005d37cc42a44aca2216f75f05))
+ __\*:__ Add test for multiple table changes at once.
 ([cf65e11](https://github.com/coldbox-modules/qb/commit/cf65e11041ba6ce8d0616e0cc3aeb992f27af1b4))
+ __\*:__ Enable adding columns to an existing table
 ([a54eb86](https://github.com/coldbox-modules/qb/commit/a54eb86a7694ea8146923697e1bae3474e39b8fa))
+ __\*:__ Add modifyColumn syntax
 ([1d64624](https://github.com/coldbox-modules/qb/commit/1d64624801e4c6cb88053266201dbf7fd93e3b73))
+ __\*:__ Add raw method for SQL escape hatch
 ([d77a729](https://github.com/coldbox-modules/qb/commit/d77a72923191b610eef09499ffe9609f3ca16e7f))
+ __\*:__ Rename columns

MySQL has an unfortunate syntax that requires the definition to be repeated.
We may be able to discover this from the table, but right now we're punting and asking the user to redeclare the column definition.

Fun fact, in MySQL, renameColumn will let you modifyColumn at the same time.
 ([0bb926e](https://github.com/coldbox-modules/qb/commit/0bb926e2c4c05acd3fdf1f868186d4c65f8e7e97))
+ __\*:__ Add rename tables functionality
 ([daa13fa](https://github.com/coldbox-modules/qb/commit/daa13fa663de5b0f6ee85adbfcc4a75e72e58099))
+ __\*:__ Add drop multiple columns

Also refactor SchemaCommands to a component that can take arbitrary parameters.
 ([f7a7fce](https://github.com/coldbox-modules/qb/commit/f7a7fce2297446f0f01a5b25a33bfbfdecd76949))
+ __\*:__ Organize code a bit
 ([d6170a3](https://github.com/coldbox-modules/qb/commit/d6170a356a368a988a2836ed6b29cb742311c37a))
+ __\*:__ Drop a column from an existing table

 ([f8940bc](https://github.com/coldbox-modules/qb/commit/f8940bca55c451a0657c8fd6f211090f05878d24))
+ __\*:__ Add dropIfExists support

 ([8b175c7](https://github.com/coldbox-modules/qb/commit/8b175c7471a1435fdf9c57fed0ecf020d8c0332a))
+ __\*:__ Add drop table command

 ([b77781a](https://github.com/coldbox-modules/qb/commit/b77781ae9b4c2d23125c6705abc6499467f3c3c9))
+ __\*:__ Refactor order of arguments in create

Since build should be overridden less often than options, make it last. ([3ee5dca](https://github.com/coldbox-modules/qb/commit/3ee5dca6eccb8c6ada179039c3f9ab5a305d6fde))
+ __\*:__ Rename Grammar to BaseGrammar

Fits better with our current documentation and `ModuleConfig.cfc` settings ([1bd2dcb](https://github.com/coldbox-modules/qb/commit/1bd2dcb04e2aa931ebe266fcf2f06aad05db0a12))
+ __\*:__ Add indexes for morphs and nullableMorphs
 ([5de9ee3](https://github.com/coldbox-modules/qb/commit/5de9ee35082d5c617023cb44dcb39e1a16cdaa1d))
+ __\*:__ Convert schema builder to allow for multiple sql statements.
 ([c9c6405](https://github.com/coldbox-modules/qb/commit/c9c6405cc141390ea43ef4a8b1e0f057fe3fd235))
+ __\*:__ Add work in progress nullable implementation.

Still needs index creation.
 ([735a03a](https://github.com/coldbox-modules/qb/commit/735a03abf81784267042ab4cdddfcd9cd2c9db6d))
+ __\*:__ Add column modifiers — comment, default, nullable, unsigned
 ([25fbade](https://github.com/coldbox-modules/qb/commit/25fbade1f4ec8eaf661a9b9f3e47a2bbe6453b4b))
+ __\*:__ Add uuid type
 ([f35e1f1](https://github.com/coldbox-modules/qb/commit/f35e1f16812c75116602f6b83b6cf0b0632056b1))
+ __\*:__ Add big, medium, small, and tiny integer and increments variants.
 ([2bb379d](https://github.com/coldbox-modules/qb/commit/2bb379deed40eb53fd7180160fa2ce2724d47a92))
+ __\*:__ Add medium and long text types
 ([35b7d83](https://github.com/coldbox-modules/qb/commit/35b7d83d913ba24bc6503934eddc8b730f37bac7))
+ __\*:__ Add json type (alias to TEXT)
 ([6403d3f](https://github.com/coldbox-modules/qb/commit/6403d3f8d9dcf97c8135e4e82890bbb23c30df7d))
+ __\*:__ Add float type
 ([86cc974](https://github.com/coldbox-modules/qb/commit/86cc974cf7925c10db7e249b15926a0e0c88ac59))
+ __\*:__ Add enum type.
 ([e2f17ab](https://github.com/coldbox-modules/qb/commit/e2f17ab9466fd16eb120603b168a3f729d931572))
+ __\*:__ Add decimal type
 ([aa13c72](https://github.com/coldbox-modules/qb/commit/aa13c7273cf7a51cd8090a94badc7c3727218a8e))
+ __\*:__ Add bit type
 ([48d0044](https://github.com/coldbox-modules/qb/commit/48d00449f8ca4c833120a58a1906a5c509fd626c))
+ __\*:__ Have boolean be it's own type so different grammars can interpolate it differently.
 ([c909f9f](https://github.com/coldbox-modules/qb/commit/c909f9f4b5709d51a6d0d7a42285f0ab5e3be605))
+ __\*:__ Add date, datetime, time, and timestamp types.
 ([857bdcf](https://github.com/coldbox-modules/qb/commit/857bdcfd10c9657685b5b41f11db14384ba3b5a9))
+ __\*:__ Add char and string types
 ([5732161](https://github.com/coldbox-modules/qb/commit/5732161ce8a17deedc3066db679be9e0fec4fed6))
+ __\*:__ Add integer, unsignedInteger, increments, and text types
 ([fb76853](https://github.com/coldbox-modules/qb/commit/fb76853754e71a8c736396bb5ee70ec6f688a506))
+ __\*:__ Add more column types for schema builder

+ bigIncrements
+ bigInteger
+ boolean
+ tinyInteger
+ unsignedBigInteger
 ([3f80002](https://github.com/coldbox-modules/qb/commit/3f8000262e0a45d7b8adb25e6ae85cc9ece307ef))
+ __\*:__ Initial Schema Buidler implementation

Move Grammars from being nested inside Query to it's own top-level folder.
Rename `Builder` to `QueryBuilder`.
Create `SchemaBuilder`, `Column`, and `TableIndex` and three basic tests.
 ([8a299f6](https://github.com/coldbox-modules/qb/commit/8a299f63e79aa4879dd163f823c779efb061e81f))
+ __\*:__ Rename Grammar to BaseGrammar to fit the rest of the documentation.
 ([365e32a](https://github.com/coldbox-modules/qb/commit/365e32a7a0ad4dd6492b04f9eac4d2b0feea369e))
+ __\*:__ Update README.md ([872355e](https://github.com/coldbox-modules/qb/commit/872355ec05ac5764e5a95b72bd5789db5f056357))
+ __\*:__ Add codesponsor.io banner
 ([a54966a](https://github.com/coldbox-modules/qb/commit/a54966a59c6212a2b2adade76a0a37f23a01ad02))
+ __\*:__ Updated API Docs
 ([a992557](https://github.com/coldbox-modules/qb/commit/a99255758f664780bc3b14505061f7a8f9a5d3a8))
+ __\*:__ 4.0.1 ([b479473](https://github.com/coldbox-modules/qb/commit/b479473cc79cf82dcbe64dd184839cf937ed40ae))
+ __\*:__ Update with new docs link ([f1c04c6](https://github.com/coldbox-modules/qb/commit/f1c04c6400ca5e4296b098f078fbca8919e2714e))
+ __\*:__ Fixed a bug where calling `toSQL` would modify the builder object.

Affected debugging and things like `updateOrInsert` where the `update` call is preceded by an `exists` call.
 ([c00ecef](https://github.com/coldbox-modules/qb/commit/c00ecefbb09e60afbfbab8719bf8f05eb76881c7))
+ __\*:__ Fix for insert bindings including other binding types as well
 ([c84ec6c](https://github.com/coldbox-modules/qb/commit/c84ec6c0af5f0575c2f182684ce19c39e7d1e2fc))
+ __\*:__ Add @BluewaterSolutions as a contributor
 ([92dd7ad](https://github.com/coldbox-modules/qb/commit/92dd7ad30f99c2b19a5515d5692883ddff2600e2))
+ __\*:__ Fix exists method to work across engines

Use the `withReturnFormat( "array" )` to get around inconsistencies with queries across CFML engines.
 ([17afdfa](https://github.com/coldbox-modules/qb/commit/17afdfa87f15911a51067390a287f4b7c4dc3f63))
+ __\*:__ Normalize line endings and trim whitespace at the end of lines
 ([bf4ecc7](https://github.com/coldbox-modules/qb/commit/bf4ecc7d09a8653c0e4df6edd1f2fc0f6d220cb2))
+ __\*:__ Allow lists to be passed in to `whereIn`
 ([d0cc901](https://github.com/coldbox-modules/qb/commit/d0cc901d26dc76a1eaa35445e126078772af80a5))
+ __\*:__ Updated API Docs
 ([bf83436](https://github.com/coldbox-modules/qb/commit/bf83436f75119709864f28ce758a327264fd0bd3))
+ __\*:__ 4.0.0 ([ca7049f](https://github.com/coldbox-modules/qb/commit/ca7049fe65a734ba19d7230488fc0edf0386f742))
+ __\*:__ Fix bug when checking for a "*" column and it was actually an Expression.

Closes #17
 ([2edaf30](https://github.com/coldbox-modules/qb/commit/2edaf30a689ef249fbdca2c359010860ff60482f))
+ __\*:__ Add `subSelect` method

Closes #18
 ([79343a0](https://github.com/coldbox-modules/qb/commit/79343a0cb9a460c98c894a2ef27dfe4fa0d6372c))
+ __\*:__ Add returnObject parameter to assist in returning the generated keys from insert statements
 ([dc5242f](https://github.com/coldbox-modules/qb/commit/dc5242f886436576064db1d5d6c4a3fa0c4fb9ce))
+ __\*:__ Add preQBExecute and postQBExecute interception points.

Perfect for logging all queries that are executed!

`interceptData` includes: `sql`, `bindings`, and `options`.
 ([0c964e5](https://github.com/coldbox-modules/qb/commit/0c964e55f814f153701dad4d9fa0d8111144285a))
+ __\*:__ BREAKING CHANGE: Have first return a struct instead of an array.

Closes #20.
 ([4b46fce](https://github.com/coldbox-modules/qb/commit/4b46fce4e5a667ff8b5d6164105beeec4ac4c486))
+ __\*:__ Add profiling test tooling
 ([25286fd](https://github.com/coldbox-modules/qb/commit/25286fda5ba1195620e0d6bd5e4ecf7c4ef03552))
+ __\*:__ Updated API Docs
 ([aa9db53](https://github.com/coldbox-modules/qb/commit/aa9db5390969d95001c5d92a6e920c709993827f))
+ __\*:__ 3.0.0 ([993b0c3](https://github.com/coldbox-modules/qb/commit/993b0c37e51c72825c5a59d71627070ec1c0c525))
+ __\*:__ Remove list detection since it isn't used in the builder and is causing issues
 ([73f16d2](https://github.com/coldbox-modules/qb/commit/73f16d2b185f383daf55f51c36107e33a391f2d6))
+ __\*:__ add MIT License ([6409438](https://github.com/coldbox-modules/qb/commit/6409438b46e88287d3e0b26c5592a7fb23f247f6))
+ __\*:__ Stylistic fix on the badges
 ([a04e631](https://github.com/coldbox-modules/qb/commit/a04e63138b2504e8cd2f7e47ca1eccb2e589e7b7))
+ __\*:__ Add @timmaybrown as a contributor
 ([584f785](https://github.com/coldbox-modules/qb/commit/584f7856699ec82bbf573ada90af44cc8c4d182c))
+ __\*:__ Add @murphydan as a contributor
 ([2bf3566](https://github.com/coldbox-modules/qb/commit/2bf3566dcfff684ffd8eece7eb1963b527aea519))
+ __\*:__ Add @aliaspooryorik as a contributor
 ([caf9065](https://github.com/coldbox-modules/qb/commit/caf906539a00e465305baba55fdbb467015c1431))
+ __\*:__ Add @elpete as a contributor
 ([bb7b8bb](https://github.com/coldbox-modules/qb/commit/bb7b8bbe11f48f18ea4a7164db2e80a547fb751f))
+ __\*:__ Merge branch 'development'
 ([e3a27f6](https://github.com/coldbox-modules/qb/commit/e3a27f6143f2cc29b4b8ef22a2f8b02dda3f37c8))
+ __\*:__ Updated API Docs
 ([b9e04f5](https://github.com/coldbox-modules/qb/commit/b9e04f53101a77cdfad8a856473f08d9284e2ee0))
+ __\*:__ 2.1.0 ([8dbddd9](https://github.com/coldbox-modules/qb/commit/8dbddd91132bb0a3c649ed59f1a06a8c969ccfd2))
+ __\*:__ A couple minor stylistic changes. ([80f14e2](https://github.com/coldbox-modules/qb/commit/80f14e2a8bee333e968358d4055e1706fc7e0db0))
+ __\*:__ Update Builder.cfc

Remove a couple blank lines. ([b77a87b](https://github.com/coldbox-modules/qb/commit/b77a87be3484452734baecd49e242b53601ff130))
+ __\*:__ issue #8 - additional tests for rawExpressions in the array, removed lists as a valid value for array value and refactored validDirections array to be an instance variable aptly named to match the other naming conventions.
 ([8704ff4](https://github.com/coldbox-modules/qb/commit/8704ff46975b2bea23535caf4570d6ed9e908e4f))
+ __\*:__ First stab at implementing the various requirements for issue #8 to accept an array or list as the column argument's value. The array can accept a variety of value formats that can be intermingled if desired. All scenarios will inherit eithe the default direction or the supplied value for the direction argument.
 ([e0b9b63](https://github.com/coldbox-modules/qb/commit/e0b9b63b79d7618d3d2c2ce633e22ccdad80eaf0))
+ __\*:__ Cache CommandBox for Travis builds
 ([5eb4561](https://github.com/coldbox-modules/qb/commit/5eb45618574ebb66784b615e73edebd0d9bc82fa))
+ __\*:__ Add new API Docs
 ([2c1f19b](https://github.com/coldbox-modules/qb/commit/2c1f19bc1f170cf3f9b1ea245172acdfb9675e6b))
+ __\*:__ 2.0.4 ([3414ea7](https://github.com/coldbox-modules/qb/commit/3414ea78908d7ac6dc28389db6c03f6548da9650))
+ __\*:__ Return result from Oracle grammar when record count is 0
 ([b8a13cd](https://github.com/coldbox-modules/qb/commit/b8a13cd54f7df437b3b95e2c283c0de3e5387035))
+ __\*:__ Updated API Docs
 ([c50d061](https://github.com/coldbox-modules/qb/commit/c50d061b527d405f0af79a871866140a8b0633ab))
+ __\*:__ 2.0.3 ([8634e5c](https://github.com/coldbox-modules/qb/commit/8634e5ca16172588c9ce5733f17d4f3e82495b9c))
+ __\*:__ Updated API Docs
 ([a6df8a3](https://github.com/coldbox-modules/qb/commit/a6df8a349544dd76c108c908494bd85bb9521df9))
+ __\*:__ 2.0.2 ([f0886b6](https://github.com/coldbox-modules/qb/commit/f0886b63148755a0869382978b739e6cde3aa4d6))
+ __\*:__ Add new API Docs package scripts
 ([c8555ec](https://github.com/coldbox-modules/qb/commit/c8555ec3a265a9de0d7e8cbd9f6f9a6e91f908f5))
+ __\*:__ Updated API Docs
 ([95c2d93](https://github.com/coldbox-modules/qb/commit/95c2d934bcd6b6f31261f077d679863c696cee29))
+ __\*:__ Nest the apidocs in a different docs site for future better looking docs
 ([9a8e1fa](https://github.com/coldbox-modules/qb/commit/9a8e1fa4f99e5fc43cee9f2eefb32381c4e4b942))
+ __\*:__ 2.0.1 ([6bd958d](https://github.com/coldbox-modules/qb/commit/6bd958dbfe76b9d9c5bcc729999b54d6f2ade537))
+ __\*:__ Add more files to the box ignore
 ([e233853](https://github.com/coldbox-modules/qb/commit/e23385382695038462a42bf5c921561ace7755f2))
+ __\*:__ Add docs to the ignore for box install
 ([29017aa](https://github.com/coldbox-modules/qb/commit/29017aad69c4fb5e8f2b005f061322e9acc45ae8))
+ __\*:__ Move to the docs folder since that is what GitHub pages looks for.
 ([7c94266](https://github.com/coldbox-modules/qb/commit/7c942661c98a237589dd214cb24eefafa80eb532))
+ __\*:__ 2.0.0 ([e1710bf](https://github.com/coldbox-modules/qb/commit/e1710bf8c351c6ce46ffeb1d8d94708da389ce3d))
+ __\*:__ Add API Docs

Commit them for now until commandbox-docbox is fixed and we can do it in Travis.
 ([fa2edae](https://github.com/coldbox-modules/qb/commit/fa2edae03b34839ad25435f7ccb1bbfb2b8423f5))
+ __\*:__ Finish API docs for QB!!!!!
 ([f145d9a](https://github.com/coldbox-modules/qb/commit/f145d9a9efff1bb7ba6d8ccbe46dac7823cb1d3a))
+ __\*:__ 1.6.2 ([c6508bb](https://github.com/coldbox-modules/qb/commit/c6508bb41bc0dd0ba8ce12aaf383493b417da71c))
+ __\*:__ Add a check to only try to remove the QB_RN column when records actually exist in the query.
 ([4d10905](https://github.com/coldbox-modules/qb/commit/4d109055b2d73ca2baadd7a183a8a740d8ac6238))
+ __\*:__ A fun refactor using closures of aggregates.  Added docblocks to the new `with` methods.
 ([9b946c4](https://github.com/coldbox-modules/qb/commit/9b946c46d81cbfced9edbfbc6252bb075cd03a6a))
+ __\*:__ Add docblocks for bindings
 ([ef1970d](https://github.com/coldbox-modules/qb/commit/ef1970d0d3dc2535501191051118b3d2b60187d7))
+ __\*:__ Add docblocks for insert, update, and delete
 ([bbd7c6a](https://github.com/coldbox-modules/qb/commit/bbd7c6afa5f87b874ebfa457638068b205c69cfa))
+ __\*:__ Add new tap method for inspecting a query in process without interrupting chaining.
 ([f9b7432](https://github.com/coldbox-modules/qb/commit/f9b74322368903faff2d06e5e98a884c10ff0522))
+ __\*:__ Use util check instead of raw `isInstanceOf`
 ([6388bfd](https://github.com/coldbox-modules/qb/commit/6388bfdd2ae965f8ad641089dfa2b969d50b7369))
+ __\*:__ Better name `forPage` arguments
 ([0037cdd](https://github.com/coldbox-modules/qb/commit/0037cdd9e701d213319db2e1b47c598dae012d1d))
+ __\*:__ Add docblocks for where clauses and groups/havings/orders/limits
 ([c396c98](https://github.com/coldbox-modules/qb/commit/c396c980835f27dc54563d8ccacabfa0bc9f35f1))
+ __\*:__ Add docblocks for joins
 ([f580f0a](https://github.com/coldbox-modules/qb/commit/f580f0a7253a419be34257e7d173d3b9f0a3f37e))
+ __\*:__ Add more to the API docs
 ([0d5dd74](https://github.com/coldbox-modules/qb/commit/0d5dd74bfaa96c268b9041fabf2ff7a52faccddf))
+ __\*:__ Fix WireBox mapping for newly required returnFormat
 ([61d8a14](https://github.com/coldbox-modules/qb/commit/61d8a1450476f737602fd578abd5d24b7c72d008))
+ __\*:__ Add missing semicolons
 ([0493b4a](https://github.com/coldbox-modules/qb/commit/0493b4a2eb36308fe39e5fba2591be8d604eebf5))
+ __\*:__ Deprecate `returningArrays` in favor of `returnFormat`

`returnFormat` can take a closure or “array” or “query”.
Aggregate methods correctly ignore `returnFormat`

Fixes #6, #7
 ([f52e25a](https://github.com/coldbox-modules/qb/commit/f52e25ac20f56ff08c0fc0c2c732df9e80042f0c))
+ __\*:__ Add `selectRaw` helper method.
Alias `table` for `from.
 ([20da7ea](https://github.com/coldbox-modules/qb/commit/20da7ea9c4061d8a8a29f41eea4268e69fd3e285))
+ __\*:__ Set up bdd with ColdBox Elixir
 ([dc5cf18](https://github.com/coldbox-modules/qb/commit/dc5cf187dbab163620fa6e10c0f85d40ce35a46e))
+ __\*:__ Add testbox runner and npm package script for tests
 ([7a3ae71](https://github.com/coldbox-modules/qb/commit/7a3ae71a2731e60b75be86cc9424da66d89132da))
+ __\*:__ 1.6.1 ([068d8a0](https://github.com/coldbox-modules/qb/commit/068d8a0d939265e7c52978cef96743231d008c1d))
+ __\*:__ Minor formatting changes

4 spaces for indentation and spaces inside braces with arguments ({}) ([73f0856](https://github.com/coldbox-modules/qb/commit/73f08564c1629bbbd69bd512963879ee25a50a68))
+ __\*:__ get tests to pass on ACF11
 ([aadb1f8](https://github.com/coldbox-modules/qb/commit/aadb1f8a99f8db4d78b37c5a616cf959ccfdb323))
+ __\*:__ Use queryExecute instead of Query() for query of query
 ([e2c8cb2](https://github.com/coldbox-modules/qb/commit/e2c8cb2362495bfa462000a338aaf0b4dff4f4b4))
+ __\*:__ 1.6.0 ([6db8522](https://github.com/coldbox-modules/qb/commit/6db85226f237e85a2ead6bdb75b49d9d9f63473b))
+ __\*:__ Parse column and table aliases without AS in them
 ([9d04a89](https://github.com/coldbox-modules/qb/commit/9d04a8959e7d2702d2c6994fa19b00f4e9587ac5))
+ __\*:__ 1.5.0 ([6937d35](https://github.com/coldbox-modules/qb/commit/6937d356d57044798e3a5ce38fc38c9226feaa94))
+ __\*:__ Add first MSSQL-specific grammar
 ([89b9c84](https://github.com/coldbox-modules/qb/commit/89b9c8406024578b08f3b274d3ab1a7662b55eb9))
+ __\*:__ 1.4.0 ([b11ea7f](https://github.com/coldbox-modules/qb/commit/b11ea7ffb8ad707f82efe9e78ef8eedc9909f4b0))
+ __\*:__ Fix failing test setup from adding return format
 ([301d013](https://github.com/coldbox-modules/qb/commit/301d013d289d2c90e1c3fee4a5ba8b905eddfcdc))
+ __\*:__ Provide custom oracle mass insert compilation
 ([d567830](https://github.com/coldbox-modules/qb/commit/d5678306e16439aff70a49ac68b86c8ec2baadc6))
+ __\*:__ Fix return results failing on insert, update, and deletes
 ([61ca2b1](https://github.com/coldbox-modules/qb/commit/61ca2b12a0334bf38a169f63f6a5d95aec8e8bae))
+ __\*:__ Allow passing options in to insert, update, and delete queries
 ([c45fdcd](https://github.com/coldbox-modules/qb/commit/c45fdcd64516d2e7f1ad577fd2fd71501c302814))
+ __\*:__ 1.3.0 ([8258998](https://github.com/coldbox-modules/qb/commit/8258998f782fb7dfe3f1cb635c49e69dab5b706b))
+ __\*:__ Allow a closure to influence return results.
 ([7a633bb](https://github.com/coldbox-modules/qb/commit/7a633bbed7e6100110a060caba5524bb5b65f71a))
+ __\*:__ 1.2.4 ([9ddea67](https://github.com/coldbox-modules/qb/commit/9ddea6764c5dfa50a090d6312b7cd2d5e42ef6ae))
+ __\*:__ Fix bug with oracle limits, offsets, and Query of Queries
 ([58189fc](https://github.com/coldbox-modules/qb/commit/58189fc840dfc3298127acae28bca5279a3781ed))
+ __\*:__ 1.2.3 ([b54ff1b](https://github.com/coldbox-modules/qb/commit/b54ff1b0b4eb65a01c31e80cc2ddc5b5b105c908))
+ __\*:__ Fix limit and offset for Oracle and remove generated QB_RN column
 ([44849ff](https://github.com/coldbox-modules/qb/commit/44849ffc1f7757e3f4a1eb613b784e1ed9131e69))
+ __\*:__ 1.2.2 ([d36c7ba](https://github.com/coldbox-modules/qb/commit/d36c7ba1da72d1aeaf8204302c9214de454388cc))
+ __\*:__ Update README formatting
 ([a0a3177](https://github.com/coldbox-modules/qb/commit/a0a31775d7439fad5e024b9dc3c0a5135098e44c))
+ __\*:__ Use `toBeWithCase` for SQL statement checks.  Add a test about uppercasing Oracle wrapped values.
 ([e14da32](https://github.com/coldbox-modules/qb/commit/e14da326c84feb63d4e6133d0ba7dc786a2b844a))
+ __\*:__ Apply the table prefix to the table alias as well.
 ([e5c6c4b](https://github.com/coldbox-modules/qb/commit/e5c6c4b3cef6e09d62d66aee672a8443844e5748))
+ __\*:__ 1.2.1 ([44752d1](https://github.com/coldbox-modules/qb/commit/44752d1dd3fc2e5a4421f0803af1e4fbb9a84f14))
+ __\*:__ Quick fixes for Oracle grammar. Still needs tests
 ([74e14f7](https://github.com/coldbox-modules/qb/commit/74e14f7c96ecb875c85da2fb72eeddcbebffe2dc))
+ __\*:__ Merge branch 'development'

* development:
  1.2.0
  Add OracleGrammar WireBox mapping in ModuleConfig
  Add section on specifying defaultGrammar
  Update readme with correct Travis badges
  Add Oracle grammar support with limit and offset
  Move MySQL Grammar tests to their own file
 ([e4146cb](https://github.com/coldbox-modules/qb/commit/e4146cb549587ff2d9301430276afc4f92b3e8a5))
+ __\*:__ 1.2.0 ([a077807](https://github.com/coldbox-modules/qb/commit/a0778075264d067b88e6498b44eee0f75b98c234))
+ __\*:__ Add OracleGrammar WireBox mapping in ModuleConfig
 ([a4499a9](https://github.com/coldbox-modules/qb/commit/a4499a9a7c09b07b5e34ed0e11115dcf4c59f9b0))
+ __\*:__ Add section on specifying defaultGrammar
 ([cdc0776](https://github.com/coldbox-modules/qb/commit/cdc077685b43e4671387e490f3a31cc7e3a552cd))
+ __\*:__ Update readme with correct Travis badges
 ([d9fce51](https://github.com/coldbox-modules/qb/commit/d9fce51bb917df65c47de192d7376c89558f83e5))
+ __\*:__ Add Oracle grammar support with limit and offset
 ([9bea030](https://github.com/coldbox-modules/qb/commit/9bea0305eb87344c981ceb4141ba3146dafc8847))
+ __\*:__ Move MySQL Grammar tests to their own file
 ([d4a6856](https://github.com/coldbox-modules/qb/commit/d4a6856b269c148ace31157ef99ef0d1049576dd))
+ __\*:__ 1.2.0 ([a33d937](https://github.com/coldbox-modules/qb/commit/a33d9375df349632ada9f7a4e9950c1b19c62cc6))
+ __\*:__ Add OracleGrammar WireBox mapping in ModuleConfig
 ([5c202f0](https://github.com/coldbox-modules/qb/commit/5c202f042ebe1e264e33b92660d9dbcf630dca6c))
+ __\*:__ Add section on specifying defaultGrammar
 ([c6dcbd5](https://github.com/coldbox-modules/qb/commit/c6dcbd5fc1a3f7475232f7bde97d8cf62ae56798))
+ __\*:__ Update readme with correct Travis badges
 ([84a937d](https://github.com/coldbox-modules/qb/commit/84a937de661d222f3b0689a9c05049a7d600c236))
+ __\*:__ Add Oracle grammar support with limit and offset
 ([c9bab7b](https://github.com/coldbox-modules/qb/commit/c9bab7b624049de9692a0324d43d39bcc401657a))
+ __\*:__ Move MySQL Grammar tests to their own file
 ([746d190](https://github.com/coldbox-modules/qb/commit/746d19036ffab1db465d7d833be1e68b610f0d2c))
+ __\*:__ 1.1.2 ([511a567](https://github.com/coldbox-modules/qb/commit/511a5670f9456063bbe2db80a7842ec2a1145e36))
+ __\*:__ Fix two functions to return any to allow for query or array return results
 ([b70b968](https://github.com/coldbox-modules/qb/commit/b70b968ccf3f908b574cb7127012d453fb70090a))
+ __\*:__ 1.1.1 ([00ac2b0](https://github.com/coldbox-modules/qb/commit/00ac2b0b8b3ca917cf251fe670fa68e5f2f949b3))
+ __\*:__ Add MySQLGrammar binding
 ([bbd2717](https://github.com/coldbox-modules/qb/commit/bbd27170056d6255a2abac32e5f1d4bdf3888e74))
+ __\*:__ 1.1.0 ([fb82230](https://github.com/coldbox-modules/qb/commit/fb822305c74f1efd395b06e38ed30df0245b4486))
+ __\*:__ Add initial MySQL Grammar support
 ([77b636c](https://github.com/coldbox-modules/qb/commit/77b636c8cca66151c98d33b11df1a120e3f18f63))
+ __\*:__ Adding mappings for WireBox.
 ([8771321](https://github.com/coldbox-modules/qb/commit/8771321a2a7686f53acdd643118a1eb1484766bf))
+ __\*:__ Remove Oracle Grammar to be implemented at a later time.
 ([8fcb297](https://github.com/coldbox-modules/qb/commit/8fcb2976a1d1360244c7e6b9512275870da5927b))
+ __\*:__ Add fix for negative values in forPage
 ([10c77ce](https://github.com/coldbox-modules/qb/commit/10c77ced2431df95208ba38f88d87a1d2f9d8ec4))
+ __\*:__ Add forPage helper to help with pagination.
 ([658af5b](https://github.com/coldbox-modules/qb/commit/658af5bd19055d91402f6d1f20976a5e6fad6df8))
+ __\*:__ Add missing semicolon for ACF
 ([da77797](https://github.com/coldbox-modules/qb/commit/da77797ec8127a7f5b1fa9192ff27b4e2359cb57))
+ __\*:__ Add havings clause
 ([f1e3f67](https://github.com/coldbox-modules/qb/commit/f1e3f67b5aa8eb6b8504ed7af14557164d168311))
+ __\*:__ Use accessor instead of direct variables access.
 ([6f54077](https://github.com/coldbox-modules/qb/commit/6f54077c0272e3664cb862746317235afe11948d))
+ __\*:__ Default to returning arrays of structs over queries.
 ([1dd330b](https://github.com/coldbox-modules/qb/commit/1dd330b0c0e26311b4aa2326b2d1cefad07b99b3))
+ __\*:__ Refactor runQuery to run.
 ([789a6c1](https://github.com/coldbox-modules/qb/commit/789a6c1f335f82db5fae44472ed96fada970fbeb))
+ __\*:__ Allow passing a single column or an array of columns to get to execute the query with those columns once.
 ([338f82c](https://github.com/coldbox-modules/qb/commit/338f82c9908b459b8672c950fdbed58e4bdc64b4))
+ __\*:__ Add value and exist helper query methods.
 ([34f7ddc](https://github.com/coldbox-modules/qb/commit/34f7ddcb9d643459afba365bf535b3648fa7d0aa))
+ __\*:__ Implement count, max, min, and sum aggregate methods.
 ([3217de2](https://github.com/coldbox-modules/qb/commit/3217de2b7cefebb70c294ba46769ed02207ba776))
+ __\*:__ Default selecting “*” if nothing is passed in to select()
 ([c542425](https://github.com/coldbox-modules/qb/commit/c54242555872bef602f4d3579587781ff4c5cda1))
+ __\*:__ Implement retrieval shortcuts — first, find, get
 ([4440e23](https://github.com/coldbox-modules/qb/commit/4440e23391031db70473886ffd098f0aae22b4b1))
+ __\*:__ Verify raw statements work in select fields
 ([9907bab](https://github.com/coldbox-modules/qb/commit/9907babd849559685e91fdf9f0530f08639cdc5c))
+ __\*:__ Minor formatting adjustments
 ([971489e](https://github.com/coldbox-modules/qb/commit/971489e9588d957c6059991e488fdca5e56afe28))
+ __\*:__ Minor formatting changes
 ([1f41186](https://github.com/coldbox-modules/qb/commit/1f411868eac38e4f4b38caa30b7380204cac9a53))
+ __\*:__ Remove unused interface
 ([ee85fc7](https://github.com/coldbox-modules/qb/commit/ee85fc753252d5061f3d00015a54519062f04282))
+ __\*:__ Remove inject helpers. We'll manage that in the ModuleConfig.cfc
 ([71b5e5c](https://github.com/coldbox-modules/qb/commit/71b5e5c0638465bad668456d08bfaba41fe76345))
+ __\*:__ Update references to qb and correct version
 ([cb1ffdd](https://github.com/coldbox-modules/qb/commit/cb1ffdd77a54ba5c591c29e0c6b28061493f5dd9))
+ __\*:__ Remove ACF 10 support because I want to use member functions.
 ([0b634bd](https://github.com/coldbox-modules/qb/commit/0b634bdb26b230f5720e489238b02796ae155626))
+ __\*:__ Add import statements for CF11.
 ([ef23bf1](https://github.com/coldbox-modules/qb/commit/ef23bf1cd46d4660a333fda6fe3700668fceec04))
+ __\*:__ Fixes for Adobe engines.
 ([64c19c7](https://github.com/coldbox-modules/qb/commit/64c19c70bafcf7d454751d418f2a6699fdc6f92c))
+ __\*:__ Update Travis script
 ([3249f98](https://github.com/coldbox-modules/qb/commit/3249f98d60ec8bfb7a5ba393ccde0b620a174cde))
+ __\*:__ Add updateOrInsert helper
 ([c30ad18](https://github.com/coldbox-modules/qb/commit/c30ad18a8a642f2a5a614b4096e8ffb5d8d5b3e9))
+ __\*:__ Add exists
 ([c678cf2](https://github.com/coldbox-modules/qb/commit/c678cf27f7c427bec01bcf14b1d83bda1215047b))
+ __\*:__ Add limit and offset
 ([e606102](https://github.com/coldbox-modules/qb/commit/e6061020263b4a4b18a72cf4da844681a5ae2656))
+ __\*:__ Update readme from Quick to qb
 ([e585a88](https://github.com/coldbox-modules/qb/commit/e585a883cd09aaaaae692d024f76916d523f743c))
+ __\*:__ Rename Quick to qb.

Quick will be the ORM implementation that will use qb underneath the hood.
 ([29b34af](https://github.com/coldbox-modules/qb/commit/29b34af1cad1934d764cedaee1fbad187fecc800))
+ __\*:__ Remove the need to return a query in a when callback.
 ([657d47c](https://github.com/coldbox-modules/qb/commit/657d47c1b2d456895111b1dd815b4157dede3567))
+ __\*:__ Insert, Updates, and Deletes! Oh my!
 ([e19dae3](https://github.com/coldbox-modules/qb/commit/e19dae3a48c480285454d989277c1a906950d8ee))
+ __\*:__ Remove unneeded dependency
 ([0452b44](https://github.com/coldbox-modules/qb/commit/0452b44d3c7f28e41e885a4ff90ed68700312775))
+ __\*:__ Clean up tests and all tests passing!
 ([6e75e61](https://github.com/coldbox-modules/qb/commit/6e75e61778931895249a2aaa165be77737d5ac4e))
+ __\*:__ Implement group bys
 ([73f961d](https://github.com/coldbox-modules/qb/commit/73f961d594cf7b3abe6a1c16cc4c5eabea1fe294))
+ __\*:__ Implement when callbacks
 ([ed65e09](https://github.com/coldbox-modules/qb/commit/ed65e09c97550d5c241a73c6703ad97fadca978a))
+ __\*:__ Refactor to addBindings
 ([7ca0d5e](https://github.com/coldbox-modules/qb/commit/7ca0d5eacb16858db98e8bcd501cc0591197fa76))
+ __\*:__ Implement joins
 ([f41bca0](https://github.com/coldbox-modules/qb/commit/f41bca0d6a84c8311f94e9efdda8641028949073))
+ __\*:__ Finish implementing where in. All wheres are done!
 ([4d734b3](https://github.com/coldbox-modules/qb/commit/4d734b3d145861b501f8afc7e4d63dea9c427fed))
+ __\*:__ Implement between statements
 ([26f937b](https://github.com/coldbox-modules/qb/commit/26f937b8d21dc17c5e013e6f7c5b10a0ce96c925))
+ __\*:__ Implement null checks
 ([9f86158](https://github.com/coldbox-modules/qb/commit/9f861583d5e3c8fe9f8e433a5c12d77709dd3eed))
+ __\*:__ Refactor to generated getters and setters.
 ([04f80f7](https://github.com/coldbox-modules/qb/commit/04f80f797b155da850317af97682ee6f2c60e3cf))
+ __\*:__ Implement where exists
 ([d4174e3](https://github.com/coldbox-modules/qb/commit/d4174e3d76fbf2e4d5cbd39ed989e4ace28e8956))
+ __\*:__ Implement table prefixes
 ([edf8f66](https://github.com/coldbox-modules/qb/commit/edf8f666954dcd2faa23d890f3440dfbfe53bcc8))
+ __\*:__ Finish basic wheres
 ([160f68d](https://github.com/coldbox-modules/qb/commit/160f68d8b302b1b2253ae0b28bd1c824ee121545))
+ __\*:__ Implement select methods
 ([baa72a2](https://github.com/coldbox-modules/qb/commit/baa72a2c36bf8f17ee2115fda5e4959047dc868f))
+ __\*:__ Reformat according to new style guidelines
 ([fadb882](https://github.com/coldbox-modules/qb/commit/fadb882166ca589872ae954ae02baf60cb3652b9))
+ __\*:__ Add sublime project file
 ([9e1cd9c](https://github.com/coldbox-modules/qb/commit/9e1cd9c372ff02d2d64c36195bc5ca3a153f78ef))
+ __\*:__ Round out failing tests. Time to start implementing
 ([bb54d35](https://github.com/coldbox-modules/qb/commit/bb54d35e447e774f42337ce54635be4151947055))
+ __\*:__ Add more failing query/grammar tests
 ([0d874c5](https://github.com/coldbox-modules/qb/commit/0d874c5386cd24e91ea99c9b4226f080fd07a700))
+ __\*:__ Add a bunch of failing tests for builder+grammar interaction
 ([532ffdb](https://github.com/coldbox-modules/qb/commit/532ffdb3321f776fcf9619019c4f4d0c8b202a2c))
+ __\*:__ Update to the latest Travis CI multi-engine file
 ([52c647c](https://github.com/coldbox-modules/qb/commit/52c647cc9004bea9e683bbf9851ef78d88b05497))
+ __\*:__ Add comments about ACF10 making life sad.
 ([bc482d1](https://github.com/coldbox-modules/qb/commit/bc482d1a5f43c7b60a9671c3b78ec4cabe57d2d5))
+ __\*:__ Clarify that PLATFORM is really an ENGINE
 ([cc328fb](https://github.com/coldbox-modules/qb/commit/cc328fb75da0ca7ef53d933ca5063bd0dc246c54))
+ __\*:__ Add Travis build badge to README.
 ([0856b69](https://github.com/coldbox-modules/qb/commit/0856b698c39b6ea859e8c30a2877b6917a634a5d))
+ __\*:__ Remove unneeded files now that the testing script is inline.
 ([1ce41ba](https://github.com/coldbox-modules/qb/commit/1ce41baf9b3167b07e84da3f7886be48f30b12da))
+ __\*:__ Move script in to travis.yml file.
 ([18c1f2e](https://github.com/coldbox-modules/qb/commit/18c1f2e1a9448355856d4a5cb19edb93047697d6))
+ __\*:__ Add a sleep call to make sure the server has time to spin up.
 ([96c4cf5](https://github.com/coldbox-modules/qb/commit/96c4cf568879ce947c242a630604bc3ac8f69837))
+ __\*:__ Specify required CFML versions.
 ([cce8483](https://github.com/coldbox-modules/qb/commit/cce8483b6e5b1835a123d038bf8f5c8d32f4996f))
+ __\*:__ Major refactoring to support ACF10
 ([3abeb67](https://github.com/coldbox-modules/qb/commit/3abeb67fcc0c59c15d84ac8aeb64c0fec3c6bf2d))
+ __\*:__ Specify that Lucee 5 is a snapshot version.
 ([cfd0d23](https://github.com/coldbox-modules/qb/commit/cfd0d23f15a957af776cb2a0aaa0e3af9c0d29a7))
+ __\*:__ Switch to the latest version of CommandBox for multi-server options.
 ([cefa79d](https://github.com/coldbox-modules/qb/commit/cefa79d4b04a3236f0264273c76921ccf4e24ff8))
+ __\*:__ Add test result properties file to gitignore
 ([a19ea45](https://github.com/coldbox-modules/qb/commit/a19ea45ac9e54325fdb33ea57e6c3c552caf803f))
+ __\*:__ Add a gitkeep file to the tests results path so tests can run on Travis.
 ([5687ae0](https://github.com/coldbox-modules/qb/commit/5687ae012d73cce32769235aa054acae92462771))
+ __\*:__ Try to add travis support for multiple cf engines.
 ([2833375](https://github.com/coldbox-modules/qb/commit/2833375234d493726270c375bdf793de24e29593))
+ __\*:__ Add README
 ([369e3c7](https://github.com/coldbox-modules/qb/commit/369e3c74dff0021cff409f4e5742a30f06cc9369))
+ __\*:__ Move the list and array inferSqlType tests to the right block.
 ([917f132](https://github.com/coldbox-modules/qb/commit/917f132352806ad97cacbe46de8c0fa5c1a03882))
+ __\*:__ Infer the sql type of lists and arrays based on if all the members share the same sql type; otherwise, default to CF_SQL_VARCHAR.
 ([7ae2548](https://github.com/coldbox-modules/qb/commit/7ae2548762b8b985981479c8f813ac3801091d21))
+ __\*:__ Added orWhere{Column} dynamic method matching.
 ([b221bcd](https://github.com/coldbox-modules/qb/commit/b221bcd453fb79d3e3059fda25dc61cfbfa15985))
+ __\*:__ Add whereIn and whereNotIn helper methods.
 ([118db23](https://github.com/coldbox-modules/qb/commit/118db23f311e263ea6c19a10e95b5aa1dfb6b5e7))
+ __\*:__ Return the Builder to continue chaining on dynamic where methods.
 ([202127a](https://github.com/coldbox-modules/qb/commit/202127ac83919cf5d7254a9100a673a2d553354f))
+ __\*:__ Add list functionality to the QueryUtils `extractBinding`
 ([80dc5b0](https://github.com/coldbox-modules/qb/commit/80dc5b09587a1f9f8520651722f084f0d30ca60c))
+ __\*:__ Wrap the parameters in an "IN" or "NOT IN" clause.
 ([c69cae3](https://github.com/coldbox-modules/qb/commit/c69cae3cb8efebf2831d193fea82296be44f1421))
+ __\*:__ Simplify the operator list
 ([4ae3cf1](https://github.com/coldbox-modules/qb/commit/4ae3cf1261aaea891f0c361e2ebb9833ca3395ab))
+ __\*:__ Upper case operators in SQL strings.
 ([d7ba404](https://github.com/coldbox-modules/qb/commit/d7ba404ad6921553b7841d0ff0a9197641192b33))
+ __\*:__ Unify exception types for invalid operators and combinators
 ([c4b9d68](https://github.com/coldbox-modules/qb/commit/c4b9d6887c3b12fb11f2a7ff2e764038f39a157e))
+ __\*:__ Don't open the browser automatically on server start. (Use `gulp watch` instead for BrowserSync.) :-)
 ([623517f](https://github.com/coldbox-modules/qb/commit/623517f3d6a38b82761c6a7be86016d442078e08))
+ __\*:__ Refactor to Wirebox injection.
 ([54bc5e0](https://github.com/coldbox-modules/qb/commit/54bc5e0867d8d74084e3ae9e556d25f1c2257a64))
+ __\*:__ Infer the cfsqltype on bindings.
 ([3f53bd5](https://github.com/coldbox-modules/qb/commit/3f53bd5e155387152692f2576da8a2b42c39f7ca))
+ __\*:__ Refactor to new QueryUtils file for shared functionality.
 ([426e72d](https://github.com/coldbox-modules/qb/commit/426e72d2709fe90781818f60df43e0320c2f8523))
+ __\*:__ Refactor bindings to use structs instead of values in preparation for cfsqltypes.
 ([90fc19c](https://github.com/coldbox-modules/qb/commit/90fc19c25e17c19b44fe4affc3ad3b8476f35b40))
+ __\*:__ Also allow the shortcut where syntax for the on method.
 ([c67bd66](https://github.com/coldbox-modules/qb/commit/c67bd66eb5d14798b9fa2128d9aacc04b6107d98))
+ __\*:__ Allow the shortcut where statement in joins.
 ([28fc828](https://github.com/coldbox-modules/qb/commit/28fc8285250d38895a227907abd2b308b19b741b))
+ __\*:__ Add join query bindings.
 ([ad911fa](https://github.com/coldbox-modules/qb/commit/ad911fabd9534d31ed9413765f19065d98919a16))
+ __\*:__ Fix the SQL compilation order.
 ([ccbc273](https://github.com/coldbox-modules/qb/commit/ccbc27391a5246866d1352c90884af35d816f4ef))
+ __\*:__ Allow default settings with user overrides in the ModuleConfig.
 ([f2d2441](https://github.com/coldbox-modules/qb/commit/f2d2441b90678ad9d6f47d266e747822a65d4389))
+ __\*:__ Fixes for new Quick module mapping.
 ([1caa4bc](https://github.com/coldbox-modules/qb/commit/1caa4bc0ef4fa41f6ba7179c79e2f8cbda5f746b))
+ __\*:__ Add box scripts to workflow
 ([23409ce](https://github.com/coldbox-modules/qb/commit/23409ce283a31d9fffdc401e985101ac0929c4eb))
+ __\*:__ 0.1.1 ([ad26504](https://github.com/coldbox-modules/qb/commit/ad26504521092b3d3e7106633b8fdedb2425b166))
+ __\*:__ Fix for mappings to work correctly in modules.
 ([7502394](https://github.com/coldbox-modules/qb/commit/7502394840190208392f176d23e04b80e1ffcac1))
+ __\*:__ Allow the join closure to be passed in as the second positional argument.
 ([9efbe5b](https://github.com/coldbox-modules/qb/commit/9efbe5b960ec8a804ea5287a4ca56c8a2a336b71))
+ __\*:__ Work on Join clauses
 ([fb25c48](https://github.com/coldbox-modules/qb/commit/fb25c488e9c3ece3deb1463fd3dd21fc29b395f6))
+ __\*:__ Implement joins
 ([c1f3228](https://github.com/coldbox-modules/qb/commit/c1f3228d7de9616aa79f2c72cb48114b761baeca))
+ __\*:__ Enable distinct flag.
Clean up duplication in tests.
Move src/ to models/
 ([7a83500](https://github.com/coldbox-modules/qb/commit/7a83500fab00015b950550851905325c20b8a2fc))
+ __\*:__ Set up BrowserSync with ColdBox Elixir
 ([8109613](https://github.com/coldbox-modules/qb/commit/8109613c3f3eb00b698c644a6f8229fccb4d87c9))
+ __\*:__ Always upper case the combinator.
 ([b4b8e2b](https://github.com/coldbox-modules/qb/commit/b4b8e2bdab063065468c98c6f090c6b59fe2d859))
+ __\*:__ Validate combinators
 ([e3bd0fe](https://github.com/coldbox-modules/qb/commit/e3bd0fee615af4e2a955bc8d073156b869083820))
+ __\*:__ Compile where statements
 ([e403216](https://github.com/coldbox-modules/qb/commit/e403216d01a10361b985391698b4e86688c4febc))
+ __\*:__ Simple query execution
 ([a2b1090](https://github.com/coldbox-modules/qb/commit/a2b1090c931ffa728dad26aff41a01cf853cab85))
+ __\*:__ Allow specifying the combinator (AND or OR)
.
 ([eb3d6e0](https://github.com/coldbox-modules/qb/commit/eb3d6e05454ab201be2fb8c599f8d34356fe906d))
+ __\*:__ Add where values to the SQL bindings array.
 ([8dc4a47](https://github.com/coldbox-modules/qb/commit/8dc4a47907e887f98829f39a41d74ce82b0478a5))
+ __\*:__ Use ColdBox Elixir
 ([9925fe6](https://github.com/coldbox-modules/qb/commit/9925fe6b39df606f101c1ca027cfc2de2499517b))
+ __\*:__ Run tests through CommandBox
 ([a2c350f](https://github.com/coldbox-modules/qb/commit/a2c350fcc820da42569358ea251b1f1d722e0ace))
+ __\*:__ Just dump everything we'd been working on.
 ([9ff2c6c](https://github.com/coldbox-modules/qb/commit/9ff2c6c8497674f5174aeda68289487ca1950a1d))
+ __\*:__ Initial commit
 ([00d24a6](https://github.com/coldbox-modules/qb/commit/00d24a642d220fa452406592e9569c0d9ac43186))

### perf

+ __QueryBuilder:__ Replace normalizeToArray with simpler Array check

normalizeToArray handles the case where variadic arguments are passed in.
This comes at a cost, about 50 ms.

Speed is everything when testing against a database.
 ([d54bcce](https://github.com/coldbox-modules/qb/commit/d54bccec88da95f2982423ea7bfbd0785e2e8d7b))
+ __BaseGrammar:__ Avoid isInstanceOf in wrapColumn

`isInstanceOf` takes about 30-40 ms per column.  For just one table with
6 columns, this is close to a quarter of a second.  This adds up.

Instead, just checking if the variable is an object that has a `getSQL`
key (which we assume is a method), we save all of that time.
 ([15042ce](https://github.com/coldbox-modules/qb/commit/15042ce04384536ecda2f06148481bd32b252eb8))


# v5.7.0
## 17 Aug 2018 — 20:51:49 UTC

### feat

+ __QueryBuilder:__ Add support for Common Table Expressions ([3e10da6](https://github.com/coldbox-modules/qb/commit/3e10da635f0b70443b83521791af2a7c6e99a4c7))
+ __QueryBuilder:__ Derived and Sub Tables ([b3f0461](https://github.com/coldbox-modules/qb/commit/b3f0461f4b0a50e0614dca529983b8f1e823fca5))
+ __QueryBuilder:__ Unions ([59028a8](https://github.com/coldbox-modules/qb/commit/59028a8d63a314ddd7f640706272a58dde948d0b))

### fix

+ __QueryBuilder:__ Fix JoinClause return value ([5d113c7](https://github.com/coldbox-modules/qb/commit/5d113c7e9dc8c125d0caeb0ed27fb36deb5da8cd))


# v5.5.0
## 07 Jun 2018 — 03:00:22 UTC

### feat

+ __QueryBuilder:__ Add andWhere method for more readable chains. ([309f4d8](https://github.com/coldbox-modules/qb/commit/309f4d85fa3ad7ef9d5a49008eec8fb4f7e1c44c))

### other

+ __\*:__ Updated API Docs ([d944917](https://github.com/coldbox-modules/qb/commit/d9449175e9e694f09b751138a4821829f167d476))


# v5.4.1
## 27 Apr 2018 — 22:48:54 UTC

### fix

+ __PostgresGrammar:__ Fix typo in getAllTableNames ([91caf6a](https://github.com/coldbox-modules/qb/commit/91caf6a467fa585fdeef26e08171b59ff71b59e1))
+ __SchemaBuilder:__ Fix dropping foreign keys in MySQL ([8895447](https://github.com/coldbox-modules/qb/commit/8895447cf3a0c36c2579a2867f0510033a28b0b7))

### other

+ __\*:__ Updated API Docs ([84913a9](https://github.com/coldbox-modules/qb/commit/84913a9cabf35fc2429787d1b7f4a37dfadb4e50))


# v5.4.0
## 16 Apr 2018 — 21:36:02 UTC

### feat

+ __AutoDiscover:__ Allow for runtime discovery ([700948a](https://github.com/coldbox-modules/qb/commit/700948a6ac503b7af59efb0e00894c211c3d8882))

### other

+ __\*:__ Updated API Docs ([f078222](https://github.com/coldbox-modules/qb/commit/f0782223d11052c560d45a6f120eb56402949d20))


# v5.3.1
## 28 Mar 2018 — 22:12:45 UTC

### fix

+ __ModuleConfig:__ Fix logic for determining CommandBox vs ColdBox environment ([5c66466](https://github.com/coldbox-modules/qb/commit/5c66466b11707342265a9589fefe016df134cb48))

### other

+ __\*:__ Updated API Docs ([9136823](https://github.com/coldbox-modules/qb/commit/913682381ec4ad6627a4c136d191a3b637fa4d75))


# v5.3.0
## 26 Mar 2018 — 16:15:55 UTC

### chore

+ __README:__ Update references to elpete to coldbox-modules ([bc7c99c](https://github.com/coldbox-modules/qb/commit/bc7c99c5f32c71bd899321dc3909313c17beb853))

### feat

+ __ModuleConfig:__ Auto discover grammar by default. ([b2347ae](https://github.com/coldbox-modules/qb/commit/b2347aebae9ca5a42655b0f7ed5fd2ed6ec804fb))

### fix

+ __ModuleConfig:__ Add PostgresGrammar alias to WireBox ([eca03f0](https://github.com/coldbox-modules/qb/commit/eca03f0594147c9323bc99ddd9505b8e7b4c6571))

### other

+ __\*:__ Updated API Docs ([654eb0c](https://github.com/coldbox-modules/qb/commit/654eb0c67e69c06e3f3fc6bc17c3fef26b95ee54))


# v5.2.1
## 14 Mar 2018 — 03:18:19 UTC

### fix

+ __QueryBuilder:__ Preserve returnFormat when creating a new builder ([4538947](https://github.com/coldbox-modules/qb/commit/4538947807d3c33865281bdf7852b858c393dbfb))

### other

+ __\*:__ Updated API Docs ([6bd1da1](https://github.com/coldbox-modules/qb/commit/6bd1da1c68ecd11227d575f9f6b0de652188633f))


# v5.2.0
## 12 Mar 2018 — 21:33:37 UTC

### feat

+ __Grammar:__ Added official support for MSSQL, Oracle, and Postgres. (#34) ([733dae3](https://github.com/coldbox-modules/qb/commit/733dae3498814f49a829b604799824e9f755bb85))

### other

+ __\*:__ Updated API Docs ([b99e000](https://github.com/coldbox-modules/qb/commit/b99e00030a2451807e3d7df9e365ee86e7be8543))


# v5.1.2
## 20 Feb 2018 — 06:59:54 UTC

### other

+ __\*:__ Updated API Docs ([fae1106](https://github.com/coldbox-modules/qb/commit/fae11067373d1e63d64318b4e27ec19aff16c4ce))

### perf

+ __QueryBuilder:__ Replace normalizeToArray with simpler Array check ([d54bcce](https://github.com/coldbox-modules/qb/commit/d54bccec88da95f2982423ea7bfbd0785e2e8d7b))
+ __BaseGrammar:__ Avoid isInstanceOf in wrapColumn ([15042ce](https://github.com/coldbox-modules/qb/commit/15042ce04384536ecda2f06148481bd32b252eb8))


# v5.1.1
## 19 Feb 2018 — 18:03:58 UTC

### fix

+ __MySQLGrammar:__ Default to CURRENT_TIMESTAMP for timestamp columns (#32) ([680750a](https://github.com/coldbox-modules/qb/commit/680750a9894c56271cc7748a6dc501c2c266ea85))

### other

+ __\*:__ Updated API Docs ([f78a21a](https://github.com/coldbox-modules/qb/commit/f78a21aaae8cb8fb1a475fa2f74acbafd506015f))


# v5.1.0
## 16 Feb 2018 — 22:23:59 UTC

### feat

+ __SchemaBuilder:__ Add dropAllObjects action. (#31) ([c3e23b5](https://github.com/coldbox-modules/qb/commit/c3e23b5c110fae3464d48d62ae80e357e8c38842))

### other

+ __\*:__ Updated API Docs ([b1499a3](https://github.com/coldbox-modules/qb/commit/b1499a3de00191478aa916aec368dc40c68319b7))


# v5.0.3
## 16 Feb 2018 — 21:10:33 UTC

### chore

+ __build:__ Enable commandbox-semantic-release ([0fe689f](https://github.com/coldbox-modules/qb/commit/0fe689f77b19124271a68293baa6a22b157a3cfd))

### errors

+ __schema:__ Better error message when passing in a TableIndex to create column ([f91a3f7](https://github.com/coldbox-modules/qb/commit/f91a3f7f4f4ae1bd513139fbb1ccfc52eef4874a))

### other

+ __\*:__ Updated API Docs ([dfd9510](https://github.com/coldbox-modules/qb/commit/dfd95103411c2fabaa0cac1cd8e681b9d088b614))
+ __\*:__ Update references from Builder to QueryBuilder ([632e697](https://github.com/coldbox-modules/qb/commit/632e697c5b37d8e6ea522efc628f487dc4e14403))
+ __\*:__ Updated API Docs ([8325db5](https://github.com/coldbox-modules/qb/commit/8325db5d232c55f3b433e4d528a43b72d7622fd9))
