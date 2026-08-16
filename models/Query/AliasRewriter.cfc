/**
 * Rewrites table aliases throughout a query graph without retaining query
 * state between calls.
 */
component {

    public void function rewrite( required QueryBuilder builder, required string oldAlias, required string newAlias ) {
        renameAliasesInColumns( argumentCollection = arguments );
        renameAliasesInJoins( argumentCollection = arguments );
        renameAliasesInWheres( argumentCollection = arguments );
        renameAliasesInGroups( argumentCollection = arguments );
        renameAliasesInHavings( argumentCollection = arguments );
        renameAliasesInOrders( argumentCollection = arguments );
        renameAliasesInUnions( argumentCollection = arguments );
        renameAliasesInCommonTables( argumentCollection = arguments );
        renameAliasesInUpdates( argumentCollection = arguments );
    }

    private void function renameAliasesInUnions(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var union in arguments.builder.getUnions() ) {
            renameAliasesInNestedQuery(
                arguments.builder,
                union.query,
                arguments.oldAlias,
                arguments.newAlias
            );
        }
    }

    private void function renameAliasesInCommonTables(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var commonTable in arguments.builder.getCommonTables() ) {
            renameAliasesInNestedQuery(
                arguments.builder,
                commonTable.query,
                arguments.oldAlias,
                arguments.newAlias
            );
        }
    }

    private void function renameAliasesInUpdates(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        var updates = arguments.builder.getUpdates();
        for ( var column in updates ) {
            var value = updates[ column ];
            if ( arguments.builder.getUtils().isBuilder( value ) ) {
                renameAliasesInNestedQuery(
                    arguments.builder,
                    value,
                    arguments.oldAlias,
                    arguments.newAlias
                );
            }
        }
    }

    private void function renameAliasesInNestedQuery(
        required QueryBuilder builder,
        required QueryBuilder query,
        required string oldAlias,
        required string newAlias
    ) {
        var nestedAlias = arguments.query.getAlias();
        var nestedTable = arguments.query.getTableName();
        var shadowsAlias = compareNoCase( nestedAlias, arguments.oldAlias ) == 0;

        if ( !shadowsAlias && nestedAlias == "" && isSimpleValue( nestedTable ) ) {
            shadowsAlias = compareNoCase( listLast( nestedTable, "." ), arguments.oldAlias ) == 0;
        }

        if ( !shadowsAlias ) {
            arguments.query.renameAliases( arguments.oldAlias, arguments.newAlias );
        }
    }

    private void function renameAliasesInColumns(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var column in arguments.builder.getColumns() ) {
            renameAliasInTypedColumn( column, arguments.oldAlias, arguments.newAlias );
            if ( column.type == "builder" ) {
                renameAliasesInNestedQuery(
                    arguments.builder,
                    column.value,
                    arguments.oldAlias,
                    arguments.newAlias
                );
            }
        }
    }

    private void function renameAliasesInJoins(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var join in arguments.builder.getJoins() ) {
            join.renameAliases( arguments.oldAlias, arguments.newAlias );
        }
    }

    private void function renameAliasesInWheres(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var where in arguments.builder.getWheres() ) {
            var renameWhere = variables[ "renameAliasInWhere#where.type#" ];
            renameWhere(
                builder = arguments.builder,
                where = where,
                oldAlias = arguments.oldAlias,
                newAlias = arguments.newAlias
            );
        }
    }

    private void function renameAliasesInGroups(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var column in arguments.builder.getGroups() ) {
            renameAliasInTypedColumn( column, arguments.oldAlias, arguments.newAlias );
        }
    }

    private void function renameAliasesInHavings(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var having in arguments.builder.getHavings() ) {
            if ( structKeyExists( having, "column" ) ) {
                renameAliasInTypedColumn( having.column, arguments.oldAlias, arguments.newAlias );
            }
        }
    }

    private void function renameAliasesInOrders(
        required QueryBuilder builder,
        required string oldAlias,
        required string newAlias
    ) {
        for ( var order in arguments.builder.getOrders() ) {
            if ( order.keyExists( "query" ) ) {
                renameAliasesInNestedQuery(
                    arguments.builder,
                    order.query,
                    arguments.oldAlias,
                    arguments.newAlias
                );
            } else if ( order.keyExists( "column" ) && order.direction != "raw" ) {
                renameAliasInTypedColumn( order.column, arguments.oldAlias, arguments.newAlias );
            }
        }
    }

    private void function renameAliasInTypedColumn(
        required struct column,
        required string oldAlias,
        required string newAlias
    ) {
        if ( arguments.column.type == "simple" ) {
            arguments.column.value = swapAlias( arguments.column.value, arguments.oldAlias, arguments.newAlias );
        } else if ( arguments.column.type == "jsonPath" ) {
            arguments.column.value.column = swapAlias(
                arguments.column.value.column,
                arguments.oldAlias,
                arguments.newAlias
            );
        }
    }

    private void function renameAliasInWhereBasic(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInTypedColumn( arguments.where.column, arguments.oldAlias, arguments.newAlias );
    }

    private void function renameAliasInWhereJsonContains(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        arguments.where.path.value.column = swapAlias(
            arguments.where.path.value.column,
            arguments.oldAlias,
            arguments.newAlias
        );
    }

    private void function renameAliasInWhereJsonExists(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereJsonContains( argumentCollection = arguments );
    }

    private void function renameAliasInWhereJsonLength(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereJsonContains( argumentCollection = arguments );
    }

    private void function renameAliasInWhereColumn(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInTypedColumn( arguments.where.first, arguments.oldAlias, arguments.newAlias );
        renameAliasInTypedColumn( arguments.where.second, arguments.oldAlias, arguments.newAlias );
    }

    private void function renameAliasInWhereSub(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInTypedColumn( arguments.where.column, arguments.oldAlias, arguments.newAlias );
        renameAliasesInNestedQuery(
            arguments.builder,
            arguments.where.query,
            arguments.oldAlias,
            arguments.newAlias
        );
    }

    private void function renameAliasInWhereIn(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereBasic( argumentCollection = arguments );
    }

    private void function renameAliasInWhereNotIn(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereBasic( argumentCollection = arguments );
    }

    private void function renameAliasInWhereInBulk(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereBasic( argumentCollection = arguments );
    }

    private void function renameAliasInWhereInSub(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInTypedColumn( arguments.where.column, arguments.oldAlias, arguments.newAlias );
        renameAliasesInNestedQuery(
            arguments.builder,
            arguments.where.query,
            arguments.oldAlias,
            arguments.newAlias
        );
    }

    private void function renameAliasInWhereNotInSub(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereInSub( argumentCollection = arguments );
    }

    private void function renameAliasInWhereRaw(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
    }

    private void function renameAliasInWhereExists(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasesInNestedQuery(
            arguments.builder,
            arguments.where.query,
            arguments.oldAlias,
            arguments.newAlias
        );
    }

    private void function renameAliasInWhereNotExists(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereExists( argumentCollection = arguments );
    }

    private void function renameAliasInWhereNested(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        arguments.where.query.renameAliases( arguments.oldAlias, arguments.newAlias );
    }

    private void function renameAliasInWhereNull(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereBasic( argumentCollection = arguments );
    }

    private void function renameAliasInWhereNotNull(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereBasic( argumentCollection = arguments );
    }

    private void function renameAliasInWhereNullSub(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereExists( argumentCollection = arguments );
    }

    private void function renameAliasInWhereNotNullSub(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereExists( argumentCollection = arguments );
    }

    private void function renameAliasInWhereBetween(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInTypedColumn( arguments.where.column, arguments.oldAlias, arguments.newAlias );
        if (
            arguments.where.keyExists( "start" ) &&
            !isNull( arguments.where.start ) &&
            arguments.builder.getUtils().isBuilder( arguments.where.start )
        ) {
            renameAliasesInNestedQuery(
                arguments.builder,
                arguments.where.start,
                arguments.oldAlias,
                arguments.newAlias
            );
        }
        if (
            arguments.where.keyExists( "end" ) &&
            !isNull( arguments.where.end ) &&
            arguments.builder.getUtils().isBuilder( arguments.where.end )
        ) {
            renameAliasesInNestedQuery(
                arguments.builder,
                arguments.where.end,
                arguments.oldAlias,
                arguments.newAlias
            );
        }
    }

    private void function renameAliasInWhereNotBetween(
        required QueryBuilder builder,
        required struct where,
        required string oldAlias,
        required string newAlias
    ) {
        renameAliasInWhereBetween( argumentCollection = arguments );
    }

    private string function swapAlias( required string column, required string oldAlias, required string newAlias ) {
        if ( left( arguments.column, len( arguments.oldAlias ) + 1 ) == arguments.oldAlias & "." ) {
            return arguments.newAlias & "." & listLast( arguments.column, "." );
        }
        return arguments.column;
    }

}
