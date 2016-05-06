component extends='testbox.system.BaseSpec' {
    function run() {
        describe('get methods', function() {
            beforeEach(function() {
                variables.query = new Quick.models.Query.Builder();
            });

            it('retreives bindings in a flat array', function() {
                query.join('second', function(join) {
                    join.where('second.locale', '=', 'en-US');
                }).where('first.quantity', '>=', '10');

                expect(query.getBindings()).toBe([{ value = 'en-US' }, { value = '10' }]);
            });

            it('retreives a map of bindings', function() {
                query.join('second', function(join) {
                    join.where('second.locale', '=', 'en-US');
                }).where('first.quantity', '>=', '10');

                var bindings = query.getRawBindings();
                
                expect(bindings).toBeStruct();
            });
        });
    }
}