component extends="tests.resources.querybuilder.AbstractQueryBuilderWhereSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
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

                    it( "can left outer join", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).leftOuterJoin( "orders", "users.id", "orders.user_id" );
                        }, leftOuterJoin() );
                    } );

                    it( "can full join", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).fullJoin( "orders", "users.id", "orders.user_id" );
                        }, fullJoin() );
                    } );

                    it( "can full outer join", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).fullOuterJoin( "orders", "users.id", "orders.user_id" );
                        }, fullOuterJoin() );
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

                    it( "it can handle nested on queries without truncating text", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "test" )
                                .leftJoin( "last_team_tasks_queue_record", function( j ) {
                                    j.on(
                                        "last_team_tasks_queue_record.task_territory_id",
                                        "team_tasks_queue.task_territory_id"
                                    );
                                    j.where( function( q ) {
                                        q.whereNull( "last_team_tasks_queue_record.when_created" );
                                        q.whereColumn(
                                            "last_team_tasks_queue_record.when_created",
                                            "<=",
                                            "team_tasks_queue.when_created",
                                            "OR"
                                        );
                                    } );
                                } );
                        }, leftJoinTruncatingText() );
                    } );

                    it( "can right join", function() {
                        testCase( function( builder ) {
                            builder.from( "orders" ).rightJoin( "users", "orders.user_id", "users.id" );
                        }, rightJoin() );
                    } );

                    it( "can right outer join", function() {
                        testCase( function( builder ) {
                            builder.from( "orders" ).rightOuterJoin( "users", "orders.user_id", "users.id" );
                        }, rightOuterJoin() );
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

                    it( "correctly positions bindings using crossJoinSub", function() {
                        var builder = getBuilder();
                        builder
                            .from( "A" )
                            .where( "A.A", "=", "A" )
                            .crossJoinSub( "B", function( query ) {
                                query.from( "B" ).where( "B.B", "=", "B" );
                            } )
                            .where( "A.C", "=", "C" );

                        expect( getTestBindings( builder ) ).toBe( [ "B", "A", "C" ] );
                    } );

                    it( "does not retain bindings from prevented duplicate joinSub clauses", function() {
                        var builder = getBuilder().setPreventDuplicateJoins( true );
                        var derivedTable = getBuilder().from( "contacts" ).where( "contacts.kind", "personal" );

                        builder
                            .from( "users AS u" )
                            .joinSub(
                                "c",
                                derivedTable,
                                "u.id",
                                "=",
                                "c.user_id"
                            )
                            .joinSub(
                                "c",
                                derivedTable,
                                "u.id",
                                "=",
                                "c.user_id"
                            );

                        expect( builder.getJoins() ).toHaveLength( 1 );
                        expect( getTestBindings( builder ) ).toBe( [ "personal" ] );
                    } );

                    it( "distinguishes joinSub clauses with the same SQL and different bindings", function() {
                        var builder = getBuilder().setPreventDuplicateJoins( true );
                        var personalContacts = getBuilder().from( "contacts" ).where( "contacts.kind", "personal" );
                        var businessContacts = getBuilder().from( "contacts" ).where( "contacts.kind", "business" );

                        builder
                            .from( "users AS u" )
                            .joinSub(
                                "c",
                                personalContacts,
                                "u.id",
                                "=",
                                "c.user_id"
                            )
                            .joinSub(
                                "c",
                                businessContacts,
                                "u.id",
                                "=",
                                "c.user_id"
                            );

                        expect( builder.getJoins() ).toHaveLength( 2 );
                        expect( getTestBindings( builder ) ).toBe( [ "personal", "business" ] );
                    } );

                    it( "correctly positions bindings using joinSub", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "A" )
                                .where( "A.A", "=", "A" )
                                .joinSub(
                                    "B",
                                    ( qb ) => {
                                        return qb.from( "B" ).where( "B.B", "=", "B" );
                                    },
                                    "A.A",
                                    "=",
                                    "B.B"
                                )
                                .where( "A.C", "=", "C" );
                        }, joinSubBindings() );
                    } );

                    it( "can cross apply", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .crossApply( "childCount", function( qb ) {
                                    qb.selectRaw( "count(*) c" )
                                        .from( "children" )
                                        .whereColumn( "children.parentID", "=", "users.ID" )
                                        .where( "children.someCol", "=", 0 )
                                } )
                                .select( [ "u.ID", "childCount.c" ] )
                                .where( "childCount.c", ">", 1 )
                        }, crossApply() );
                    } );

                    it( "can outer apply", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users as u" )
                                .outerApply( "childCount", function( qb ) {
                                    qb.selectRaw( "count(*) c" )
                                        .from( "children" )
                                        .whereColumn( "children.parentID", "=", "users.ID" )
                                        .where( "children.someCol", "=", 0 )
                                } )
                                .select( [ "u.ID", "childCount.c" ] )
                                .where( "childCount.c", ">", 1 )
                        }, outerApply() );
                    } );

                    it( "correctly positions bindings using crossApply", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "A" )
                                .where( "A.A", "=", "A" )
                                .crossApply(
                                    "B",
                                    getBuilder()
                                        .from( "x" )
                                        .where( "x.x", "=", "B" )
                                        .whereColumn( "x.b", "=", "a.b" )
                                )
                                .where( "A.C", "=", "C" )
                                .outerApply( "D", ( qb ) => {
                                    qb.from( "y" )
                                        .where( "y.y", "=", "D" )
                                        .whereColumn( "y.d", "=", "a.d" )
                                } )
                        }, correctlyPositionsBindingsUsingCrossApply() );
                    } );

                    it( "eliminates duplicate cross or outer applies", function() {
                        testCase( function( builder ) {
                            var gen = function( name ) {
                                return function( qb ) {
                                    qb.from( name ).select( "someColumn" );
                                };
                            };
                            builder
                                .setPreventDuplicateJoins( true )
                                .from( "A" )
                                .crossApply( "B", gen( "crossapply_B" ) )
                                .outerApply( "C", gen( "outerapply_C" ) )
                                .crossApply( "B", gen( "crossapply_B" ) )
                                .outerApply( "C", gen( "outerapply_C" ) )
                                .crossApply( "D", gen( "crossapply_D" ) )
                                .outerApply( "E", gen( "outerapply_E" ) )
                                .crossApply( "D", gen( "crossapply_D" ) )
                                .outerApply( "E", gen( "outerapply_E" ) )
                        }, duplicateCrossAndOuterAppliesEliminated() );
                    } );

                    it( "can join with a callback that includes a whereExists clause", function() {
                        testCase( ( builder ) => {
                            builder
                                .from( "LeftTable AS lt" )
                                .leftJoin( "RightTable AS rt", ( j ) => {
                                    j.on( "rt.id", "lt.id" )
                                        .whereExists( ( qb ) => {
                                            qb.selectRaw( 1 )
                                                .from( "ExistsTable AS et" )
                                                .whereColumn( "et.id", "lt.id" );
                                        } );
                                } );
                        }, joinCallbackWhereExists() );
                    } );
                } );
            } );
        } );
    }

}
