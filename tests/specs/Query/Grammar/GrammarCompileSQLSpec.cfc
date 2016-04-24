component extends='testbox.system.BaseSpec' {
    function run() {
        describe('compileSelect', function() {
            beforeEach(function() {
                variables.grammar = new Quick.Query.Grammars.OracleGrammar();
                variables.mockQuery = getMockBox().createMock('Quick.Query.Builder');
            });

            describe('compiling columns', function() {
                it('transforms a query builder object to a SQL statement', function() {
                    mockQuery.$('getColumns', ['*']);
                    mockQuery.$('getWheres', []);
                    mockQuery.$('getFrom', 'sometable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM sometable');
                });

                it('correctly compiles a query with a single specific column', function() {
                    mockQuery.$('getColumns', ['column_one']);
                    mockQuery.$('getWheres', []);
                    mockQuery.$('getFrom', 'anothertable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT column_one FROM anothertable');
                });

                it('correctly compiles a query with multiple columns', function() {
                    mockQuery.$('getColumns', ['somecolumn', 'anothercolumn']);
                    mockQuery.$('getWheres', ['']);
                    mockQuery.$('getFrom', 'testtable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT somecolumn,anothercolumn FROM testtable');
                });
            });

            describe('compiling wheres', function() {
                it('adds where clauses to the SQL statement', function() {
                    mockQuery.$('getColumns', ['*']);
                    mockQuery.$('getWheres', [
                        {
                            column = 'some_column',
                            operator = '=',
                            value = '::does not matter::',
                            combinator = 'and'
                        }
                    ]);
                    mockQuery.$('getFrom', 'testtable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM testtable WHERE some_column = ?');
                });

                it('compiles multiple where claueses', function() {
                    mockQuery.$('getColumns', ['*']);
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
                    mockQuery.$('getFrom', 'testtable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM testtable WHERE some_column = ? AND another_column = ?');
                });

                it('compiles different boolean combinators', function() {
                    mockQuery.$('getColumns', ['*']);
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
                    mockQuery.$('getFrom', 'testtable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM testtable WHERE some_column = ? OR another_column = ?');
                });
            });

            describe('data sanitization', function() {
                xit('escapes double quotes in value statements', function() {

                });
            });            
        });
    }
}