component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "binding lifecycle", function() {
            it( "replaces derived-table bindings when replacing the FROM source", function() {
                var builder = new qb.models.Query.QueryBuilder();

                builder.fromSub( "source", function( query ) {
                    query.from( "orders" ).where( "kind", "retail" );
                } );
                builder.fromSub( "source", function( query ) {
                    query.from( "payments" ).where( "status", "settled" );
                } );

                expect( builder.toSql() ).toBe(
                    "SELECT * FROM (SELECT * FROM ""payments"" WHERE ""status"" = ?) AS ""source"""
                );
                expect( builder.getBindings() ).toHaveLength( 1 );
                expect( builder.getBindings()[ 1 ].value ).toBe( "settled" );
            } );

            it( "clears the previous alias when replacing the FROM source", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users AS old_source" ).from( "payments" );

                expect( builder.toSql() ).toBe( "SELECT * FROM ""payments""" );
            } );

            it( "removes HAVING bindings that are not part of an INSERT", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).having( "age", ">", 21 );

                expect( builder.insert( { name: "new user" }, {}, true ) ).toBe(
                    "INSERT INTO ""users"" (""name"") VALUES (?)"
                );

                expect( builder.getBindings() ).toHaveLength( 1 );
                expect( builder.getBindings()[ 1 ].value ).toBe( "new user" );
            } );

            it( "preserves an explicit null HAVING value", function() {
                var builder = new qb.models.Query.QueryBuilder()
                    .from( "users" )
                    .having( "score", "=", javacast( "null", "" ) );

                expect( builder.getHavings()[ 1 ].operator ).toBe( "=" );
                expect( builder.getRawBindings().having[ 1 ].null ).toBeTrue();
                expect( builder.getRawBindings().having[ 1 ].value ).toBe( "" );
                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users"" HAVING ""score"" = ?" );
            } );

            it( "does not retain basic predicate state when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.where( "id", "=", { unexpected: "value" } );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getWheres() ).toBeEmpty();
                expect( builder.getRawBindings().where ).toBeEmpty();
            } );

            it( "does not retain IN predicate state when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.whereIn( "id", [ 1, { unexpected: "value" } ] );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getWheres() ).toBeEmpty();
                expect( builder.getRawBindings().where ).toBeEmpty();
            } );

            it( "does not retain BETWEEN bindings when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.whereBetween( "id", 1, { unexpected: "value" } );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getWheres() ).toBeEmpty();
                expect( builder.getRawBindings().where ).toBeEmpty();
            } );

            it( "does not retain HAVING state when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.having( "score", ">", { unexpected: "value" } );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getHavings() ).toBeEmpty();
                expect( builder.getRawBindings().having ).toBeEmpty();
            } );

            it( "does not retain raw HAVING state when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.having( builder.raw( "COUNT(*) > ?", [ { unexpected: "value" } ] ) );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getHavings() ).toBeEmpty();
                expect( builder.getRawBindings().having ).toBeEmpty();
            } );

            it( "does not retain JSON length state when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.whereJsonLength( "profile->languages", "=", { unexpected: "value" } );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getWheres() ).toBeEmpty();
                expect( builder.getRawBindings().where ).toBeEmpty();
            } );

            it( "restores aggregate state when aggregate binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).orderBy( "name" );

                expect( function() {
                    builder.sum( builder.raw( "?", [ { unexpected: "value" } ] ) );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getAggregate() ).toBeEmpty();
                expect( builder.getOrders() ).toHaveLength( 1 );
                expect( builder.getRawBindings().aggregate ).toBeEmpty();
            } );

            it( "does not retain joins when raw table binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.join(
                        builder.raw( "accounts ?", [ { unexpected: "value" } ] ),
                        "users.id",
                        "=",
                        "accounts.user_id"
                    );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getJoins() ).toBeEmpty();
                expect( builder.getRawBindings().join ).toBeEmpty();
            } );

            it( "preserves selected columns when replacement binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).select( "id" );

                expect( function() {
                    builder.select( builder.raw( "?", [ { unexpected: "value" } ] ) );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.toSQL() ).toBe( "SELECT ""id"" FROM ""users""" );
                expect( builder.getRawBindings().select ).toBeEmpty();
            } );

            it( "does not retain added columns when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).select( "id" );

                expect( function() {
                    builder.addSelect( builder.raw( "?", [ { unexpected: "value" } ] ) );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.toSQL() ).toBe( "SELECT ""id"" FROM ""users""" );
                expect( builder.getRawBindings().select ).toBeEmpty();
            } );

            it( "preserves the FROM source when raw binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                expect( function() {
                    builder.fromRaw( "accounts ?", [ { unexpected: "value" } ] );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.toSQL() ).toBe( "SELECT * FROM ""users""" );
                expect( builder.getRawBindings().from ).toBeEmpty();
            } );

            it( "does not retain grouping state when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).groupBy( "team_id" );

                expect( function() {
                    builder.groupBy( builder.raw( "?", [ { unexpected: "value" } ] ) );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getGroups() ).toHaveLength( 1 );
                expect( builder.getRawBindings().groupBy ).toBeEmpty();
            } );

            it( "does not retain ordering state when binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).orderBy( "name" );

                expect( function() {
                    builder.orderBy( builder.raw( "?", [ { unexpected: "value" } ] ) );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getOrders() ).toHaveLength( 1 );
                expect( builder.getRawBindings().orderBy ).toBeEmpty();
            } );

            it( "preserves selected columns when raw reselection binding validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" ).select( "id" );

                expect( function() {
                    builder.reselectRaw( "?", [ { unexpected: "value" } ] );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.toSQL() ).toBe( "SELECT ""id"" FROM ""users""" );
                expect( builder.getRawBindings().select ).toBeEmpty();
            } );

            it( "replaces update bindings when reusing a builder", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                builder.update( values = { "name": "first" }, toSQL = true );
                builder.update( values = { "name": "second" }, toSQL = true );

                expect( builder.getRawBindings().update ).toHaveLength( 1 );
                expect( builder.getRawBindings().update[ 1 ].value ).toBe( "second" );
            } );

            it( "preserves update bindings when replacement validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );
                builder.update( values = { "name": "first" }, toSQL = true );

                expect( function() {
                    builder.update( values = { "name": { "unexpected": "value" } }, toSQL = true );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getRawBindings().update ).toHaveLength( 1 );
                expect( builder.getRawBindings().update[ 1 ].value ).toBe( "first" );
            } );

            it( "replaces insert bindings when reusing a builder", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );

                builder.insert( values = { "name": "first" }, toSQL = true );
                builder.insert( values = { "name": "second" }, toSQL = true );

                expect( builder.getRawBindings().insert ).toHaveLength( 1 );
                expect( builder.getRawBindings().insert[ 1 ].value ).toBe( "second" );
            } );

            it( "preserves insert bindings when replacement validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder().from( "users" );
                builder.insert( values = { "name": "first" }, toSQL = true );

                expect( function() {
                    builder.insert( values = { "name": { "unexpected": "value" } }, toSQL = true );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getRawBindings().insert ).toHaveLength( 1 );
                expect( builder.getRawBindings().insert[ 1 ].value ).toBe( "first" );
            } );

            it( "replaces insert-ignore bindings when reusing a builder", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() ).from(
                    "users"
                );

                builder.insertIgnore( values = { "name": "first" }, toSQL = true );
                builder.insertIgnore( values = { "name": "second" }, toSQL = true );

                expect( builder.getRawBindings().insert ).toHaveLength( 1 );
                expect( builder.getRawBindings().insert[ 1 ].value ).toBe( "second" );
            } );

            it( "preserves insert-ignore bindings when replacement validation fails", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.MySQLGrammar() ).from(
                    "users"
                );
                builder.insertIgnore( values = { "name": "first" }, toSQL = true );

                expect( function() {
                    builder.insertIgnore( values = { "name": { "unexpected": "value" } }, toSQL = true );
                } ).toThrow( type = "QBInvalidQueryParam" );

                expect( builder.getRawBindings().insert ).toHaveLength( 1 );
                expect( builder.getRawBindings().insert[ 1 ].value ).toBe( "first" );
            } );
        } );
    }

}
