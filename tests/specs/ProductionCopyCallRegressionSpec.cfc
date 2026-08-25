component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "production copy calls", function() {
            it( "does not use duplicate or structCopy", function() {
                var productionFiles = [];
                for (
                    var modelFile in directoryList(
                        expandPath( "/qb/models" ),
                        true,
                        "path",
                        "*.cfc"
                    )
                ) {
                    productionFiles.append( modelFile );
                }
                productionFiles.append( expandPath( "/qb/ModuleConfig.cfc" ) );

                var matchingFiles = [];
                for ( var filePath in productionFiles ) {
                    if ( reFindNoCase( "\b(?:duplicate|structCopy)\s*\(", fileRead( filePath ) ) ) {
                        matchingFiles.append( filePath );
                    }
                }

                expect( matchingFiles ).toBeEmpty(
                    "Production code should construct owned values directly. Matches: #matchingFiles.toList( ", " )#"
                );
            } );
        } );
    }

}
