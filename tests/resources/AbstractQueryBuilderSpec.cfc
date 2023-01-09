component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "basic selects", function() {
                    it( "can select all columns from a table", function() {
                        testCase( function( builder ) {
                            builder.select( "*" ).from( "users" );
                        }, selectAllColumns() );
                    } );

                    it( "can specify the column to select", function() {
                        testCase( function( builder ) {
                            builder.select( "name" ).from( "users" );
                        }, selectSpecificColumn() );
                    } );

                    it( "can select multiple columns using an array", function() {
                        testCase( function( builder ) {
                            builder.select( [ "name", builder.raw( "COUNT(*)" ) ] ).from( "users" );
                        }, selectMultipleArray() );
                    } );

                    it( "can add selects to a query", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "foo" )
                                .addSelect( "bar" )
                                .addSelect( [ "baz", "boom" ] )
                                .from( "users" );
                        }, addSelect() );
                    } );

                    it( "adding a select to a * query gets rid of the star", function() {
                        testCase( function( builder ) {
                            builder.addSelect( "foo" ).from( "users" );
                        }, addSelectRemovesStar() );
                    } );

                    it( "can select distinct records", function() {
                        testCase( function( builder ) {
                            builder
                                .distinct()
                                .select( [ "foo", "bar" ] )
                                .from( "users" );
                        }, selectDistinct() );
                    } );

                    it( "can parse column aliases", function() {
                        testCase( function( builder ) {
                            builder.select( "foo as bar" ).from( "users" );
                        }, parseColumnAlias() );
                    } );

                    it( "does not change aliases when quoted", function() {
                        testCase( function( builder ) {
                            builder.select( "foo as ""bar""" ).from( "users" );
                        }, parseColumnAliasWithQuotes() );
                    } );

                    it( "can parse column aliases in where clauses", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "users.foo" )
                                .from( "users" )
                                .where( "users.foo", "bar" );
                        }, parseColumnAliasInWhere() );
                    } );

                    it( "can parse column aliases in where clauses with subselects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users u" )
                                .select( "u.*, user_roles.roleid, roles.rolecode" )
                                .join( "user_roles", "user_roles.userid", "u.userid" )
                                .leftjoin( "roles", "user_roles.roleid", "roles.roleid" )
                                .where(
                                    "user_roles.roleid",
                                    "=",
                                    function( q ) {
                                        q.select( "roleid" )
                                            .from( "roles" )
                                            .where( "rolecode", "SYSADMIN" );
                                    }
                                );
                        }, parseColumnAliasInWhereSubselect() );
                    } );

                    it( "wraps columns and aliases correctly", function() {
                        testCase( function( builder ) {
                            builder.select( "x.y as foo.bar" ).from( "public.users" );
                        }, wrapColumnsAndAliases() );
                    } );

                    it( "selects raw values correctly", function() {
                        testCase( function( builder ) {
                            builder.select( builder.raw( "substr( foo, 6 )" ) ).from( "users" );
                        }, selectWithRaw() );
                    } );

                    it( "can easily select raw values with `selectRaw`", function() {
                        testCase( function( builder ) {
                            builder.selectRaw( "substr( foo, 6 )" ).from( "users" );
                        }, selectRaw() );
                    } );

                    it( "can select multiple raw values with `selectRaw` when passing in an array", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).selectRaw( [ "substr( foo, 6 )", "trim( bar )" ] );
                        }, selectRawArray() );
                    } );

                    it( "can clear the selected columns for a query", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( [ "foo", "bar" ] )
                                .clearSelect();
                        }, clearSelect() );
                    } );

                    it( "can reselect the columns for a query", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( [ "foo", "bar" ] )
                                .reselect( "baz" );
                        }, reselect() );
                    } );

                    it( "can reselect the columns for a query with raw expressions", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( [ "foo", "bar" ] )
                                .reselectRaw( [ "substr( foo, 6 )", "trim( bar )" ] );
                        }, reselectRaw() );
                    } );
                } );

                describe( "sub-selects", function() {
                    it( "can execute sub-selects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect( "latestUpdatedDate", function( q ) {
                                    return q
                                        .from( "posts" )
                                        .selectRaw( "MAX(updated_date)" )
                                        .whereColumn( "posts.user_id", "users.id" );
                                } );
                        }, subSelect() );
                    } );

                    it( "can take a query object in a sub-selects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect(
                                    "latestUpdatedDate",
                                    builder
                                        .newQuery()
                                        .from( "posts" )
                                        .selectRaw( "MAX(updated_date)" )
                                        .whereColumn( "posts.user_id", "users.id" )
                                );
                        }, subSelectQueryObject() );
                    } );

                    it( "can execute sub-selects with bindings", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect( "latestUpdatedDate", function( q ) {
                                    return q
                                        .from( "posts" )
                                        .selectRaw( "MAX(updated_date)" )
                                        .where( "posts.user_id", 1 );
                                } );
                        }, subSelectWithBindings() );
                    } );
                } );

                describe( "from", function() {
                    it( "can specify the table to select from", function() {
                        testCase( function( builder ) {
                            builder.from( "users" );
                        }, from() );
                    } );

                    it( "can specify a Expression object as the input for from", function() {
                        testCase( function( builder ) {
                            builder.from( builder.raw( "Test (nolock)" ) );
                        }, fromRaw() );
                    } );

                    it( "can use `table` as an alias for from", function() {
                        testCase( function( builder ) {
                            builder.table( "users" );
                        }, table() );
                    } );

                    it( "can specify a Expression object as the input for table", function() {
                        testCase( function( builder ) {
                            builder.table( builder.raw( "Test (nolock)" ) );
                        }, fromRaw() );
                    } );

                    it( "can specify the table to select from as a string using fromRaw", function() {
                        testCase( function( builder ) {
                            builder.fromRaw( "Test (nolock)" );
                        }, fromRaw() );
                    } );

                    it( "can add bindings to fromRaw", function() {
                        testCase( function( builder ) {
                            builder.fromRaw( "Test (nolock)", [ 1, 2, 3 ] );
                        }, { sql: fromRaw(), bindings: [ 1, 2, 3 ] } );
                    } );

                    it( "can specify the table using fromSub as QueryBuilder", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( [ "id", "name" ] )
                                .from( "users" )
                                .where( "age", ">=", "21" );

                            builder.fromSub( "u", derivedTable );
                        }, fromDerivedTable() );
                    } );

                    it( "can specify the table using fromSub as a closure", function() {
                        testCase( function( builder ) {
                            builder.fromSub( "u", function( q ) {
                                q.select( [ "id", "name" ] )
                                    .from( "users" )
                                    .where( "age", ">=", "21" );
                            } );
                        }, fromDerivedTable() );
                    } );
                } );

                describe( "locking", function() {
                    it( "can set no lock", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .noLock();
                        }, noLock() );
                    } );

                    it( "can set a shared lock", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .sharedLock();
                        }, sharedLock() );
                    } );

                    it( "can lock for update", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .lockForUpdate();
                        }, lockForUpdate() );
                    } );

                    it( "can lock for update skipping locked rows", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .lockForUpdate( skipLocked = true );
                        }, lockForUpdateSkipLocked() );
                    } );

                    it( "can pass an arbitrary string to lock", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .lock( "foobar" );
                        }, lockArbitraryString() );
                    } );
                } );

                describe( "using table prefixes", function() {
                    it( "can perform a basic select with a table prefix", function() {
                        testCase( function( builder ) {
                            builder.getGrammar().setTablePrefix( "prefix_" );
                            builder.select( "*" ).from( "users" );
                        }, tablePrefix() );
                    } );

                    it( "can parse column aliases with a table prefix", function() {
                        testCase( function( builder ) {
                            builder.getGrammar().setTablePrefix( "prefix_" );
                            builder.select( "*" ).from( "users as people" );
                        }, tablePrefixWithAlias() );
                    } );
                } );

                describe( "aliases", function() {
                    describe( "column aliases", function() {
                        it( "can parse column aliases with AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "id AS user_id" ).from( "users" );
                            }, columnAliasWithAs() );
                        } );

                        it( "can parse column aliases without AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "id user_id" ).from( "users" );
                            }, columnAliasWithoutAs() );
                        } );
                    } );

                    describe( "table aliases", function() {
                        it( "can parse table aliases with AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "*" ).from( "users as people" );
                            }, tableAliasWithAs() );
                        } );

                        it( "can parse table aliases without AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "*" ).from( "users people" );
                            }, tableAliasWithoutAs() );
                        } );
                    } );
                } );

                describe( "wheres", function() {
                    describe( "basic wheres", function() {
                        it( "can add a where statement", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "id", "=", 1 );
                            }, basicWhere() );
                        } );

                        it( "can add a where statement with a query param struct", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where(
                                        "createdDate",
                                        ">=",
                                        { value: "01/01/2019", cfsqltype: "CF_SQL_TIMESTAMP" }
                                    );
                            }, basicWhereWithQueryParamStruct() );
                        } );

                        it( "can add or where statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "id", "=", 1 )
                                    .orWhere( "email", "foo" );
                            }, orWhere() );
                        } );

                        it( "can add and where statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "id", "=", 1 )
                                    .andWhere( "email", "foo" );
                            }, andWhere() );
                        } );

                        it( "can add raw where statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereRaw( "id = ? OR email = ?", [ 1, "foo" ] );
                            }, whereRaw() );
                        } );

                        it( "can add raw or where statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "id", "=", 1 )
                                    .orWhereRaw( "email = ?", [ "foo" ] );
                            }, orWhereRaw() );
                        } );

                        it( "can specify a where between two columns", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereColumn( "first_name", "last_name" );
                            }, whereColumn() );
                        } );

                        it( "can specify an or where between two columns", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereColumn( "first_name", "last_name" )
                                    .orWhereColumn( "updated_date", ">", "created_date" );
                            }, orWhereColumn() );
                        } );

                        it( "can add nested where statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "email", "foo" )
                                    .orWhere( function( q ) {
                                        q.where( "name", "bar" ).where( "age", ">=", "21" );
                                    } );
                            }, whereNested() );
                        } );

                        it( "can have full sub-selects in where statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "email", "foo" )
                                    .orWhere(
                                        "id",
                                        "=",
                                        function( q ) {
                                            q.select( q.raw( "MAX(id)" ) )
                                                .from( "users" )
                                                .where( "email", "bar" );
                                        }
                                    );
                            }, whereSubSelect() );
                        } );

                        it( "can configure a where with a builder instance", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "email", "foo" )
                                    .orWhere(
                                        "id",
                                        "=",
                                        builder
                                            .newQuery()
                                            .select( builder.raw( "MAX(id)" ) )
                                            .from( "users" )
                                            .where( "email", "bar" )
                                    );
                            }, whereBuilderInstance() );
                        } );
                    } );

                    describe( "where exists", function() {
                        it( "can add a where exists clause", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "orders" )
                                    .whereExists( function( q ) {
                                        q.select( q.raw( 1 ) )
                                            .from( "products" )
                                            .whereColumn( "products.id", "orders.id" );
                                    } );
                            }, whereExists() );
                        } );

                        it( "can add an or where exists clause", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "orders" )
                                    .where( "id", 1 )
                                    .orWhereExists( function( q ) {
                                        q.select( q.raw( 1 ) )
                                            .from( "products" )
                                            .whereColumn( "products.id", "orders.id" );
                                    } );
                            }, orWhereExists() );
                        } );

                        it( "can add a where not exists clause", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "orders" )
                                    .whereNotExists( function( q ) {
                                        q.select( q.raw( 1 ) )
                                            .from( "products" )
                                            .whereColumn( "products.id", "orders.id" );
                                    } );
                            }, whereNotExists() );
                        } );

                        it( "can add an or where not exists clause", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "orders" )
                                    .where( "id", 1 )
                                    .orWhereNotExists( function( q ) {
                                        q.select( q.raw( 1 ) )
                                            .from( "products" )
                                            .whereColumn( "products.id", "orders.id" );
                                    } );
                            }, orWhereNotExists() );
                        } );

                        it( "can add a where exists clause using a builder instance", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "orders" )
                                    .whereExists(
                                        builder
                                            .newQuery()
                                            .select( builder.raw( 1 ) )
                                            .from( "products" )
                                            .whereColumn( "products.id", "orders.id" )
                                    );
                            }, whereExistsBuilderInstance() );
                        } );
                    } );

                    describe( "where null", function() {
                        it( "can add where null statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereNull( "id" );
                            }, whereNull() );
                        } );

                        it( "can add or where null statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "id", 1 )
                                    .orWhereNull( "id" );
                            }, orWhereNull() );
                        } );

                        it( "can add where not null statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereNotNull( "id" );
                            }, whereNotNull() );
                        } );

                        it( "can add or where not null statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "id", 1 )
                                    .orWhereNotNull( "id" );
                            }, orWhereNotNull() );
                        } );

                        it( "can add a where null with a subselect", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereNull( function( q ) {
                                        q.selectRaw( "MAX(created_date)" )
                                            .from( "logins" )
                                            .whereColumn( "logins.user_id", "users.id" );
                                    } );
                            }, whereNullSubselect() );
                        } );

                        it( "can add a where null with a builder instance", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereNull(
                                        builder
                                            .newQuery()
                                            .selectRaw( "MAX(created_date)" )
                                            .from( "logins" )
                                            .whereColumn( "logins.user_id", "users.id" )
                                    );
                            }, whereNullSubquery() );
                        } );
                    } );

                    describe( "where between", function() {
                        it( "can add where between statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereBetween( "id", 1, 2 );
                            }, whereBetween() );
                        } );

                        it( "can add where between statements with query param structs", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereBetween(
                                        "createdDate",
                                        { value: "1/1/2019", cfsqltype: "CF_SQL_TIMESTAMP" },
                                        { value: "12/31/2019", cfsqltype: "CF_SQL_TIMESTAMP" }
                                    );
                            }, whereBetweenWithQueryParamStructs() );
                        } );

                        it( "can add where not between statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereNotBetween( "id", 1, 2 );
                            }, whereNotBetween() );
                        } );

                        it( "can add where between statements using closures", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereBetween(
                                        "id",
                                        function( q ) {
                                            q.select( q.raw( "MIN(id)" ) )
                                                .from( "users" )
                                                .where( "email", "bar" );
                                        },
                                        function( q ) {
                                            q.select( q.raw( "MAX(id)" ) )
                                                .from( "users" )
                                                .where( "email", "bar" );
                                        }
                                    );
                            }, whereBetweenClosures() );
                        } );

                        it( "can add where between statements using builder instances", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereBetween(
                                        "id",
                                        builder
                                            .newQuery()
                                            .select( builder.raw( "MIN(id)" ) )
                                            .from( "users" )
                                            .where( "email", "bar" ),
                                        builder
                                            .newQuery()
                                            .select( builder.raw( "MAX(id)" ) )
                                            .from( "users" )
                                            .where( "email", "bar" )
                                    );
                            }, whereBetweenBuilderInstances() );
                        } );

                        it( "can add where between statements using both closures and builder instances", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereBetween(
                                        "id",
                                        function( q ) {
                                            q.select( q.raw( "MIN(id)" ) )
                                                .from( "users" )
                                                .where( "email", "bar" );
                                        },
                                        builder
                                            .newQuery()
                                            .select( builder.raw( "MAX(id)" ) )
                                            .from( "users" )
                                            .where( "email", "bar" )
                                    );
                            }, whereBetweenMixed() );
                        } );
                    } );

                    describe( "where in", function() {
                        it( "can add where in statements from a list", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).whereIn( "id", "1,2,3" );
                            }, whereInList() );
                        } );

                        it( "can add where in statements from an array", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).whereIn( "id", [ 1, 2, 3 ] );
                            }, whereInArray() );
                        } );

                        it( "can add where in statements from an array", function() {
                            testCase( function( builder ) {
                                builder
                                    .from( "users" )
                                    .whereIn( "id", [ 1, { value: 2, cfsqltype: "CF_SQL_INTEGER" }, 3 ] );
                            }, whereInArrayOfQueryParamStructs() );
                        } );

                        it( "can add or where in statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .from( "users" )
                                    .where( "email", "foo" )
                                    .orWhereIn( "id", [ 1, 2, 3 ] );
                            }, orWhereIn() );
                        } );

                        it( "can add raw where in statements", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).whereIn( "id", [ builder.raw( 1 ) ] );
                            }, whereInRaw() );
                        } );

                        it( "correctly handles empty where ins", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).whereIn( "id", [] );
                            }, whereInEmpty() );
                        } );

                        it( "correctly handles empty where not ins", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).whereNotIn( "id", [] );
                            }, whereNotInEmpty() );
                        } );

                        it( "handles sub selects in 'in' statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .from( "users" )
                                    .whereIn( "id", function( q ) {
                                        q.select( "id" )
                                            .from( "users" )
                                            .where( "age", ">", 25 );
                                    } );
                            }, whereInSubselect() );
                        } );

                        it( "handles builder instances in 'in' statements", function() {
                            testCase( function( builder ) {
                                builder
                                    .from( "users" )
                                    .whereIn(
                                        "id",
                                        builder
                                            .newQuery()
                                            .select( "id" )
                                            .from( "users" )
                                            .where( "age", ">", 25 )
                                    );
                            }, whereInBuilderInstance() );
                        } );
                    } );

                    describe( "where like shortcuts", function() {
                        it( "can add like statements using a shortcut method", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).whereLike( "username", "Jo%" );
                            }, whereLike() );
                        } );

                        it( "can add where not like statements using a shortcut method", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).whereNotLike( "username", "Jo%" );
                            }, whereNotLike() );
                        } );
                    } );
                } );

                describe( "joins", function() {
                    it( "can inner join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join(
                                    "contacts",
                                    "users.id",
                                    "=",
                                    "contacts.id"
                                );
                        }, innerJoin() );
                    } );

                    it( "can inner join on table as expression", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join(
                                    builder.raw( "contacts (nolock)" ),
                                    "users.id",
                                    "=",
                                    "contacts.id"
                                );
                        }, innerJoinRaw() );
                    } );

                    it( "can inner join on raw sql", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .joinRaw(
                                    "contacts (nolock)",
                                    "users.id",
                                    "=",
                                    "contacts.id"
                                );
                        }, innerJoinRaw() );
                    } );

                    it( "can inner join using the shorthand", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).join( "contacts", "users.id", "contacts.id" );
                        }, innerJoinShorthand() );
                    } );

                    it( "can specify multiple joins", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", "users.id", "contacts.id" )
                                .join( "addresses AS a", "a.contact_id", "contacts.id" );
                        }, multipleJoins() );
                    } );

                    it( "can join with where bindings instead of columns", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .joinWhere(
                                    "contacts",
                                    "contacts.balance",
                                    "<",
                                    100
                                );
                        }, joinWithWhere() );
                    } );

                    it( "can join with a callback", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" );
                                } );
                        }, innerJoinCallback() );
                    } );

                    it( "can join with a standalone join clause", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( builder.newJoin( "contacts" ).on( "users.id", "=", "contacts.id" ) );
                        }, innerJoinWithJoinInstance() );
                    } );

                    it( "can left join", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).leftJoin( "orders", "users.id", "orders.user_id" );
                        }, leftJoin() );
                    } );

                    it( "can left join on table as expression", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .leftJoin(
                                    builder.raw( "contacts (nolock)" ),
                                    "users.id",
                                    "=",
                                    "contacts.id"
                                );
                        }, leftJoinRaw() );
                    } );

                    it( "can left join on raw sql", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .leftJoinRaw(
                                    "contacts (nolock)",
                                    "users.id",
                                    "=",
                                    "contacts.id"
                                );
                        }, leftJoinRaw() );
                    } );

                    it( "can left join using a nested query", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .leftJoin( "orders", function( j ) {
                                    j.on( "users.id", "=", "orders.user_id" );
                                } );
                        }, leftJoinNested() );
                    } );

                    it( "can right join", function() {
                        testCase( function( builder ) {
                            builder.from( "orders" ).rightJoin( "users", "orders.user_id", "users.id" );
                        }, rightJoin() );
                    } );

                    it( "can right join on table as expression", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .rightJoin(
                                    builder.raw( "contacts (nolock)" ),
                                    "users.id",
                                    "=",
                                    "contacts.id"
                                );
                        }, rightJoinRaw() );
                    } );

                    it( "can right join on raw sql", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .rightJoinRaw(
                                    "contacts (nolock)",
                                    "users.id",
                                    "=",
                                    "contacts.id"
                                );
                        }, rightJoinRaw() );
                    } );

                    it( "can cross join", function() {
                        testCase( function( builder ) {
                            builder.from( "sizes" ).crossJoin( "colors" );
                        }, crossJoin() );
                    } );

                    it( "can cross join on table as expression", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).crossJoin( builder.raw( "contacts (nolock)" ) );
                        }, crossJoinRaw() );
                    } );

                    it( "can cross join on raw sql", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).crossJoinRaw( "contacts (nolock)" );
                        }, crossJoinRaw() );
                    } );

                    it( "can accept a callback for complex joins", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .orOn( "users.name", "=", "contacts.name" )
                                        .orWhere( "users.admin", 1 );
                                } );
                        }, complexJoin() );
                    } );

                    it( "can specify where null in a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).whereNull( "contacts.deleted_date" );
                                } );
                        }, joinWithWhereNull() );
                    } );

                    it( "can specify or where null in a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).orWhereNull( "contacts.deleted_date" );
                                } );
                        }, joinWithOrWhereNull() );
                    } );

                    it( "can specify where not null in a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).whereNotNull( "contacts.deleted_date" );
                                } );
                        }, joinWithWhereNotNull() );
                    } );

                    it( "can specify or where not null in a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).orWhereNotNull( "contacts.deleted_date" );
                                } );
                        }, joinWithOrWhereNotNull() );
                    } );

                    it( "can specify where in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).whereIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithWhereIn() );
                    } );

                    it( "can specify or where in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).orWhereIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithOrWhereIn() );
                    } );

                    it( "can specify where not in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).whereNotIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithWhereNotIn() );
                    } );

                    it( "can specify or where not in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" ).orWhereNotIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithOrWhereNotIn() );
                    } );

                    it( "can inner join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( "id" )
                                .from( "contacts" )
                                .whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .joinSub(
                                    "c",
                                    derivedTable,
                                    "u.id",
                                    "=",
                                    "c.id"
                                );
                        }, joinSub() );
                    } );

                    it( "can inner join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .joinSub(
                                    "c",
                                    function( qb ) {
                                        qb.select( "id" )
                                            .from( "contacts" )
                                            .whereNotIn( "id", [ 1, 2, 3 ] );
                                    },
                                    "u.id",
                                    "=",
                                    "c.id"
                                );
                        }, joinSub() );
                    } );

                    it( "can inner join to a derived table with joinSub using the shorthand", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( "id" )
                                .from( "contacts" )
                                .whereNotIn( "id", [ 1, 2, 3 ] );

                            builder.from( "users as u" ).joinSub( "c", derivedTable, "u.id", "c.id" );
                        }, joinSub() );
                    } );

                    it( "can left join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( "id" )
                                .from( "contacts" )
                                .whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .leftJoinSub(
                                    "c",
                                    derivedTable,
                                    "u.id",
                                    "=",
                                    "c.id"
                                );
                        }, leftJoinSub() );
                    } );

                    it( "can left join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .leftJoinSub(
                                    "c",
                                    function( qb ) {
                                        qb.select( "id" )
                                            .from( "contacts" )
                                            .whereNotIn( "id", [ 1, 2, 3 ] );
                                    },
                                    "u.id",
                                    "=",
                                    "c.id"
                                );
                        }, leftJoinSub() );
                    } );

                    it( "can left join to a derived table with joinSub using the shorthand", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( "id" )
                                .from( "contacts" )
                                .whereNotIn( "id", [ 1, 2, 3 ] );

                            builder.from( "users as u" ).leftJoinSub( "c", derivedTable, "u.id", "c.id" );
                        }, leftJoinSub() );
                    } );

                    it( "can right join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( "id" )
                                .from( "contacts" )
                                .whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .rightJoinSub(
                                    "c",
                                    derivedTable,
                                    "u.id",
                                    "=",
                                    "c.id"
                                );
                        }, rightJoinSub() );
                    } );

                    it( "can right join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .rightJoinSub(
                                    "c",
                                    function( qb ) {
                                        qb.select( "id" )
                                            .from( "contacts" )
                                            .whereNotIn( "id", [ 1, 2, 3 ] );
                                    },
                                    "u.id",
                                    "=",
                                    "c.id"
                                );
                        }, rightJoinSub() );
                    } );

                    it( "can right join to a derived table with joinSub using the shorthand", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( "id" )
                                .from( "contacts" )
                                .whereNotIn( "id", [ 1, 2, 3 ] );

                            builder.from( "users as u" ).rightJoinSub( "c", derivedTable, "u.id", "c.id" );
                        }, rightJoinSub() );
                    } );

                    it( "can cross join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( "id" )
                                .from( "contacts" )
                                .whereNotIn( "id", [ 1, 2, 3 ] );

                            builder.from( "users as u" ).crossJoinSub( "c", derivedTable );
                        }, crossJoinSub() );
                    } );

                    it( "can cross join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .crossJoinSub( "c", function( qb ) {
                                    qb.select( "id" )
                                        .from( "contacts" )
                                        .whereNotIn( "id", [ 1, 2, 3 ] );
                                } );
                        }, crossJoinSub() );
                    } );
                } );

                describe( "group bys", function() {
                    it( "can add a simple group by", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "*" )
                                .from( "users" )
                                .groupBy( "email" );
                        }, groupBy() );
                    } );

                    it( "can group by multiple fields using an array", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).groupBy( [ "id", "email" ] );
                        }, groupByArray() );
                    } );

                    it( "can group by multiple fields using raw sql", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).groupBy( builder.raw( "DATE(created_at)" ) );
                        }, groupByRaw() );
                    } );
                } );

                describe( "havings", function() {
                    it( "can add a basic having clause", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).having( "email", ">", 1 );
                        }, havingBasic() );
                    } );

                    it( "can add a having clause with a raw column", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .groupBy( "email" )
                                .having( builder.raw( "COUNT(email)" ), ">", 1 );
                        }, havingRawColumn() );
                    } );

                    it( "can use a raw expression as the entire having clause", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .groupBy( "email" )
                                .having( builder.raw( "COUNT(email) > ?", [ 1 ] ) );
                        }, havingRawExpression() );
                    } );

                    it( "can use a havingRaw shortcut method", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .groupBy( "email" )
                                .havingRaw( "COUNT(email) > ?", [ 1 ] );
                        }, havingRawExpression() );
                    } );

                    it( "can add a having clause with a raw column that contains bindings", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .groupBy( "email" )
                                .having(
                                    builder.raw( "CASE WHEN active = ? THEN COUNT(email) ELSE 0 END", [ 1 ] ),
                                    ">",
                                    2
                                );
                        }, havingRawColumnWithBindings() );
                    } );

                    it( "can add a having clause with a raw value", function() {
                        testCase( function( builder ) {
                            builder
                                .select( builder.raw( "COUNT(*) AS ""total""" ) )
                                .from( "items" )
                                .where( "department", "=", "popular" )
                                .groupBy( "category" )
                                .having( "total", ">", builder.raw( 3 ) );
                        }, havingRawValue() );
                    } );
                } );

                describe( "order bys", function() {
                    it( "can add a simple order by", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderBy( "email" );
                        }, orderBy() );
                    } );

                    it( "can add a simple order by using the asc shortcut method", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderByAsc( "email" );
                        }, orderBy() );
                    } );

                    it( "can order in descending order", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderBy( "email", "desc" );
                        }, orderByDesc() );
                    } );

                    it( "can order in descending order using the desc shortcut method", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderByDesc( "email" );
                        }, orderByDesc() );
                    } );

                    it( "combines all order by calls", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy( "id" )
                                .orderBy( "email", "desc" );
                        }, combinesOrderBy() );
                    } );

                    it( "can order by a raw expression", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderBy( builder.raw( "DATE(created_at)" ) );
                        }, orderByRaw() );
                    } );

                    it( "has an orderByRaw shortcut method", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderByRaw( "DATE(created_at)" );
                        }, orderByRaw() );
                    } );

                    it( "can accept bindings in orderByRaw", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderByRaw( "CASE WHEN id = ? THEN 1 ELSE 0 END DESC", [ 1 ] );
                        }, orderByRawWithBindings() );
                    } );

                    it( "can accept bindings in a raw expression in orderBy", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy( builder.raw( "CASE WHEN id = ? THEN 1 ELSE 0 END DESC", [ 1 ] ) );
                        }, orderByWithRawBindings() );
                    } );

                    it( "can order by a subselect", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy( function( q ) {
                                    q.selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" );
                                } );
                        }, orderBySubselect() );
                    } );

                    it( "can order by a subselect using the asc shortcut method", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderByAsc( function( q ) {
                                    q.selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" );
                                } );
                        }, orderBySubselect() );
                    } );

                    it( "can order by a subselect descending", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy( function( q ) {
                                    q.selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" );
                                }, "desc" );
                        }, orderBySubselectDescending() );
                    } );

                    it( "can order by a subselect descending using the desc shortcut method", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderByDesc( function( q ) {
                                    q.selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" );
                                } );
                        }, orderBySubselectDescending() );
                    } );

                    it( "can order by a builder instance", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy(
                                    builder
                                        .newQuery()
                                        .selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" )
                                );
                        }, orderByBuilderInstance() );
                    } );

                    it( "can order by a builder instance using the asc shortcut method", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderByAsc(
                                    builder
                                        .newQuery()
                                        .selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" )
                                );
                        }, orderByBuilderInstance() );
                    } );

                    it( "can order by a builder instance descending", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy(
                                    builder
                                        .newQuery()
                                        .selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" ),
                                    "desc"
                                );
                        }, orderByBuilderInstanceDescending() );
                    } );

                    it( "can order by a builder instance descending using the desc shortcut method", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderByDesc(
                                    builder
                                        .newQuery()
                                        .selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" )
                                );
                        }, orderByBuilderInstanceDescending() );
                    } );

                    it( "can order by a builder instance with bindings", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy(
                                    builder
                                        .newQuery()
                                        .selectRaw( "MAX(created_date)" )
                                        .from( "logins" )
                                        .whereColumn( "users.id", "logins.user_id" )
                                        .where( "created_date", ">", "2020-01-01 00:00:00" )
                                );
                        }, orderByBuilderWithBindings() );
                    } );

                    describe( "can accept an array for the column argument", function() {
                        describe( "with the array values", function() {
                            it( "as simple strings", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( [ "last_name", "age", "favorite_color" ] );
                                }, orderByArray() );
                            } );

                            it( "can clear already configured orders", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [ "last_name", "age", "favorite_color" ] )
                                        .clearOrders();
                                }, orderByClearOrders() );
                            } );

                            it( "can reorder a query", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [ "last_name", "favorite_color" ] )
                                        .reorder( "age" );
                                }, reorder() );
                            } );

                            it( "as pipe delimited strings", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [ "last_name|desc", "age|asc", "favorite_color|desc" ] );
                                }, orderByPipeDelimited() );
                            } );

                            it( "as a nested positional array", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [ [ "last_name", "desc" ], [ "age", "asc" ], [ "favorite_color" ] ] );
                                }, orderByArrayOfArrays() );
                            } );

                            it( "as a nested positional array with leniency for arrays of length 1 or longer than 2 which assumes position 1 is column name and position 2 is the direction and ignores other entries in the nested array", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            [ "last_name", "desc" ],
                                            [ "age", "asc" ],
                                            [ "favorite_color" ],
                                            [
                                                "height",
                                                "asc",
                                                "will",
                                                "be",
                                                "ignored"
                                            ]
                                        ] );
                                }, orderByArrayOfArraysIgnoringExtraValues() );
                            } );

                            it( "as a any combo of values and ignores then inherits the direction's argument value if an invalid direction is supplied (anything other than (asc|desc)", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            [ "last_name", "desc" ],
                                            [ "age", "forward" ],
                                            "favorite_color|backward",
                                            "favorite_food|desc",
                                            { column: "height", direction: "tallest" },
                                            { column: "weight", direction: "desc" },
                                            builder.raw( "DATE(created_at)" ),
                                            { column: builder.raw( "DATE(modified_at)" ), direction: "desc" } // desc will be ignored in this case because it's an expression
                                        ] );
                                }, orderByComplex() );
                            } );

                            it( "as raw expressions", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            builder.raw( "DATE(created_at)" ),
                                            { column: builder.raw( "DATE(modified_at)" ) }
                                        ] );
                                }, orderByRawInStruct() );
                            } );

                            it( "as simple strings OR pipe delimited strings intermingled", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( [ "last_name", "age|desc", "favorite_color" ] );
                                }, orderByMixSimpleAndPipeDelimited() );
                            } );

                            it( "can accept a struct with a column key and optionally the direction key", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy(
                                            [
                                                { column: "last_name" },
                                                { column: "age", direction: "asc" },
                                                { column: "favorite_color", direction: "desc" }
                                            ],
                                            "desc"
                                        );
                                }, orderByStruct() );
                            } );

                            it( "as values that when additional orderBy() calls are chained the chained calls preserve the order of the calls", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( "last_name,age desc" )
                                        .orderBy( "favorite_color desc" )
                                        .orderBy(
                                            column = [ { column: "height" }, { column: "weight", direction: "asc" } ],
                                            direction = "desc"
                                        )
                                        .orderBy( column = "eye_color", direction = "desc" )
                                        .orderBy( [
                                            { column: "is_athletic", direction: "desc", extraKey: "ignored" },
                                            builder.raw( "DATE(created_at)" )
                                        ] )
                                        .orderBy( builder.raw( "DATE(modified_at)" ) );
                                }, multipleOrderByCalls() );
                            } );

                            it( "as any combo of any valid values intermingled", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            "last_name",
                                            "age|desc",
                                            [ "eye_color", "desc" ],
                                            [ "hair_color" ],
                                            { column: "is_musical" },
                                            { column: "is_athletic", direction: "desc", extraKey: "ignored" },
                                            builder.raw( "DATE(created_at)" ),
                                            { column: builder.raw( "DATE(modified_at)" ), direction: "desc" } // direction is ignored because it should be RAW
                                        ] );
                                }, orderByMixed() );
                            } );
                        } );
                    } );

                    describe( "can accept a comma delimited list for the column argument", function() {
                        describe( "with the list values", function() {
                            it( "as simple column names that inherit the default direction", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( "last_name,age,favorite_color" );
                                }, orderByList() );
                            } );

                            it( "as simple column names while inheriting the direction argument's supplied value", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( "last_name,age,favorite_color", "desc" );
                                }, orderByListDefaultDirection() );
                            } );

                            it( "as column names with secondary piped delimited value representing the direction for each column", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( "last_name|desc,age|desc,favorite_color|asc" );
                                }, orderByListPipeDelimited() );
                            } );

                            it( "as column names with optional secondary piped delimited value representing the direction for that column and inherits the direction argument's value when supplied", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( "last_name|asc,age,favorite_color|asc", "desc" );
                                }, orderByListPipeDelimitedWithDefaultDirection() );
                            } );
                        } );
                    } );
                } );

                describe( "unions", function() {
                    it( "can union multiple statements using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 )
                                    ;
                                } )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 3 )
                                    ;
                                } )
                            ;
                        }, union() );
                    } );

                    it( "can union multiple statements using a QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var union2 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 2 );
                            var union3 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 3 );

                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( union2 )
                                .union( union3 )
                            ;
                        }, union() );
                    } );

                    it( "union can contain order by on main query only", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 )
                                    ;
                                } )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 3 )
                                    ;
                                } )
                                .orderBy( "name" )
                            ;
                        }, unionOrderBy() );
                    } );

                    it( "union query cannot contain orderBy", function() {
                        var builder = getBuilder();

                        builder
                            .select( "name" )
                            .from( "users" )
                            .where( "id", 1 )
                            .union( function( q ) {
                                q.select( "name" )
                                    .from( "users" )
                                    .where( "id", 2 )
                                    .orderBy( "name" )
                                ;
                            } )
                            .union( function( q ) {
                                q.select( "name" )
                                    .from( "users" )
                                    .where( "id", 3 )
                                ;
                            } )
                            .orderBy( "name" )
                        ;


                        try {
                            var statements = builder.toSql();
                        } catch ( any e ) {
                            // Darn ACF nests the exception message. ðŸ˜ 
                            if ( e.message == "An exception occurred while calling the function map." ) {
                                expect( e.detail ).toBe( "The ORDER BY clause is not allowed in a UNION statement." );
                            } else {
                                expect( e.message ).toBe( "The ORDER BY clause is not allowed in a UNION statement." );
                            }
                            return;
                        }
                        fail( "Should have caught an exception, but didn't." );
                    } );

                    it( "can union all multiple statements using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .unionAll( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 )
                                    ;
                                } )
                                .unionAll( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 3 )
                                    ;
                                } )
                            ;
                        }, unionAll() );
                    } );

                    it( "can union all multiple statements using a QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var union2 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 2 );
                            var union3 = getBuilder()
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 3 );

                            builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .unionAll( union2 )
                                .unionAll( union3 )
                            ;
                        }, unionAll() );
                    } );

                    it( "can run an aggregate query like count on a union query", function() {
                        testCase( function( builder ) {
                            return builder
                                .select( "name" )
                                .from( "users" )
                                .where( "id", 1 )
                                .union( function( q ) {
                                    q.select( "name" )
                                        .from( "users" )
                                        .where( "id", 2 )
                                    ;
                                } )
                                .count( toSQL = true )
                            ;
                        }, unionCount() );
                    } );
                } );

                describe( "common table expressions (i.e. CTEs)", function() {
                    it( "can create CTE from closure", function() {
                        testCase( function( builder ) {
                            builder
                                .with( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "can create CTE from QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var cte = getBuilder()
                                .select( "*" )
                                .from( "users" )
                                .join( "contacts", "users.id", "contacts.id" )
                                .where( "users.age", ">", 25 )
                            ;

                            builder
                                .with( "UsersCTE", cte )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "can correctly bind parameters regardless of order", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                                .with( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "can create recursive CTE", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpressionWithRecursive() );
                    } );

                    it( "properly handles recursive CTEs with included columns", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive(
                                    "UsersCTE",
                                    function( q ) {
                                        q.select( [ "users.id AS usersId", "contacts.id AS contactsId" ] )
                                            .from( "users" )
                                            .join( "contacts", "users.id", "contacts.id" )
                                            .where( "users.age", ">", 25 )
                                        ;
                                    },
                                    [ "usersId", "contactsId" ]
                                )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpressionWithRecursiveWithColumns() );
                    } );

                    it( "can create multiple CTEs where the second CTE is not recursive", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                                .with( "OrderCTE", function( q ) {
                                    q.from( "orders" ).where( "created", ">", "2018-04-30" )
                                    ;
                                } )
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                            ;
                        }, commonTableExpressionMultipleCTEsWithRecursive() );
                    } );

                    it( "can create bindings in the correct order", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "UsersCTE" )
                                .whereNotIn( "user.id", [ 1, 2 ] )
                                .with( "OrderCTE", function( q ) {
                                    q.from( "orders" ).where( "created", ">", "2018-04-30" )
                                    ;
                                } )
                                .withRecursive( "UsersCTE", function( q ) {
                                    q.select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                } )
                            ;
                        }, commonTableExpressionBindingOrder() );
                    } );
                } );

                describe( "limits", function() {
                    it( "can limit the record set returned", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).limit( 3 );
                        }, limit() );
                    } );

                    it( "has an alias of ""take""", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).take( 1 );
                        }, take() );
                    } );
                } );

                describe( "offsets", function() {
                    it( "can offset the record set returned", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).offset( 3 );
                        }, offset() );
                    } );

                    it( "can offset with an order by", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .orderBy( "id" )
                                .offset( 3 );
                        }, offsetWithOrderBy() );
                    } );
                } );

                describe( "forPage", function() {
                    it( "combines limits and offsets for easy pagination", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).forPage( 3, 15 );
                        }, forPage() );
                    } );

                    it( "returns zeros values less than zero", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).forPage( 0, -2 );
                        }, forPageWithLessThanZeroValues() );
                    } );
                } );

                describe( "reset", function() {
                    it( "can reset the query to default values", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .where( "active", 1 )
                                .orderByAsc( "createdDate" )
                                .forPage( 3, 15 )
                                .reset()
                                .from( "otherTable" );
                        }, reset() );
                    } );
                } );
            } );

            describe( "insert statements", function() {
                it( "can insert a struct of data into a table", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).insert( values = { "email": "foo" }, toSql = true );
                    }, insertSingleColumn() );
                } );

                it( "can insert a struct of data with multiple columns into a table", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insert( values = { "email": "foo", "name": "bar" }, toSql = true );
                    }, insertMultipleColumns() );
                } );

                it( "can batch insert multiple records", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insert(
                                values = [ { "email": "foo", "name": "bar" }, { "email": "baz", "name": "bleh" } ],
                                toSql = true
                            );
                    }, batchInsert() );
                } );

                it( "can insert with returning", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .returning( "id" )
                            .insert( values = { "email": "foo", "name": "bar" }, toSql = true );
                    }, returning() );
                } );

                it( "returning ignores table qualifiers", function() {
                    testCase( function( builder ) {
                        return builder
                            .setColumnFormatter( function( column ) {
                                return "tablePrefix." & column;
                            } )
                            .from( "users" )
                            .returning( "id" )
                            .insert( values = { "email": "foo", "name": "bar" }, toSql = true );
                    }, returningIgnoresTableQualifiers() );
                } );

                it( "can insert with raw values", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insert(
                                values = { "email": "john@example.com", "created_date": builder.raw( "now()" ) },
                                toSql = true
                            );
                    }, insertWithRaw() );
                } );

                it( "can insert with null values", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insert(
                                values = { "email": "john@example.com", "optional_field": javacast( "null", "" ) },
                                toSql = true
                            );
                    }, insertWithNull() );
                } );

                it( "can insert using a select statement and a callback", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insertUsing(
                                columns = [ "email", "createdDate" ], // purposefully not in alphabetical order
                                source = function( q ) {
                                    q.from( "activeDirectoryUsers" )
                                        .select( [ "email", "createdDate" ] )
                                        .where( "active", 1 );
                                },
                                toSql = true
                            );
                    }, insertUsingSelectCallback() );
                } );

                it( "can insert using a select statement and a builder object", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insertUsing(
                                columns = [ "email", "createdDate" ], // purposefully not in alphabetical order
                                source = builder
                                    .newQuery()
                                    .from( "activeDirectoryUsers" )
                                    .select( [ "email", "createdDate" ] )
                                    .where( "active", 1 ),
                                toSql = true
                            );
                    }, insertUsingSelectBuilder() );
                } );

                it( "can derive the columns to insert from the source query", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insertUsing(
                                source = function( q ) {
                                    q.from( "activeDirectoryUsers" )
                                        .select( [ "email", "modifiedDate AS createdDate" ] )
                                        .where( "active", 1 );
                                },
                                toSql = true
                            );
                    }, insertUsingDerivingColumnNames() );
                } );

                it( "can guess column names from raw statements in an insert using query", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insertUsing(
                                source = function( q ) {
                                    q.from( "activeDirectoryUsers" )
                                        .select( "email" )
                                        .selectRaw( "COALESCE(modifiedDate, NOW()) AS createdDate" )
                                        .where( "active", 1 );
                                },
                                toSql = true
                            );
                    }, insertUsingDerivedColumnNamesFromRawStatements() );
                } );

                it( "can insert ignoring conflicts", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .insertIgnore(
                                values = [ { "email": "foo", "name": "bar" }, { "email": "baz", "name": "bleh" } ],
                                target = [ "email" ],
                                toSql = true
                            );
                    }, insertIgnore() );
                } );
            } );

            describe( "update statements", function() {
                it( "can update all records in a table", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .update( values = { "email": "foo", "name": "bar" }, toSql = true );
                    }, updateAllRecords() );
                } );

                it( "can be constrained by a where statement", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereId( 1 )
                            .update( values = { "email": "foo", "name": "bar" }, toSql = true );
                    }, updateWithWhere() );
                } );

                it( "can use an expression in an update", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "hits" )
                            .where( "page", "someUrl" )
                            .update( values = { "count": builder.raw( "count + 1" ) }, toSql = true );
                    }, updateWithRaw() );
                } );

                it( "can add incrementally with addUpdate", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereId( 1 )
                            .addUpdate( { "email": "foo", "name": "bar" } )
                            .when( true, function( q ) {
                                q.addUpdate( { "foo": "yes" } );
                            } )
                            .when( false, function( q ) {
                                q.addUpdate( { "bar": "no" } );
                            } )
                            .update( toSql = true );
                    }, addUpdate() );
                } );

                it( "can update with a join", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "employees" )
                            .join( "departments", "departments.id", "employees.departmentId" )
                            .update(
                                values = { "employees.departmentName": builder.raw( "departments.name" ) },
                                toSql = true
                            );
                    }, updateWithJoin() );
                } );

                it( "can update with a join using aliases", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "employees e" )
                            .join( "departments d", "d.id", "e.departmentId" )
                            .update( values = { "departmentName": builder.raw( "d.name" ) }, toSql = true );
                    }, updateWithJoinAndAliases() );
                } );

                it( "can update with a join and a where", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "employees" )
                            .join( "departments", "departments.id", "employees.departmentId" )
                            .where( "departments.active", 1 )
                            .update(
                                values = { "employees.departmentName": builder.raw( "departments.name" ) },
                                toSql = true
                            );
                    }, updateWithJoinAndWhere() );
                } );

                it( "turns a function into a subselect", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "employees" )
                            .update(
                                values = {
                                    "departmentName": function( qb ) {
                                        qb.from( "departments" )
                                            .select( "name" )
                                            .whereColumn( "employees.departmentId", "departments.id" );
                                    }
                                },
                                toSql = true
                            );
                    }, updateWithSubselect() );
                } );

                it( "turns a builder instance into a subselect", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "employees" )
                            .update(
                                values = {
                                    "departmentName": builder
                                        .newQuery()
                                        .from( "departments" )
                                        .select( "name" )
                                        .whereColumn( "employees.departmentId", "departments.id" )
                                },
                                toSql = true
                            );
                    }, updateWithBuilder() );
                } );
            } );

            describe( "updateOrInsert statements", function() {
                it( "inserts a new record when the where clause does not bring back any records", function() {
                    testCase( function( builder ) {
                        grammar.$( "runQuery", queryNew( "aggregate", "varchar", [ { "aggregate": 0 } ] ) );
                        return builder
                            .from( "users" )
                            .where( "email", "foo" )
                            .updateOrInsert( values = { "name": "baz" }, toSql = true );
                    }, updateOrInsertNotExists() );
                } );

                it( "updates an existing record when the where clause brings back at least one record", function() {
                    testCase( function( builder ) {
                        grammar.$( "runQuery", queryNew( "aggregate", "varchar", [ { "aggregate": 5 } ] ) );
                        return builder
                            .from( "users" )
                            .where( "email", "foo" )
                            .updateOrInsert( values = { "name": "baz" }, toSql = true );
                    }, updateOrInsertExists() );
                } );
            } );

            describe( "upsert statements", function() {
                it( "can perform an upsert", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "users" )
                            .upsert(
                                values = {
                                    "username": "foo",
                                    "active": 1,
                                    "createdDate": "2021-09-08 12:00:00",
                                    "modifiedDate": "2021-09-08 12:00:00"
                                },
                                target = [ "username" ],
                                update = [ "active", "modifiedDate" ],
                                toSql = true
                            );
                    }, upsert() );
                } );

                it( "updates all values if none are passed to update", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "users" )
                            .upsert(
                                values = {
                                    "username": "foo",
                                    "active": 1,
                                    "createdDate": "2021-09-08 12:00:00",
                                    "modifiedDate": "2021-09-08 12:00:00"
                                },
                                target = [ "username" ],
                                toSql = true
                            );
                    }, upsertAllValues() );
                } );

                it( "just performs an insert when given an empty struct or array to update", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "users" )
                            .upsert(
                                values = {
                                    "username": "foo",
                                    "active": 1,
                                    "createdDate": "2021-09-08 12:00:00",
                                    "modifiedDate": "2021-09-08 12:00:00"
                                },
                                target = [ "username" ],
                                update = [],
                                toSql = true
                            );
                    }, upsertEmptyUpdate() );
                } );

                it( "can specify specific update values", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "stats" )
                            .upsert(
                                values = [
                                    { "postId": 1, "viewedDate": "2021-09-08", "views": 1 },
                                    { "postId": 2, "viewedDate": "2021-09-08", "views": 1 }
                                ],
                                target = [ "postId", "viewedDate" ],
                                update = { "views": builder.raw( "stats.views + 1" ) },
                                toSql = true
                            );
                    }, upsertWithInsertedValue() );
                } );

                it( "can match the target as a single value", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "users" )
                            .upsert(
                                values = {
                                    "username": "foo",
                                    "active": 1,
                                    "createdDate": "2021-09-08 12:00:00",
                                    "modifiedDate": "2021-09-08 12:00:00"
                                },
                                target = "username",
                                update = [ "active", "modifiedDate" ],
                                toSql = true
                            );
                    }, upsertSingleTarget() );
                } );

                it( "can perform an upsert with a closure as the source", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "users" )
                            .upsert(
                                source = function( q ) {
                                    q.from( "activeDirectoryUsers" )
                                        .select( [
                                            "username",
                                            "active",
                                            "createdDate",
                                            "modifiedDate"
                                        ] )
                                        .where( "active", 1 );
                                },
                                values = [
                                    "username",
                                    "active",
                                    "createdDate",
                                    "modifiedDate"
                                ],
                                target = [ "username" ],
                                update = [ "active", "modifiedDate" ],
                                toSql = true
                            );
                    }, upsertFromClosure() );
                } );

                it( "can perform an upsert with a builder object as the source", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "users" )
                            .upsert(
                                source = builder
                                    .newQuery()
                                    .from( "activeDirectoryUsers" )
                                    .select( [
                                        "username",
                                        "active",
                                        "createdDate",
                                        "modifiedDate"
                                    ] )
                                    .where( "active", 1 ),
                                values = [
                                    "username",
                                    "active",
                                    "createdDate",
                                    "modifiedDate"
                                ],
                                target = [ "username" ],
                                update = [ "active", "modifiedDate" ],
                                toSql = true
                            );
                    }, upsertFromBuilder() );
                } );

                it( "can delete unmatched source rows in an upsert (SQL Server)", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "users" )
                            .upsert(
                                source = function( q ) {
                                    q.from( "activeDirectoryUsers" )
                                        .select( [
                                            "username",
                                            "active",
                                            "createdDate",
                                            "modifiedDate"
                                        ] )
                                        .where( "active", 1 );
                                },
                                values = [
                                    "username",
                                    "active",
                                    "createdDate",
                                    "modifiedDate"
                                ],
                                target = [ "username" ],
                                update = [ "active", "modifiedDate" ],
                                deleteUnmatched = true,
                                toSql = true
                            );
                    }, upsertWithDelete() );
                } );
            } );

            describe( "delete statements", function() {
                it( "can delete an entire table", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).delete( toSql = true );
                    }, deleteAll() );
                } );

                it( "can delete a specific id quickly", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).delete( id = 1, toSql = true );
                    }, deleteById() );
                } );

                it( "can be constrained with a where statement", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .where( "email", "foo" )
                            .delete( toSql = true );
                    }, deleteWhere() );
                } );
            } );
        } );
    }

    private function testCase( callback, expected ) {
        try {
            var builder = getBuilder();
            var sql = callback( builder );
            if ( !isNull( sql ) ) {
                if ( !isSimpleValue( sql ) ) {
                    sql = sql.toSQL();
                }
            } else {
                sql = builder.toSQL();
            }
            if ( isSimpleValue( expected ) ) {
                expected = { sql: expected, bindings: [] };
            }
            expect( sql ).toBeWithCase( expected.sql );
            expect( getTestBindings( builder ) ).toBe( expected.bindings );
        } catch ( any e ) {
            if ( !isSimpleValue( expected ) && structKeyExists( expected, "exception" ) ) {
                expect( e.type ).toBe( expected.exception );
                return;
            }
            rethrow;
        }
    }

    private function getBuilder() {
        throw( "Must be implemented in a subclass" );
    }

    private array function getTestBindings( builder ) {
        return builder
            .getBindings()
            .map( function( binding ) {
                if ( builder.getUtils().isExpression( binding ) ) {
                    return binding.getSQL();
                } else {
                    if ( binding.null ) {
                        return "NULL";
                    } else {
                        return binding.value;
                    }
                }
            } );
    }

}
