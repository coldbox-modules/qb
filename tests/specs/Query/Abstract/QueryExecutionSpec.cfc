component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "retrieval shortcuts", function() {
            describe( "get", function() {
                it( "executes the query when calling `get`", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "id", "integer", [ { id = 1 } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.select( "id" ).from( "users" ).get();

                    expect( results ).toBe( expectedQuery );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""id"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "can pass in an array of columns to retrieve for the single query execution", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedGetQuery = queryNew( "id,name", "integer,varchar", [ { id = 1, name = "foo" } ] );
                    var expectedNormalQuery = queryNew( "id,name,age", "integer,varchar,integer", [ { id = 1, name = "foo", age = 24 } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""id"", ""name"" FROM ""users""",
                        options = {}
                    ).$results( expectedGetQuery );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT * FROM ""users""",
                        options = {}
                    ).$results( expectedNormalQuery );

                    expect( builder.from( "users" ).get( [ "id", "name" ] ) )
                        .toBe( expectedGetQuery );
                    expect( builder.from( "users" ).get() )
                        .toBe( expectedNormalQuery );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 2, "runQuery should have been called twice" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""id"", ""name"" FROM ""users""",
                        options = {}
                    } );
                    expect( runQueryLog[ 2 ] ).toBe( {
                        sql = "SELECT * FROM ""users""",
                        options = {}
                    } );
                } );

                it( "can get a single column for a single query execution", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    expect( builder.from( "users" ).get( "name" ) )
                        .toBe( expectedQuery );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "preserves original columns after executing a get with columns", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    builder.select( "id" ).from( "users" );
                    builder.get( "name" );
                    expect( builder.getColumns() ).toBe( [ "id" ] );
                } );
            } );

            describe( "first", function() {
                it( "retrieves the first record when calling `first`", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id = 1, name = "foo" } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).whereName( "foo" ).first();

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id = 1, name = "foo" } );
                    expect( getTestBindings( builder ) ).toBe( [ "foo" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT * FROM ""users"" WHERE ""name"" = ? LIMIT 1",
                        options = {}
                    } );
                } );
            } );

            describe( "last", function() {
                it( "retrieves the last record when calling `last`", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id = 1, name = "foo" }, { id = 2, name = "test" } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT * FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).last();

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id = 2, name = "test" } );
                } );
            } );

            describe( "find", function() {
                it( "returns the first result by id when calling `find`", function() {
                    var builder = getBuilder();
                    builder.setReturnFormat( "query" );
                    var expectedQuery = queryNew( "id,name", "integer,varchar", [ { id = 1, name = "foo" } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).find( 1 );

                    expect( results ).toBeStruct();
                    expect( results ).toBe( { id = 1, name = "foo" } );
                    expect( getTestBindings( builder ) ).toBe( [ 1 ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT * FROM ""users"" WHERE ""id"" = ? LIMIT 1",
                        options = {}
                    } );
                } );
            } );

            describe( "value", function() {
                it( "returns the first value when calling value", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""name"" FROM ""users"" LIMIT 1",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).value( "name" );

                    expect( results ).toBe( "foo" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""name"" FROM ""users"" LIMIT 1",
                        options = {}
                    } );
                } );
            } );

            describe( "values", function() {
                it( "returns an array of values for a column", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [ { name = "foo" }, { name = "bar" } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).values( "name" );

                    expect( results ).toBe( [ "foo", "bar" ] );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    } );
                } );
            } );

            describe( "implode", function() {
                it( "can join the values of all columns together in to a single value", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [
                        { name = "foo" },
                        { name = "bar" },
                        { name = "baz" }
                    ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).implode( "name" );

                    expect( results ).toBe( "foobarbaz" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "can specify a custom glue string when imploding", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "name", "varchar", [
                        { name = "foo" },
                        { name = "bar" },
                        { name = "baz" }
                    ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).implode( "name", "-" );

                    expect( results ).toBe( "foo-bar-baz" );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT ""name"" FROM ""users""",
                        options = {}
                    } );
                } );
            } );
        } );

        describe( "aggregate functions", function() {
            describe( "count", function() {
                it( "can count all the records on a table", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedCount } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).count();

                    expect( results ).toBe( expectedCount );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "can count a specific column", function() {
                    var builder = getBuilder();
                    var expectedCount = 1;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedCount } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT COUNT(""name"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).count( "name" );

                    expect( results ).toBe( expectedCount );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT COUNT(""name"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    } );
                } );

                it( "should maintain selected columns after an aggregate has been executed", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = 1 } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    builder.select( [ "id", "name" ] ).from( "users" );
                    builder.from( "users" ).count();

                    expect( builder.getColumns() ).toBe( [ "id", "name" ] );
                } );

                it( "should clear out the aggregate properties after an aggregate has been executed", function() {
                    var builder = getBuilder();
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = 1 } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT COUNT(*) AS ""aggregate"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    builder.from( "users" ).count();

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );
            } );

            describe( "max", function() {
                it( "can return the max record of a table", function() {
                    var builder = getBuilder();
                    var expectedMax = 54;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedMax } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT MAX(""age"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).max( "age" );

                    expect( results ).toBe( expectedMax );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT MAX(""age"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );
            } );

            describe( "min", function() {
                it( "can return the min record of a table", function() {
                    var builder = getBuilder();
                    var expectedMin = 3;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedMin } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT MIN(""age"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).min( "age" );

                    expect( results ).toBe( expectedMin );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT MIN(""age"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );
            } );

            describe( "sum", function() {
                it( "can return the sum of a column in a table", function() {
                    var builder = getBuilder();
                    var expectedSum = 42;
                    var expectedQuery = queryNew( "aggregate", "integer", [ { aggregate = expectedSum } ] );
                    builder.$( "runQuery" ).$args(
                        sql = "SELECT SUM(""answers"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    ).$results( expectedQuery );

                    var results = builder.from( "users" ).sum( "answers" );

                    expect( results ).toBe( expectedSum );

                    var runQueryLog = builder.$callLog().runQuery;
                    expect( runQueryLog ).toBeArray();
                    expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                    expect( runQueryLog[ 1 ] ).toBe( {
                        sql = "SELECT SUM(""answers"") AS ""aggregate"" FROM ""users""",
                        options = {}
                    } );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );
            } );

            describe( "exists", function() {
                it( "returns true if any records come back from the query", function() {
                    var builder = getBuilder();
                    builder.$( "runQuery", queryNew( "name,email", "CF_SQL_VARCHAR,CF_SQL_VARCHAR", [
                        { name = "foo", email = "bar" }
                    ] ) );
                    expect( builder.select( "*" ).from( "users" ).exists() ).toBe( true );

                    expect( builder.getAggregate() ).toBeEmpty( "Aggregate should have been cleared after running" );
                } );

                it( "returns false if no records come back from the query", function() {
                    var builder = getBuilder();
                    builder.$( "runQuery", queryNew( "name,email", "CF_SQL_VARCHAR,CF_SQL_VARCHAR", [] ) );
                    expect( builder.select( "*" ).from( "users" ).exists() ).toBe( false );
                } );
            } );
        } );

        describe( "returnFormat", function() {
            it( "has a default return value of array", function() {
                var builder = getBuilder();
                var data = [ { id = 1 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder.$( "runQuery" ).$args(
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                ).$results( expectedQuery );

                var results = builder.select( "id" ).from( "users" ).get();

                expect( results ).toBe( data );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ] ).toBe( {
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                } );
            } );

            it( "can return an array of structs", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "array" );
                var data = [ { id = 1 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder.$( "runQuery" ).$args(
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                ).$results( expectedQuery );

                var results = builder.select( "id" ).from( "users" ).get();

                expect( results ).toBe( data );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ] ).toBe( {
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                } );
            } );

            it( "can return a query", function() {
                var builder = getBuilder();
                builder.setReturnFormat( "query" );
                var data = [ { id = 1 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder.$( "runQuery" ).$args(
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                ).$results( expectedQuery );

                var results = builder.select( "id" ).from( "users" ).get();

                expect( results ).toBe( expectedQuery );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ] ).toBe( {
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                } );
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
                var data = [ { id = 1 }, { id = 2 } ];
                var expectedQuery = queryNew( "id", "integer", data );
                builder.$( "runQuery" ).$args(
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                ).$results( expectedQuery );

                var results = builder.select( "id" ).from( "users" ).get();

                expect( results ).toBe( [ { id = 2 }, { id = 4 } ] );
                var runQueryLog = builder.$callLog().runQuery;
                expect( runQueryLog ).toBeArray();
                expect( runQueryLog ).toHaveLength( 1, "runQuery should have been called once" );
                expect( runQueryLog[ 1 ] ).toBe( {
                    sql = "SELECT ""id"" FROM ""users""",
                    options = {}
                } );
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
        var grammar = getMockBox()
            .createMock( "qb.models.Grammars.BaseGrammar" );
        var queryUtils = getMockBox()
            .createMock( "qb.models.Query.QueryUtils" );
        var builder = getMockBox().createMock( "qb.models.Query.QueryBuilder" )
            .init( grammar, queryUtils );
        return builder;
    }

    private array function getTestBindings( builder ) {
        return builder.getBindings().map( function( binding ) {
            return binding.value;
        } );
    }

}
