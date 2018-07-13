component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "schema builder + basic grammar", function() {
            it( "can create an empty table", function() {
                testCase( function( schema ) {
                    return schema.create( "users", function() {}, {}, false );
                }, emptyTable() );
            } );

            it( "can create a simple table", function() {
                testCase( function( schema ) {
                    return schema.create( "users", function( table ) {
                        table.string( "username" );
                        table.string( "password" );
                    }, {}, false );
                }, simpleTable() );
            } );

            it( "create a complicated table", function() {
                testCase( function( schema ) {
                    return schema.create( "users", function( table ) {
                        table.increments( "id" );
                        table.string( "username" );
                        table.string( "first_name" );
                        table.string( "last_name" );
                        table.string( "password", 100 );
                        table.unsignedInteger( "country_id" ).references( "id" ).onTable( "countries" ).onDelete( "cascade" );
                        table.timestamp( "created_date" ).setDefault( "CURRENT_TIMESTAMP" );
                        table.timestamp( "modified_date" ).setDefault( "CURRENT_TIMESTAMP" );
                    }, {}, false );
                }, complicatedTable() );
            } );

            describe( "column types", function() {
                it( "bigIncrements", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.bigIncrements( "id" );
                        }, {}, false );
                    }, bigIncrements() );
                } );

                it( "bigInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "weather_reports", function( table ) {
                            table.bigInteger( "temperature" );
                        }, {}, false );
                    }, bigInteger() );
                } );

                it( "bigInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "weather_reports", function( table ) {
                            table.bigInteger( "temperature", 5 );
                        }, {}, false );
                    }, bigIntegerWithPrecision() );
                } );

                it( "bit", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.bit( "active" );
                        }, {}, false );
                    }, bit() );
                } );

                it( "bit (with length)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.bit( "something", 4 );
                        }, {}, false );
                    }, bitWithLength() );
                } );

                it( "boolean", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.boolean( "active" );
                        }, {}, false );
                    }, boolean() );
                } );

                it( "char", function() {
                    testCase( function( schema ) {
                        return schema.create( "classifications", function( table ) {
                            table.char( "level" );
                        }, {}, false );
                    }, char() );
                } );

                it( "char (with length)", function() {
                    testCase( function( schema ) {
                        return schema.create( "classifications", function( table ) {
                            table.char( "abbreviation", 3 );
                        }, {}, false );
                    }, charWithLength() );
                } );

                it( "date", function() {
                    testCase( function( schema ) {
                        return schema.create( "posts", function( table ) {
                            table.date( "posted_date" );
                        }, {}, false );
                    }, date() );
                } );

                it( "datetime", function() {
                    testCase( function( schema ) {
                        return schema.create( "posts", function( table ) {
                            table.datetime( "posted_date" );
                        }, {}, false );
                    }, datetime() );
                } );

                it( "decimal (with defaults)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.decimal( "salary" );
                        }, {}, false );
                    }, decimal() );
                } );

                it( "decimal (with length)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.decimal( "salary", 3 );
                        }, {}, false );
                    }, decimalWithLength() );
                } );

                it( "decimal (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.decimal( name = "salary", precision = 2 );
                        }, {}, false );
                    }, decimalWithPrecision() );
                } );

                it( "decimal (with length and precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.decimal( "salary", 3, 2 );
                        }, {}, false );
                    }, decimalWithLengthAndPrecision() );
                } );

                it( "enum", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] );
                        }, {}, false );
                    }, enum() );
                } );

                it( "float (with defaults)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.float( "salary" );
                        }, {}, false );
                    }, float() );
                } );

                it( "float (with length)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.float( "salary", 3 );
                        }, {}, false );
                    }, floatWithLength() );
                } );

                it( "float (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.float( name = "salary", precision = 2 );
                        }, {}, false );
                    }, floatWithPrecision() );
                } );

                it( "float (with length and precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.float( "salary", 3, 2 );
                        }, {}, false );
                    }, floatWithLengthAndPrecision() );
                } );

                it( "increments", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.increments( "id" );
                        }, {}, false );
                    }, increments() );
                } );

                it( "integer", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.integer( "age" );
                        }, {}, false );
                    }, integer() );
                } );

                it( "integer (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.integer( "age", 2 );
                        }, {}, false );
                    }, integerWithPrecision() );
                } );

                it( "json", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.json( "personalizations" );
                        }, {}, false );
                    }, json() );
                } );

                it( "longText", function() {
                    testCase( function( schema ) {
                        return schema.create( "posts", function( table ) {
                            table.longText( "body" );
                        }, {}, false );
                    }, longText() );
                } );

                it( "mediumIncrements", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.mediumIncrements( "id" );
                        }, {}, false );
                    }, mediumIncrements() );
                } );

                it( "mediumInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.mediumInteger( "age" );
                        }, {}, false );
                    }, mediumInteger() );
                } );

                it( "mediumInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.mediumInteger( "age", 5 );
                        }, {}, false );
                    }, mediumIntegerWithPrecision() );
                } );

                it( "mediumText", function() {
                    testCase( function( schema ) {
                        return schema.create( "posts", function( table ) {
                            table.mediumText( "body" );
                        }, {}, false );
                    }, mediumText() );
                } );

                it( "morphs", function() {
                    testCase( function( schema ) {
                        return schema.create( "tags", function( table ) {
                            table.morphs( "taggable" );
                        }, {}, false );
                    }, morphs() );
                } );

                it( "nullableMorphs", function() {
                    testCase( function( schema ) {
                        return schema.create( "tags", function( table ) {
                            table.nullableMorphs( "taggable" );
                        }, {}, false );
                    }, nullableMorphs() );
                } );

                it( "raw", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.raw( "id BLOB NOT NULL" );
                        }, {}, false );
                    }, raw() );
                } );

                it( "smallIncrements", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.smallIncrements( "id" );
                        }, {}, false );
                    }, smallIncrements() );
                } );

                it( "smallInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.smallInteger( "age" );
                        }, {}, false );
                    }, smallInteger() );
                } );

                it( "smallInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.smallInteger( "age", 5 );
                        }, {}, false );
                    }, smallIntegerWithPrecision() );
                } );

                it( "string", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.string( "username" );
                        }, {}, false );
                    }, string() );
                } );

                it( "string (with length)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.string( "password", 50 );
                        }, {}, false );
                    }, stringWithLength() );
                } );

                it( "text", function() {
                    testCase( function( schema ) {
                        return schema.create( "posts", function( table ) {
                            table.text( "body" );
                        }, {}, false );
                    }, text() );
                } );

                it( "time", function() {
                    testCase( function( schema ) {
                        return schema.create( "recurring_tasks", function( table ) {
                            table.time( "fire_time" );
                        }, {}, false );
                    }, time() );
                } );

                it( "timestamp", function() {
                    testCase( function( schema ) {
                        return schema.create( "posts", function( table ) {
                            table.timestamp( "posted_date" );
                        }, {}, false );
                    }, timestamp() );
                } );

                it( "tinyIncrements", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.tinyIncrements( "id" );
                        }, {}, false );
                    }, tinyIncrements() );
                } );

                it( "tinyInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.tinyInteger( "active" );
                        }, {}, false );
                    }, tinyInteger() );
                } );

                it( "tinyInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.tinyInteger( "active", 3 );
                        }, {}, false );
                    }, tinyIntegerWithPrecision() );
                } );

                it( "unsignedBigInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.unsignedBigInteger( "salary" );
                        }, {}, false );
                    }, unsignedBigInteger() );
                } );

                it( "unsignedBigInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "employees", function( table ) {
                            table.unsignedBigInteger( "salary", 5 );
                        }, {}, false );
                    }, unsignedBigIntegerWithPrecision() );
                } );

                it( "unsignedInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedInteger( "age" );
                        }, {}, false );
                    }, unsignedInteger() );
                } );

                it( "unsignedInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedInteger( "age", 5 );
                        }, {}, false );
                    }, unsignedIntegerWithPrecision() );
                } );

                it( "unsignedMediumInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedMediumInteger( "age" );
                        }, {}, false );
                    }, unsignedMediumInteger() );
                } );

                it( "unsignedMediumInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedMediumInteger( "age", 5 );
                        }, {}, false );
                    }, unsignedMediumIntegerWithPrecision() );
                } );

                it( "unsignedSmallInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedSmallInteger( "age" );
                        }, {}, false );
                    }, unsignedSmallInteger() );
                } );

                it( "unsignedSmallInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedSmallInteger( "age", 5 );
                        }, {}, false );
                    }, unsignedSmallIntegerWithPrecision() );
                } );

                it( "unsignedTinyInteger", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedTinyInteger( "age" );
                        }, {}, false );
                    }, unsignedTinyInteger() );
                } );

                it( "unsignedTinyInteger (with precision)", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.unsignedTinyInteger( "age", 5 );
                        }, {}, false );
                    }, unsignedTinyIntegerWithPrecision() );
                } );

                it( "uuid", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.uuid( "id" );
                        }, {}, false );
                    }, uuid() );
                } );
            } );

            describe( "column modifiers", function() {
                it( "comment", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.boolean( "active" ).comment( "This is a comment" );
                        }, {}, false );
                    }, comment() );
                } );

                it( "default", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.char( "active" ).default( "'Y'" );
                        }, {}, false );
                    }, default() );
                } );

                it( "nullable", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.uuid( "id" ).nullable();
                        }, {}, false );
                    }, nullable() );
                } );

                it( "unsigned", function() {
                    testCase( function( schema ) {
                        return schema.create( "users", function( table ) {
                            table.integer( "age" ).unsigned();
                        }, {}, false );
                    }, unsigned() );
                } );
            } );

            describe( "indexes", function() {
                describe( "unique", function() {
                    describe( "in create", function() {
                        it( "unique (off of column)", function() {
                            testCase( function( schema ) {
                                return schema.create( "users", function( table ) {
                                    table.string( "username" ).unique();
                                }, {}, false );
                            }, columnUnique() );
                        } );

                        it( "unique (off of table)", function() {
                            testCase( function( schema ) {
                                return schema.create( "users", function( table ) {
                                    table.string( "username" );
                                    table.unique( "username" );
                                }, {}, false );
                            }, tableUnique() );
                        } );

                        it( "unique (overriding constaint name)", function() {
                            testCase( function( schema ) {
                                return schema.create( "users", function( table ) {
                                    table.string( "username" );
                                    table.unique( "username", "unq_uname" );
                                }, {}, false );
                            }, uniqueOverridingName() );
                        } );

                        it( "unique (multiple columns)", function() {
                            testCase( function( schema ) {
                                return schema.create( "users", function( table ) {
                                    table.string( "first_name" );
                                    table.string( "last_name" );
                                    table.unique( [ "first_name", "last_name" ] );
                                }, {}, false );
                            }, uniqueMultipleColumns() );
                        } );
                    } );

                    describe( "in alter", function() {
                        it( "add constraint", function() {
                            testCase( function( schema ) {
                                return schema.alter( "users", function( table ) {
                                    table.addConstraint( table.unique( "username" ) );
                                }, {}, false );
                            }, addConstraint() );
                        } );

                        it( "adds multiple constraints at once", function() {
                            testCase( function( schema ) {
                                return schema.alter( "users", function( table ) {
                                    table.addConstraint( table.unique( "username" ) );
                                    table.addConstraint( table.unique( "email" ) );
                                }, {}, false );
                            }, addMultipleConstraints() );
                        } );

                        it( "renames constraints", function() {
                            testCase( function( schema ) {
                                return schema.alter( "users", function( table ) {
                                    table.renameConstraint( "unq_users_first_name_last_name", "unq_users_full_name" );
                                }, {}, false );
                            }, renameConstraint() );
                        } );

                        it( "drop constraint", function() {
                            testCase( function( schema ) {
                                return schema.alter( "users", function( table ) {
                                    table.dropConstraint( "unique_username" );
                                }, {}, false );
                            }, dropConstraintFromName() );
                        } );

                        it( "drop constraint (from index object)", function() {
                            testCase( function( schema ) {
                                return schema.alter( "users", function( table ) {
                                    table.dropConstraint( table.unique( "username" ) );
                                }, {}, false );
                            }, dropConstraintFromIndex() );
                        } );

                        it( "drop foreign key", function() {
                            testCase( function( schema ) {
                                return schema.alter( "users", function( table ) {
                                    table.dropForeignKey( "fk_posts_author_id" );
                                }, {}, false );
                            }, dropForeignKey() );
                        } );
                    } );
                } );

                describe( "basic indexes", function() {
                    it( "basic index", function() {
                        testCase( function( schema ) {
                            return schema.create( "users", function( table ) {
                                table.timestamp( "published_date" );
                                table.index( "published_date" );
                            }, {}, false );
                        }, basicIndex() );
                    } );

                    it( "composite index", function() {
                        testCase( function( schema ) {
                            return schema.create( "users", function( table ) {
                                table.string( "first_name" );
                                table.string( "last_name" );
                                table.index( [ "first_name", "last_name" ] );
                            }, {}, false );
                        }, compositeIndex() );
                    } );

                    it( "override index name", function() {
                        testCase( function( schema ) {
                            return schema.create( "users", function( table ) {
                                table.string( "first_name" );
                                table.string( "last_name" );
                                table.index( [ "first_name", "last_name" ], "index_full_name" );
                            }, {}, false );
                        }, overrideIndexName() );
                    } );
                } );

                describe( "primary key indexes", function() {
                    it( "column primary key", function() {
                        testCase( function( schema ) {
                            return schema.create( "users", function( table ) {
                                table.string( "uuid" ).primaryKey();
                            }, {}, false );
                        }, columnPrimaryKey() );
                    } );

                    it( "table primary key", function() {
                        testCase( function( schema ) {
                            return schema.create( "users", function( table ) {
                                table.string( "uuid" );
                                table.primaryKey( "uuid" );
                            }, {}, false );
                        }, tablePrimaryKey() );
                    } );

                    it( "composite primary key", function() {
                        testCase( function( schema ) {
                            return schema.create( "users", function( table ) {
                                table.string( "first_name" );
                                table.string( "last_name" );
                                table.primaryKey( [ "first_name", "last_name" ] );
                            }, {}, false );
                        }, compositePrimaryKey() );
                    } );

                    it( "override primary key index name", function() {
                        testCase( function( schema ) {
                            return schema.create( "users", function( table ) {
                                table.string( "first_name" );
                                table.string( "last_name" );
                                table.primaryKey( [ "first_name", "last_name" ], "pk_full_name" );
                            }, {}, false );
                        }, overridePrimaryKeyIndexName() );
                    } );
                } );

                describe( "foreign key indexes", function() {
                    it( "column foreign key", function() {
                        testCase( function( schema ) {
                            return schema.create( "posts", function( table ) {
                                table.unsignedInteger( "author_id" ).references( "id" ).onTable( "users" );
                            }, {}, false );
                        }, columnForeignKey() );
                    } );

                    it( "table foreign key", function() {
                        testCase( function( schema ) {
                            return schema.create( "posts", function( table ) {
                                table.unsignedInteger( "author_id" );
                                table.foreignKey( "author_id" ).references( "id" ).onTable( "users" );
                            }, {}, false );
                        }, tableForeignKey() );
                    } );

                    it( "override column foreign key index name", function() {
                        testCase( function( schema ) {
                            return schema.create( "posts", function( table ) {
                                table.unsignedInteger( "author_id" ).references( "id" ).onTable( "users" ).setName( "fk_author" );
                            }, {}, false );
                        }, overrideColumnForeignKeyIndexName() );
                    } );

                    it( "override table foreign key index name", function() {
                        testCase( function( schema ) {
                            return schema.create( "posts", function( table ) {
                                table.unsignedInteger( "author_id" );
                                table.foreignKey( "author_id" ).references( "id" ).onTable( "users" ).setName( "fk_author" );
                            }, {}, false );
                        }, overrideTableForeignKeyIndexName() );
                    } );

                    it( "alter table foreign key with better exception messages", function() {
                        var schema = getBuilder();
                        var blueprint = schema.alter( "users", function( table ) {
                            table.addColumn( table.string( "country_id" ).references( "id" ).onTable( "countries" ) );
                        }, {}, false );
                        try {
                            var statements = blueprint.toSql();
                        }
                        catch ( any e ) {
                            // Darn ACF nests the exception message. 😠
                            if ( e.message == "An exception occurred while calling the function map." ) {
                                expect( e.detail ).toBe( "Recieved a TableIndex instead of a Column when trying to create a Column." );
                            }
                            else {
                                expect( e.message ).toBe( "Recieved a TableIndex instead of a Column when trying to create a Column." );
                            }
                            return;
                        }
                        fail( "Should have caught an exception, but didn't." );
                    } );
                } );
            } );

            describe( "rename tables", function() {
                it( "rename table", function() {
                    testCase( function( schema ) {
                        return schema.rename( "workers", "employees", {}, false );
                    }, renameTable() );
                } );
            } );

            describe( "rename columns", function() {
                it( "renames a column", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.renameColumn( "name", table.string( "username" ) );
                        }, {}, false );
                    }, renameColumn() );
                } );

                it( "renames multiple columns", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.renameColumn( "name", table.string( "username" ) );
                            table.renameColumn( "purchase_date", table.timestamp( "purchased_at" ).nullable() );
                        }, {}, false );
                    }, renameMultipleColumns() );
                } );
            } );

            describe( "modify columns", function() {
                it( "modifies a column", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.modifyColumn( "name", table.text( "name" ) );
                        }, {}, false );
                    }, modifyColumn() );
                } );

                it( "modifies multiple columns", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.modifyColumn( "name", table.text( "name" ) );
                            table.modifyColumn( "purchase_date", table.timestamp( "purchased_date" ).nullable() );
                        }, {}, false );
                    }, modifyMultipleColumns() );
                } );
            } );

            describe( "adding columns", function() {
                it( "can add a new column", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.addColumn( table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] ) );
                        }, {}, false );
                    }, addColumn() );
                } );

                it( "can add multiple columns", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.addColumn( table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] ) );
                            table.addColumn( table.boolean( "is_active" ) );
                        }, {}, false );
                    }, addMultiple() );
                } );
            } );

            it( "can drop and add and rename and modify columns and constraints at the same time", function() {
                testCase( function( schema ) {
                    return schema.alter( "users", function( table ) {
                        table.dropColumn( "is_active" );
                        table.addColumn( table.enum( "tshirt_size", [ "S", "M", "L", "XL", "XXL" ] ) );
                        table.renameColumn( "name", table.string( "username" ) );
                        table.modifyColumn( "purchase_date", table.timestamp( "purchase_date" ).nullable() );
                        table.addConstraint( table.unique( "username" ) );
                        table.addConstraint( table.unique( "email" ) );
                        table.dropConstraint( "idx_users_created_date" );
                        table.dropConstraint( "idx_users_modified_date" );
                    }, {}, false );
                }, complicatedModify() );
            } );

            describe( "drop", function() {
                it( "drop table", function() {
                    testCase( function( schema ) {
                        return schema.drop( "users", {}, false );
                    }, dropTable() );
                } );

                it( "dropIfExists", function() {
                    testCase( function( schema ) {
                        return schema.dropIfExists( "users", {}, false );
                    }, dropIfExists() );
                } );

                it( "drop column", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.dropColumn( "username" );
                        }, {}, false );
                    }, dropColumn() );
                } );

                it( "drops multiple columns", function() {
                    testCase( function( schema ) {
                        return schema.alter( "users", function( table ) {
                            table.dropColumn( "username" );
                            table.dropColumn( "password" );
                        }, {}, false );
                    }, dropsMultipleColumns() );
                } );
            } );

            it( "has table", function() {
                testCase( function( schema ) {
                    return schema.hasTable( "users", {}, false );
                }, hasTable() );
            } );

            it( "has column", function() {
                testCase( function( schema ) {
                    return schema.hasColumn( "users", "username", {}, false );
                }, hasColumn() );
            } );
        } );
    }

    private function getBuilder( mockGrammar ) {
        throw( "Must be implemented in a subclass" );
    }

    private function testCase( callback, expected ) {
        var schema = getBuilder();
        var statements = callback( schema );
        if ( ! isSimpleValue( statements ) ) {
            statements = statements.toSql();
        }
        if ( ! isArray( statements ) ) {
            statements = [ statements ];
        }
        expect( statements ).toBeArray();
        expect( statements ).toHaveLength( arrayLen( expected ) );
        for ( var i = 1; i <= expected.len(); i++ ) {
            expect( statements[ i ] ).toBeWithCase( expected[ i ] );
        }
    }

}
