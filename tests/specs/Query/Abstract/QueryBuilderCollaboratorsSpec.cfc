component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "QueryBuilder collaborators", function() {
            it( "does not instantiate collaborators during construction", function() {
                var builder = prepareBuilder();

                expect( getCollaborators( builder ) ).toBeEmpty();
            } );

            it( "lazily instantiates JSON support", function() {
                var builder = prepareBuilder( validateOperatorsAndCombinators = false );

                builder.jsonPath( "profile->name" );

                expect( getCollaborators( builder ) ).toHaveKey( "JsonQueryClause" );
                expect( getCollaborators( builder ) ).toHaveLength( 1 );
            } );

            it( "lazily instantiates alias rewriting", function() {
                var builder = prepareBuilder();

                builder.from( "users AS u" ).withAlias( "members" );

                expect( getCollaborators( builder ) ).toHaveKey( "AliasRewriter" );
                expect( getCollaborators( builder ) ).toHaveLength( 1 );
            } );

            it( "lazily instantiates query execution", function() {
                var builder = prepareBuilder(
                    validateOperatorsAndCombinators = false,
                    validateDuplicateSelectColumns = false,
                    validateQueryExecuteReturnType = false
                );

                builder
                    .pretend()
                    .from( "users" )
                    .get();

                expect( getCollaborators( builder ) ).toHaveKey( "QueryExecutor" );
                expect( getCollaborators( builder ) ).toHaveLength( 1 );
            } );

            it( "lazily instantiates validation", function() {
                var builder = prepareBuilder();

                builder.where( "id", 1 );

                expect( getCollaborators( builder ) ).toHaveKey( "QueryValidator" );
                expect( getCollaborators( builder ) ).toHaveLength( 1 );
            } );

            it( "supports collaborators on QueryBuilder subclasses outside the qb package", function() {
                var builder = prepareMock( new tests.resources.ExternalQueryBuilder() );

                expect( function() {
                    builder.where( function( query ) {
                        query.where( "id", 1 );
                    } );
                } ).notToThrow();

                expect( getCollaborators( builder ) ).toHaveKey( "QueryExecutor" );
                expect( builder.wasWhereNestedCalled() ).toBeTrue();
            } );

            it( "rebuilds validation after settings change", function() {
                var builder = prepareBuilder();
                builder.where( "id", 1 );
                var originalValidator = getCollaborators( builder ).QueryValidator;

                builder.setValidateOperatorsAndCombinators( false );
                expect( getCollaborators( builder ) ).notToHaveKey( "QueryValidator" );

                builder.where( "name", "Eric" );
                var rebuiltValidator = getCollaborators( builder ).QueryValidator;

                expect( originalValidator.getValidateOperatorsAndCombinators() ).toBeTrue();
                expect( rebuiltValidator.getValidateOperatorsAndCombinators() ).toBeFalse();
                expect( rebuiltValidator.getValidateDuplicateSelectColumns() ).toBeFalse();
                expect( rebuiltValidator.getValidateQueryExecuteReturnType() ).toBeFalse();
            } );

            it( "copies validation settings without copying collaborators", function() {
                var builder = prepareBuilder(
                    validateOperatorsAndCombinators = false,
                    validateDuplicateSelectColumns = true,
                    validateQueryExecuteReturnType = true
                );
                builder.select( "id" );
                expect( function() {
                    builder.toSQL();
                } ).notToThrow();

                var newBuilder = prepareMock( builder.newQuery() );

                expect( getCollaborators( newBuilder ) ).toBeEmpty();
                expect( newBuilder.getValidateOperatorsAndCombinators() ).toBeFalse();
                expect( newBuilder.getValidateDuplicateSelectColumns() ).toBeTrue();
                expect( newBuilder.getValidateQueryExecuteReturnType() ).toBeTrue();
            } );
        } );
    }

    private QueryBuilder function prepareBuilder() {
        var builder = new qb.models.Query.QueryBuilder( argumentCollection = arguments );
        return prepareMock( builder );
    }

    private struct function getCollaborators( required QueryBuilder builder ) {
        return arguments.builder.$getProperty( name = "collaborators", scope = "variables" );
    }

}
