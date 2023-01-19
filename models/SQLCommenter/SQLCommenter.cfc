/**
 * @doc_abstract true
 */
component singleton {

    /**
     * Gathers comments from the configured commenters and appends it to the SQL query.
     * @doc_abstract true
     *
     * @sql         The SQL string to add the comment to.
     * @datasource  The datasource that will execute the query.
     *              If null, the default datasource is going to be used.
     *
     * @return      Commented SQL string
     */
    public string function appendSqlComments( required string sql, string datasource ) {
        throw( "appendSqlComments is an abstract method and must be implemented in a subclass." );
    }

    /**
     * Serializes and appends a struct of key/value comment pairs to the provided SQL string.
     *
     * @sql       The SQL string to add the serialized comments to.
     * @comments  The key/value pairs to serialize and append.
     *
     * @return    Commented SQL string
     */
    public string function appendCommentsToSQL( required string sql, required struct comments ) {
        // DO NOT mutate a statement with an already present comment
        if ( containsSQLComment( arguments.sql ) ) {
            return arguments.sql;
        }

        var serializedComments = [];
        for ( var key in arguments.comments ) {
            serializedComments.append( serializeComment( key, arguments.comments[ key ] ) );
        }

        arraySort( serializedComments, "textnocase" )

        return arguments.sql & " /*#arrayToList( serializedComments )#*/";
    }

    /**
     * Parses a commented SQL string into the SQL and a struct of the key/value pair comments.
     *
     * @sql     The commented SQL string to parse.
     *
     * @return  { "sql": string, "comments": struct }
     */
    public struct function parseCommentedSQL( required string sql ) {
        var commentStartPosition = find( "/*", arguments.sql ) - 1;
        return {
            "sql": left( arguments.sql, commentStartPosition - 1 ),
            "comments": parseCommentString(
                mid( arguments.sql, commentStartPosition + 1, len( arguments.sql ) - commentStartPosition + 1 )
            )
        };
    }

    /**
     * Parses a comment string into a struct.
     *
     * @commentString  The comment string to parse into a struct.
     *
     * @return         A struct of key/value pairs from the comment.
     */
    public struct function parseCommentString( required string commentString ) {
        arguments.commentString = trim( arguments.commentString );
        arguments.commentString = replace( arguments.commentString, "/*", "" );
        arguments.commentString = replace( arguments.commentString, "*/", "" );
        return listToArray( arguments.commentString ).reduce( ( acc, serializedKeyValuePair ) => {
            var key = decodeFromURL( unescapeMetaCharacters( listFirst( serializedKeyValuePair, "=" ) ) );
            var value = decodeFromURL(
                unescapeMetaCharacters( unescapeSQL( listLast( serializedKeyValuePair, "=" ) ) )
            );
            acc[ key ] = value;
            return acc;
        }, {} );
    }

    /**
     * Returns true if the SQL already contains a comment.
     *
     * @sql     The SQL to check for a comment.
     *
     * @return  True if the SQL already contains a comment.
     */
    private boolean function containsSQLComment( required string sql ) {
        return find( "--", arguments.sql ) > 0 || find( "/*", arguments.sql ) > 0;
    }

    /**
     * Serializes a key/value pair for use in a comment string.
     *
     * @key     The key to serialize.
     * @value   The value to serialize.
     *
     * @return  A serialized string for the key/value pair.
     */
    private string function serializeComment( required string key, required string value ) {
        return serializeKey( arguments.key ) & "=" & serializeValue( arguments.value );
    }

    /**
     * Serializes a key for use in a comment string.
     *
     * @key     The key to serialize.
     *
     * @return  The serialized key.
     */
    private string function serializeKey( required string key ) {
        return escapeMetaCharacters( encodeForURL( arguments.key ) );
    }

    /**
     * Serializes a value for use in a comment string.
     *
     * @value   The value to serialize.
     *
     * @return  The serialized value.
     */
    private string function serializeValue( required string value ) {
        return escapeSQL(
            escapeMetaCharacters(
                replace(
                    encodeForURL( arguments.value ),
                    "+",
                    "%20",
                    "all"
                )
            )
        );
    }

    /**
     * Escapes meta characters such as single quotes in the passed in string.
     *
     * @str     The string to escape meta characters.
     *
     * @return  The string with meta characters escaped.
     */
    private string function escapeMetaCharacters( required string str ) {
        return replace( arguments.str, "'", "\'", "all" );
    }

    /**
     * Unescapes meta characters such as single quotes in the passed in string.
     *
     * @str     The string to unescape meta characters.
     *
     * @return  The string without meta characters escaped.
     */
    private string function unescapeMetaCharacters( required string str ) {
        return replace( arguments.str, "\'", "'", "all" );
    }

    /**
     * Escapes a string for SQL by surrounding it in single quotes.
     *
     * @str      The string to escape for SQL.
     *
     * @returns  The string escaped for SQL.
     */
    private string function escapeSQL( required string str ) {
        return "'" & arguments.str & "'";
    }

    /**
     * Unescapes a string for SQL by removing the surrounding single quotes.
     *
     * @str      The string to unescape for SQL.
     *
     * @returns  The string unescaped for SQL.
     */
    private string function unescapeSQL( required string str ) {
        return mid( arguments.str, 2, len( arguments.str ) - 2 );
    }

}
