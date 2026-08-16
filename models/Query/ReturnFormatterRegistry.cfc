component accessors="true" singleton {

    property name="utils";
    property name="wirebox" inject="wirebox";

    public ReturnFormatterRegistry function init(
        any utils = new qb.models.Query.QueryUtils(),
        struct returnFormatters = {}
    ) {
        variables.utils = arguments.utils;
        variables.wirebox = javacast( "null", "" );
        variables.returnFormatters = {};

        registerBuiltInReturnFormatters();
        registerReturnFormatters( arguments.returnFormatters );

        return this;
    }

    public ReturnFormatterRegistry function registerReturnFormatters( required struct returnFormatters ) {
        for ( var name in arguments.returnFormatters ) {
            var definition = normalizeFormatterDefinition( arguments.returnFormatters[ name ] );
            registerReturnFormatter(
                name = name,
                factory = definition.factory,
                options = definition.options,
                properties = definition.properties,
                force = definition.force
            );
        }

        return this;
    }

    public ReturnFormatterRegistry function registerReturnFormatter(
        required string name,
        required any factory,
        struct options = {},
        struct properties = {},
        boolean force = false
    ) {
        if ( hasReturnFormatter( arguments.name ) && !arguments.force ) {
            throw(
                type = "DuplicateReturnFormatter",
                message = "A return formatter named [#arguments.name#] has already been registered. Pass force = true to replace it."
            );
        }

        variables.returnFormatters[ arguments.name ] = {
            "factory": arguments.factory,
            "options": cloneConfigurationValue( arguments.options ),
            "properties": cloneConfigurationValue( arguments.properties )
        };

        return this;
    }

    public function getReturnFormatter( required string name, struct options = {} ) {
        if ( !hasReturnFormatter( arguments.name ) ) {
            throw(
                type = "UnknownReturnFormatter",
                message = "No return formatter named [#arguments.name#] has been registered."
            );
        }

        var definition = variables.returnFormatters[ arguments.name ];
        var formatterOptions = cloneConfigurationValue( definition.options );
        structAppend( formatterOptions, cloneConfigurationValue( arguments.options ), true );

        var factory = resolveFactory( definition.factory, cloneConfigurationValue( definition.properties ) );

        if ( isClosure( factory ) || isCustomFunction( factory ) ) {
            return factory( formatterOptions );
        }

        return factory.toFormatter( formatterOptions );
    }

    public boolean function hasReturnFormatter( required string name ) {
        return variables.returnFormatters.keyExists( arguments.name );
    }

    private void function registerBuiltInReturnFormatters() {
        registerReturnFormatter(
            name = "query",
            factory = function( options ) {
                return function( q ) {
                    return q;
                };
            }
        );
        registerReturnFormatter(
            name = "none",
            factory = function( options ) {
                return function( q ) {
                    return q;
                };
            }
        );
        registerReturnFormatter(
            name = "array",
            factory = function( options ) {
                return function( q ) {
                    return variables.utils.queryToArrayOfStructs( q );
                };
            }
        );
        registerReturnFormatter(
            name = "struct",
            factory = new qb.models.Query.Formatters.StructFormatter( variables.utils )
        );
    }

    private struct function normalizeFormatterDefinition( required any definition ) {
        if ( isStruct( arguments.definition ) && arguments.definition.keyExists( "factory" ) ) {
            var normalizedDefinition = structCopy( arguments.definition );
            param normalizedDefinition.options = {};
            param normalizedDefinition.properties = {};
            param normalizedDefinition.force = false;

            return {
                "factory": normalizedDefinition.factory,
                "options": normalizedDefinition.options,
                "properties": normalizedDefinition.properties,
                "force": normalizedDefinition.force
            };
        }

        return {
            "factory": arguments.definition,
            "options": {},
            "properties": {},
            "force": false
        };
    }

    private any function cloneConfigurationValue( any value ) {
        if ( isNull( arguments.value ) ) {
            return javacast( "null", "" );
        }

        if ( isStruct( arguments.value ) ) {
            var clonedStruct = {};
            for ( var key in arguments.value ) {
                clonedStruct[ key ] = isNull( arguments.value[ key ] )
                 ? javacast( "null", "" )
                 : cloneConfigurationValue( arguments.value[ key ] );
            }
            return clonedStruct;
        }

        if ( isArray( arguments.value ) ) {
            var clonedArray = [];
            if ( !arguments.value.isEmpty() ) {
                arrayResize( clonedArray, arguments.value.len() );
            }
            for ( var i = 1; i <= arguments.value.len(); i++ ) {
                if ( arrayIsDefined( arguments.value, i ) ) {
                    clonedArray[ i ] = isNull( arguments.value[ i ] )
                     ? javacast( "null", "" )
                     : cloneConfigurationValue( arguments.value[ i ] );
                }
            }
            return clonedArray;
        }

        return arguments.value;
    }

    private function resolveFactory( required any factory, struct properties = {} ) {
        if ( isClosure( arguments.factory ) || isCustomFunction( arguments.factory ) ) {
            return arguments.factory;
        }

        if ( isSimpleValue( arguments.factory ) ) {
            if ( isNull( variables.wirebox ) ) {
                throw(
                    type = "WireBoxRequired",
                    message = "A WireBox instance is required to resolve the [#arguments.factory#] return formatter factory."
                );
            }

            return variables.wirebox.getInstance(
                name = arguments.factory,
                initArguments = { "properties": arguments.properties }
            );
        }

        if ( !structKeyExists( arguments.factory, "toFormatter" ) ) {
            throw(
                type = "InvalidReturnFormatter",
                message = "Return formatter factories must be a closure, WireBox mapping name, or component with a toFormatter method."
            );
        }

        return arguments.factory;
    }

}
