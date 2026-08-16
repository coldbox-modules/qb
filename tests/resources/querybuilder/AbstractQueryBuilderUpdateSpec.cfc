component extends="tests.resources.querybuilder.AbstractQueryBuilderInsertSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
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

                it( "preserves bindings carried by update expressions", function() {
                    var builder = getBuilder();
                    var sql = builder
                        .from( "hits" )
                        .update( values = { "count": builder.raw( "COALESCE(?, 0) + ?", [ 10, 1 ] ) }, toSql = true );

                    expect( reMatch( "\?", sql ) ).toHaveLength( 2 );
                    expect( getTestBindings( builder ) ).toBe( [ 10, 1 ] );
                } );

                it( "can use an expression in an update table or from clause", function() {
                    testCase( function( builder ) {
                        return builder
                            .tableRaw( "LogFiles..Browsers" )
                            .where( "ID", 1 )
                            .update( values = { "UserAgent": "Mozilla/5.0" }, toSql = true );
                    }, updateWithRawTable() );
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
                        var subselect = function( qb ) {
                            qb.from( "departments" )
                                .select( "name" )
                                .whereColumn( "employees.departmentId", "departments.id" );
                        };
                        return builder
                            .table( "employees" )
                            .update( values = { "departmentName": subselect }, toSql = true );
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

                it( "can update with returning", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .where( "id", 1 )
                            .returning( "modifiedDate" )
                            .update( values = { "email": "john@example.com" }, toSql = true );
                    }, updateReturning() );
                } );

                it( "can update with raw returning columns", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .where( "id", 1 )
                            .returningRaw( [ "DELETED.modifiedDate AS oldModifiedDate", "INSERTED.modifiedDate AS newModifiedDate" ] )
                            .update( values = { "email": "john@example.com" }, toSql = true );
                    }, updateReturningRaw() );
                } );

                it( "can update with returning and joins", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "zzz" )
                            .returning( "xxx" )
                            .join( "aaa", ( j ) => {
                                j.on( "aaa.ddd", "zzz.ddd" )
                            } )
                            .whereIn( "aaa.id", [ 1, 2, 3 ] )
                            .update( values = { "zzz.user_id": 1, "zzz.created": "2025-01-01 00:00:00" }, toSQL = true );
                    }, updateReturningWithJoin() );
                } );

                it( "returning ignores table qualifiers in update statements", function() {
                    testCase( function( builder ) {
                        return builder
                            .setColumnFormatter( function( column ) {
                                return "tablePrefix." & column;
                            } )
                            .from( "users" )
                            .where( "id", 1 )
                            .returning( "modifiedDate" )
                            .update( values = { "email": "john@example.com" }, toSql = true );
                    }, updateReturningIgnoresTableQualifiers() );
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
                        grammar.$( "runQuery", queryNew( "aggregate", "varchar", [ { "aggregate": 1 } ] ) );
                        return builder
                            .from( "users" )
                            .where( "email", "foo" )
                            .updateOrInsert( values = { "name": "baz" }, toSql = true );
                    }, updateOrInsertExists() );
                } );
            } );

            describe( "upsert statements", function() {
                it( "does not include unrelated parent bindings in upserts", function() {
                    var builder = getBuilder().from( "users" ).where( "tenant_id", 42 );

                    var sql = builder.upsert(
                        values = { "email": "eric@example.com" },
                        target = [ "email" ],
                        update = [ "email" ],
                        toSql = true
                    );

                    expect( getTestBindings( builder ) ).toBe( [ "eric@example.com" ] );
                    expect( reMatch( "\?", sql ) ).toHaveLength( 1 );
                } );

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

                it( "can opt in to matching null target values", function() {
                    testCase( function( builder ) {
                        return builder
                            .table( "records" )
                            .upsert(
                                values = [
                                    { "a": 1, "b": javacast( "null", "" ), "c": "first" },
                                    { "a": 2, "b": "value", "c": "second" }
                                ],
                                target = [ "a", "b" ],
                                update = [ "c" ],
                                matchNulls = true,
                                toSql = true
                            );
                    }, upsertMatchNulls() );
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

                it( "can delete unmatched source rows in an upsert with additional restrictions (SQL Server)", function() {
                    testCase(
                        callback = function( builder ) {
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
                                            .where( "active", { value: 1, cfsqltype: "INTEGER" } );
                                    },
                                    values = [
                                        "username",
                                        "active",
                                        "createdDate",
                                        "modifiedDate"
                                    ],
                                    target = [ "username" ],
                                    update = [ "active", "modifiedDate" ],
                                    deleteUnmatched = ( q ) => {
                                        q.where( "active", { value: 0, cfsqltype: "INTEGER" } );
                                    },
                                    toSql = true
                                );
                        },
                        expected = upsertWithDeleteRestricted(),
                        withFullBindings = true
                    );
                } );

                it( "can update fields to null", () => {
                    testCase( function( builder ) {
                        return builder
                            .table( "vendors" )
                            .upsert(
                                target = [ "vendorCode", "code" ],
                                values = {
                                    "vendorCode": "AA",
                                    "code": "BB",
                                    "name": javacast( "null", "" ),
                                    "count": 1
                                },
                                update = { "count": builder.raw( "vendors.count + 1" ), "name": javacast( "null", "" ) },
                                toSQL = true
                            );
                    }, upsertUpdateToNull() );
                } );

                it( "adds bindings for explicit update values", () => {
                    testCase(
                        callback = function( builder ) {
                            return builder
                                .table( "vendors" )
                                .upsert(
                                    target = [ "vendorCode", "code" ],
                                    values = {
                                        "vendorCode": "AA",
                                        "code": "BB",
                                        "name": "New Name",
                                        "count": 1
                                    },
                                    update = { "count": builder.raw( "vendors.count + 1" ), "name": "New Name" },
                                    toSQL = true
                                );
                        },
                        expected = upsertUpdateWithExplicitValue()
                    );
                } );

                it( "preserves bindings carried by upsert expressions", function() {
                    var builder = getBuilder();
                    var sql = builder
                        .table( "scores" )
                        .upsert(
                            values = { "id": 1, "score": builder.raw( "COALESCE(?, 0)", [ 2 ] ) },
                            target = [ "id" ],
                            update = { "score": builder.raw( "? + 1", [ 3 ] ) },
                            toSql = true
                        );

                    expect( reMatch( "\?", sql ) ).toHaveLength( 3 );
                    expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3 ] );
                } );
            } );
        } );
    }

}
