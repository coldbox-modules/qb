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

                    it( "can select multiple columns using variadic parameters", function() {
                        testCase( function( builder ) {
                            builder.select( "id", "name" ).from( "users" );
                        }, selectMultipleVariadic() );
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
                            builder.distinct().select( "foo", "bar" ).from( "users" );
                        }, selectDistinct() );
                    } );

                    it( "can parse column aliases", function() {
                        testCase( function( builder ) {
                            builder.select( "foo as bar" ).from( "users" );
                        }, parseColumnAlias() );
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
                } );

                describe( "sub-selects", function() {
                    it( "can execute sub-selects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect( "latestUpdatedDate", function( q ) {
                                    return q.from( "posts" )
                                        .selectRaw( "MAX(updated_date)" )
                                        .whereColumn( "posts.user_id", "users.id" );
                                } );
                        }, subSelect() );
                    } );

                    it( "can execute sub-selects with bindings", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( "name" )
                                .subSelect( "latestUpdatedDate", function( q ) {
                                    return q.from( "posts" )
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
                            builder.from( builder.raw("Test (nolock)") );
                        }, fromRaw() );
                    } );

                    it( "can use `table` as an alias for from", function() {
                        testCase( function( builder ) {
                            builder.table( "users" );
                        }, table() );
                    } );

                    it( "can specify a Expression object as the input for table", function() {
                        testCase( function( builder ) {
                            builder.table( builder.raw("Test (nolock)") );
                        }, fromRaw() );
                    } );

                    it( "can specify the table to select from as a string using fromRaw", function() {
                        testCase( function( builder ) {
                            builder.fromRaw( "Test (nolock)" );
                        }, fromRaw() );
                    } );

                    it( "can add bindings to fromRaw", function() {
                        testCase( function( builder ) {
                            builder.fromRaw( "Test (nolock)", [1, 2, 3] );
                        }, {sql: fromRaw(), bindings: [1, 2, 3]} );
                    } );

                    it( "can specify the table using fromSub as QueryBuilder", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id", "name").from("users").where( "age", ">=", "21" );

                            builder.fromSub( "u", derivedTable );
                        }, fromDerivedTable() );
                    } );

                    it( "can specify the table using fromSub as a closure", function() {
                        testCase( function( builder ) {
                            builder.fromSub( "u", function (q){
                                q.select("id", "name").from("users").where( "age", ">=", "21" );
                            } );
                        }, fromDerivedTable() );
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
                                builder.select( "*" ).from( "users" ).where( "id", "=", 1 );
                            }, basicWhere() );
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
                                builder.select( "*" ).from( "users" ).whereRaw( "id = ? OR email = ?", [ 1, "foo" ] );
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
                                    .orWhere( "id", "=", function( q ) {
                                        q.select( q.raw( "MAX(id)" ) )
                                            .from( "users" )
                                            .where( "email", "bar" );
                                    } );
                            }, whereSubSelect() );
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
                                            .where( "products.id", "=", q.raw( "orders.id" ) );
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
                                            .where( "products.id", "=", q.raw( "orders.id" ) );
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
                                            .where( "products.id", "=", q.raw( "orders.id" ) );
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
                                            .where( "products.id", "=", q.raw( "orders.id" ) );
                                    } );
                            }, orWhereNotExists() );
                        } );
                    } );

                    describe( "where null", function() {
                        it( "can add where null statements", function() {
                            testCase( function( builder ) {
                                builder.select( "*" ).from( "users" ).whereNull( "id" );
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
                                builder.select( "*" ).from( "users" ).whereNotNull( "id" );
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
                    } );

                    describe( "where between", function() {
                        it( "can add where between statements", function() {
                            testCase( function( builder ) {
                                builder.select( "*" ).from( "users" ).whereBetween( "id", 1, 2 );
                            }, whereBetween() );
                        } );

                        it( "can add where not between statements", function() {
                            testCase( function( builder ) {
                                builder.select( "*" ).from( "users" ).whereNotBetween( "id", 1, 2 );
                            }, whereNotBetween() );
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

                        it( "can add or where in statements", function() {
                            testCase( function( builder ) {
                                builder.from( "users" ).where( "email", "foo" ).orWhereIn( "id", [ 1, 2, 3 ] );
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
                                builder.from( "users" ).whereIn( "id", function( q ) {
                                    q.select( "id" ).from( "users" ).where( "age", ">", 25 );
                                } );
                            }, whereInSubselect() );
                        } );
                    } );
                } );

                describe( "joins", function() {
                    it( "can inner join", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).join( "contacts", "users.id", "=", "contacts.id" );
                        }, innerJoin() );
                    } );

                    it( "can inner join on table as expression", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).join( builder.raw("contacts (nolock)"), "users.id", "=", "contacts.id" );
                        }, innerJoinRaw() );
                    } );

                    it( "can inner join on raw sql", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).joinRaw( "contacts (nolock)", "users.id", "=", "contacts.id" );
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
                            builder.from( "users" ).joinWhere( "contacts", "contacts.balance", "<", 100 );
                        }, joinWithWhere() );
                    } );

                    it( "can left join", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).leftJoin( "orders", "users.id", "orders.user_id" );
                        }, leftJoin() );
                    } );

                    it( "can left join on table as expression", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).leftJoin( builder.raw("contacts (nolock)"), "users.id", "=", "contacts.id" );
                        }, leftJoinRaw() );
                    } );

                    it( "can left join on raw sql", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).leftJoinRaw( "contacts (nolock)", "users.id", "=", "contacts.id" );
                        }, leftJoinRaw() );
                    } );

                    it( "can right join", function() {
                        testCase( function( builder ) {
                            builder.from( "orders" ).rightJoin( "users", "orders.user_id", "users.id" );
                        }, rightJoin() );
                    } );

                    it( "can right join on table as expression", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).rightJoin( builder.raw("contacts (nolock)"), "users.id", "=", "contacts.id" );
                        }, rightJoinRaw() );
                    } );

                    it( "can right join on raw sql", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).rightJoinRaw( "contacts (nolock)", "users.id", "=", "contacts.id" );
                        }, rightJoinRaw() );
                    } );

                    it( "can cross join", function() {
                        testCase( function( builder ) {
                            builder.from( "sizes" ).crossJoin( "colors" );
                        }, crossJoin() );
                    } );

                    it( "can cross join on table as expression", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).crossJoin( builder.raw("contacts (nolock)") );
                        }, crossJoinRaw() );
                    } );

                    it( "can cross join on raw sql", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).crossJoinRaw( "contacts (nolock)");
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
                                    j.on( "users.id", "=", "contacts.id" )
                                        .whereNull( "contacts.deleted_date" );
                                } );
                        }, joinWithWhereNull() );
                    } );

                    it( "can specify or where null in a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .orWhereNull( "contacts.deleted_date" );
                                } );
                        }, joinWithOrWhereNull() );
                    } );

                    it( "can specify where not null in a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .whereNotNull( "contacts.deleted_date" );
                                } );
                        }, joinWithWhereNotNull() );
                    } );

                    it( "can specify or where not null in a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .orWhereNotNull( "contacts.deleted_date" );
                                } );
                        }, joinWithOrWhereNotNull() );
                    } );

                    it( "can specify where in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .whereIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithWhereIn() );
                    } );

                    it( "can specify or where in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .orWhereIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithOrWhereIn() );
                    } );

                    it( "can specify where not in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .whereNotIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithWhereNotIn() );
                    } );

                    it( "can specify or where not in inside a join", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .join( "contacts", function( j ) {
                                    j.on( "users.id", "=", "contacts.id" )
                                        .orWhereNotIn( "contacts.id", [ 1, 2, 3 ] );
                                } );
                        }, joinWithOrWhereNotIn() );
                    } );

                    it( "can inner join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .joinSub( "c", derivedTable, "u.id", "=", "c.id");
                        }, joinSub() );
                    } );

                    it( "can inner join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .joinSub( "c", function (qb){
                                    qb.select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );
                                }, "u.id", "=", "c.id");
                        }, joinSub() );
                    } );

                    it( "can inner join to a derived table with joinSub using the shorthand", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .joinSub( "c", derivedTable, "u.id", "c.id");
                        }, joinSub() );
                    } );

                    it( "can left join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .leftJoinSub( "c", derivedTable, "u.id", "=", "c.id");
                        }, leftJoinSub() );
                    } );

                    it( "can left join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .leftJoinSub( "c", function (qb){
                                    qb.select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );
                                }, "u.id", "=", "c.id");
                        }, leftJoinSub() );
                    } );

                    it( "can left join to a derived table with joinSub using the shorthand", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .leftJoinSub( "c", derivedTable, "u.id", "c.id");
                        }, leftJoinSub() );
                    } );

                    it( "can right join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .rightJoinSub( "c", derivedTable, "u.id", "=", "c.id");
                        }, rightJoinSub() );
                    } );

                    it( "can right join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .rightJoinSub( "c", function (qb){
                                    qb.select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );
                                }, "u.id", "=", "c.id");
                        }, rightJoinSub() );
                    } );

                    it( "can right join to a derived table with joinSub using the shorthand", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .rightJoinSub( "c", derivedTable, "u.id", "c.id");
                        }, rightJoinSub() );
                    } );

                    it( "can cross join to a derived table with joinSub using a QueryBuilder object", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder().select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );

                            builder
                                .from( "users as u" )
                                .crossJoinSub( "c", derivedTable);
                        }, crossJoinSub() );
                    } );

                    it( "can cross join to a derived table with joinSub using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .crossJoinSub( "c", function (qb){
                                    qb.select("id").from("contacts").whereNotIn( "id", [ 1, 2, 3 ] );
                                });
                        }, crossJoinSub() );
                    } );
                } );

                describe( "group bys", function() {
                    it( "can add a simple group by", function() {
                        testCase( function( builder ) {
                            builder.select( "*" ).from( "users" ).groupBy( "email" );
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

                    it( "can order in descending order", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderBy( "email", "desc" );
                        }, orderByDesc() );
                    } );

                    it( "combines all order by calls", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderBy( "id" ).orderBy( "email", "desc" );
                        }, combinesOrderBy() );
                    } );

                    it( "can order by a raw expression", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderBy( builder.raw( "DATE(created_at)" ) );
                        }, orderByRaw() );
                    } );

                    describe( "can accept an array for the column argument", function() {
                        describe( "with the array values", function() {
                            it( "as simple strings", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( [ "last_name", "age", "favorite_color" ] );
                                }, orderByArray() );
                            } );

                            it( "as pipe delimited strings", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( [ "last_name|desc", "age|asc", "favorite_color|desc" ] );
                                }, orderByPipeDelimited() );
                            } );

                            it( "as a nested positional array", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            [ "last_name", "desc" ],
                                            [ "age", "asc" ],
                                            [ "favorite_color" ]
                                        ] );
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
                                            [ "height", "asc", "will", "be", "ignored" ]
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
                                            { column = "height", direction = "tallest" },
                                            { column = "weight", direction = "desc" },
                                            builder.raw( "DATE(created_at)" ),
                                            { column = builder.raw( "DATE(modified_at)" ), direction = "desc" } //desc will be ignored in this case because it's an expression
                                        ] );
                                }, orderByComplex() );
                            } );

                            it( "as raw expressions", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            builder.raw( "DATE(created_at)" ),
                                            { column = builder.raw( "DATE(modified_at)" ) }
                                        ] );
                                }, orderByRawInStruct() );
                            } );

                            it( "as simple strings OR pipe delimited strings intermingled", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [ "last_name", "age|desc", "favorite_color" ] );
                                }, orderByMixSimpleAndPipeDelimited() );
                            } );

                            it( "can accept a struct with a column key and optionally the direction key", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            { column = "last_name" },
                                            { column = "age", direction = "asc" },
                                            { column = "favorite_color", direction = "desc" }
                                        ], "desc" );
                                }, orderByStruct() );
                            } );

                            it( "as values that when additional orderBy() calls are chained the chained calls preserve the order of the calls", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .orderBy( [
                                            "last_name",
                                            "age|desc"
                                        ] )
                                        .orderBy( "favorite_color", "desc" )
                                        .orderBy( column = [ { column = "height" }, { column = "weight", direction = "asc" } ], direction = "desc" )
                                        .orderBy( column = "eye_color", direction = "desc" )
                                        .orderBy( [
                                            { column = "is_athletic", direction = "desc", extraKey = "ignored" },
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
                                            { column = "is_musical" },
                                            { column = "is_athletic", direction = "desc", extraKey = "ignored" },
                                            builder.raw( "DATE(created_at)" ),
                                            { column = builder.raw( "DATE(modified_at)" ), direction = "desc" } // direction is ignored because it should be RAW
                                        ] );
                                }, orderByMixed() );
                            });
                        });
                    });

                    describe( "can accept a comma delimited list for the column argument", function() {
                        describe( "with the list values", function() {
                            it( "as simple column names that inherit the default direction", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).orderBy( "last_name,age,favorite_color");
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
                                .select("name")
                                .from( "users" )
                                .where( "id", 1 )
                                .union(function (q){
                                    q
                                        .select("name")
                                        .from("users")
                                        .where( "id", 2 )
                                    ;
                                })
                                .union(function (q){
                                    q
                                        .select("name")
                                        .from("users")
                                        .where( "id", 3 )
                                    ;
                                })
                            ;
                        }, union() );
                    } );

                    it( "can union multiple statements using a QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var union2 = getBuilder().select("name").from("users").where( "id", 2 );
                            var union3 = getBuilder().select("name").from("users").where( "id", 3 );

                            builder
                                .select("name")
                                .from( "users" )
                                .where( "id", 1 )
                                .union(union2)
                                .union(union3)
                            ;
                        }, union() );
                    } );

                    it( "union can contain order by on main query only", function() {
                        testCase( function( builder ) {
                            builder
                                .select("name")
                                .from( "users" )
                                .where( "id", 1 )
                                .union(function (q){
                                    q
                                        .select("name")
                                        .from("users")
                                        .where( "id", 2 )
                                    ;
                                })
                                .union(function (q){
                                    q
                                        .select("name")
                                        .from("users")
                                        .where( "id", 3 )
                                    ;
                                })
                                .orderBy("name")
                            ;
                        }, unionOrderBy() );
                    } );

                    it( "union query cannot contain orderBy", function() {
                        var builder = getBuilder();

                        builder
                            .select("name")
                            .from( "users" )
                            .where( "id", 1 )
                            .union(function (q){
                                q
                                    .select("name")
                                    .from("users")
                                    .where( "id", 2 )
                                    .orderBy("name")
                                ;
                            })
                            .union(function (q){
                                q
                                    .select("name")
                                    .from("users")
                                    .where( "id", 3 )
                                ;
                            })
                            .orderBy("name")
                        ;


                        try {
                            var statements = builder.toSql();
                        }
                        catch ( any e ) {
                            // Darn ACF nests the exception message. 😠
                            if ( e.message == "An exception occurred while calling the function map." ) {
                                expect( e.detail ).toBe( "The ORDER BY clause is not allowed in a UNION statement." );
                            }
                            else {
                                expect( e.message ).toBe( "The ORDER BY clause is not allowed in a UNION statement." );
                            }
                            return;
                        }
                        fail( "Should have caught an exception, but didn't." );
                    } );

                    it( "can union all multiple statements using a closure", function() {
                        testCase( function( builder ) {
                            builder
                                .select("name")
                                .from( "users" )
                                .where( "id", 1 )
                                .unionAll(function (q){
                                    q
                                        .select("name")
                                        .from("users")
                                        .where( "id", 2 )
                                    ;
                                })
                                .unionAll(function (q){
                                    q
                                        .select("name")
                                        .from("users")
                                        .where( "id", 3 )
                                    ;
                                })
                            ;
                        }, unionAll() );
                    } );

                    it( "can union all multiple statements using a QueryBuilder instance", function() {
                        testCase( function( builder ) {
                            var union2 = getBuilder().select("name").from("users").where( "id", 2 );
                            var union3 = getBuilder().select("name").from("users").where( "id", 3 );

                            builder
                                .select("name")
                                .from( "users" )
                                .where( "id", 1 )
                                .unionAll(union2)
                                .unionAll(union3)
                            ;
                        }, unionAll() );
                    }) ;
                } );

                describe( "common table expressions (i.e. CTEs)", function() {
                    it( "can create CTE from closure", function() {
                        testCase( function( builder ) {
                            builder
                                .with("UsersCTE", function (q){
                                    q
                                        .select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                })
                                .from( "UsersCTE" )
                                .whereNotIn("user.id", [1, 2])
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
                                .with("UsersCTE", cte)
                                .from( "UsersCTE" )
                                .whereNotIn("user.id", [1, 2])
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "can correctly bind parameters regardless of order", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "UsersCTE" )
                                .whereNotIn("user.id", [1, 2])
                                .with("UsersCTE", function (q){
                                    q
                                        .select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                })
                            ;
                        }, commonTableExpression() );
                    } );

                    it( "can create recursive CTE", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive("UsersCTE", function (q){
                                    q
                                        .select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                })
                                .from( "UsersCTE" )
                                .whereNotIn("user.id", [1, 2])
                            ;
                        }, commonTableExpressionWithRecursive() );
                    } );

                    it( "can create multiple CTEs where the second CTE is not recursive", function() {
                        testCase( function( builder ) {
                            builder
                                .withRecursive("UsersCTE", function (q){
                                    q
                                        .select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                })
                                .with("OrderCTE", function (q){
                                    q
                                        .from( "orders" )
                                        .where( "created", ">", "2018-04-30" )
                                    ;
                                })
                                .from( "UsersCTE" )
                                .whereNotIn("user.id", [1, 2])
                            ;
                        }, commonTableExpressionMultipleCTEsWithRecursive() );
                    } );

                    it( "can create bindings in the correct order", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "UsersCTE" )
                                .whereNotIn("user.id", [1, 2])
                                .with("OrderCTE", function (q){
                                    q
                                        .from( "orders" )
                                        .where( "created", ">", "2018-04-30" )
                                    ;
                                })
                                .withRecursive("UsersCTE", function (q){
                                    q
                                        .select( "*" )
                                        .from( "users" )
                                        .join( "contacts", "users.id", "contacts.id" )
                                        .where( "users.age", ">", 25 )
                                    ;
                                })
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
                            builder.from( "users" ).orderBy( "id" ).offset( 3 );
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
            } );

            describe( "insert statements", function() {
                it( "can insert a struct of data into a table", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).insert( values = { "email" = "foo" }, toSql = true );
                    }, insertSingleColumn() );
                } );

                it( "can insert a struct of data with multiple columns into a table", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).insert( values = { "email" = "foo", "name" = "bar" }, toSql = true );
                    }, insertMultipleColumns() );
                } );

                it( "can batch insert multiple records", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).insert( values = [
                            { "email" = "foo", "name" = "bar" },
                            { "email" = "baz", "name" = "bleh" }
                        ], toSql = true );
                    }, batchInsert() );
                } );

                it( "can insert with returning", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).returning( "id" ).insert( values = {
                            "email" = "foo",
                            "name" = "bar"
                        }, toSql = true );
                    }, returning() );
                } );
            } );

            describe( "update statements", function() {
                it( "can update all records in a table", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" )
                            .update( values = {
                                "email" = "foo",
                                "name" = "bar"
                            }, toSql = true );
                    }, updateAllRecords() );
                } );

                it( "can be constrained by a where statement", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" )
                            .whereId( 1 )
                            .update( values = {
                                "email" = "foo",
                                "name" = "bar"
                            }, toSql = true );
                    }, updateWithWhere() );
                } );
            } );

            describe( "updateOrInsert statements", function() {
                it( "inserts a new record when the where clause does not bring back any records", function() {
                    testCase( function( builder ) {
                        builder.$( "exists", false );
                        return builder.from( "users" )
                            .where( "email", "foo" )
                            .updateOrInsert(
                                values = { "name" = "baz" },
                                toSql = true
                            );
                    }, updateOrInsertNotExists() );
                } );

                it( "updates an existing record when the where clause brings back at least one record", function() {
                    testCase( function( builder ) {
                        builder.$( "exists", true );
                        return builder.from( "users" )
                            .where( "email", "foo" )
                            .updateOrInsert(
                                values = { "name" = "baz" },
                                toSql = true
                            );
                    }, updateOrInsertExists() );
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
                        return builder.from( "users" )
                            .where( "email", "foo" )
                            .delete( toSql = true );
                    }, deleteWhere() );
                } );
            } );
        } );
    }

    private function testCase( callback, expected ) {
        var builder = getBuilder();
        var sql = callback( builder );
        if ( ! isNull( sql ) ) {
            if ( ! isSimpleValue( sql ) ) {
                sql = sql.toSQL();
            }
        }
        else {
            sql = builder.toSQL();
        }
        if ( isSimpleValue( expected ) ) {
            expected = {
                sql = expected,
                bindings = []
            };
        }
        expect( sql ).toBeWithCase( expected.sql );
        expect( getTestBindings( builder ) ).toBe( expected.bindings );
    }

    private function getBuilder() {
        throw( "Must be implemented in a subclass" );
    }

    private array function getTestBindings( builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}
