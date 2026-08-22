component extends="tests.resources.querybuilder.AbstractQueryBuilderJsonSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "insert statements", function() {
                it( "can insert a struct of data into a table", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).insert( values = { "email": "foo" }, toSql = true );
                    }, insertSingleColumn() );
                } );

                it( "correctly formats booleans during an insert", function() {
                    testCase(
                        callback = function( builder ) {
                            return builder.from( "users" ).insert( values = { "active": true }, toSql = true );
                        },
                        expected = insertBoolean(),
                        withFullBindings = true
                    );
                } );

                it( "always uses passed in cfsqltypes if available", function() {
                    testCase(
                        callback = function( builder ) {
                            return builder
                                .from( "users" )
                                .insert(
                                    values = { "active": { "value": true, "cfsqltype": "BOOLEAN" } },
                                    toSql = true
                                );
                        },
                        expected = insertBooleanExplicitSqlType(),
                        withFullBindings = true
                    );
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

                it( "preserves commas inside returningRaw expressions", function() {
                    var builder = getBuilder().returningRaw( "'last,first' AS label" );

                    expect( builder.getReturning() ).toHaveLength( 1 );
                    expect( builder.getReturning()[ 1 ].value.getSQL() ).toBe( "'last,first' AS label" );
                } );

                it( "can return all from an insert", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .returningAll()
                            .insert( values = { "email": "foo", "name": "bar" }, toSql = true );
                    }, returningAll() );
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

                it( "preserves bindings carried by insert expressions", function() {
                    var builder = getBuilder();
                    var sql = builder
                        .from( "users" )
                        .insert(
                            values = {
                                "first": builder.raw( "COALESCE(?, 0)", [ 10 ] ),
                                "second": 20,
                                "third": builder.raw( "COALESCE(?, ?)", [ 30, 40 ] )
                            },
                            toSql = true
                        );

                    expect( reMatch( "\?", sql ) ).toHaveLength( 4 );
                    expect( getTestBindings( builder ) ).toBe( [ 10, 20, 30, 40 ] );
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

                it( "does not include unrelated parent bindings in insert using statements", function() {
                    var builder = getBuilder().from( "users" ).where( "tenant_id", 42 );
                    var source = builder
                        .newQuery()
                        .from( "activeDirectoryUsers" )
                        .select( "email" )
                        .where( "active", 1 );

                    var sql = builder.insertUsing( columns = [ "email" ], source = source, toSql = true );

                    expect( reMatch( "\?", sql ) ).toHaveLength( 1 );
                    expect( getTestBindings( builder ) ).toBe( [ 1 ] );
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
        } );
    }

}
