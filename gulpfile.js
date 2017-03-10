var elixir = require('coldbox-elixir');

elixir.config.testing.testbox.command = "cross-env FORCE_COLOR=true npm test";

elixir(function(mix) {
    mix.testbox();
    mix.browserSync({
        proxy: '127.0.0.1:7777'
    });
});