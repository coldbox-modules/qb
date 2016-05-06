component displayname='QueryUtilsSpec' extends='testbox.system.BaseSpec' {
    function beforeAll() {
        variables.utils = new Quick.models.Query.QueryUtils();
    }

    function run() {
        describe('inferSqlType()', function() {
            it('strings', function() {
                expect(utils.inferSqlType('a string')).toBe('CF_SQL_VARCHAR');
            });

            it('numbers', function() {
                expect(utils.inferSqlType(100)).toBe('CF_SQL_NUMERIC');
            });

            it('dates', function() {
                expect(utils.inferSqlType(Now())).toBe('CF_SQL_TIMESTAMP');
            });
        });
    }
}