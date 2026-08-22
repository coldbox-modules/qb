component extends="testbox.system.BaseSpec" {

    function run() {
    }

    private function testCase( required function callback, required any expected, boolean withFullBindings = false ) {
        try {
            var builder = getBuilder();
            local.sql = callback( builder );
            if ( !isNull( local.sql ) ) {
                if ( !isSimpleValue( local.sql ) ) {
                    local.sql = local.sql.toSQL();
                }
            } else {
                local.sql = builder.toSQL();
            }
            if ( isSimpleValue( expected ) ) {
                expected = { sql: expected, bindings: [] };
            }

            expect( local.sql ).toBeWithCase( expected.sql );
            var testBindings = getTestBindings( builder, arguments.withFullBindings );
            expect( testBindings ).toHaveLength( expected.bindings.len() );
            testBindings.each( ( testBinding, index ) => {
                var expectedBinding = expected.bindings[ index ];
                if ( isStruct( expectedBinding ) ) {
                    expect( testBinding ).toBeStruct();
                    for ( var key in expectedBinding ) {
                        expect( testBinding ).toHaveKey( key );
                        expect( testBinding[ key ] ).toBe( expectedBinding[ key ] );
                    }
                } else {
                    expect( testBinding ).toBe( expectedBinding );
                }
            } );
        } catch ( any e ) {
            if ( !isSimpleValue( expected ) && structKeyExists( expected, "exception" ) ) {
                if ( e.type != expected.exception ) {
                    debug( e );
                    expect( e.type ).toBe( expected.exception );
                }
                return;
            }
            rethrow;
        }
    }

    private function getBuilder() {
        throw( "Must be implemented in a subclass" );
    }

    string function bulkTimestampSqlType() {
        return "TIMESTAMP";
    }

    string function bulkExplicitSqlType() {
        return "BIGINT";
    }

    private array function getTestBindings( required QueryBuilder builder, boolean withFullBindings = false ) {
        return builder
            .getBindings()
            .map( function( binding ) {
                if ( builder.getUtils().isExpression( binding ) ) {
                    return binding.getSQL();
                } else {
                    if ( binding.null ) {
                        return "NULL";
                    } else {
                        return withFullBindings ? binding : binding.value;
                    }
                }
            } );
    }

}
