component {

    this.title         = 'Quick';
    this.author        = 'Eric Peterson';
    this.webURL        = 'https://github.com/elpete/quick';
    this.description   = 'Query builder for the rest of us';
    this.version       = '0.1.0';
    this.autoMapModels = true;
    this.cfmapping     = 'Quick';

    variables.defaultSettings = {
        defaultGrammar = 'OracleGrammar'
    };

    function configure() {
        var settings = controller.getConfigSettings();

        parseParentSettings(settings);

        binder.map('Grammar@Quick')
            .to('#moduleMapping#.models.Query.Grammars.#settings.quick.defaultGrammar#');
    }

    private void function parseParentSettings(required struct settings) {
        if (! structKeyExists(settings, 'quick')) {
            settings.quick = {};
        }

        var userSettings = controller.getSetting('ColdBoxConfig')
            .getPropertyMixin('quick', 'variables', structNew());

        structAppend(settings.quick, variables.defaultSettings);

        structAppend(settings.quick, userSettings, true);
    }

}