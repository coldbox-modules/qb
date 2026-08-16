component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "QueryValidator", function() {
            it( "captures all validation settings", function() {
                var validator = new qb.models.Query.QueryValidator(
                    validateOperatorsAndCombinators = false,
                    validateDuplicateSelectColumns = true,
                    validateQueryExecuteReturnType = true
                );

                expect( validator.getValidateOperatorsAndCombinators() ).toBeFalse();
                expect( validator.getValidateDuplicateSelectColumns() ).toBeTrue();
                expect( validator.getValidateQueryExecuteReturnType() ).toBeTrue();
            } );

            it( "validates operators and combinators according to its configuration", function() {
                var strictValidator = new qb.models.Query.QueryValidator( validateOperatorsAndCombinators = true );
                var relaxedValidator = new qb.models.Query.QueryValidator( validateOperatorsAndCombinators = false );

                expect( function() {
                    strictValidator.validateOperator( "not-an-operator" );
                } ).toThrow( type = "InvalidSQLType" );
                expect( function() {
                    strictValidator.validateCombinator( "not-a-combinator" );
                } ).toThrow( type = "InvalidSQLType" );
                expect( function() {
                    relaxedValidator.validateOperator( "not-an-operator" );
                    relaxedValidator.validateCombinator( "not-a-combinator" );
                } ).notToThrow();
            } );

            it( "validates queryExecute return types according to its configuration", function() {
                var strictValidator = new qb.models.Query.QueryValidator( validateQueryExecuteReturnType = true );
                var relaxedValidator = new qb.models.Query.QueryValidator( validateQueryExecuteReturnType = false );

                expect( function() {
                    strictValidator.validateQueryExecuteOptions( { "returntype": "array" } );
                } ).toThrow( type = "InvalidQueryExecuteOption" );

                var options = { "returntype": "array", "columnkey": "id" };
                relaxedValidator.validateQueryExecuteOptions( options );
                expect( options ).notToHaveKey( "returntype" );
                expect( options ).notToHaveKey( "columnkey" );
            } );
        } );
    }

}
