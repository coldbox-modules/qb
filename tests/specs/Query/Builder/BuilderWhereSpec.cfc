component extends='testbox.system.BaseSpec' {
    function run() {
        describe('where methods', function() {
            beforeEach(function() {
                variables.mockGrammar = getMockBox().createStub(implements = 'Quick.Query.Grammars.Grammar');
                variables.query = new Quick.Query.Builder(variables.mockGrammar);
            });

            it('defaults to empty', function() {
                expect(query.getWheres()).toBeEmpty('Default `wheres` should be empty.');
            });

            describe('where', function() {
                it('specifices a where clause', function() {
                    query.where('::some column::', '=', '::some value::');
                    expect(query.getWheres()).toBe([{
                        column = '::some column::',
                        operator = '=',
                        value = '::some value::'
                    }]);
                });

                it('only infers the = when only two arguments', function() {
                    query.where('::some column::', '::some value::');
                    expect(query.getWheres()).toBe([{
                        column = '::some column::',
                        operator = '=',
                        value = '::some value::'
                    }]);
                });

                describe('dynamic where statements', function() {
                    it('translates whereColumn in to where("column"', function() {
                        query.whereSomeColumn('::some value::');
                        expect(query.getWheres()).toBe([{
                            column = 'somecolumn',
                            operator = '=',
                            value = '::some value::'
                        }]);
                    });
                });

                describe('operators', function() {
                    it('throws an exception on illegal operators', function() {
                        expect(function() {
                            query.where('::some column::', '::invalid operator::', '::some value::')
                        }).toThrow(
                            type = 'InvalidArgumentException',
                            regex = 'Illegal operator'
                        );
                    });
                });
            });
        });
    }
}