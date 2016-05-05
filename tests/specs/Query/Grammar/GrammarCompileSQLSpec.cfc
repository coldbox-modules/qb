component extends='testbox.system.BaseSpec' {
    function run() {
        describe('compileSelect', function() {
            beforeEach(function() {
                variables.grammar = new Quick.models.Query.Grammars.OracleGrammar();
                variables.mockQuery = getMockBox().createMock('Quick.models.Query.Builder');
                mockQuery.$('getDistinct', false);
                mockQuery.$('getColumns', ['*']);
                mockQuery.$('getFrom', 'sometable');
                mockQuery.$('getJoins', []);
                mockQuery.$('getWheres', []);
            });

            describe('compiling distinct', function() {
                it('correctly sets the distinct option', function() {
                    mockQuery.$('getDistinct', true);
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT DISTINCT * FROM sometable');       
                });   
            });

            describe('compiling columns', function() {
                it('transforms a query builder object to a SQL statement', function() {
                    mockQuery.$('getColumns', ['*']);
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM sometable');
                });

                it('correctly compiles a query with a single specific column', function() {
                    mockQuery.$('getColumns', ['column_one']);
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT column_one FROM sometable');
                });

                it('correctly compiles a query with multiple columns', function() {
                    mockQuery.$('getColumns', ['somecolumn', 'anothercolumn']);
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT somecolumn,anothercolumn FROM sometable');
                });
            });

            describe('compiling from', function() {
                it('correctly sets the from table', function() {
                    mockQuery.$('getFrom', 'sometable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM sometable');       
                });   
            });

            describe('compiling joins', function() {
                it('adds a single join', function() {
                    var mockJoin = getMockBox().createMock('Quick.models.Query.JoinClause');
                    mockJoin.$('getType', 'inner');
                    mockJoin.$('getTable', 'othertable');
                    mockJoin.$('getClauses', [{
                        first = 'sometable.id',
                        operator = '=',
                        second = 'othertable.sometable_id',
                        combinator = 'and'
                    }]);
                    mockQuery.$('getJoins', [ mockJoin ]);

                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql)
                        .toBe('SELECT * FROM sometable INNER JOIN othertable ON sometable.id = othertable.sometable_id');
                });

                it('adds multiple joins', function() {
                    var mockJoinOne = getMockBox().createMock('Quick.models.Query.JoinClause');
                    mockJoinOne.$('getType', 'inner');
                    mockJoinOne.$('getTable', 'othertable');
                    mockJoinOne.$('getClauses', [{
                        first = 'sometable.id',
                        operator = '=',
                        second = 'othertable.sometable_id',
                        combinator = 'and'
                    }]);
                    var mockJoinTwo = getMockBox().createMock('Quick.models.Query.JoinClause');
                    mockJoinTwo.$('getType', 'left');
                    mockJoinTwo.$('getTable', 'anothertable');
                    mockJoinTwo.$('getClauses', [{
                        first = 'othertable.id',
                        operator = '<=',
                        second = 'anothertable.othertable_id',
                        combinator = 'and'
                    }]);
                    mockQuery.$('getJoins', [ mockJoinOne, mockJoinTwo ]);

                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql)
                        .toBe('SELECT * FROM sometable INNER JOIN othertable ON sometable.id = othertable.sometable_id LEFT JOIN anothertable ON othertable.id <= anothertable.othertable_id');
                });

                it('adds all the clauses in a join', function() {
                    var mockJoin = getMockBox().createMock('Quick.models.Query.JoinClause');
                    mockJoin.$('getType', 'inner');
                    mockJoin.$('getTable', 'othertable');
                    mockJoin.$('getClauses', [
                        {
                            first = 'sometable.id',
                            operator = '=',
                            second = 'othertable.sometable_id',
                            combinator = 'and'
                        },
                        {
                            first = 'sometable.locale',
                            operator = '=',
                            second = 'othertable.locale',
                            combinator = 'and'
                        }
                    ]);
                    mockQuery.$('getJoins', [ mockJoin ]);

                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql)
                        .toBe('SELECT * FROM sometable INNER JOIN othertable ON sometable.id = othertable.sometable_id AND sometable.locale = othertable.locale');
                });
            });

            describe('compiling wheres', function() {
                it('adds where clauses to the SQL statement', function() {
                    mockQuery.$('getWheres', [
                        {
                            column = 'some_column',
                            operator = '=',
                            value = '::does not matter::',
                            combinator = 'and'
                        }
                    ]);
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM sometable WHERE some_column = ?');
                });

                it('compiles multiple where claueses', function() {
                    mockQuery.$('getWheres', [
                        {
                            column = 'some_column',
                            operator = '=',
                            value = '::does not matter::',
                            combinator = 'and'
                        },
                        {
                            column = 'another_column',
                            operator = '=',
                            value = '::still does not matter::',
                            combinator = 'and'
                        }
                    ]);
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM sometable WHERE some_column = ? AND another_column = ?');
                });

                it('compiles different boolean combinators', function() {
                    mockQuery.$('getWheres', [
                        {
                            column = 'some_column',
                            operator = '=',
                            value = '::does not matter::',
                            combinator = 'AND'
                        },
                        {
                            column = 'another_column',
                            operator = '=',
                            value = '::still does not matter::',
                            combinator = 'OR'
                        }
                    ]);
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM sometable WHERE some_column = ? OR another_column = ?');
                });
            });

            describe('data sanitization', function() {
                xit('escapes double quotes in value statements', function() {

                });
            });            
        });
    }
}