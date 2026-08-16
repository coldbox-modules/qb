component extends="tests.resources.querybuilder.AbstractQueryBuilderBaseSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "basic selects", function() {
                    it( "can select all columns from a table", function() {
                        testCase( function( builder ) {
                            builder.select( "*" ).from( "users" );
                        }, selectAllColumns() );
                    } );

                    it( "can specify the column to select", function() {
                        testCase( function( builder ) {
                            builder.select( "name" ).from( "users" );
                        }, selectSpecificColumn() );
                    } );

                    it( "can select multiple columns using an array", function() {
                        testCase( function( builder ) {
                            builder.select( [ "name", builder.raw( "COUNT(*)" ) ] ).from( "users" );
                        }, selectMultipleArray() );
                    } );

                    it( "can add selects to a query", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "foo" )
                                .addSelect( "bar" )
                                .addSelect( [ "baz", "boom" ] )
                                .from( "users" );
                        }, addSelect() );
                    } );

                    it( "adding a select to a * query gets rid of the star", function() {
                        testCase( function( builder ) {
                            builder.addSelect( "foo" ).from( "users" );
                        }, addSelectRemovesStar() );
                    } );

                    it( "can select distinct records", function() {
                        testCase( function( builder ) {
                            builder
                                .distinct()
                                .select( [ "foo", "bar" ] )
                                .from( "users" );
                        }, selectDistinct() );
                    } );

                    it( "can parse column aliases", function() {
                        testCase( function( builder ) {
                            builder.select( "foo as bar" ).from( "users" );
                        }, parseColumnAlias() );
                    } );

                    it( "does not change aliases when quoted", function() {
                        testCase( function( builder ) {
                            builder.select( "foo as ""bar""" ).from( "users" );
                        }, parseColumnAliasWithQuotes() );
                    } );

                    it( "can parse column aliases in where clauses", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "users.foo" )
                                .from( "users" )
                                .where( "users.foo", "bar" );
                        }, parseColumnAliasInWhere() );
                    } );

                    it( "can parse column aliases in where clauses with subselects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users u" )
                                .select( "u.*, user_roles.roleid, roles.rolecode" )
                                .join( "user_roles", "user_roles.userid", "u.userid" )
                                .leftjoin( "roles", "user_roles.roleid", "roles.roleid" )
                                .where(
                                    "user_roles.roleid",
                                    "=",
                                    function( q ) {
                                        q.select( "roleid" )
                                            .from( "roles" )
                                            .where( "rolecode", "SYSADMIN" );
                                    }
                                );
                        }, parseColumnAliasInWhereSubselect() );
                    } );

                    it( "can also parse column aliases in whereColumn clauses with subselects", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users u" )
                                .select( "u.*, user_roles.roleid, roles.rolecode" )
                                .join( "user_roles", "user_roles.userid", "u.userid" )
                                .leftjoin( "roles", "user_roles.roleid", "roles.roleid" )
                                .whereColumn(
                                    "user_roles.roleid",
                                    "=",
                                    function( q ) {
                                        q.select( "roleid" )
                                            .from( "roles" )
                                            .where( "rolecode", "SYSADMIN" );
                                    }
                                );
                        }, parseColumnAliasInWhereSubselect() );
                    } );

                    it( "wraps columns and aliases correctly", function() {
                        testCase( function( builder ) {
                            builder.select( "x.y as foo.bar" ).from( "public.users" );
                        }, wrapColumnsAndAliases() );
                    } );

                    it( "handles dynamic whereColumns", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "ID" )
                                .from( "users" )
                                .whereID( 1 );
                        }, dynamicWhere() );
                    } );

                    it( "parses operators in dynamic whereColumns", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "ID" )
                                .from( "users" )
                                .whereID( ">", 1 );
                        }, parseOperatorsWithDynamicWhere() );
                    } );

                    it( "parses operators in dynamic andWhereColumns", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "ID" )
                                .from( "users" )
                                .whereID( ">", 1 )
                                .andWhereID( "<", 10 );
                        }, parseOperatorsWithDynamicAndWhere() );
                    } );

                    it( "parses operators in dynamic orWhereColumns", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "ID" )
                                .from( "users" )
                                .whereID( ">", 1 )
                                .orWhereID( "<", 0 );
                        }, parseOperatorsWithDynamicOrWhere() );
                    } );

                    it( "selects raw values correctly", function() {
                        testCase( function( builder ) {
                            builder.select( builder.raw( "substr( foo, 6 )" ) ).from( "users" );
                        }, selectWithRaw() );
                    } );

                    it( "can easily select raw values with `selectRaw`", function() {
                        testCase( function( builder ) {
                            builder.selectRaw( "substr( foo, 6 )" ).from( "users" );
                        }, selectRaw() );
                    } );

                    it( "can select multiple raw values with `selectRaw` when passing in an array", function() {
                        testCase( function( builder ) {
                            builder.from( "users" ).selectRaw( [ "substr( foo, 6 )", "trim( bar )" ] );
                        }, selectRawArray() );
                    } );

                    it( "preserves bindings carried by expressions across select clauses", function() {
                        var builder = getBuilder();
                        builder
                            .select( builder.raw( "? AS selectedValue", [ 1 ] ) )
                            .from( builder.raw( "(SELECT ? AS id) source", [ 2 ] ) )
                            .where( "id", ">", builder.raw( "?", [ 3 ] ) )
                            .whereIn( "id", [ 4, builder.raw( "?", [ 5 ] ) ] )
                            .groupBy( builder.raw( "?", [ 6 ] ) )
                            .having( "id", ">", builder.raw( "?", [ 7 ] ) )
                            .orderBy( { column: builder.raw( "?", [ 8 ] ) } );

                        expect( reMatch( "\?", builder.toSQL() ) ).toHaveLength( 8 );
                        expect( getTestBindings( builder ) ).toBe( [ 1, 2, 3, 4, 5, 6, 7, 8 ] );
                    } );

                    it( "preserves bindings carried by expression columns across predicates", function() {
                        var builder = getBuilder();
                        builder
                            .from( "users" )
                            .whereIn( builder.raw( "COALESCE(?, id)", [ 1 ] ), [ 2 ] )
                            .whereNull( builder.raw( "NULLIF(?, id)", [ 3 ] ) )
                            .whereBetween( builder.raw( "COALESCE(?, id)", [ 4 ] ), 5, 6 )
                            .whereColumn(
                                builder.raw( "COALESCE(?, id)", [ 7 ] ),
                                "=",
                                builder.raw( "COALESCE(?, other_id)", [ 8 ] )
                            )
                            .where(
                                builder.raw( "COALESCE(?, id)", [ 9 ] ),
                                "=",
                                function( query ) {
                                    query
                                        .select( "id" )
                                        .from( "accounts" )
                                        .where( "active", 10 );
                                }
                            )
                            .whereIn( builder.raw( "COALESCE(?, id)", [ 11 ] ), function( query ) {
                                query
                                    .select( "id" )
                                    .from( "accounts" )
                                    .where( "active", 12 );
                            } );

                        expect( reMatch( "\?", builder.toSQL() ) ).toHaveLength( 12 );
                        expect( getTestBindings( builder ) ).toBe( [
                            1,
                            2,
                            3,
                            4,
                            5,
                            6,
                            7,
                            8,
                            9,
                            10,
                            11,
                            12
                        ] );
                    } );

                    it( "preserves bindings carried by expression columns in bulk predicates", function() {
                        var builder = getBuilder();
                        builder.from( "users" ).whereInBulk( builder.raw( "COALESCE(?, id)", [ 1 ] ), [ 2, 3 ] );

                        expect( getTestBindings( builder )[ 1 ] ).toBe( 1 );
                        expect( deserializeJSON( getTestBindings( builder )[ 2 ] ) ).toBe( [ 2, 3 ] );
                    } );

                    it( "preserves bindings carried by expression join tables", function() {
                        var builder = getBuilder();
                        builder
                            .from( "users" )
                            .join(
                                builder.raw( "(SELECT ? AS id) joined", [ 1 ] ),
                                "joined.id",
                                "=",
                                "users.id"
                            )
                            .crossJoin( builder.raw( "(SELECT ? AS id) crossed", [ 2 ] ) );

                        expect( reMatch( "\?", builder.toSQL() ) ).toHaveLength( 2 );
                        expect( getTestBindings( builder ) ).toBe( [ 1, 2 ] );
                        expect( getTestBindings( builder.clone() ) ).toBe( [ 1, 2 ] );
                    } );

                    it( "provides a grammar-specific helper for concat", function() {
                        testCase( function( builder ) {
                            builder.select( builder.concat( "my_alias", "a,b,c,d" ) ).from( "users" );
                        }, selectConcat() );
                    } );

                    it( "concat can accept an array of values", function() {
                        testCase( function( builder ) {
                            // I kid you not, ACF2018 wouldn't let me pass `[ "a", "b", "c", "d" ]`
                            var items = [];
                            items
                                .append( "a" )
                                .append( "b" )
                                .append( "c" )
                                .append( "d" );

                            builder.select( builder.concat( "my_alias", items ) ).from( "users" );
                        }, selectConcatArray() );
                    } );

                    it( "can clear the selected columns for a query", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( [ "foo", "bar" ] )
                                .clearSelect();
                        }, clearSelect() );
                    } );

                    it( "can reselect the columns for a query", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( [ "foo", "bar" ] )
                                .reselect( "baz" );
                        }, reselect() );
                    } );

                    it( "can reselect the columns for a query with raw expressions", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .select( [ "foo", "bar" ] )
                                .reselectRaw( [ "substr( foo, 6 )", "trim( bar )" ] );
                        }, reselectRaw() );
                    } );

                    describe( "wrapping values", function() {
                        it( "wraps values by default", () => {
                            testCase( function( builder ) {
                                builder.from( "users" ).select( [ "foo", "bar" ] );
                            }, wrappingDefault() );
                        } );

                        it( "can configure the grammar to not wrap values by default", () => {
                            testCase( function( builder ) {
                                builder.getGrammar().setShouldWrapValues( false );

                                builder.from( "users" ).select( [ "foo", "bar" ] );
                            }, wrappingGrammarOff() );
                        } );

                        it( "can configure the query builder to not wrap values by default", () => {
                            testCase( function( builder ) {
                                builder.getGrammar().setShouldWrapValues( true );

                                builder
                                    .withoutWrappingValues()
                                    .from( "users" )
                                    .select( [ "foo", "bar" ] );
                            }, wrappingBuilderOverride() );
                        } );
                    } );
                } );
            } );
        } );
    }

}
