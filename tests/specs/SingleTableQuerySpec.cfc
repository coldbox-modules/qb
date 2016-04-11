component extends='testbox.system.BaseSpec' {
    function run() {
        describe('creating a query from a single table', function() {
            it('creates a query from just a table name', function() {
                var Quick = new quick.Quick();
                var sql = Quick.from('users').toSQL();
                expect(sql).toBe('SELECT * FROM users');

                var Quick = new quick.Quick();
                var sql = Quick.from('products').toSQL();
                expect(sql).toBe('SELECT * FROM products');
            });

            describe('specifying columns', function() {
                it('can specify a single column from a query', function() {
                    var Quick = new quick.Quick();
                    var sql = Quick.from('users').select('email').toSQL();
                    expect(sql).toBe('SELECT email FROM users');
                });

                describe('can specify multiple columns in a query', function() {
                    it('using a list', function() {
                        var Quick = new quick.Quick();
                        var sql = Quick.from('users').select('email, last_logged_in').toSQL();
                        expect(sql).toBe('SELECT email,last_logged_in FROM users');
                    });

                    it('using an array', function() {
                        var Quick = new quick.Quick();
                        var sql = Quick.from('users').select(['email', 'last_logged_in']).toSQL();
                        expect(sql).toBe('SELECT email,last_logged_in FROM users');
                    });

                    it('using variadic parameters', function() {
                        var Quick = new quick.Quick();
                        var sql = Quick.from('users').select('email', 'last_logged_in').toSQL();
                        expect(sql).toBe('SELECT email,last_logged_in FROM users');
                    });
                });

                describe('adding select columns on to existing queries', function() {

                    beforeEach(function() {
                        variables.Quick = new quick.Quick();
                        Quick.from('users').select('email');
                    });

                    afterEach(function() {
                        structDelete(variables, 'Quick', false);
                    });

                    it('can add a single column to an existing query', function() {
                        Quick.addSelect('last_logged_in');
                        expect(Quick.toSQL()).toBe('SELECT email,last_logged_in FROM users');
                    });

                    describe('can add multiple columns to an existing query', function() {
                        it('using a list', function() {
                            Quick.addSelect('last_logged_in, username');
                            expect(Quick.toSQL()).toBe('SELECT email,last_logged_in,username FROM users');
                        });

                        it('using an array', function() {
                            Quick.addSelect(['last_logged_in', 'username']);
                            expect(Quick.toSQL()).toBe('SELECT email,last_logged_in,username FROM users');
                        });

                        it('using variadic parameters', function() {
                            Quick.addSelect('last_logged_in', 'username');
                            expect(Quick.toSQL()).toBe('SELECT email,last_logged_in,username FROM users');
                        });
                    });
                });
            });

        });
    }
}