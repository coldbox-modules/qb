component extends="tests.resources.querybuilder.AbstractQueryBuilderSourceSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
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
                                    .where( "createdDate", ">=", { value: "01/01/2019", cfsqltype: "DATE" } );
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

                        it( "can add a where statement with a boolean literal", function() {
                            testCase(
                                callback = function( builder ) {
                                    builder
                                        .select( "*" )
                                        .from( "users" )
                                        .where( "active", "=", true );
                                },
                                expected = whereBoolean(),
                                withFullBindings = true
                            );
                        } );

                        it( "can handle null values passed to where clauses", () => {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .where( "id", "=", javacast( "null", "" ) );
                            }, nullWhere() );
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

                        it( "preserves bindings from where null subqueries", function() {
                            var builder = getBuilder()
                                .from( "users" )
                                .whereNull( function( query ) {
                                    query
                                        .select( "deletedAt" )
                                        .from( "accounts" )
                                        .where( "status", "closed" );
                                } );

                            expect( reMatch( "\?", builder.toSQL() ) ).toHaveLength( 1 );
                            expect( getTestBindings( builder ) ).toBe( [ "closed" ] );
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

                        it( "can add where between statements with raw expressions", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereBetween(
                                        "createdDate",
                                        builder.raw( "GETDATE() - 7" ),
                                        builder.raw( "GETDATE()" )
                                    );
                            }, whereBetweenRaw() );
                        } );

                        it( "can add where between statements with query param structs", function() {
                            testCase( function( builder ) {
                                builder
                                    .select( "*" )
                                    .from( "users" )
                                    .whereBetween(
                                        "createdDate",
                                        { value: "1/1/2019", cfsqltype: "DATE" },
                                        { value: "12/31/2019", cfsqltype: "DATE" }
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

                        it( "can add where not between statements with expression boundaries", function() {
                            var builder = getBuilder()
                                .from( "users" )
                                .whereNotBetween(
                                    "score",
                                    getBuilder().raw( "COALESCE(?, 0)", [ 10 ] ),
                                    getBuilder().raw( "COALESCE(?, 100)", [ 90 ] )
                                );

                            expect( builder.toSQL() ).toInclude( "NOT BETWEEN COALESCE(?, 0) AND COALESCE(?, 100)" );
                            expect( getTestBindings( builder ) ).toBe( [ 10, 90 ] );
                        } );

                        it( "can add where not between statements with subquery boundaries", function() {
                            var builder = getBuilder()
                                .from( "users" )
                                .whereNotBetween(
                                    "id",
                                    function( query ) {
                                        query
                                            .selectRaw( "MIN(id)" )
                                            .from( "users" )
                                            .where( "type", "minimum" );
                                    },
                                    function( query ) {
                                        query
                                            .selectRaw( "MAX(id)" )
                                            .from( "users" )
                                            .where( "type", "maximum" );
                                    }
                                );

                            expect( builder.toSQL() ).toInclude( "NOT BETWEEN (SELECT" );
                            expect( getTestBindings( builder ) ).toBe( [ "minimum", "maximum" ] );
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
                                builder.from( "users" ).whereIn( "id", [ 1, { value: 2, cfsqltype: "INTEGER" }, 3 ] );
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

                        describe( "bulk values", function() {
                            it( "binds an array as a single parameter", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereInBulk( "id", [ 1, 2, 3 ] );
                                }, whereInBulk() );
                            } );

                            it( "uses a large text binding for the serialized values", function() {
                                var builder = getBuilder().from( "users" ).whereInBulk( "id", [ 1, 2, 3 ] );
                                var bindings = builder.getBindings();
                                expect( bindings ).toHaveLength( 1 );
                                expect( bindings[ 1 ].value ).toBe( "[1,2,3]" );
                                expect( bindings[ 1 ].cfsqltype ).toBe( "LONGVARCHAR" );
                            } );

                            it( "serializes values from query parameter structs", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .whereInBulk(
                                            "id",
                                            [
                                                { value: 1, cfsqltype: "INTEGER" },
                                                { value: 2, cfsqltype: "INTEGER" },
                                                { value: 3, cfsqltype: "INTEGER" }
                                            ]
                                        );
                                }, whereInBulk() );
                            } );

                            it( "infers string values using the grammar-specific string type", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereInBulk( "status", [ "active", "pending" ] );
                                }, whereInBulkStrings() );
                            } );

                            it( "falls back to the grammar-specific string type for mixed values", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereInBulk( "externalId", [ 1, "two" ] );
                                }, whereInBulkMixed() );
                            } );

                            it( "infers boolean values using the grammar-specific boolean type", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereInBulk( "active", [ true, false ] );
                                }, whereInBulkBooleans() );
                            } );

                            it( "uses matching query parameter types as the inferred type", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .whereInBulk(
                                            "id",
                                            [ { value: 1, cfsqltype: "BIGINT" }, { value: 2, cfsqltype: "BIGINT" } ]
                                        );
                                }, whereInBulkBigInt() );
                            } );

                            it( "allows an explicit SQL type to override inference", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereInBulk( "id", [ 1, 2, 3 ], bulkExplicitSqlType() );
                                }, whereInBulkExplicitType() );
                            } );

                            it( "infers the SQL type when explicitly passed null", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereInBulk( "id", [ 1, 2, 3 ], javacast( "null", "" ) );
                                }, whereInBulk() );
                            } );

                            it( "maps inferred timestamp types for the active grammar", function() {
                                expect( getBuilder().getGrammar().resolveWhereInBulkSqlType( "TIMESTAMP" ) ).toBe(
                                    bulkTimestampSqlType()
                                );
                            } );

                            it( "supports dynamic or where shortcuts", function() {
                                testCase( function( builder ) {
                                    builder
                                        .from( "users" )
                                        .where( "active", 1 )
                                        .orWhereInBulk( "id", [ 1, 2, 3 ] );
                                }, orWhereInBulk() );
                            } );

                            it( "supports negated bulk values", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereNotInBulk( "id", [ 1, 2, 3 ] );
                                }, whereNotInBulk() );
                            } );

                            it( "handles empty bulk values without a binding", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereInBulk( "id", [] );
                                }, whereInBulkEmpty() );
                            } );

                            it( "handles empty negated bulk values without a binding", function() {
                                testCase( function( builder ) {
                                    builder.from( "users" ).whereNotInBulk( "id", [] );
                                }, whereNotInBulkEmpty() );
                            } );

                            it( "rejects SQL expressions in bulk values", function() {
                                expect( function() {
                                    getBuilder().whereInBulk( "id", [ getBuilder().raw( "SELECT 1" ) ] );
                                } ).toThrow( type = "InvalidBulkValue" );
                            } );

                            it( "rejects unsafe SQL types", function() {
                                expect( function() {
                                    getBuilder().whereInBulk( "id", [ 1, 2, 3 ], "INTEGER); DROP TABLE users; --" );
                                } ).toThrow( type = "InvalidSQLType" );
                            } );

                            it( "rejects an explicitly empty SQL type", function() {
                                expect( function() {
                                    getBuilder().whereInBulk( "id", [ 1, 2, 3 ], "" );
                                } ).toThrow( type = "InvalidSQLType" );
                            } );
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
            } );
        } );
    }

}
