component extends="tests.resources.querybuilder.AbstractQueryBuilderJoinSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
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

                    it( "correctly orders bindings with having and raw statements and whereIn", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "holdings h" )
                                .join( "accounts a", "h.account_id", "a.account_id" )
                                .where( "shares", "<>", "-999" )
                                .andWhere( "investment_type", "taxable" )
                                .andWhereNotLike( "security_id", "*%" )
                                .select( "h.account_id, security_id" )
                                .groupBy( "h.account_id, security_id" )
                                .having( builder.raw( "COUNT(security_id)" ), ">", 1 )
                                .orderBy( "h.account_id, security_id" )
                                .when( true, ( q ) => {
                                    q.whereIn( "h.account_id", ( q ) => {
                                        q.select( "portfolioCode" )
                                            .from( "accounts" )
                                            .whereIn( "id", [ 662 ] );
                                    } )
                                } );
                        }, havingRawWhereIn() );
                    } );
                } );

                describe( "order bys", function() {
                    it( "can add a simple order by", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderBy( "email" );
                        }, orderBy() );
                    } );

                    it( "can order by random", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).orderByRandom();
                        }, orderByRandom() );
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
                        it( "rejects invalid default directions", function() {
                            expect( function() {
                                getBuilder().from( "users" ).orderBy( "email", "DESC; DROP TABLE users" );
                            } ).toThrow( type = "InvalidSQLType", regex = "Illegal order direction" );
                            expect( function() {
                                getBuilder().orderBySub( ( query ) => query.selectRaw( "1" ), "DESC; DROP TABLE users" );
                            } ).toThrow( type = "InvalidSQLType", regex = "Illegal order direction" );
                        } );

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
            } );
        } );
    }

}
