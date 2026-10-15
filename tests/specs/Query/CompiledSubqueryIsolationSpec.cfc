component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "immediately compiled subquery isolation", function() {
            for (
                var mode in [
                    "fromSub",
                    "joinSub",
                    "crossJoinSub",
                    "crossApply",
                    "outerApply"
                ]
            ) {
                for ( var asCallback in [ false, true ] ) {
                    for ( var withCTE in [ false, true ] ) {
                        it(
                            title = "isolates #mode# input (callback=#asCallback#, CTE=#withCTE#)",
                            data = { mode: mode, asCallback: asCallback, withCTE: withCTE },
                            body = function( data ) {
                                var owner = newBuilder().from( "accounts" ).where( "accounts.tenant_id", 99 );
                                var captured = configureSource( newBuilder(), data.withCTE );
                                var sourceSQL = captured.toSQL();
                                var sourceBindings = duplicate( captured.getBindings() );
                                var input = captured;
                                if ( data.asCallback ) {
                                    input = function( child ) {
                                        captured = configureSource( child, data.withCTE );
                                    };
                                }
                                attach( owner, input, data.mode );
                                var attachedSQL = owner.toSQL();
                                var attachedBindings = duplicate( owner.getBindings() );
                                expect( captured.toSQL() ).toBe( sourceSQL );
                                expect( captured.getBindings() ).toBe( sourceBindings );
                                expect( captured.getCommonTables() ).toHaveLength( data.withCTE ? 1 : 0 );
                                expect( owner.getCommonTables() ).toHaveLength( data.withCTE ? 1 : 0 );

                                captured.where( "source.id", -1 ).selectRaw( "? AS added", [ -2 ] );
                                captured.getRawBindings().select[ 1 ].value = -10;
                                captured.getRawBindings().where[ 1 ].value = -20;
                                captured.getRawBindings().orderBy[ 1 ].value = -40;
                                captured.getWheres()[ 2 ].query.where( "id", -30 );
                                if ( data.withCTE ) {
                                    captured.getCommonTables()[ 1 ].query.where( "id", -5 );
                                    captured.getRawBindings().commonTables[ 1 ].value = -5;
                                }
                                expect( owner.toSQL() ).toBe( attachedSQL );
                                expect( owner.getBindings() ).toBe( attachedBindings );
                            }
                        );
                    }
                }
            }

            it( "leaves the owner and source unchanged when non-CTE compilation fails", function() {
                var owner = newBuilder().from( "accounts" ).where( "id", 99 );
                var source = newBuilder()
                    .from( "users" )
                    .select( [ "id", "id" ] )
                    .setValidateDuplicateSelectColumns( true );
                var ownerSQL = owner.toSQL();
                var ownerBindings = duplicate( owner.getBindings() );
                expect( function() {
                    owner.fromSub( "derived", source );
                } ).toThrow();
                expect( owner.toSQL() ).toBe( ownerSQL );
                expect( owner.getBindings() ).toBe( ownerBindings );
                expect( source.getColumns() ).toHaveLength( 2 );
                expect( source.getCommonTables() ).toBeEmpty();
            } );

            it( "preserves independently configured wrapping policies", function() {
                var source = configureSource( newBuilder(), false ).withoutWrappingValues();
                var originalSQL = source.toSQL();
                var owner = newBuilder().fromSub( "derived", source );
                expect( owner.toSQL() ).toInclude( "SELECT TOP (1) id, ? AS score FROM source" );
                expect( owner.toSQL() ).toInclude( "AS [derived]" );
                expect( source.toSQL() ).toBe( originalSQL );
                expect( source.getShouldWrapValues() ).toBeFalse();
            } );
        } );
    }

    private function newBuilder() {
        return new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
    }

    private function configureSource( required any query, required boolean withCTE ) {
        arguments.query
            .from( "source" )
            .select( "id" )
            .selectRaw( "? AS score", [ 10 ] )
            .where( "tenant_id", 20 )
            .whereExists( function( child ) {
                child.from( "children" ).where( "active", 30 );
            } )
            .orderByRaw( "CASE WHEN ? = 1 THEN id END", [ 40 ] )
            .limit( 1 );
        if ( arguments.withCTE ) {
            arguments.query.with( "seed", function( cte ) {
                cte.from( "seed_rows" ).where( "active", 5 );
            } );
        }
        return arguments.query;
    }

    private void function attach( required any owner, required any input, required string mode ) {
        switch ( arguments.mode ) {
            case "fromSub":
                arguments.owner.fromSub( "derived", arguments.input );
                break;
            case "joinSub":
                arguments.owner.joinSub(
                    "derived",
                    arguments.input,
                    "derived.id",
                    "=",
                    "accounts.id"
                );
                break;
            case "crossJoinSub":
                arguments.owner.crossJoinSub( "derived", arguments.input );
                break;
            case "crossApply":
                arguments.owner.crossApply( "derived", arguments.input );
                break;
            case "outerApply":
                arguments.owner.outerApply( "derived", arguments.input );
                break;
        }
    }

}
