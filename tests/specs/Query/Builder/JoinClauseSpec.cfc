component extends='testbox.system.BaseSpec' {
    function run() {
        describe('initialization', function() {
            it('requires a type and a table', function() {
                expect(function() { new Quick.models.Query.JoinClause(); }).toThrow();
                expect(function() { new Quick.models.Query.JoinClause('inner'); }).toThrow();
                expect(function() { new Quick.models.Query.JoinClause('inner', 'sometable'); }).notToThrow();
            });

            it('validates the type is a valid sql join type', function() {
                expect(function() { new Quick.models.Query.JoinClause('gibberish', 'sometable') }).toThrow();
                expect(function() { new Quick.models.Query.JoinClause('left typo', 'sometable') }).toThrow();
                expect(function() { new Quick.models.Query.JoinClause('left', 'sometable') }).notToThrow();
                expect(function() { new Quick.models.Query.JoinClause('left outer', 'sometable') }).notToThrow();
            });
        });

        describe('adding join conditions', function() {
            beforeEach(function() {
                variables.join = new Quick.models.Query.JoinClause('inner', 'second');
                getMockBox().prepareMock(join);
                join.$property(propertyName = 'utils', mock = new Quick.models.Query.QueryUtils());
            });

            afterEach(function() {
                structDelete(variables, 'join');
            });

            describe('on()', function() {
                it('can add a single join condition', function() {
                    join.on('first.id', '=', 'second.first_id', 'and', false);

                    var clauses = join.getClauses();
                    expect(arrayLen(clauses)).toBe(1, 'Only one clause should exist in the join statement');

                    var clause = clauses[1];
                    expect(clause.first).toBe('first.id', 'First column should be [first.id]');
                    expect(clause.operator).toBe('=', 'Operator should be [=]');
                    expect(clause.second).toBe('second.first_id', 'First column should be [second.first_id]');
                    expect(clause.combinator).toBe('and');
                    expect(clause.where).toBe(false);
                });

                it('defaults to "and" for the combinator and "false" for the where flag', function() {
                    join.on('first.id', '=', 'second.first_id');

                    var clauses = join.getClauses();
                    expect(arrayLen(clauses)).toBe(1, 'Only one clause should exist in the join statement');

                    var clause = clauses[1];
                    expect(clause.first).toBe('first.id', 'First column should be [first.id]');
                    expect(clause.operator).toBe('=', 'Operator should be [=]');
                    expect(clause.second).toBe('second.first_id', 'First column should be [second.first_id]');
                    expect(clause.combinator).toBe('and');
                    expect(clause.where).toBe(false);
                });

                it('can add multiple join clauses', function() {
                    join.on('first.id', '=', 'second.first_id');
                    join.on('first.locale', '=', 'second.locale');

                    var clauses = join.getClauses();
                    expect(arrayLen(clauses)).toBe(2, 'Two clauses should exist in the join statement');

                    var clauseOne = clauses[1];
                    expect(clauseOne.first).toBe('first.id', 'First column should be [first.id]');
                    expect(clauseOne.operator).toBe('=', 'Operator should be [=]');
                    expect(clauseOne.second).toBe('second.first_id', 'First column should be [second.first_id]');
                    expect(clauseOne.combinator).toBe('and');
                    expect(clauseOne.where).toBe(false);

                    var clauseTwo = clauses[2];
                    expect(clauseTwo.first).toBe('first.locale', 'First column should be [first.locale]');
                    expect(clauseTwo.operator).toBe('=', 'Operator should be [=]');
                    expect(clauseTwo.second).toBe('second.locale', 'First column should be [second.locale]');
                    expect(clauseTwo.combinator).toBe('and');
                    expect(clauseTwo.where).toBe(false);
                });

                it('validates that the operator is a valid sql operator', function() {
                    expect(function() {
                        join.on('first.id', '==', 'second.first_id');
                    }).toThrow();

                    expect(function() {
                        join.on('first.id', '<>', 'second.first_id');
                    }).notToThrow();
                });
            });

            describe('orOn()', function() {
                it('can add a single join condition', function() {
                    join.orOn('first.another_value', '>=', 'second.another_value');

                    var clauses = join.getClauses();
                    expect(arrayLen(clauses)).toBe(1, 'Only one clause should exist in the join statement');

                    var clause = clauses[1];
                    expect(clause.first).toBe('first.another_value', 'First column should be [first.another_value]');
                    expect(clause.operator).toBe('>=', 'Operator should be [>=]');
                    expect(clause.second).toBe('second.another_value', 'First column should be [second.another_value]');
                    expect(clause.combinator).toBe('or');
                    expect(clause.where).toBe(false);
                });
            });

            describe('where()', function() {
                it('adds a where statement to a join clause', function() {
                    join.where('second.locale', '=', 'en-US');

                    var clauses = join.getClauses();
                    expect(arrayLen(clauses)).toBe(1, 'Only one clause should exist in the join statement');

                    var clause = clauses[1];
                    expect(clause.first).toBe('second.locale', 'First column should be [second.locale]');
                    expect(clause.operator).toBe('=', 'Operator should be [>=]');
                    expect(clause.second).toBe('?', 'First column should be a binding placeholder [?]');
                    expect(clause.combinator).toBe('and');
                    expect(clause.where).toBe(true, 'The where flag should be true');
                });

                it('can use the shortcut where statement when the operator is equals (=)', function() {
                    join.where('second.locale', 'en-US');

                    var clauses = join.getClauses();
                    expect(arrayLen(clauses)).toBe(1, 'Only one clause should exist in the join statement');

                    var clause = clauses[1];
                    expect(clause.first).toBe('second.locale', 'First column should be [second.locale]');
                    expect(clause.operator).toBe('=', 'Operator should be [>=]');
                    expect(clause.second).toBe('?', 'First column should be a binding placeholder [?]');
                    expect(clause.combinator).toBe('and');
                    expect(clause.where).toBe(true, 'The where flag should be true');
                });

                it('adds the where value to the bindings', function() {
                    join.where('second.locale', '=', 'en-US');

                    var bindings = join.getBindings();
                    expect(arrayLen(bindings)).toBe(1, 'Only one clause should exist in the join statement');
                    expect(bindings[1]).toBe({ value = 'en-US', cfsqltype = 'cf_sql_varchar' });
                });
            });
        });
    }
}