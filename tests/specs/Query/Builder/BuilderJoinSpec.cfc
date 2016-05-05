component extends='testbox.system.BaseSpec' {
    function run() {
        describe('join methods', function() {
            beforeEach(function() {
                variables.mockGrammar = getMockBox().createStub(implements = 'Quick.models.Query.Grammars.GrammarInterface');
                variables.query = new Quick.models.Query.Builder(variables.mockGrammar);
            });

            it('does a simple inner join', function() {
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
                expect(clause.where).toBe(false);
            });

            it('does a left join', function() {
                query.leftJoin('second', 'first.id', '=', 'second.first_id');

                var joins = query.getJoins();
                expect(arrayLen(joins)).toBe(1, 'Only one join should exist');

                var join = joins[1];
                expect(join).toBeInstanceOf('Quick.Query.JoinClause');
                expect(join.getType()).toBe('left');
                expect(join.getTable()).toBe('second');

                var clauses = join.getClauses();
                expect(arrayLen(clauses)).toBe(1, 'Only one join clause should exist');

                var clause = clauses[1];
                expect(clause).toBeStruct();
                expect(clause.first).toBe('first.id', 'First column should be [first.id]');
                expect(clause.operator).toBe('=', 'Operator should be [=]');
                expect(clause.second).toBe('second.first_id', 'First column should be [second.first_id]');
                expect(clause.combinator).toBe('and');
                expect(clause.where).toBe(false);
            });

            it('does a right join', function() {
                query.rightJoin('second', 'first.id', '=', 'second.first_id');

                var joins = query.getJoins();
                expect(arrayLen(joins)).toBe(1, 'Only one join should exist');

                var join = joins[1];
                expect(join).toBeInstanceOf('Quick.Query.JoinClause');
                expect(join.getType()).toBe('right');
                expect(join.getTable()).toBe('second');

                var clauses = join.getClauses();
                expect(arrayLen(clauses)).toBe(1, 'Only one join clause should exist');

                var clause = clauses[1];
                expect(clause).toBeStruct();
                expect(clause.first).toBe('first.id', 'First column should be [first.id]');
                expect(clause.operator).toBe('=', 'Operator should be [=]');
                expect(clause.second).toBe('second.first_id', 'First column should be [second.first_id]');
                expect(clause.combinator).toBe('and');
                expect(clause.where).toBe(false);
            });

            it('can use a callback to specify advanced join clauses', function() {
                query.join(table = 'second', conditions = function(join) {
                    join.on('first.id', '=', 'second.first_id')
                        .on('first.locale', '=', 'second.locale');
                });

                var joins = query.getJoins();
                expect(arrayLen(joins)).toBe(1, 'Only one join should exist');

                var join = joins[1];
                expect(join).toBeInstanceOf('Quick.Query.JoinClause');
                expect(join.getType()).toBe('inner');
                expect(join.getTable()).toBe('second');

                var clauses = join.getClauses();
                expect(arrayLen(clauses)).toBe(2, 'Two join clauses should exist');

                var clauseOne = clauses[1];
                expect(clauseOne).toBeStruct();
                expect(clauseOne.first).toBe('first.id', 'First column should be [first.id]');
                expect(clauseOne.operator).toBe('=', 'Operator should be [=]');
                expect(clauseOne.second).toBe('second.first_id', 'First column should be [second.first_id]');
                expect(clauseOne.combinator).toBe('and');
                expect(clauseOne.where).toBe(false);

                var clauseTwo = clauses[2];
                expect(clauseTwo).toBeStruct();
                expect(clauseTwo.first).toBe('first.locale', 'First column should be [first.locale]');
                expect(clauseTwo.operator).toBe('=', 'Operator should be [=]');
                expect(clauseTwo.second).toBe('second.locale', 'First column should be [second.locale]');
                expect(clauseTwo.combinator).toBe('and');
                expect(clauseTwo.where).toBe(false);
            });

            it('can pass the callback as the second parameter when using positional parameters', function() {
                query.join('second', function(join) {
                    join.on('first.id', '=', 'second.first_id')
                        .on('first.locale', '=', 'second.locale');
                });

                var joins = query.getJoins();
                expect(arrayLen(joins)).toBe(1, 'Only one join should exist');

                var join = joins[1];
                expect(join).toBeInstanceOf('Quick.Query.JoinClause');
                expect(join.getType()).toBe('inner');
                expect(join.getTable()).toBe('second');

                var clauses = join.getClauses();
                expect(arrayLen(clauses)).toBe(2, 'Two join clauses should exist');

                var clauseOne = clauses[1];
                expect(clauseOne).toBeStruct();
                expect(clauseOne.first).toBe('first.id', 'First column should be [first.id]');
                expect(clauseOne.operator).toBe('=', 'Operator should be [=]');
                expect(clauseOne.second).toBe('second.first_id', 'First column should be [second.first_id]');
                expect(clauseOne.combinator).toBe('and');
                expect(clauseOne.where).toBe(false);

                var clauseTwo = clauses[2];
                expect(clauseTwo).toBeStruct();
                expect(clauseTwo.first).toBe('first.locale', 'First column should be [first.locale]');
                expect(clauseTwo.operator).toBe('=', 'Operator should be [=]');
                expect(clauseTwo.second).toBe('second.locale', 'First column should be [second.locale]');
                expect(clauseTwo.combinator).toBe('and');
                expect(clauseTwo.where).toBe(false);
            });
        });
    }
}