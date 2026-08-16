component extends="tests.resources.querybuilder.AbstractQueryBuilderSubselectSpec" {

    function run() {
        super.run();

        describe( "query builder + grammar integration", function() {
            describe( "select statements", function() {
                describe( "from", function() {
                    it( "can specify the table to select from", function() {
                        testCase( function( builder ) {
                            builder.from( "users" );
                        }, from() );
                    } );

                    it( "can specify a Expression object as the input for from", function() {
                        testCase( function( builder ) {
                            builder.from( builder.raw( "Test (nolock)" ) );
                        }, fromRaw() );
                    } );

                    it( "can use `table` as an alias for from", function() {
                        testCase( function( builder ) {
                            builder.table( "users" );
                        }, table() );
                    } );

                    it( "can specify a Expression object as the input for table", function() {
                        testCase( function( builder ) {
                            builder.table( builder.raw( "Test (nolock)" ) );
                        }, fromRaw() );
                    } );

                    it( "can specify the table to select from as a string using fromRaw", function() {
                        testCase( function( builder ) {
                            builder.fromRaw( "Test (nolock)" );
                        }, fromRaw() );
                    } );

                    it( "can add bindings to fromRaw", function() {
                        testCase( function( builder ) {
                            builder.fromRaw( "Test (nolock)", [ 1, 2, 3 ] );
                        }, { sql: fromRaw(), bindings: [ 1, 2, 3 ] } );
                    } );

                    it( "can specify the table using fromSub as QueryBuilder", function() {
                        testCase( function( builder ) {
                            var derivedTable = getBuilder()
                                .select( [ "id", "name" ] )
                                .from( "users" )
                                .where( "age", ">=", "21" );

                            builder.fromSub( "u", derivedTable );
                        }, fromDerivedTable() );
                    } );

                    it( "can specify the table using fromSub as a closure", function() {
                        testCase( function( builder ) {
                            builder.fromSub( "u", function( q ) {
                                q.select( [ "id", "name" ] )
                                    .from( "users" )
                                    .where( "age", ">=", "21" );
                            } );
                        }, fromDerivedTable() );
                    } );

                    it( "correctly positions bindings using fromSub", function() {
                        testCase( function( builder ) {
                            builder
                                .select( "accounts.id" )
                                .fromSub( "u", function( q ) {
                                    q.select( [ "id", "name" ] )
                                        .from( "users" )
                                        .where( "age", ">=", "21" );
                                } )
                                .join( "accounts", ( j ) => {
                                    j.on( "accounts.userId", "=", "u.id" );
                                    j.where( "accounts.active", 1 );
                                } );
                        }, fromSubBindings() );
                    } );

                    it( "can select from no table or a dummy table like DUAL", () => {
                        testCase( function( builder ) {
                            builder.selectRaw( "1 + 1" );
                        }, fromEmpty() );
                    } );

                    it( "can clear a configured table", () => {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .selectRaw( "1 + 1" )
                                .clearFrom();
                        }, clearFrom() );
                    } );

                    it( "can add raw expressions after the from clause", function() {
                        testCase( function( builder ) {
                            builder
                                .select( [ "id", "name" ] )
                                .from( "users" )
                                .forRaw( "JSON AUTO" );
                        }, forRaw() );
                    } );
                } );

                describe( "locking", function() {
                    it( "can set no lock", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .noLock();
                        }, noLock() );
                    } );

                    it( "can set a shared lock", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .sharedLock();
                        }, sharedLock() );
                    } );

                    it( "can lock for update", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .lockForUpdate();
                        }, lockForUpdate() );
                    } );

                    it( "can lock for update skipping locked rows", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .lockForUpdate( skipLocked = true );
                        }, lockForUpdateSkipLocked() );
                    } );

                    it( "can pass an arbitrary string to lock", function() {
                        testCase( function( builder ) {
                            builder
                                .from( "users" )
                                .where( "id", 1 )
                                .lock( "foobar" );
                        }, lockArbitraryString() );
                    } );
                } );

                describe( "using table prefixes", function() {
                    it( "can perform a basic select with a table prefix", function() {
                        testCase( function( builder ) {
                            builder.getGrammar().setTablePrefix( "prefix_" );
                            builder.select( "*" ).from( "users" );
                        }, tablePrefix() );
                    } );

                    it( "can parse column aliases with a table prefix", function() {
                        testCase( function( builder ) {
                            builder.getGrammar().setTablePrefix( "prefix_" );
                            builder.select( "*" ).from( "users as people" );
                        }, tablePrefixWithAlias() );
                    } );
                } );

                describe( "aliases", function() {
                    describe( "column aliases", function() {
                        it( "can parse column aliases with AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "id AS user_id" ).from( "users" );
                            }, columnAliasWithAs() );
                        } );

                        it( "can parse column aliases without AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "id user_id" ).from( "users" );
                            }, columnAliasWithoutAs() );
                        } );
                    } );

                    describe( "table aliases", function() {
                        it( "can parse table aliases with AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "*" ).from( "users as people" );
                            }, tableAliasWithAs() );
                        } );

                        it( "can parse table aliases without AS in them", function() {
                            testCase( function( builder ) {
                                builder.select( "*" ).from( "users people" );
                            }, tableAliasWithoutAs() );
                        } );
                    } );
                } );
            } );
        } );
    }

}
