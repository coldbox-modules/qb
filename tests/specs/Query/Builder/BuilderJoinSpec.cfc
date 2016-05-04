component extends='testbox.system.BaseSpec' {
    function run() {
        describe('join methods', function() {
            beforeEach(function() {
                variables.mockGrammar = getMockBox().createStub(implements = 'Quick.Query.Grammars.Grammar');
                variables.query = new Quick.Query.Builder(variables.mockGrammar);
            });

            describe('join()', function() {
                it('does a simple on join', function() {
                    query.join('second', 'first.id', '=', 'second.first_id');

                    var joins = query.getJoins();
                    expect(arrayLen(joins)).toBe(1, 'Only one join should exist');

                    var join = joins[1];
                    expect(join).toBeInstanceOf('Quick.Query.JoinClause');
                    expect(join.getType()).toBe('inner');
                    expect(join.getTable()).toBe('second');

                    var clauses = join.getClauses();
                    expect(arrayLen(clauses)).toBe(1, 'Only one join clause should exist');

                    var clause = clauses[1];
                    expect(clause).toBeStruct();
                    expect(clause.first).toBe('first.id', 'First column should be [first.id]');
                    expect(clause.operator).toBe('=', 'Operator should be [=]');
                    expect(clause.second).toBe('second.first_id', 'First column should be [second.first_id]');
                    expect(clause.combinator).toBe('and');
                });
            });
        });
    }
}