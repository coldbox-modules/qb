component extends='testbox.system.BaseSpec' {
    function run() {
        describe('interaction with collaborators', function() {
            beforeEach(function() {
                variables.mockGrammar = getMockBox().createStub(implements = 'Quick.Query.Grammars.Grammar');
                variables.query = new Quick.Query.Builder(variables.mockGrammar);
            });

            describe('interaction with grammar', function() {
                describe('toSQL()', function() {
                    it('returns the result of sending itself to its grammar', function() {
                        mockGrammar.$('compileSelect').$args(query).$results('::compiled SQL::');
                        expect(query.toSQL()).toBe('::compiled SQL::');
                        expect(mockGrammar.$once('compileSelect')).toBeTrue('compileSelect() should have been called once.');
                    });
                });
            });
        });
    }
}