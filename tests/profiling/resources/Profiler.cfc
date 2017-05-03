component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        addMatchers( {
            toAverageLessThan = variables.toAverageLessThan
        } );
    }

    function getAverageExecutionTime( callback, iterations = 1 ) {
        var threads = [];
        for ( var i = 1; i <= iterations; i++ ) {
            var threadName = "profiler-#createUUID()#";
            arrayAppend( threads, threadName );
            thread action="run" name="#threadName#" callback="#callback#" {
                try {
                    attributes.callback();
                }
                catch ( any e ) {
                    thread.exception = e;
                }
            }
        }

        thread action="join" name="#threads.toList()#";

        var times = [];
        for ( var threadName in threads ) {
            var threadInstance = cfthread[ threadName ];

            if ( structKeyExists( threadInstance, "exception" ) ) {
                throw( argumentCollection = threadInstance.exception );
            }

            arrayAppend( times, threadInstance.elapsedTime );
        }

        return arrayAvg( times );
    }

    function toAverageLessThan( expectation, args = {} ) {
        param args.ms = 0;
        param args.iterations = 1;
        param args.dumpOutTimes = false;

        args.ms = args [ 1 ];

        var threads = [];
        for ( var i = 1; i <= args.iterations; i++ ) {
            var threadName = "profiler-#createUUID()#";
            arrayAppend( threads, threadName );
            thread action="run" name="#threadName#" expectation="#expectation#" {
                try {
                    attributes.expectation.actual();
                }
                catch ( any e ) {
                    thread.exception = e;
                }
            }
        }

        thread action="join" name="#threads.toList()#";

        var times = [];
        for ( var threadName in threads ) {
            var threadInstance = cfthread[ threadName ];

            if ( structKeyExists( threadInstance, "exception" ) ) {
                expectation.message = "An exception was thrown: #serializeJSON( threadInstance.exception )#";
                return false;
            }

            arrayAppend( times, threadInstance.elapsedTime );
        }
        if ( args.dumpOutTimes ) {
            writeDump( var = times );
        }
        var averageTime = arrayAvg( times );
        
        expectation.message = "Average elapsed time [#averageTime#] is greater than allowed time [#args.ms#].";
        return averageTime < args.ms;
    }

    function newMySQLBuilder() {
        return new models.Query.Builder(
            new models.Query.Grammars.MySQLGrammar()
        );
    }

}