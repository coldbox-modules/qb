component extends="qb.models.Grammars.BaseGrammar" singleton {

    /**
     * Creates a new SQLite Query Grammar.
     *
     * @utils A collection of query utilities. Default: qb.models.Query.QueryUtils
     *
     * @return qb.models.Grammars.SQLiteGrammar
     */
    public SQLiteGrammar function init( qb.models.Query.QueryUtils utils ) {
        super.init( argumentCollection = arguments );

        variables.cteColumnsRequireParentheses = true;

        return this;
    }

	/**
     * Runs a query through `queryExecute`.
     * This function exists so that platform-specific grammars can override it if needed.
     *
     * @sql The sql string to execute.
     * @bindings The bindings to apply to the query.
     * @options Any options to pass to `queryExecute`. Default: {}.
     *
     * @return any
     */
    public any function runQuery(
        sql,
        bindings,
        options,
        returnObject = "query"
    ) {
        local.result = "";
        var data = {
            sql: replaceConcat(arguments.sql),
            bindings: arguments.bindings,
            options: arguments.options,
            returnObject: arguments.returnObject
        };
        tryPreInterceptor( data );
        structAppend( data.options, { result: "local.result" }, true );
        variables.log.debug( "Executing sql: #data.sql#", "With bindings: #serializeJSON( data.bindings )#" );
        var startTick = getTickCount();
        var q = queryExecute( data.sql, data.bindings, data.options );
        data.executionTime = getTickCount() - startTick;
        data.query = isNull( q ) ? javacast( "null", "" ) : q;
        data.result = local.result;
        tryPostInterceptor( data );
        return returnObject == "query" ? ( isNull( q ) ? javacast( "null", "" ) : q ) : {
            result: local.result,
            query: ( isNull( q ) ? javacast( "null", "" ) : q )
        };
    }

    /*===================================
    =           Query Builder           =
    ===================================*/

		/**
		 * Replace instances of CONCAT function with || since SQLite does not support CONCAT
		 *
		 * @sql The sql string.
		 *
		 * @return string
		 */
		private string function replaceConcat( sql ) {
			var matches = reFindNoCase("concat\(", sql, 1, true, "ALL");
			var replacements = [];
			var charArray = sql.toCharArray();
			matches.each(function(item) {
				var charIndex = item.pos[1];
				var buffer = "";
				var replacementBuffer = "";
				var openParenCount = 0;
				var isOpen = true;
				if ( charIndex != 0 ){
					do {
						var thisCharacter = charArray[charIndex];
						buffer &= thisCharacter;
						if (thisCharacter == "(") {
							openParenCount++;
						}

						if (thisCharacter == ")") {
							openParenCount--;
							isOpen = (openParenCount == 1);
						}

						if (openParenCount == 1) {
							replacementBuffer &= replace(thisCharacter,",","||");
						}
						else {
							replacementBuffer &= thisCharacter;
						}

						charIndex++;
					} while( isOpen );

					replacements.append({
						"origional": buffer,
						"new": mid(replacementBuffer,8,replacementBuffer.len() - 8)
					});
				}
			});

			var newStatement = sql;
			replacements.each(function( item) {
				newStatement = replace(newStatement,item.origional,item.new);
			});

			return newStatement;
		}

        /**
         * Compiles the lock portion of a sql statement.
         *
         * @query The Builder instance.
         * @lockType The lock type to compile.
         *
         * @return string
         */
        private string function compileLockType( required query, required string lockType ) {
            return "";
        }

        /**
         * Compiles the offset portion of a sql statement.
         *
         * @query The Builder instance.
         * @offsetValue The offset value.
         *
         * @return string
         */
        private string function compileOffsetValue( required QueryBuilder query, offsetValue ) {
            if ( isNull( arguments.offsetValue ) ) {
                return "";
            }

            //SQLite requires LIMIT when using OFFSET. A negative integer means no limit
            if ( isNull( query.getLimitValue() ) ) {
                return "LIMIT -1 OFFSET #offsetValue#";
            }

            return "OFFSET #offsetValue#";
        }

            /**
             * Compile a Builder's query into an insert string.
             *
             * @query The Builder instance.
             * @columns The array of columns into which to insert.
             * @values The array of values to insert.
             *
             * @return string
             */
            public string function compileInsert( required QueryBuilder query, required array columns, required array values ) {
                var returningColumns = query
                    .getReturning()
                    .map( wrapColumn )
                    .toList( ", " );
                var returningClause = returningColumns != "" ? " RETURNING #returningColumns#" : "";
                return super.compileInsert( argumentCollection = arguments ) & returningClause;
            }

            /**
             * Compile a Builder's query into an insert string ignoring duplicate key values.
             *
             * @qb The Builder instance.
             * @columns The array of columns into which to insert.
             * @target The array of key columns to match.
             * @values The array of values to insert.
             *
             * @return string
             */
            public string function compileInsertIgnore(
                required QueryBuilder qb,
                required array columns,
                required array target,
                required array values
            ) {
                return replace(
                    compileInsert( arguments.qb, arguments.columns, arguments.values ),
                    "INSERT",
                    "INSERT OR IGNORE",
                    "one"
                );
            }

            /**
             * Compile a Builder's query into an update string.
             *
             * @query The Builder instance.
             * @columns The array of columns into which to insert.
             *
             * @return string
             */
            public string function compileUpdate(
                required QueryBuilder query,
                required array columns,
                required struct updateMap
            ) {
                var updateList = columns
                    .map( function( column ) {
                        var value = updateMap[ column.original ];
                        var assignment = "?";
                        if ( utils.isExpression( value ) ) {
                            assignment = value.getSql();
                        } else if ( utils.isBuilder( value ) ) {
                            assignment = "(#value.toSQL()#)";
                        }
                        return "#wrapColumn( column.formatted )# = #assignment#";
                    } )
                    .toList( ", " );

                var updateStatement = "UPDATE #wrapTable( query.getFrom() )#";
                var joinStatement = "";
                if ( !arguments.query.getJoins().isEmpty() ) {
                    joinStatement = " FROM #wrapTable( query.getFrom() )# " & compileJoins( arguments.query, arguments.query.getJoins() );
                }

                return trim(
                    updateStatement & " SET #updateList##joinStatement# #compileWheres( query, query.getWheres() )# #compileLimitValue( query, query.getLimitValue() )#"
                );
            }

            public string function compileUpsert(
                required QueryBuilder qb,
                required array insertColumns,
                required array values,
                required array updateColumns,
                required any updates,
                required array target,
                QueryBuilder source,
                boolean deleteUnmatched = false
            ) {
                if ( arguments.deleteUnmatched ) {
                    throw( type = "UnsupportedOperation", message = "This grammar does not support DELETE in a upsert clause" );
                }

                var insertString = isNull( arguments.source ) ? this.compileInsert(
                    arguments.qb,
                    arguments.insertColumns,
                    arguments.values
                ) : this.compileInsertUsing( arguments.qb, arguments.insertColumns, arguments.source );
                var updateString = "";
                if ( isArray( arguments.updates ) ) {
                    updateString = arguments.updateColumns
                        .map( function( column ) {
                            return "#wrapValue( column.formatted )# = EXCLUDED.#wrapValue( column.formatted )#";
                        } )
                        .toList( ", " );
                } else {
                    updateString = arguments.updateColumns
                        .map( function( column ) {
                            var value = updates[ column.original ];
                            return "#wrapValue( column.formatted )# = #getUtils().isExpression( value ) ? value.getSQL() : "?"#";
                        } )
                        .toList( ", " );
                }

                var constraintString = arguments.target
                    .map( function( column ) {
                        return wrapColumn( column.formatted );
                    } )
                    .toList( ", " );

                var returningColumns = arguments.qb
                    .getReturning()
                    .map( wrapColumn )
                    .toList( ", " );
                var returningClause = returningColumns != "" ? " RETURNING #returningColumns#" : "";

                return insertString & " ON CONFLICT (#constraintString#) DO UPDATE SET #updateString##returningClause#";
            }
    /*=====  End of Query Builder  ======*/

    /*===================================
    =           Column Types            =
    ===================================*/

        function wrapDefaultType( column ) {
            switch ( column.getType() ) {
                case "boolean":
                    return column.getDefault() ? 1 : 0;
                case "char":
                case "string":
                    return "'#column.getDefault()#'";
                default:
                    return column.getDefault();
            }
        }

        function typeString( column ) {
            return "TEXT";
        }

        function typeUnicodeString( column ) {
            return typeString( argumentCollection = arguments );
        }

        function typeBigInteger( column ) {

            if ( column.getAutoIncrement() ) {
                return "INTEGER";
            }

            return "BIGINT";
        }

        function typeSmallInteger( column ) {

            if ( column.getAutoIncrement() ) {
                return "INTEGER";
            }

            return "SMALLINT";
        }

        function typeInteger( column ) {
            return "INTEGER";
        }

        function typeMediumInteger( column ) {

            if ( column.getAutoIncrement() ) {
                return "INTEGER";
            }

            return "MEDIUMINT";
        }

        function modifyUnsigned( column ) {
            return "";
        }

        function typeBit( column ) {
            return "BOOLEAN";
        }

        function typeBoolean( column ) {
            return "BOOLEAN";
        }

        function typeChar( column ) {
            return "VARCHAR(#column.getLength()#)";
        }

        function typeEnum( column, blueprint ) {
            return "TEXT";
        }

        function typeLineString( column, blueprint ) {
            return "TEXT";
        }

        function typePoint( column ) {
            return "TEXT";
        }

        function typePolygon( column ) {
            return "TEXT";
        }

        function typeTime( column ) {
            return "TEXT";
        }

        function typeTimeTz( column ) {
            return "TEXT";
        }

        function typeTimestamp( column ) {
            return "TEXT";
        }

        function typeTinyInteger( column ) {
            if ( column.getAutoIncrement() ) {
                return "INTEGER";
            }

            RETURN "TINYINT";
        }




    /*=====  End of Column Types  ======*/

    /*=========================================
    =            Blueprint: Create            =
    =========================================*/

        function generateAutoIncrement( column, blueprint ) {

            //SQLite does not allow the primary key defined as a constraint when using autoincrement
            if ( column.getAutoIncrement() ) {
                blueprint.setIndexes( blueprint.getIndexes().filter(function(index) {
                    return index.getType() != "primary";
                }) );
            }
            return column.getAutoIncrement() ? "PRIMARY KEY AUTOINCREMENT" : "";
        }

        function generateUniqueConstraint( column, blueprint ) {
            //SQLite does not have an enum type so we add an CHECK constraint to enforce specific values
            if ( column.getType() == "enum" ) {
                var values = column
                    .getValues()
                    .map( function( value ) {
                        return "'#value#'";
                    } )
                    .toList( ", " );
                return "CHECK (#wrapColumn(column.getName())# IN (#values#))";
            }

            return column.getUnique() ? "UNIQUE" : "";
        }

        function generateDefault( column ) {
            if (
                column.getDefault() == "" &&
                column.getType().findNoCase( "TIMESTAMP" ) > 0
            ) {
                if ( column.getNullable() ) {
                    return "";
                } else {
                    column.withCurrent();
                }
            }
            return super.generateDefault( column );
        }

        function indexBasic( index, blueprint ) {
            blueprint.addCommand( "addIndex", { index: index, table: blueprint.getTable() } );
            return "";
        }

        function generateComment( column ) {
            return "";
        }


    /*=====  End of Blueprint: Create  ======*/

    /*========================================
    =            Blueprint: Alter            =
    ========================================*/

        function compileModifyColumn( blueprint, commandParameters ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support modifying columns" );
        }

        function compileAddColumn( blueprint, commandParameters ) {
            return arrayToList(
                arrayFilter(
                    [
                        "ALTER TABLE",
                        wrapTable( blueprint.getTable() ),
                        "ADD COLUMN",
                        compileCreateColumn( commandParameters.column, blueprint )
                    ],
                    function( item ) {
                        return item != "";
                    }
                ),
                " "
            );
        }

        function compileAddConstraint( blueprint, commandParameters ) {
            var index = commandParameters.index;
            var constraint = invoke( this, "index#index.getType()#", { index: index, isAlter: true, tableName: blueprint.getTable() } );
            return "#constraint#";
        }

        function compileRenameConstraint( blueprint, commandParameters ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support renaming constraints. You can drop it and add a new one with a different name." );
        }

        function compileDropConstraint( blueprint, commandParameters ) {
            return "DROP INDEX #wrapValue( commandParameters.name )#";
        }

        function compileDropForeignKey( blueprint, commandParameters ) {
            throw( type = "UnsupportedOperation", message = "This grammar does not support droping foreign keys constraints." );
        }

        function compileRenameColumn( blueprint, commandParameters ) {
            return arrayToList(
                arrayFilter(
                    [
                        "ALTER TABLE",
                        wrapTable( blueprint.getTable() ),
                        "RENAME COLUMN",
                        wrapColumn( commandParameters.from ),
                        "TO",
                        wrapColumn( commandParameters.to.getName() )
                    ],
                    function( item ) {
                        return item != "";
                    }
                ),
                " "
            );
        }

    /*=====  End of Blueprint: Alter  ======*/

    /*=======================================
    =            Blueprint: Drop            =
    =======================================*/

        function compileTableExists( tableName, schemaName = "" ) {
            var sql = "SELECT 1 FROM #wrapTable( "pragma_table_list" )# WHERE #wrapColumn( "type" )# = 'table' AND #wrapColumn( "name" )# = ?";

            if ( schemaName != "" ) {
                sql &= " AND #wrapColumn( "schema" )# = ?";
            }
            else {
                sql &= " AND #wrapColumn( "schema" )# = 'main'";
            }
            return sql;
        }

        function compileColumnExists( table, column, schema = "" ) {
            var sql = "SELECT 1 FROM #wrapTable( "pragma_table_list" )# tl JOIN pragma_table_info(tl.name) ti WHERE tl.#wrapColumn( "type" )# = 'table' AND tl.#wrapColumn( "name" )# = ? AND ti.#wrapColumn( "name" )# = ?";
            if ( schema != "" ) {
                sql &= " AND tl.#wrapColumn( "schema" )# = ?";
            }
            else {
                sql &= " AND tl.#wrapColumn( "schema" )# = 'main'";
            }
            return sql;
        }

    /*=====  End of Blueprint: Drop  ======*/

    /*===================================
    =            Index Types            =
    ===================================*/

        function indexUnique( index, tableName, isAlter = false ) {
            var references = index
                .getColumns()
                .map( function( column ) {
                    return wrapColumn( column );
                } )
                .toList( ", " );

            if ( isAlter ) {
                return "CREATE UNIQUE INDEX #wrapValue( index.getName() )# ON #wrapTable( tableName )#(#references#)";
            }
            else {
                return "CONSTRAINT #wrapValue( index.getName() )# UNIQUE (#references#)";
            }

        }

        function indexPrimary( index ) {
            var references = index
                .getColumns()
                .map( function( column ) {
                    return wrapColumn( column );
                } )
                .toList( ", " );
            return "PRIMARY KEY (#references#)";
        }

        function indexForeign( index ) {
            // FOREIGN KEY ("country_id") REFERENCES countries ("id") ON DELETE CASCADE
            var keys = index
                .getForeignKey()
                .map( function( key ) {
                    return wrapColumn( key );
                } )
                .toList( ", " );
            var references = index
                .getColumns()
                .map( function( column ) {
                    return wrapColumn( column );
                } )
                .toList( ", " );
            return arrayToList(
                [
                    "FOREIGN KEY (#keys#)",
                    "REFERENCES #wrapTable( index.getTable() )# (#references#)",
                    "ON UPDATE #uCase( index.getOnUpdate() )#",
                    "ON DELETE #uCase( index.getOnDelete() )#"
                ],
                " "
            );
        }

    /*=====  End of Index Types  ======*/

    /*===================================
    =               Views               =
    ===================================*/

        function compileCreateView( blueprint, commandParameters ) {
            var query = commandParameters[ "query" ];
            return "CREATE VIEW #wrapTable( blueprint.getTable() )# AS #compileSelect( query )#";
        }

    /*=====  End of Views  ======*/


}
