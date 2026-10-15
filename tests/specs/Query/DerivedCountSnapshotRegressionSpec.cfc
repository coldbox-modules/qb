component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "derived count snapshots", function() {
            for ( var mode in [ "group", "distinct", "having" ] ) {
                it(
                    title = "preserves source CTEs and order bindings for #mode# pagination",
                    data = { mode: mode },
                    body = function( data ) {
                        var builder = getBuilder()
                            .with( "active_users", function( cte ) {
                                cte.from( "users" ).where( "active", 1 );
                            } )
                            .from( "active_users" )
                            .select( "id" )
                            .where( "id", ">", 2 )
                            .orderByRaw( "CASE WHEN ? = 1 THEN id END", [ 99 ] );
                        if ( data.mode == "distinct" ) {
                            builder.distinct();
                        } else {
                            builder.groupBy( "id" );
                            if ( data.mode == "having" ) {
                                builder.having( "id", ">", 3 );
                            }
                        }
                        var sourceSQL = builder.toSQL();
                        var sourceBindings = duplicate( builder.getBindings() );

                        var result = builder.paginate();
                        var countCall = builder.getGrammar().$callLog().runQuery[ 1 ];
                        expect( result.pagination.totalRecords ).toBe( 2 );
                        expect( countCall.sql ).toInclude( ";WITH [active_users]" );
                        expect( countCall.sql ).toInclude( "AS [aggregate_table]" );
                        expect( countCall.sql ).notToInclude( "CASE WHEN" );
                        expect( countCall.bindings.map( ( binding ) => binding.value ) ).toBe(
                            data.mode == "having" ? [ 1, 2, 3 ] : [ 1, 2 ]
                        );
                        builder.setLimitValue( javacast( "null", "" ) ).setOffsetValue( javacast( "null", "" ) );
                        expect( builder.toSQL() ).toBe( sourceSQL );
                        expect( builder.getBindings() ).toBe( sourceBindings );
                        expect( builder.getCommonTables() ).toHaveLength( 1 );
                    }
                );
            }

            it( "can repeatedly aggregate a union with CTEs without changing its source", function() {
                var builder = getBuilder()
                    .with( "active_users", function( cte ) {
                        cte.from( "users" ).where( "active", 1 );
                    } )
                    .from( "active_users" )
                    .select( "id" )
                    .where( "id", 2 )
                    .union( function( archived ) {
                        archived
                            .from( "archived_users" )
                            .select( "id" )
                            .where( "id", 3 );
                    } );
                var sourceSQL = builder.toSQL();
                var sourceBindings = duplicate( builder.getBindings() );
                for ( var i = 1; i <= 2; i++ ) {
                    var countSQL = builder.count( toSQL = true );
                    expect( countSQL ).toInclude( ";WITH [active_users]" );
                    expect( countSQL ).toInclude( "AS [qb_aggregate_source]" );
                    expect( countSQL ).toInclude( "UNION" );
                    expect( builder.toSQL() ).toBe( sourceSQL );
                    expect( builder.getBindings() ).toBe( sourceBindings );
                    expect( builder.getCommonTables() ).toHaveLength( 1 );
                }
            } );
        } );
    }

    private function getBuilder() {
        var grammar = getMockBox().createMock( "qb.models.Grammars.SqlServerGrammar" ).init();
        grammar.$( "runQuery", queryNew( "aggregate", "integer", [ { aggregate: 2 } ] ) );
        return new qb.models.Query.QueryBuilder( grammar = grammar );
    }

}
