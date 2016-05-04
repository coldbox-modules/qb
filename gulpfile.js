var elixir = require('coldbox-elixir');

elixir(function(mix) {
    mix.browserSync({
        proxy: '127.0.0.1:7777'
    });
});