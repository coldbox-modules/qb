component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "selective query snapshots", function() {
            it( "omits only root WHERE predicates while isolating retained query graphs", function() {
                var source = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() )
                    .with( "active_users", function( cte ) {
                        cte.from( "users" ).where( "active", 1 );
                    } )
                    .from( "active_users" )
                    .select( "id" )
                    .subSelect( "child_id", function( child ) {
                        child
                            .from( "children" )
                            .select( "id" )
                            .where( "type", 11 );
                    } )
                    .join( "teams", function( join ) {
                        join.on( "teams.id", "active_users.team_id" ).where( "teams.active", 22 );
                    } )
                    .where( "id", 33 )
                    .union( function( branch ) {
                        branch
                            .from( "archived_users" )
                            .select( "id" )
                            .where( "type", 44 );
                    } )
                    .orderByRaw( "CASE WHEN ? = 1 THEN id END", [ 55 ] )
                    .limit( 10 )
                    .offset( 5 )
                    .pretend();
                var sourceSQL = source.toSQL();
                var sourceBindings = duplicate( source.getBindings() );

                var snapshot = source.cloneWithoutWheres();
                expect( snapshot.getWheres() ).toBeEmpty();
                expect( snapshot.getRawBindings().where ).toBeEmpty();
                expect( snapshot.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1, 11, 22, 44, 55 ] );
                expect( snapshot.getColumns()[ 2 ].value.getWheres() ).toHaveLength( 1 );
                expect( snapshot.getJoins()[ 1 ].getWheres() ).toHaveLength( 2 );
                expect( snapshot.getUnions()[ 1 ].query.getWheres() ).toHaveLength( 1 );
                expect( snapshot.getLimitValue() ).toBe( 10 );
                expect( snapshot.getOffsetValue() ).toBe( 5 );
                expect( snapshot.isPretending() ).toBeTrue();

                snapshot.getColumns()[ 2 ].value.where( "id", -1 );
                snapshot.getJoins()[ 1 ].where( "teams.id", -1 );
                snapshot.getUnions()[ 1 ].query.where( "id", -1 );
                snapshot.getCommonTables()[ 1 ].query.where( "id", -1 );
                snapshot.getRawBindings().select[ 1 ].value = -1;
                snapshot.where( "id", 99 );
                expect( source.toSQL() ).toBe( sourceSQL );
                expect( source.getBindings() ).toBe( sourceBindings );
                expect( source.getWheres() ).toHaveLength( 1 );
            } );

            it( "keeps ordinary clones complete and isolated", function() {
                var source = new qb.models.Query.QueryBuilder().from( "users" ).where( "id", 1 );
                var clone = source.clone();
                clone.getRawBindings().where[ 1 ].value = 2;
                clone.where( "active", 1 );
                expect( source.getWheres() ).toHaveLength( 1 );
                expect( source.getBindings()[ 1 ].value ).toBe( 1 );
                expect( clone.getWheres() ).toHaveLength( 2 );
            } );
        } );

        describe( "ordered UNION compilation without graph copies", function() {
            it( "repeatedly compiles CTEs and nested ordered branches without altering query state", function() {
                var source = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() )
                    .with( "active_users", function( cte ) {
                        cte.from( "users" ).where( "active", 1 );
                    } )
                    .from( "active_users" )
                    .select( "id" )
                    .where( "id", 2 )
                    .orderBy( "id" )
                    .limit( 5 )
                    .unionAll( function( branch ) {
                        branch
                            .from( "archived_users" )
                            .select( "id" )
                            .where( "id", 3 )
                            .orderBy( "id" )
                            .limit( 4 );
                        branch.union( function( nested ) {
                            nested
                                .from( "older_users" )
                                .select( "id" )
                                .where( "id", 4 )
                                .orderBy( "id" )
                                .limit( 3 );
                        } );
                    } );
                var expectedSQL = ";WITH [active_users] AS (SELECT * FROM [users] WHERE [active] = ?) SELECT * FROM (SELECT TOP (5) [id] FROM [active_users] WHERE [id] = ? ORDER BY [id] ASC) AS [qb_union_0] UNION ALL SELECT * FROM (SELECT * FROM (SELECT TOP (4) [id] FROM [archived_users] WHERE [id] = ? ORDER BY [id] ASC) AS [qb_union_0] UNION SELECT * FROM (SELECT TOP (3) [id] FROM [older_users] WHERE [id] = ? ORDER BY [id] ASC) AS [qb_union_1]) AS [qb_union_1]";
                for ( var i = 1; i <= 2; i++ ) {
                    expect( source.toSQL() ).toBe( expectedSQL );
                    expect( source.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1, 2, 3, 4 ] );
                    expect( source.getCommonTables() ).toHaveLength( 1 );
                    expect( source.getUnions()[ 1 ].query.getUnions() ).toHaveLength( 1 );
                }
            } );

            it( "restores grammar wrapping and preserves branches after failed compilation", function() {
                var grammar = new qb.models.Grammars.SqlServerGrammar();
                var source = new qb.models.Query.QueryBuilder( grammar = grammar )
                    .from( "users" )
                    .withoutWrappingValues()
                    .unionAll( function( branch ) {
                        branch.from( "archived_users" ).orderBy( "id" );
                    } );
                var originalWrapping = grammar.getShouldWrapValues();
                expect( function() {
                    source.toSQL();
                } ).toThrow( "OrderByNotAllowed" );
                expect( grammar.getShouldWrapValues() ).toBe( originalWrapping );
                expect( source.getUnions() ).toHaveLength( 1 );
                expect( source.getUnions()[ 1 ].query.getOrders() ).toHaveLength( 1 );
                source.getUnions()[ 1 ].query.limit( 5 );
                expect( source.toSQL() ).toInclude( "SELECT TOP (5)" );
                expect( grammar.getShouldWrapValues() ).toBe( originalWrapping );
            } );
        } );
    }

}
