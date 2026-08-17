component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "SchemaBuilder module default options regression", function() {
            it( "wires configured default options into SchemaBuilder", function() {
                var mappings = {};
                var currentAlias = "";
                var fakeBinder = {};
                fakeBinder.map = function( required string alias, boolean force = false ) {
                    currentAlias = arguments.alias;
                    mappings[ currentAlias ] = { initArguments: {} };
                    return fakeBinder;
                };
                fakeBinder.to = function( required string path ) {
                    mappings[ currentAlias ].path = arguments.path;
                    return fakeBinder;
                };
                fakeBinder.initArg = function( required string name, any value, string ref ) {
                    mappings[ currentAlias ].initArguments[ arguments.name ] = arguments.keyExists( "value" )
                     ? arguments.value
                     : arguments.ref;
                    return fakeBinder;
                };

                var moduleConfig = prepareMock( new qb.ModuleConfig() );
                moduleConfig.configure();
                var settings = moduleConfig.$getProperty( "settings", "variables" );
                settings.defaultOptions = { datasource: "reporting", timeout: 15 };
                moduleConfig.$property( propertyName = "binder", mock = fakeBinder );
                moduleConfig.$property(
                    propertyName = "wirebox",
                    mock = {
                        getInstance: function() {
                            return {
                                setShouldWrapValues: function() {
                                }
                            };
                        }
                    }
                );

                moduleConfig.onLoad();

                expect( mappings[ "SchemaBuilder@qb" ].initArguments ).toHaveKey( "defaultOptions" );
                expect( mappings[ "SchemaBuilder@qb" ].initArguments.defaultOptions ).toBe( settings.defaultOptions );
            } );
        } );
    }

}
