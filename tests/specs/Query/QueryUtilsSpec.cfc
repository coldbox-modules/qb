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

        describe('extractBinding()', function() {
            it('includes sensible defaults', function() {
                var binding = utils.extractBinding('05/10/2016');

                expect(binding).toBeStruct();
                expect(binding.value).toBe('05/10/2016');
                expect(binding.cfsqltype).toBe('CF_SQL_TIMESTAMP');
                expect(binding.list).toBe(false);
                expect(binding.null).toBe(false);
            });

            it('detects arrays and converts them in to lists', function() {
                var binding = utils.extractBinding(['one', 'two']);

                expect(binding).toBeStruct();
                expect(binding.value).toBe('one,two');
                expect(binding.cfsqltype).toBe('CF_SQL_VARCHAR');
                expect(binding.list).toBe(true);
                expect(binding.null).toBe(false);
            });

            it('detects lists and sets the list property to true', function() {
                var binding = utils.extractBinding('yes,no');

                expect(binding).toBeStruct();
                expect(binding.value).toBe('yes,no');
                expect(binding.cfsqltype).toBe('CF_SQL_VARCHAR');
                expect(binding.list).toBe(true);
                expect(binding.null).toBe(false);
            });

            describe('it infers the sql type from the members of a list', function() {
                it('if all the members of the list are the same', function() {
                    var binding = utils.extractBinding('1,2');

                    expect(binding).toBeStruct();
                    expect(binding.value).toBe('1,2');
                    expect(binding.cfsqltype).toBe('CF_SQL_NUMERIC');
                    expect(binding.list).toBe(true);
                    expect(binding.null).toBe(false);
                });

                it('but defaults to CF_SQL_VARCHAR if they are different', function() {
                    var binding = utils.extractBinding('1,2,3,test');

                    expect(binding).toBeStruct();
                    expect(binding.value).toBe('1,2,3,test');
                    expect(binding.cfsqltype).toBe('CF_SQL_VARCHAR');
                    expect(binding.list).toBe(true);
                    expect(binding.null).toBe(false);
                });
            });

            describe('it infers the sql type from the members of an array', function() {
                it('if all the members of the array are the same', function() {
                    var binding = utils.extractBinding([1, 2]);

                    expect(binding).toBeStruct();
                    expect(binding.value).toBe('1,2');
                    expect(binding.cfsqltype).toBe('CF_SQL_NUMERIC');
                    expect(binding.list).toBe(true);
                    expect(binding.null).toBe(false);
                });

                it('but defaults to CF_SQL_VARCHAR if they are different', function() {
                    var binding = utils.extractBinding([1, 2, 3, DateFormat('05/01/2016', 'MM/DD/YYYY')]);

                    expect(binding).toBeStruct();
                    expect(binding.value).toBe('1,2,3,05/01/2016');
                    expect(binding.cfsqltype).toBe('CF_SQL_VARCHAR');
                    expect(binding.list).toBe(true);
                    expect(binding.null).toBe(false);
                });
            });
        });
    }
}