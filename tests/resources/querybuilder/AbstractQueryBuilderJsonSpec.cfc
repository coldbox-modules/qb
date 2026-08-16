component extends="tests.resources.querybuilder.AbstractQueryBuilderPaginationSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "JSON support", function() {
                it( "selects scalar values with explicit and arrow syntax", function() {
                    testCase( function( builder ) {
                        return builder
                            .select( [
                                builder.jsonPath(
                                    column = "profile",
                                    path = [ "contacts", 0, "email" ],
                                    alias = "explicitName"
                                ),
                                "profile->contacts->0->email AS shortcutName"
                            ] )
                            .from( "users" );
                    }, jsonScalarSelect() );
                } );

                it( "uses scalar values in predicates with explicit and arrow syntax", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .where( builder.jsonPath( column = "profile", path = [ "age" ] ), ">=", 21 )
                            .where( "profile->age", "<", 65 );
                    }, jsonScalarWhere() );
                } );

                it( "checks containment with explicit and arrow syntax", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereJsonContains( column = "profile", path = [ "languages" ], value = "en" )
                            .whereJsonContains( "profile->languages", "en" );
                    }, jsonContains() );
                } );

                it( "checks path existence with explicit and arrow syntax", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereJsonExists( column = "profile", path = [ "name" ] )
                            .whereJsonExists( "profile->name" );
                    }, jsonExists() );
                } );

                it( "checks array length and orders scalar values with both syntaxes", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereJsonLength(
                                column = "profile",
                                path = [ "languages" ],
                                operator = ">",
                                value = 1
                            )
                            .whereJsonLength( "profile->languages", ">", 1 )
                            .orderBy( builder.jsonPath( "profile", [ "name" ] ) )
                            .orderByDesc( "profile->name" );
                    }, jsonLengthAndOrder() );
                } );

                it( "defaults JSON length comparisons to equality with both syntaxes", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereJsonLength( column = "profile", path = [ "languages" ], value = 1 )
                            .whereJsonLength( "profile->languages", 1 )
                            .orWhereJsonLength( column = "profile", path = [ "languages" ], value = 2 )
                            .orWhereJsonLength( "profile->languages", 2 );
                    }, jsonLengthEqualityShortcut() );
                } );

                it( "supports compound containment values with both syntaxes", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereJsonContains( column = "profile", path = [ "languages" ], value = [ "en", "de" ] )
                            .whereJsonContains( "profile->languages", [ "en", "de" ] );
                    }, jsonCompoundContains() );
                } );

                it( "preserves an empty array passed as a shortcut containment value", function() {
                    testCase( function( builder ) {
                        return builder.from( "users" ).whereJsonContains( "profile->languages", [] );
                    }, jsonEmptyCompoundContains() );
                } );

                it(
                    title = "preserves explicit paths when checking containment for JSON null",
                    body = function() {
                        testCase( function( builder ) {
                            return builder
                                .from( "users" )
                                .whereJsonContains(
                                    column = "profile",
                                    path = [ "languages" ],
                                    value = javacast( "null", "" )
                                )
                                .whereJsonContains( "profile->languages", javacast( "null", "" ) );
                        }, jsonNullContains() );
                    },
                    skip = function() {
                        var fullNull = createObject( "java", "java.lang.System" ).getEnv( "FULL_NULL" );
                        return isNull( fullNull ) || !fullNull;
                    }
                );

                it( "distinguishes explicit numeric object keys from shortcut array indexes", function() {
                    testCase( function( builder ) {
                        return builder
                            .select( [ builder.jsonPath( "profile", [ "0" ], "explicitKey" ), "profile->0 AS shortcutIndex" ] )
                            .from( "users" );
                    }, jsonNumericObjectKey() );
                } );

                it( "supports JSON boolean and negative convenience methods", function() {
                    testCase( function( builder ) {
                        return builder
                            .from( "users" )
                            .whereJsonDoesntContain( column = "profile", path = [ "languages" ], value = "en" )
                            .orWhereJsonDoesntContain( "profile->languages", "fr" )
                            .orWhereJsonContains( column = "profile", path = [ "languages" ], value = "de" )
                            .whereJsonDoesntExist( column = "profile", path = [ "nickname" ] )
                            .orWhereJsonExists( "profile->name" )
                            .orWhereJsonDoesntExist( "profile->timezone" )
                            .orWhereJsonLength(
                                column = "profile",
                                path = [ "languages" ],
                                operator = ">",
                                value = 1
                            );
                    }, jsonConveniencePredicates() );
                } );
            } );
        } );
    }

}
