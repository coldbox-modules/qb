component extends="qb.models.Grammars.PostgresGrammar" {

    variables.unwrappedEntered = createObject( "java", "java.util.concurrent.CountDownLatch" ).init( 1 );
    variables.wrappedEntered = createObject( "java", "java.util.concurrent.CountDownLatch" ).init( 1 );
    variables.unwrappedRead = createObject( "java", "java.util.concurrent.CountDownLatch" ).init( 1 );

    function wrapValue( required any value ) {
        if ( arguments.value == "unwrapped_column" ) {
            variables.unwrappedEntered.countDown();
            variables.wrappedEntered.await();
            var result = super.wrapValue( arguments.value );
            variables.unwrappedRead.countDown();
            return result;
        }

        if ( arguments.value == "wrapped_column" ) {
            variables.unwrappedEntered.await();
            variables.wrappedEntered.countDown();
            variables.unwrappedRead.await();
        }

        return super.wrapValue( arguments.value );
    }

}
