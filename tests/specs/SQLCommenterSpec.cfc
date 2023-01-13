component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.sqlCommenter = new qb.models.SQLCommenter.SQLCommenter();
    }

    function run() {
        describe( "SQLCommenter", () => {
            describe( "containsSQLComment", () => {
                it( "can detect if a SQL statement has a comment in it", function() {
                    makePublic( variables.sqlCommenter, "containsSQLComment", "containsSQLCommentPublic" );
                    expect(
                        variables.sqlCommenter.containsSQLCommentPublic( "SELECT * /* should not use star */ FROM users" )
                    ).toBeTrue();
                    expect( variables.sqlCommenter.containsSQLCommentPublic( "SELECT * FROM users" ) ).toBeFalse();
                } );
            } );

            describe( "serializeValue", () => {
                it( "can serialize values in a key value pair", function() {
                    makePublic( variables.sqlCommenter, "serializeValue", "serializeValuePublic" );
                    expect( variables.sqlCommenter.serializeValuePublic( "DROP TABLE FOO" ) ).toBe( "'DROP%20TABLE%20FOO'" );
                    expect( variables.sqlCommenter.serializeValuePublic( "/param first" ) ).toBe( "'%2Fparam%20first'" );
                    expect( variables.sqlCommenter.serializeValuePublic( "1234" ) ).toBe( "'1234'" );
                } );
            } );

            describe( "serializeComment", () => {
                it( "can serialize key value pair comments", function() {
                    makePublic( variables.sqlCommenter, "serializeComment", "serializeCommentPublic" );
                    expect( variables.sqlCommenter.serializeCommentPublic( "route", "/polls 1000" ) ).toBe( "route='%2Fpolls%201000'" );
                    expect( variables.sqlCommenter.serializeCommentPublic( "name''", """DROP TABLE USERS'""" ) ).toBe( "name%27%27='%22DROP%20TABLE%20USERS%27%22'" );
                } );
            } );

            describe( "appendCommentsToSQL", () => {
                it( "serializes comments on the end of a sql query", function() {
                    var commentedSQL = variables.sqlCommenter.appendCommentsToSQL(
                        sql = "SELECT * FROM foo",
                        comments = {
                            "event": "Main.index",
                            "framework": "coldbox-6.0.0",
                            "handler": "Main",
                            "action": "index",
                            "route": "/",
                            "dbDriver": "mysql-connector-java-8.0.25 (Revision: 08be9e9b4cba6aa115f9b27b215887af40b159e0)"
                        }
                    );

                    expect( commentedSQL ).toBeWithCase(
                        "SELECT * FROM foo /*action='index',dbDriver='mysql-connector-java-8.0.25%20%28Revision%3A%2008be9e9b4cba6aa115f9b27b215887af40b159e0%29',event='Main.index',framework='coldbox-6.0.0',handler='Main',route='%2F'*/"
                    );
                } );
            } );

            describe( "parseCommentedSQL", () => {
                it( "can parse a commented SQL string into the sql and the comments", function() {
                    var commentedSQL = "SELECT * FROM foo /*action='index',dbDriver='mysql-connector-java-8.0.25%20%28Revision%3A%2008be9e9b4cba6aa115f9b27b215887af40b159e0%29',event='Main.index',framework='coldbox-6.0.0',handler='Main',route='%2F'*/";
                    var sqlAndComments = variables.sqlCommenter.parseCommentedSQL( commentedSQL );
                    expect( sqlAndComments.sql ).toBeWithCase( "SELECT * FROM foo" );
                    expect( sqlAndComments.comments ).toBe( {
                        "event": "Main.index",
                        "framework": "coldbox-6.0.0",
                        "handler": "Main",
                        "action": "index",
                        "route": "/",
                        "dbDriver": "mysql-connector-java-8.0.25 (Revision: 08be9e9b4cba6aa115f9b27b215887af40b159e0)"
                    } );
                } );
            } );
        } );
    }

}
