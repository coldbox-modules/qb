/**
 * No-op logger used outside of a ColdBox application.
 */
component singleton {

    public boolean function canDebug() {
        return false;
    }

    public void function debug( any message, any extraInfo ) {
    }

}
