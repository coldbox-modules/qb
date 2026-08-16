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
                    expect( builder.getColumns().map( ( c ) => c.value ) ).toBe( [ "id" ] );
                } );

                it( "preserves original columns when executing a get with columns throws", function() {
                    var builder = getMockBox()
                        .createMock( "qb.models.Query.QueryBuilder" )
                        .init(
                            grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init(),
                            validateQueryExecuteReturnType = true
                        );
                    builder.select( "id" ).from( "users" );

                    expect( function() {
                        builder.get( columns = "name", options = { "returntype": "array" } );
                    } ).toThrow( type = "InvalidQueryExecuteOption" );

                    expect( builder.getColumns().map( ( column ) => column.value ) ).toBe( [ "id" ] );
                } );

                it( "does not execute temporary get columns with stale select bindings", function() {
                    var builder = new qb.models.Query.QueryBuilder()
                        .pretend()
                        .selectRaw( "CASE WHEN id = ? THEN name END AS selectedName", [ 10 ] )
                        .from( "users" );

                    builder.get( columns = "name" );

                    expect( builder.getQueryLog()[ 1 ].sql ).toBe( "SELECT ""name"" FROM ""users""" );
                    expect( builder.getQueryLog()[ 1 ].bindings ).toBeEmpty();
                    expect( getTestBindings( builder ) ).toBe( [ 10 ] );
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
                it( "rejects non-positive chunk sizes", function() {
                    for ( var max in [ 0, -1 ] ) {
                        expect( function() {
                            getBuilder()
                                .from( "users" )
                                .chunk( max, function() {
                                } );
                        } ).toThrow( type = "InvalidChunkSize" );
                    }
                } );

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

                it( "does not execute aggregates with bindings from removed orders", function() {
                    var executions = [];
                    var grammar = new qb.models.Grammars.BaseGrammar();
                    grammar.setInterceptorService( {
                        processState: function( state, data ) {
                            if ( arguments.state == "preQBExecute" ) {
                                executions.append( arguments.data );
                            }
                        }
                    } );
                    var builder = new qb.models.Query.QueryBuilder( grammar = grammar )
                        .pretend()
                        .from( "users" )
                        .orderByRaw( "CASE WHEN id = ? THEN 0 ELSE 1 END", [ 10 ] );

                    try {
                        builder.count();
                    } catch ( any ignored ) {
                    }

                    expect( executions ).toHaveLength( 1 );
                    expect( executions[ 1 ].sql ).toBe( "SELECT COALESCE(COUNT(*), 0) AS ""aggregate"" FROM ""users""" );
                    expect( executions[ 1 ].bindings ).toBeEmpty();
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

                    expect( builder.getColumns().map( ( c ) => c.value ) ).toBe( [ "id", "name" ] );
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

                    expect( builder.getOrders() ).toBe( [ { "column": { "type": "simple", "value": "name" }, "direction": "asc" } ] );
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

                it( "restores aggregate query state when execution throws", function() {
                    var builder = getMockBox()
                        .createMock( "qb.models.Query.QueryBuilder" )
                        .init(
                            grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init(),
                            validateQueryExecuteReturnType = true
                        );
                    builder
                        .select( "id" )
                        .from( "users" )
                        .orderBy( "name" );

                    expect( function() {
                        builder.count( options = { "returntype": "array" } );
                    } ).toThrow( type = "InvalidQueryExecuteOption" );

                    expect( builder.getAggregate() ).toBeEmpty();
                    expect( builder.getColumns().map( ( column ) => column.value ) ).toBe( [ "id" ] );
                    expect( builder.getOrders() ).toBe( [ { "column": { "type": "simple", "value": "name" }, "direction": "asc" } ] );
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

                it( "can return a default value for max if no records are found", function() {
                    var builder = getBuilder();
                    var expectedMax = 100;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedMax } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(MAX(""age""), 100) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).max( "age", 100 );

                    expect( results ).toBe( expectedMax );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( { sql: "SELECT COALESCE(MAX(""age""), 100) AS ""aggregate"" FROM ""users""", options: {} } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "can return the max date of a table", function() {
                    var builder = getBuilder();
                    var maxDate = now();
                    var expectedQuery = queryNew( "aggregate", "timestamp", [ { aggregate: maxDate } ] );
                    var expectedMax = expectedQuery.aggregate;
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

                it( "can return a default value when there is no records in a table", function() {
                    var builder = getBuilder();
                    var expectedMin = "2025-01-01 00:00:00";
                    var expectedQuery = queryNew( "aggregate", "timestamp", [ { aggregate: expectedMin } ] );
                    builder
                        .$( "runQuery" )
                        .$args(
                            sql = "SELECT COALESCE(MIN(""createdDate""), GETDATE()) AS ""aggregate"" FROM ""users""",
                            options = {}
                        )
                        .$results( expectedQuery );

                    var results = builder.from( "users" ).min( "createdDate", "GETDATE()" );

                    expect( results ).toBe( expectedMin );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql: "SELECT COALESCE(MIN(""createdDate""), GETDATE()) AS ""aggregate"" FROM ""users""",
                        options: {}
                    } );

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

                it( "passes bindings carried by aggregate expressions to the grammar", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: 42 } ] );
                    builder.getGrammar().$( "runQuery", expectedQuery );

                    var result = builder
                        .from( "users" )
                        .sum( builder.raw( "CASE WHEN active = ? THEN amount ELSE 0 END", [ 1 ] ) );

                    expect( result ).toBe( 42 );
                    expect(
                        builder.getGrammar().$callLog().runQuery[ 1 ].bindings.map( function( binding ) {
                            return binding.value;
                        } )
                    ).toBe( [ 1 ] );
                } );
            } );

            describe( "exists", function() {
                it( "returns true if any records come back from the query", function() {
                    var builder = getBuilder();
                    builder.getGrammar().$( "runQuery", queryNew( "aggregate", "varchar", [ { "aggregate": 1 } ] ) );
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
                    builder.getGrammar().$( "runQuery", queryNew( "aggregate", "varchar", [ { "aggregate": 0 } ] ) );
                    expect(
                        builder
                            .select( "*" )
                            .from( "users" )
                            .exists()
                    ).toBe( false );
                } );

                it( "generates the correct sql for exists", () => {
                    var sql = getBuilder()
                        .from( "users" )
                        .where( "active", 1 )
                        .exists( toSQL = true );
                    expect( sql ).toBe( "SELECT CASE WHEN EXISTS (SELECT * FROM ""users"" WHERE ""active"" = ? LIMIT 1) THEN 1 ELSE 0 END AS aggregate" );
                } );

                it( "restores the original limit when exists compilation fails", function() {
                    var builder = getBuilder()
                        .from( "users" )
                        .limit( 5 )
                        .whereJsonExists( "profile->name" );

                    expect( function() {
                        builder.exists( toSQL = true );
                    } ).toThrow( type = "UnsupportedOperation" );
                    expect( builder.getLimitValue() ).toBe( 5 );
                } );
            } );

            describe( "existsOrFail", function() {
                it( "returns true if any records are found for the query", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder.getGrammar().$( "runQuery", expectedQuery )

                    var results = builder
                        .from( "users" )
                        .where( "id", 1 )
                        .existsOrFail();

                    expect( results ).toBeTrue();

                    var runQueryLog = builder.getGrammar().$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ].sql ).toBe( "SELECT CASE WHEN EXISTS (SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1) THEN 1 ELSE 0 END AS aggregate" );
                    expect( runQueryLog[ 1 ].bindings ).toBe( [
                        {
                            "CFSQLTYPE": "INTEGER",
                            "SQLTYPE": "INTEGER",
                            "VALUE": 1,
                            "LIST": false,
                            "NULL": false
                        }
                    ] );
                } );

                it( "throws a RecordNotFound exception if no rows are found", function() {
                    var builder = getBuilder();
                    var expectedCount = 0;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder.getGrammar().$( "runQuery", expectedQuery );

                    expect( function() {
                        builder
                            .from( "users" )
                            .where( "id", 1 )
                            .existsOrFail();
                    } ).toThrow( type = "RecordNotFound" );

                    var runQueryLog = builder.getGrammar().$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ].sql ).toBe( "SELECT CASE WHEN EXISTS (SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1) THEN 1 ELSE 0 END AS aggregate" );
                    expect( runQueryLog[ 1 ].bindings ).toBe( [
                        {
                            "CFSQLTYPE": "INTEGER",
                            "SQLTYPE": "INTEGER",
                            "VALUE": 1,
                            "LIST": false,
                            "NULL": false
                        }
                    ] );
                } );

                it( "can supply a custom errorMessage", function() {
                    var builder = getBuilder();
                    var expectedCount = 0;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate: expectedCount } ] );
                    builder.getGrammar().$( "runQuery", expectedQuery );

                    expect( function() {
                        builder
                            .from( "users" )
                            .where( "id", 1 )
                            .existsOrFail( errorMessage = "Whoops" );
                    } ).toThrow( type = "RecordNotFound", regex = "Whoops" );

                    var runQueryLog = builder.getGrammar().$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ].sql ).toBe( "SELECT CASE WHEN EXISTS (SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1) THEN 1 ELSE 0 END AS aggregate" );
                    expect( runQueryLog[ 1 ].bindings ).toBe( [
                        {
                            "CFSQLTYPE": "INTEGER",
                            "SQLTYPE": "INTEGER",
                            "VALUE": 1,
                            "LIST": false,
                            "NULL": false
                        }
                    ] );
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

            it( "can return a struct of structs", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "struct", { "columnKey": "name" } );
                var data = [ { "id": 1, "name": "jane" }, { "id": 2, "name": "john" } ];
                var expectedQuery = queryNew( "id,name", "integer,varchar", data );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"", ""name"" FROM ""users""", options = { "result": "local.result" } )
                    .$results( expectedQuery );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"", ""name"" FROM ""users""", options = {} )
                    .$results( expectedQuery );

                var results = builder
                    .select( [ "id", "name" ] )
                    .from( "users" )
                    .get();

                expect( results ).toBe( { "jane": data[ 1 ], "john": data[ 2 ] } );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ].sql ).toBe( "SELECT ""id"", ""name"" FROM ""users""" );
            } );

            it( "can return a struct of structs using withReturnFormat", function() {
                var builder = getBuilder();
                var data = [ { "id": 1, "name": "jane" }, { "id": 2, "name": "john" } ];
                var expectedQuery = queryNew( "id,name", "integer,varchar", data );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"", ""name"" FROM ""users""", options = { "result": "local.result" } )
                    .$results( expectedQuery );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"", ""name"" FROM ""users""", options = {} )
                    .$results( expectedQuery );

                var results = builder.withReturnFormat(
                    "struct",
                    function() {
                        return builder
                            .select( [ "id", "name" ] )
                            .from( "users" )
                            .get();
                    },
                    { "columnKey": "name" }
                );

                expect( results ).toBe( { "jane": data[ 1 ], "john": data[ 2 ] } );
            } );

            it( "restores the return formatter when withReturnFormat throws", function() {
                var builder = getBuilder();
                var originalReturnFormat = builder.getReturnFormat();

                expect( function() {
                    builder.withReturnFormat( "query", function() {
                        throw( type = "ExpectedReturnFormatException" );
                    } );
                } ).toThrow( type = "ExpectedReturnFormatException" );

                expect( builder.getReturnFormat() ).toBe( originalReturnFormat );
            } );

            it( "uses the last row when struct return format keys are duplicated", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "struct", { "columnKey": "name" } );
                var data = [ { "id": 1, "name": "jane" }, { "id": 2, "name": "jane" } ];
                var expectedQuery = queryNew( "id,name", "integer,varchar", data );
                builder.$( "runQuery", expectedQuery );

                var results = builder
                    .select( [ "id", "name" ] )
                    .from( "users" )
                    .get();

                expect( results ).toBe( { "jane": data[ 2 ] } );
            } );

            it( "can use custom registered return formatters", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();
                registry.registerReturnFormatter(
                    "firstId",
                    function( options ) {
                        return function( q ) {
                            return options.prefix & q.id[ 1 ];
                        };
                    },
                    { "prefix": "user-" }
                );
                var builder = getMockBox()
                    .createMock( "qb.models.Query.QueryBuilder" )
                    .init(
                        grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init(),
                        returnFormatterRegistry = registry
                    );
                builder.setReturnFormat( "firstId", { "prefix": "account-" } );
                var expectedQuery = queryNew( "id", "integer", [ { "id": 1 } ] );
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

                expect( results ).toBe( "account-1" );
            } );

            it( "carries return formatter settings to new queries and clones", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();
                registry.registerReturnFormatter( "firstId", function( options ) {
                    return function( q ) {
                        return q.id[ 1 ];
                    };
                } );
                var builder = getMockBox()
                    .createMock( "qb.models.Query.QueryBuilder" )
                    .init(
                        grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init(),
                        returnFormatterRegistry = registry,
                        validateQueryExecuteReturnType = true,
                        collectQueryLog = false
                    );

                var newBuilder = builder.newQuery();
                var clonedBuilder = builder.clone();

                expect( newBuilder.getReturnFormatterRegistry() ).toBe( registry );
                expect( newBuilder.getValidateQueryExecuteReturnType() ).toBeTrue();
                expect( newBuilder.getCollectQueryLog() ).toBeFalse();
                newBuilder.setReturnFormat( "firstId" );

                expect( clonedBuilder.getReturnFormatterRegistry() ).toBe( registry );
                expect( clonedBuilder.getValidateQueryExecuteReturnType() ).toBeTrue();
                expect( clonedBuilder.getCollectQueryLog() ).toBeFalse();
                clonedBuilder.setReturnFormat( "firstId" );
            } );

            it( "carries behavioral settings to new queries and clones", function() {
                var sqlCommenter = {
                    "appendSqlComments": function( sql ) {
                        return sql;
                    }
                };
                var shouldMaxRowsOverrideToAll = function( maxRows ) {
                    return maxRows == 99;
                };
                var builder = getMockBox()
                    .createMock( "qb.models.Query.QueryBuilder" )
                    .init(
                        grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init(),
                        preventDuplicateJoins = true,
                        sqlCommenter = sqlCommenter,
                        shouldMaxRowsOverrideToAll = shouldMaxRowsOverrideToAll
                    );

                var derivedBuilders = [ builder.newQuery(), builder.clone() ];
                derivedBuilders.each( function( derivedBuilder ) {
                    expect( derivedBuilder.getPreventDuplicateJoins() ).toBeTrue();
                    $assert.isSameInstance( sqlCommenter, derivedBuilder.getSqlCommenter() );
                    $assert.isSameInstance( shouldMaxRowsOverrideToAll, derivedBuilder.getShouldMaxRowsOverrideToAll() );
                } );
            } );

            it( "carries a resolved struct return formatter to new queries and clones", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();
                registry.registerReturnFormatter( "structFormatter", function() {
                    return {
                        "format": function( q ) {
                            return q;
                        }
                    };
                } );
                var builder = getMockBox()
                    .createMock( "qb.models.Query.QueryBuilder" )
                    .init(
                        grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init(),
                        returnFormatterRegistry = registry
                    )
                    .setReturnFormat( "structFormatter" );

                var returnFormat = builder.getReturnFormat();
                $assert.isSameInstance( returnFormat, builder.newQuery().getReturnFormat() );
                $assert.isSameInstance( returnFormat, builder.clone().getReturnFormat() );
            } );

            it( "carries a resolved component return formatter to new queries and clones", function() {
                var builder = getBuilder().setReturnFormat( "struct", { "columnKey": "id" } );

                expect( builder.newQuery().getReturnFormat() ).toBe( builder.getReturnFormat() );
                expect( builder.clone().getReturnFormat() ).toBe( builder.getReturnFormat() );
            } );

            it( "creates a default return formatter registry when none is passed", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "none" );
                var expectedQuery = queryNew( "id", "integer", [ { "id": 1 } ] );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = { "result": "local.result" } )
                    .$results( expectedQuery );
                builder
                    .$( "runQuery" )
                    .$args( sql = "SELECT ""id"" FROM ""users""", options = {} )
                    .$results( expectedQuery );

                expect(
                    builder
                        .select( "id" )
                        .from( "users" )
                        .get()
                ).toBe( expectedQuery );
            } );

            it( "throws from the struct formatter at runtime if columnKey is missing", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "struct" );
                var expectedQuery = queryNew( "id,name", "integer,varchar", [ { "id": 1, "name": "jane" } ] );
                builder.$( "runQuery", expectedQuery );

                expect( function() {
                    builder
                        .select( [ "id", "name" ] )
                        .from( "users" )
                        .get();
                } ).toThrow( type = "MissingColumnKey" );
            } );

            it( "throws from the struct formatter at runtime if the columnKey column is missing", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "struct", { "columnKey": "name" } );
                var expectedQuery = queryNew( "id", "integer", [ { "id": 1 } ] );
                builder.$( "runQuery", expectedQuery );

                expect( function() {
                    builder
                        .select( "id" )
                        .from( "users" )
                        .get();
                } ).toThrow( type = "MissingColumnKey" );
            } );

            it( "can strip native queryExecute returntype options", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "query" );
                var expectedQuery = queryNew( "id", "integer", [ { "id": 1 } ] );
                builder
                    .getGrammar()
                    .$( "runQuery" )
                    .$results( expectedQuery );

                var results = builder
                    .select( "id" )
                    .from( "users" )
                    .get( options = { "returntype": "array", "columnkey": "id", "columnKey": "id" } );

                expect( results ).toBe( expectedQuery );
                expect( builder.getGrammar().$callLog().runQuery[ 1 ].options ).toBe( {} );
            } );

            it( "does not mutate per-query options while preparing them for execution", function() {
                var options = { "returntype": "array", "columnkey": "id", "timeout": 5 };
                var originalOptions = duplicate( options );

                new qb.models.Query.QueryBuilder( new qb.models.Grammars.BaseGrammar() )
                    .pretend()
                    .from( "users" )
                    .get( options = options );

                expect( options ).toBe( originalOptions );
            } );

            it( "can strip native queryExecute returntype options from default options without mutating them", function() {
                var builder = getBuilder();
                builder.mergeDefaultOptions( { "returntype": "array", "columnkey": "id", "columnKey": "id" } );
                builder.setReturnFormat( "query" );
                var expectedQuery = queryNew( "id", "integer", [ { "id": 1 } ] );
                builder
                    .getGrammar()
                    .$( "runQuery" )
                    .$results( expectedQuery );

                var results = builder
                    .select( "id" )
                    .from( "users" )
                    .get();

                expect( results ).toBe( expectedQuery );
                expect( builder.getGrammar().$callLog().runQuery[ 1 ].options ).toBe( {} );
                expect( builder.getDefaultOptions() ).toBe( { "returntype": "array", "columnkey": "id", "columnKey": "id" } );
            } );

            it( "can validate native queryExecute returntype options", function() {
                var builder = getMockBox()
                    .createMock( "qb.models.Query.QueryBuilder" )
                    .init(
                        grammar = getMockBox().createMock( "qb.models.Grammars.BaseGrammar" ).init(),
                        validateQueryExecuteReturnType = true
                    );

                expect( function() {
                    builder
                        .select( "id" )
                        .from( "users" )
                        .get( options = { "returntype": "array" } );
                } ).toThrow( type = "InvalidQueryExecuteOption" );
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

        describe( "write input immutability", function() {
            it( "does not merge configured update values into the caller's struct", function() {
                var values = { "name": "Jane" };
                var originalValues = duplicate( values );
                var builder = new qb.models.Query.QueryBuilder( new qb.models.Grammars.BaseGrammar() )
                    .from( "users" )
                    .addUpdate( { "active": true } );

                builder.update( values = values, toSql = true );

                expect( values ).toBe( originalValues );
            } );
        } );

        describe( "bulk inserts", function() {
            it( "includes columns introduced by later insert rows", function() {
                var builder = getBuilder().from( "users" );

                var sql = builder.insert(
                    values = [ { "id": 1 }, { "email": "two@example.com", "id": 2 } ],
                    toSql = true
                );

                expect( sql ).toBe( "INSERT INTO ""users"" (""email"", ""id"") VALUES (?, ?), (?, ?)" );
                expect( builder.getBindings() ).toHaveLength( 4 );
                expect( builder.getBindings()[ 1 ].null ).toBeTrue();
                expect( builder.getBindings()[ 2 ].value ).toBe( 1 );
                expect( builder.getBindings()[ 3 ].value ).toBe( "two@example.com" );
                expect( builder.getBindings()[ 4 ].value ).toBe( 2 );
            } );

            it( "includes columns introduced by later upsert rows", function() {
                var builder = new qb.models.Query.QueryBuilder( new qb.models.Grammars.PostgresGrammar() ).from( "users" );

                var sql = builder.upsert(
                    values = [ { "id": 1 }, { "email": "two@example.com", "id": 2 } ],
                    target = "id",
                    update = [ "email" ],
                    toSql = true
                );

                expect( sql ).toBe(
                    "INSERT INTO ""users"" (""email"", ""id"") VALUES (?, ?), (?, ?) ON CONFLICT (""id"") DO UPDATE SET ""email"" = EXCLUDED.""email"""
                );
                expect( builder.getBindings() ).toHaveLength( 4 );
                expect( builder.getBindings()[ 1 ].null ).toBeTrue();
                expect( builder.getBindings()[ 2 ].value ).toBe( 1 );
                expect( builder.getBindings()[ 3 ].value ).toBe( "two@example.com" );
                expect( builder.getBindings()[ 4 ].value ).toBe( 2 );
            } );

            it( "keeps all source bindings before explicit upsert update bindings", function() {
                var grammar = new qb.models.Grammars.PostgresGrammar();
                var source = new qb.models.Query.QueryBuilder( grammar )
                    .selectRaw( "? AS id", [ 1 ] )
                    .unionAll( ( query ) => query.selectRaw( "? AS id", [ 2 ] ) );
                var builder = new qb.models.Query.QueryBuilder( grammar ).from( "users" );

                builder.upsert(
                    values = [ "id" ],
                    target = [ "id" ],
                    update = { "id": 3 },
                    source = source,
                    toSql = true
                );

                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1, 2, 3 ] );
            } );

            it( "includes columns introduced by later native bulk insert rows", function() {
                var grammar = new qb.models.Grammars.SqlServerGrammar();
                var builder = new qb.models.Query.QueryBuilder( grammar ).from( "users" );

                var prepared = grammar.prepareBulkInsert(
                    builder,
                    [ { "id": 1 }, { "email": "two@example.com", "id": 2 } ],
                    {}
                );

                expect( prepared.columns.map( ( column ) => column.original ) ).toBe( [ "email", "id" ] );
                expect( deserializeJSON( prepared.binding.value ) ).toBe( [ { "email": javacast( "null", "" ), "id": 1 }, { "email": "two@example.com", "id": 2 } ] );
            } );

            it( "does not include unrelated builder bindings in native bulk inserts", function() {
                var grammar = getMockBox().createMock( "qb.models.Grammars.SqlServerGrammar" ).init();
                grammar.$( "runQuery", {} );
                var builder = new qb.models.Query.QueryBuilder( grammar )
                    .fromRaw( "users", [ "unused-from" ] )
                    .where( "active", 1 );

                builder.insertBulk( [ { "email": "one@example.com" } ] );

                expect( grammar.$callLog().runQuery[ 1 ].bindings ).toHaveLength( 1 );
                expect( deserializeJSON( grammar.$callLog().runQuery[ 1 ].bindings[ 1 ].value ) ).toBe( [ { "email": "one@example.com" } ] );
            } );

            it( "inserts values in explicit batches", function() {
                var sql = getBuilder()
                    .from( "users" )
                    .insertBulk(
                        values = [
                            { "email": "one@example.com" },
                            { "email": "two@example.com" },
                            { "email": "three@example.com" }
                        ],
                        chunkSize = 2,
                        toSql = true
                    );

                expect( sql ).toBe( [ "INSERT INTO ""users"" (""email"") VALUES (?), (?)", "INSERT INTO ""users"" (""email"") VALUES (?)" ] );
            } );

            it( "caps batches using the grammar parameter limit", function() {
                var builder = getBuilder();
                builder.getGrammar().parameterLimit = 4;

                var sql = builder
                    .from( "users" )
                    .insertBulk(
                        values = [
                            { "email": "one@example.com", "name": "One" },
                            { "email": "two@example.com", "name": "Two" },
                            { "email": "three@example.com", "name": "Three" }
                        ],
                        chunkSize = 100,
                        toSql = true
                    );

                expect( sql ).toBe( [
                    "INSERT INTO ""users"" (""email"", ""name"") VALUES (?, ?), (?, ?)",
                    "INSERT INTO ""users"" (""email"", ""name"") VALUES (?, ?)"
                ] );
            } );

            it( "treats a zero grammar parameter limit as unlimited", function() {
                var builder = getBuilder();
                builder.getGrammar().parameterLimit = 0;

                var sql = builder
                    .from( "users" )
                    .insertBulk(
                        values = [
                            { "email": "one@example.com" },
                            { "email": "two@example.com" },
                            { "email": "three@example.com" }
                        ],
                        chunkSize = 100,
                        toSql = true
                    );

                expect( sql ).toBe( [ "INSERT INTO ""users"" (""email"") VALUES (?), (?), (?)" ] );
            } );

            it( "returns an empty array for no values", function() {
                expect( getBuilder().from( "users" ).insertBulk( values = [], toSql = true ) ).toBe( [] );
            } );

            it( "uses a non-positive chunk size to insert all rows", function() {
                var sql = getBuilder()
                    .from( "users" )
                    .insertBulk(
                        values = [ { "email": "one@example.com" }, { "email": "two@example.com" } ],
                        chunkSize = -1,
                        toSql = true
                    );

                expect( sql ).toBe( [ "INSERT INTO ""users"" (""email"") VALUES (?), (?)" ] );
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
