component extends='testbox.system.BaseSpec' {
    function run() {
        describe('where methods', function() {
            beforeEach(function() {
                variables.query = new Quick.models.Query.Builder();
                getMockBox().prepareMock(query);
                query.$property(propertyName = 'utils', mock = new Quick.models.Query.QueryUtils());
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
                        value = '::some value::',
                        combinator = 'and'
                    }]);
                });

                it('only infers the = when only two arguments', function() {
                    query.where('::some column::', '::some value::');
                    expect(query.getWheres()).toBe([{
                        column = '::some column::',
                        operator = '=',
                        value = '::some value::',
                        combinator = 'and'
                    }]);
                });

                it('can be specify the boolean combinator', function() {
                    query.where('::some column::', '=', '::some value::')
                         .where('::another column::', '=', '::another value::', 'or');
                    expect(query.getWheres()).toBe([
                        {
                            column = '::some column::',
                            operator = '=',
                            value = '::some value::',
                            combinator = 'and'
                        },
                        {
                            column = '::another column::',
                            operator = '=',
                            value = '::another value::',
                            combinator = 'or'
                        }
                    ]);
                });

                describe('bindings', function() {
                    it('adds the bindings for where statements received', function() {
                        query.where('::some column::', '=', '::some value::');
                        expect(query.getRawBindings().where).toBe([{ value = '::some value::' }]);
                    });
                });

                describe('dynamic where statements', function() {
                    it('translates whereColumn in to where("column"', function() {
                        query.whereSomeColumn('::some value::');
                        expect(query.getWheres()).toBe([{
                            column = 'somecolumn',
                            operator = '=',
                            value = '::some value::',
                            combinator = 'and'
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