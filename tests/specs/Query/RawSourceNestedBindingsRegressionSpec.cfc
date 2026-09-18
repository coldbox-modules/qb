component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Raw source nested predicate bindings", function() {
            it( "does not duplicate source bindings in a nested null predicate", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder
                    .fromRaw( "openjson(?) xjson", [ "[null]" ] )
                    .where( function( nested ) {
                        nested.whereNull( "value" );
                    } );
                expect( builder.toSQL() ).toBe( "SELECT * FROM openjson(?) xjson WHERE ([value] IS NULL)" );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ "[null]" ] );
            } );

            it( "keeps source and deeply nested predicate bindings in SQL order", function() {
                var builder = new qb.models.Query.QueryBuilder( grammar = new qb.models.Grammars.SqlServerGrammar() );
                builder
                    .fromRaw( "openjson(?) xjson", [ "[1,2]" ] )
                    .where( function( nested ) {
                        nested
                            .where( "value", 1 )
                            .orWhere( function( inner ) {
                                inner.where( "value", 2 );
                            } );
                    } );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ "[1,2]", 1, 2 ] );
            } );

            it( "preserves a parent alias for nested predicate callbacks", function() {
                var builder = new qb.models.Query.QueryBuilder();
                builder
                    .from( "users u" )
                    .where( function( nested ) {
                        expect( nested.getTableName() ).toBe( "users" );
                        expect( nested.getAlias() ).toBe( "u" );
                        nested.where( "u.id", 1 );
                    } );
                expect( builder.getBindings().map( ( binding ) => binding.value ) ).toBe( [ 1 ] );
            } );
        } );
    }

}
