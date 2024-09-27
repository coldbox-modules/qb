component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "retrieval shortcuts", function() {
            describe( "get", function() {
                it( "executes the query when calling `get`", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "id", "integer", [ { id: 1 } ] );
                    builder.$( "runQuery", expectedQuery );

                    var results = builder
                        .select( "id" )
                        .from( "users" )
                        .get();

                    expect( results ).toBe( expectedQuery );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""id"" FROM ""users""" );
                } );

                it( "can pass in an array of columns to retrieve for the single query execution", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedGetQuery = queryNew( "id,name", "integer,varchar", [ { id: 1, name: "foo" } ] );
                    var expectedNormalQuery = queryNew(
                        "id,name,age",
                        "integer,varchar,integer",
                        [ { id: 1, name: "foo", age: 24 } ]
                    );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""id"", ""name"" FROM ""users""", options = { "result": "local.result" } )
                        .$results( expectedGetQuery );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""id"", ""name"" FROM ""users""", options = {} )
                        .$results( expectedGetQuery );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users""", options = { "result": "local.result" } )
                        .$results( expectedNormalQuery );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users""", options = {} )
                        .$results( expectedNormalQuery );

                    expect( builder.from( "users" ).get( [ "id", "name" ] ) ).toBe( expectedGetQuery );
                    expect( builder.from( "users" ).get() ).toBe( expectedNormalQuery );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 2, "runQuery should have been called twice" );
                    expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""id"", ""name"" FROM ""users""" );
                    expect( runQueryLog[ 2 ].sql ).toBe( "SELECT * FROM ""users""" );
                } );

                it( "can get a single column for a single query execution", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users""", options = { "result": "local.result" } )
                        .$results( expectedQuery );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    expect( builder.from( "users" ).get( "name" ) ).toBe( expectedQuery );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""name"" FROM ""users""" );
                } );

                it( "preserves original columns after executing a get with columns", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users""", options = { "result": "local.result" } )
                        .$results( expectedQuery );

                    builder.select( "id" ).from( "users" );
                    builder.get( "name" );
                    expect( builder.getColumns() ).toBe( [ "id" ] );
                } );
            } );

            describe( "first", function() {
                it( "retrieves the first record when calling `first`", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id: 1, name: "foo" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var results = builder
                        .from( "users" )
                        .whereName( "foo" )
                        .first();

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id: 1, name: "foo" } );
                    expect( getTestBindings( builder ) ).toBe( [ "foo" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options: {} } );
                } );
            } );

            describe( "last", function() {
                it( "retrieves the last record when calling `last`", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew(
                        "id,name",
                        "integer,varchar",
                        [ { id: 1, name: "foo" }, { id: 2, name: "test" } ]
                    );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).last();

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id: 2, name: "test" } );
                } );
            } );

            describe( "find", function() {
                it( "returns the first result by id when calling `find`", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id: 1, name: "foo" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).find( 1 );

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id: 1, name: "foo" } );
                    expect( getTestBindings( builder ) ).toBe( [ 1 ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options: {} } );
                } );
            } );

            describe( "value", function() {
                it( "returns the first value when calling value", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" } ] );
                    // writeDump( var = expectedQuery, abort = true );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).value( "name" );

                    expect( results ).toBe( "foo" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""name"" FROM ""users"" LIMIT 1", options: {} } );
                } );

                it( "returns the first value when calling value using a fully-qualified column", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" } ] );
                    // writeDump( var = expectedQuery, abort = true );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""some_table"".""name"" FROM ""users"" LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).value( "some_table.name" );

                    expect( results ).toBe( "foo" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""some_table"".""name"" FROM ""users"" LIMIT 1", options: {} } );
                } );

                it( "returns the first value when the column is changed by a column formatter", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" } ] );
                    // writeDump( var = expectedQuery, abort = true );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""some_table"".""name"" FROM ""users"" LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var results = builder
                        .setColumnFormatter( function( column ) {
                            return "some_table.name";
                        } )
                        .from( "users" )
                        .value( "different" );

                    expect( results ).toBe( "foo" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""some_table"".""name"" FROM ""users"" LIMIT 1", options: {} } );
                } );

                it( "returns the defaultValue when calling value with an empty query", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [] );
                    // writeDump( var = expectedQuery, abort = true );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var result = builder.from( "users" ).value( "name" );

                    expect( result ).toBe( "" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""name"" FROM ""users"" LIMIT 1", options: {} } );
                } );

                it( "returns a custom defaultValue when provided", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [] );
                    // writeDump( var = expectedQuery, abort = true );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var result = builder.from( "users" ).value( column = "name", defaultValue = "default" );

                    expect( result ).toBe( "default" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""name"" FROM ""users"" LIMIT 1", options: {} } );
                } );

                it( "throws an exception when calling value with an empty query and throwWhenNotFound is true", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [] );

                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    expect( function() {
                        var result = builder.from( "users" ).value( column = "name", throwWhenNotFound = true );
                    } ).toThrow( type = "RecordCountException" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""name"" FROM ""users"" LIMIT 1", options: {} } );
                } );

                it( "can call value using a raw expression", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "fullName", "varchar", [ { fullName: "John Doe" } ] );

                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users"" LIMIT 1",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder
                        .from( "users" )
                        .value( builder.raw( "CONCAT(fname, ' ', lname) AS fullName" ) );

                    expect( results ).toBe( "John Doe" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users"" LIMIT 1", options: {} } );
                } );

                it( "can use the valueRaw shortcut method", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "fullName", "varchar", [ { fullName: "John Doe" } ] );

                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users"" LIMIT 1",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).valueRaw( "CONCAT(fname, ' ', lname) AS fullName" );

                    expect( results ).toBe( "John Doe" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users"" LIMIT 1", options: {} } );
                } );
            } );

            describe( "values", function() {
                it( "returns an array of values for a column", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" }, { name: "bar" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).values( "name" );
                    expect( results ).toBe( [ "foo", "bar" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""name"" FROM ""users""", options: {} } );
                } );

                it( "can return an array of values with fully qualified columns", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" }, { name: "bar" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""some_table"".""name"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).values( "some_table.name" );
                    expect( results ).toBe( [ "foo", "bar" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""some_table"".""name"" FROM ""users""", options: {} } );
                } );

                it( "can return an array of values when the column formatter changes the column name", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name: "foo" }, { name: "bar" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""some_table"".""name"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder
                        .setColumnFormatter( function( column ) {
                            return "some_table.name";
                        } )
                        .from( "users" )
                        .values( "different" );
                    expect( results ).toBe( [ "foo", "bar" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""some_table"".""name"" FROM ""users""", options: {} } );
                } );

                it( "can call values with a raw expression", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew(
                        "fullName",
                        "varchar",
                        [ { fullName: "John Doe" }, { fullName: "Jane Doe" } ]
                    );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder
                        .from( "users" )
                        .values( builder.raw( "CONCAT(fname, ' ', lname) AS fullName" ) );
                    expect( results ).toBe( [ "John Doe", "Jane Doe" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users""", options: {} } );
                } );

                it( "can use the valuesRaw shortcut method", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew(
                        "fullName",
                        "varchar",
                        [ { fullName: "John Doe" }, { fullName: "Jane Doe" } ]
                    );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).valuesRaw( "CONCAT(fname, ' ', lname) AS fullName" );
                    expect( results ).toBe( [ "John Doe", "Jane Doe" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT CONCAT(fname, ' ', lname) AS fullName FROM ""users""", options: {} } );
                } );
            } );

            describe( "implode", function() {
                it( "can join the values of all columns together in to a single value", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew(
                        "name",
                        "varchar",
                        [ { name: "foo" }, { name: "bar" }, { name: "baz" } ]
                    );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).implode( "name" );

                    expect( results ).toBe( "foobarbaz" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""name"" FROM ""users""", options: {} } );
                } );

                it( "can specify a custom glue string when imploding", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew(
                        "name",
                        "varchar",
                        [ { name: "foo" }, { name: "bar" }, { name: "baz" } ]
                    );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).implode( "name", "-" );

                    expect( results ).toBe( "foo-bar-baz" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT ""name"" FROM ""users""", options: {} } );
                } );
            } );

            describe( "chunk", function() {
                it( "can chunk a query into smaller sections", function() {
                    var builder = getBuilder();
                    var expectedQuery100 = queryNew( "name", "varchar" );
                    for ( var i = 1; i <= 100; i++ ) {
                        queryAddRow( expectedQuery100, { "name": "name-#i#" } );
                    }
                    var expectedQueryRest = queryNew( "name", "varchar" );
                    for ( var i = 1; i <= 57; i++ ) {
                        queryAddRow( expectedQueryRest, { "name": "name-#i#" } );
                    }
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( queryNew( "aggregate", "varchar", [ { "aggregate": 257 } ] ) )
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 100 OFFSET 0", options = {} )
                        .$results( expectedQuery100 )
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 100 OFFSET 100", options = {} )
                        .$results( expectedQuery100 )
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 100 OFFSET 200", options = {} )
                        .$results( expectedQueryRest );

                    builder
                        .select( "name" )
                        .from( "users" )
                        .chunk( 100, function( results ) {
                            expect( results ).toBeArray();
                            expect( arrayLen( results ) ).toBeLTE( 100 );
                        } );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 4 );
                } );

                it( "can stop the chunk early by returning false", function() {
                    var builder = getBuilder();
                    var expectedQuery100 = queryNew( "name", "varchar" );
                    for ( var i = 1; i <= 100; i++ ) {
                        queryAddRow( expectedQuery100, { "name": "name-#i#" } );
                    }
                    var expectedQueryRest = queryNew( "name", "varchar" );
                    for ( var i = 1; i <= 57; i++ ) {
                        queryAddRow( expectedQueryRest, { "name": "name-#i#" } );
                    }
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( queryNew( "aggregate", "varchar", [ { "aggregate": 257 } ] ) )
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 100 OFFSET 0", options = {} )
                        .$results( expectedQuery100 )
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 100 OFFSET 100", options = {} )
                        .$results( expectedQuery100 )
                        .$( "runQuery" )
                        .$args( sql = "SELECT ""name"" FROM ""users"" LIMIT 100 OFFSET 200", options = {} )
                        .$results( expectedQueryRest );

                    builder
                        .select( "name" )
                        .from( "users" )
                        .chunk( 100, function( results ) {
                            expect( results ).toBeArray();
                            expect( arrayLen( results ) ).toBeLTE( 100 );
                            return false;
                        } );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 2 );
                } );
            } );

            describe( "firstOrFail", function() {
                it( "retrieves the first record when calling `firstOrFail`", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id: 1, name: "foo" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var results = builder
                        .from( "users" )
                        .whereName( "foo" )
                        .firstOrFail();

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id: 1, name: "foo" } );
                    expect( getTestBindings( builder ) ).toBe( [ "foo" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options: {} } );
                } );

                it( "throw a RecordNotFound exception if no rows are returned", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    expect( function() {
                        builder
                            .from( "users" )
                            .whereName( "foo" )
                            .firstOrFail();
                    } ).toThrow( type = "RecordNotFound" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options: {} } );
                } );

                it( "can supply a custom errorMessage", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    expect( function() {
                        builder
                            .from( "users" )
                            .whereName( "foo" )
                            .firstOrFail( errorMessage = "Whoops" );
                    } ).toThrow( type = "RecordNotFound", regex = "Whoops" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1", options: {} } );
                } );
            } );

            describe( "findOrFail", function() {
                it( "returns the first result by id when calling `find`", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id: 1, name: "foo" } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).findOrFail( 1 );

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id: 1, name: "foo" } );
                    expect( getTestBindings( builder ) ).toBe( [ 1 ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options: {} } );
                } );

                it( "throw a RecordNotFound exception if no rows are returned", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    expect( function() {
                        builder.from( "users" ).findOrFail( 1 );
                    } ).toThrow( type = "RecordNotFound" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options: {} } );
                } );

                it( "can supply a custom errorMessage", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options = {} )
                        .$results( expectedQuery );

                    expect( function() {
                        builder.from( "users" ).findOrFail( id = 1, errorMessage = "Whoops" );
                    } ).toThrow( type = "RecordNotFound", regex = "Whoops" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1", options: {} } );
                } );
            } );
        } );

        describe( "aggregate functions", function() {
            describe( "count", function() {
                it( "can count all the records on a table", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).count();

                    expect( results ).toBe( expectedCount );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options: {} } );
                } );

                it( "can count a specific column", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(COUNT(""name""), 0) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).count( "name" );

                    expect( results ).toBe( expectedCount );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(COUNT(""name""), 0) AS ""aggregate"" FROM ""users""", options: {} } );
                } );

                it( "returns 0 if no records are returned", function() {
                    var builder = getBuilder();
                    var expectedCount = 0;
                    var expectedQuery = queryNew( "aggregate", "integer", [] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(COUNT(""name""), 0) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).count( "name" );

                    expect( results ).toBe( expectedCount );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(COUNT(""name""), 0) AS ""aggregate"" FROM ""users""", options: {} } );
                } );

                it( "should maintain selected columns after an aggregate has been executed", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: 1 } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    builder.select( [ "id", "name" ] ).from( "users" );
                    builder.from( "users" ).count();

                    expect( builder.getColumns() ).toBe( [ "id", "name" ] );
                } );

                it( "ignores orders in the aggregate query and sets them back afterward", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: 1 } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    builder.from( "users" ).orderBy( "name" );
                    builder.from( "users" ).count();

                    expect( builder.getOrders() ).toBe( [ { "column": "name", "direction": "asc" } ] );
                } );

                it( "should clear out the aggregate properties after an aggregate has been executed", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: 1 } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    builder.from( "users" ).count();

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "correctly orders a distinct count", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(COUNT(DISTINCT ""name""), 0) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder
                        .from( "users" )
                        .distinct()
                        .count( "name" );

                    expect( results ).toBe( expectedCount );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(COUNT(DISTINCT ""name""), 0) AS ""aggregate"" FROM ""users""", options: {} } );
                } );

                it( "correctly ignores distinct when doing an open count", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder
                        .from( "users" )
                        .distinct()
                        .count();

                    expect( results ).toBe( expectedCount );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""", options: {} } );
                } );
            } );

            describe( "max", function() {
                it( "can return the max record of a table", function() {
                    var builder = getBuilder();
                    var expectedMax = 54;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedMax } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT MAX(""age"") AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).max( "age" );

                    expect( results ).toBe( expectedMax );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT MAX(""age"") AS ""aggregate"" FROM ""users""", options: {} } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "can return the max date of a table", function() {
                    var builder = getBuilder();
                    var expectedMax = now();
                    var expectedQuery = queryNew( "aggregate", "timestamp", [ { aggregate: expectedMax } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT MAX(""login_date"") AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).max( "login_date" );

                    expect( results ).toBe( expectedMax );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT MAX(""login_date"") AS ""aggregate"" FROM ""users""", options: {} } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );
            } );

            describe( "min", function() {
                it( "can return the min record of a table", function() {
                    var builder = getBuilder();
                    var expectedMin = 3;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedMin } ] );
                    builder
                        .$( "runQuery" )
                        .$args( sql = "SELECT MIN(""age"") AS ""aggregate"" FROM ""users""", options = {} )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).min( "age" );

                    expect( results ).toBe( expectedMin );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT MIN(""age"") AS ""aggregate"" FROM ""users""", options: {} } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );
            } );

            describe( "sum", function() {
                it( "can return the sum of a column in a table", function() {
                    var builder = getBuilder();
                    var expectedSum = 42;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedSum } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(SUM(""answers""), 0) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).sum( "answers" );

                    expect( results ).toBe( expectedSum );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(SUM(""answers""), 0) AS ""aggregate"" FROM ""users""", options: {} } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "returns 0 if no records are returned", function() {
                    var builder = getBuilder();
                    var expectedSum = 0;
                    var expectedQuery = queryNew( "aggregate", "integer", [] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(SUM(""questions""), 0) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).sum( "questions" );

                    expect( results ).toBe( expectedSum );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(SUM(""questions""), 0) AS ""aggregate"" FROM ""users""", options: {} } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "returns 0 if a null record is returned", function() {
                    var builder = getBuilder();
                    var expectedSum = 0;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { "aggregate": 0 } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(SUM(""questions""), 0) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).sum( "questions" );

                    expect( results ).toBe( expectedSum );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(SUM(""questions""), 0) AS ""aggregate"" FROM ""users""", options: {} } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "can use the sumRaw shortcut method", function() {
                    var builder = getBuilder();
                    var expectedSum = 424242;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedSum } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(SUM(netAdditions + netTransfers), 0) AS ""aggregate"" FROM ""accounts""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "accounts" ).sumRaw( "netAdditions + netTransfers" );

                    expect( results ).toBe( expectedSum );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql: "SELECT COALESCE(SUM(netAdditions + netTransfers), 0) AS ""aggregate"" FROM ""accounts""",
                        options: {}
                    } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );
            } );

            describe( "exists", function() {
                it( "returns true if any records come back from the query", function() {
                    var builder = getBuilder();
                    builder.$( "runQuery", queryNew( "aggregate", "varchar", [ { "aggregate": 6 } ] ) );
                    expect(
                        builder
                            .select( "*" )
                            .from( "users" )
                            .exists()
                    ).toBe( true );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "returns false if no records come back from the query", function() {
                    var builder = getBuilder();
                    builder.$( "runQuery", queryNew( "aggregate", "varchar", [ { "aggregate": 0 } ] ) );
                    expect(
                        builder
                            .select( "*" )
                            .from( "users" )
                            .exists()
                    ).toBe( false );
                } );
            } );

            describe( "existsOrFail", function() {
                it( "returns true if any records are found for the query", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users"" WHERE ""id"" = ?",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder
                        .from( "users" )
                        .where( "id", 1 )
                        .existsOrFail();

                    expect( results ).toBeTrue();

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql: "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users"" WHERE ""id"" = ?",
                        options: {}
                    } );
                } );

                it( "throws a RecordNotFound exception if no rows are found", function() {
                    var builder = getBuilder();
                    var expectedCount = 0;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users"" WHERE ""id"" = ?",
                            options = {}
                        )
                        .$results( expectedQuery );

                    expect( function() {
                        builder
                            .from( "users" )
                            .where( "id", 1 )
                            .existsOrFail();
                    } ).toThrow( type = "RecordNotFound" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql: "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users"" WHERE ""id"" = ?",
                        options: {}
                    } );
                } );

                it( "can supply a custom errorMessage", function() {
                    var builder = getBuilder();
                    var expectedCount = 0;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users"" WHERE ""id"" = ?",
                            options = {}
                        )
                        .$results( expectedQuery );

                    expect( function() {
                        builder
                            .from( "users" )
                            .where( "id", 1 )
                            .existsOrFail( errorMessage = "Whoops" );
                    } ).toThrow( type = "RecordNotFound", regex = "Whoops" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql: "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users"" WHERE ""id"" = ?",
                        options: {}
                    } );
                } );
            } );
        } );

        describe( "returnFormat", function() {
            it( "has a default return format of array", function() {
                var builder = getBuilder();
                var data = [ { id: 1 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = { "result": "local.result" } )
                    .$results( expectedQuery );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = {} )
                    .$results( expectedQuery );

                var results = builder
                    .select( "id" )
                    .from( "users" )
                    .get();

                expect( results ).toBe( data );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""id"" FROM ""users""" );
            } );

            it( "can return an array of structs", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "array" );
                var data = [ { id: 1 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = { "result": "local.result" } )
                    .$results( expectedQuery );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = {} )
                    .$results( expectedQuery );

                var results = builder
                    .select( "id" )
                    .from( "users" )
                    .get();

                expect( results ).toBe( data );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""id"" FROM ""users""" );
            } );

            it( "can return a query", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "query" );
                var data = [ { id: 1 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = { "result": "local.result" } )
                    .$results( expectedQuery );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = {} )
                    .$results( expectedQuery );

                var results = builder
                    .select( "id" )
                    .from( "users" )
                    .get();

                expect( results ).toBe( expectedQuery );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""id"" FROM ""users""" );
            } );

            it( "can return the results of a closure", function() {
                var builder = getBuilder();
                builder.setReturnFormat( function( q ) {
                    var results = [];
                    for ( var row in q ) {
                        row.id *= 2;
                        arrayAppend( results, row );
                    }
                    return results;
                } );
                var data = [ { id: 1 }, { id: 2 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = { "result": "local.result" } )
                    .$results( expectedQuery );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = {} )
                    .$results( expectedQuery );

                var results = builder
                    .select( "id" )
                    .from( "users" )
                    .get();

                expect( results ).toBe( [ { id: 2 }, { id: 4 } ] );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""id"" FROM ""users""" );
            } );
        } );

        describe( "compiling the same builder multiple times", function() {
            it( "can call toSql many times and get the same output", function() {
                var builder = getBuilder();
                builder.from( "users" ).whereId( 10 );
                var sql = builder.toSql();
                var sqlAgain = builder.toSql();
                expect( sql ).toBe( sqlAgain );
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init();
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" ).init( grammar );
        return builder;
    }

    private array function getTestBindings( builder ) {
        return builder
            .getBindings()
            .map( function( binding ) {
                return binding.value;
            } );
    }

    private boolean function supportsNativeReturnType() {
        return server.keyExists( "lucee" ) || listFirst( server.coldfusion.productversion ) >= 2021;
    }

}
