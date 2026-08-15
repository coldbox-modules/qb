component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "ReturnFormatterRegistry", function() {
            it( "registers the built-in return formatters", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();

                expect( registry.hasReturnFormatter( "array" ) ).toBeTrue();
                expect( registry.hasReturnFormatter( "query" ) ).toBeTrue();
                expect( registry.hasReturnFormatter( "none" ) ).toBeTrue();
                expect( registry.hasReturnFormatter( "struct" ) ).toBeTrue();
            } );

            it( "registers closure factories", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();
                registry.registerReturnFormatter(
                    "ids",
                    function( options ) {
                        return function( q ) {
                            return options.prefix & q.id[ 1 ];
                        };
                    },
                    { "prefix": "user-" }
                );

                var formatter = registry.getReturnFormatter( "ids" );
                var q = queryNew( "id", "integer", [ { "id": 1 } ] );

                expect( formatter( q ) ).toBe( "user-1" );
            } );

            it( "merges runtime options over registered options", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();
                registry.registerReturnFormatter(
                    "ids",
                    function( options ) {
                        return function( q ) {
                            return options.prefix & q.id[ 1 ];
                        };
                    },
                    { "prefix": "user-" }
                );

                var formatter = registry.getReturnFormatter( "ids", { "prefix": "account-" } );
                var q = queryNew( "id", "integer", [ { "id": 1 } ] );

                expect( formatter( q ) ).toBe( "account-1" );
            } );

            it( "throws for duplicate formatter names unless force is true", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();
                var factory = function( options ) {
                    return function( q ) {
                        return q;
                    };
                };
                registry.registerReturnFormatter( "custom", factory );

                expect( function() {
                    registry.registerReturnFormatter( "custom", factory );
                } ).toThrow( type = "DuplicateReturnFormatter" );

                registry.registerReturnFormatter(
                    name = "custom",
                    factory = function( options ) {
                        return function( q ) {
                            return "forced";
                        };
                    },
                    force = true
                );

                expect( registry.getReturnFormatter( "custom" )( queryNew( "" ) ) ).toBe( "forced" );
            } );

            it( "normalizes shorthand return formatter definitions", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry(
                    returnFormatters = {
                        "custom": function( options ) {
                            return function( q ) {
                                return "custom";
                            };
                        }
                    }
                );

                expect( registry.getReturnFormatter( "custom" )( queryNew( "" ) ) ).toBe( "custom" );
            } );

            it( "does not mutate formatter definitions while normalizing them", function() {
                var definition = {
                    "factory": function( options ) {
                        return function( q ) {
                            return q;
                        };
                    }
                };
                var originalKeys = definition.keyArray();
                var registry = new qb.models.Query.ReturnFormatterRegistry(
                    returnFormatters = { "custom": definition }
                );

                expect( definition.keyArray() ).toBe( originalKeys );
                expect( definition ).notToHaveKey( "options" );
                expect( definition ).notToHaveKey( "properties" );
                expect( definition ).notToHaveKey( "force" );
                expect( registry.hasReturnFormatter( "custom" ) ).toBeTrue();
            } );

            it( "resolves WireBox formatter factories with properties", function() {
                var registry = new qb.models.Query.ReturnFormatterRegistry();
                registry.setWirebox( {
                    "getInstance": function( name, initArguments ) {
                        expect( name ).toBe( "MyFormatter@testing" );
                        expect( initArguments ).toBe( { "properties": { "prefix": "user-" } } );
                        return {
                            "toFormatter": function( options ) {
                                return function( q ) {
                                    return initArguments.properties.prefix & options.suffix;
                                };
                            }
                        };
                    }
                } );
                registry.registerReturnFormatter(
                    name = "wirebox",
                    factory = "MyFormatter@testing",
                    properties = { "prefix": "user-" },
                    options = { "suffix": "1" }
                );

                expect( registry.getReturnFormatter( "wirebox" )( queryNew( "" ) ) ).toBe( "user-1" );
            } );
        } );
    }

}
