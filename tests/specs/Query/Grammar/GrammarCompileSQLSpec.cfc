component extends='testbox.system.BaseSpec' {
    function run() {
        describe('compileSelect', function() {
            beforeEach(function() {
                variables.grammar = new Quick.Query.Grammars.OracleGrammar();
                variables.mockQuery = getMockBox().createMock('Quick.Query.Builder');
                mockQuery.$('getFrom', 'sometable');
                mockQuery.$('getDistinct', false);
                mockQuery.$('getColumns', ['*']);
                mockQuery.$('getWheres', []);
            });

            describe('compiling from', function() {
                it('correctly sets the from table', function() {
                    mockQuery.$('getFrom', 'sometable');
                    var sql = grammar.compileSelect(mockQuery);
                    expect(sql).toBe('SELECT * FROM sometable');       
                });   
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