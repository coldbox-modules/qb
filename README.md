# qb
[![Build Status](https://img.shields.io/travis/coldbox-modules/qb/master.svg?style=flat-square)](https://travis-ci.org/coldbox-modules/qb)

## Introduction

qb is a fluent query builder for CFML.  It is **heavily** inspired by [Eloquent](https://laravel.com/docs/5.3/eloquent) from [Laravel](https://laravel.com/).

Using qb, you can:

+ Quickly scaffold simple queries
+ Make complex, out-of-order queries possible
+ Abstract away differences between database engines

## Requirements

+ Adobe ColdFusion 2018+
+ Lucee 5+

## Installation

Installation is easy through [CommandBox](https://www.ortussolutions.com/products/commandbox) and [ForgeBox](https://www.coldbox.org/forgebox).  Simply type `box install qb` to get started.

## Code Samples

Compare these two examples:

```cfc
// Plain old CFML
q = queryExecute("SELECT * FROM users");

// qb
query = wirebox.getInstance('QueryBuilder@qb');
q = query.from('users').get();
```

The differences become even more stark when we introduce more complexity:

```cfc
// Plain old CFML
q = queryExecute(
    "SELECT * FROM posts WHERE published_at IS NOT NULL AND author_id IN ?",
    [ { value = '5,10,27', cfsqltype = 'NUMERIC', list = true } ]
);

// qb
query = wirebox.getInstance('QueryBuilder@qb');
q = query.from('posts')
         .whereNotNull('published_at')
         .whereIn('author_id', [5, 10, 27])
         .get();
```

With Quick you can easily handle setting order by statements before the columns you want or join statements after a where clause:

```cfc
query = wirebox.getInstance('QueryBuilder@qb');
q = query.from('posts')
         .orderBy('published_at')
         .select('post_id', 'author_id', 'title', 'body')
         .whereLike('author', 'Ja%')
         .join('authors', 'authors.id', '=', 'posts.author_id')
         .get();

// Becomes

q = queryExecute(
    "SELECT post_id, author_id, title, body FROM posts INNER JOIN authors ON authors.id = posts.author_id WHERE author LIKE ? ORDER BY published_at",
    [ { value = 'Ja%', cfsqltype = 'VARCHAR', list = false, null = false } ]
);
```

qb enables you to explore new ways of organizing your code by letting you pass around a query builder object that will compile down to the right SQL without you having to keep track of the order, whitespace, or other SQL gotchas!

## Bulk WHERE IN

For large value collections, `whereInBulk` serializes the values into one bound parameter and lets the active grammar expand them into rows. This avoids database parameter limits without changing the behavior or performance of regular `whereIn` calls.

```cfc
query
    .from( "users" )
    .whereInBulk( "id", userIds )
    .get();
```

qb infers a common type from the values and translates it to the active database grammar. Matching `cfsqltype` values in query parameter structs are preserved. Mixed values fall back to the grammar's string type.

You can pass an explicit `sqlType` as the third argument when the column needs a more specific database type, such as `BIGINT`, `UUID`, or a particular decimal precision:

```cfc
query
    .from( "users" )
    .whereInBulk( "id", userIds, "BIGINT" )
    .get();
```

The explicit `sqlType` should match the constrained column so the database can avoid implicit conversions. `whereNotInBulk`, `andWhereInBulk`, `orWhereInBulk`, `andWhereNotInBulk`, and `orWhereNotInBulk` are also available.

Bulk value expansion is supported by these grammars and database features:

+ SQL Server 2016+ using `OPENJSON`; database compatibility level 130+ is required
+ PostgreSQL 9.4+ using `JSONB_ARRAY_ELEMENTS_TEXT`
+ MySQL 8.0.4+ and MariaDB 10.6+ using `JSON_TABLE`
+ Oracle Database 12c Release 1 (12.1.0.2)+ using `JSON_TABLE`
+ SQLite with JSON functions enabled; they are built in by default as of SQLite 3.38.0

Derby does not support bulk value expansion and throws an `UnsupportedOperation` exception for non-empty collections.

## Development Validation

qb can detect statically identifiable duplicate select output names before they are silently collapsed by CFML query results. Enable this validation in development and leave it disabled in production:

```cfc
moduleSettings = {
    "qb": {
        "validateDuplicateSelectColumns": true
    }
};
```

The validation checks the final selection when the query is compiled, including simple columns, explicit aliases, subselect aliases, and explicitly aliased typed columns. Wildcards and expressions without explicit aliases are skipped because their output names cannot be known until the query executes.

## Return Formatters

qb includes named return formatters for `array`, `query`, `none`, and `struct`. The `struct` formatter returns a struct of rows keyed by a selected column:

```cfc
usersByUsername = query
    .setReturnFormat( "struct", { "columnKey": "username" } )
    .from( "users" )
    .get();
```

Applications can register reusable custom formatter factories in their qb module settings:

```cfc
moduleSettings = {
    "qb": {
        "returnFormatters": {
            "ids": function( options ) {
                return function( q ) {
                    return queryColumnData( q, options.column );
                };
            }
        }
    }
};

ids = query
    .setReturnFormat( "ids", { "column": "id" } )
    .from( "users" )
    .get();
```

Formatter factories can also be WireBox mapping names or components with a `toFormatter( options )` method.

Here's a gist with an example of the powerful models you can create with this!
https://gist.github.com/elpete/80d641b98025f16059f6476561d88202

## SQLite Datasource Setup

To use the SQLite grammar for qb you will need to setup a datasource that connects to a SQLite database.

### Install the SQLite JDBC driver

1. Download the [latest release](https://github.com/xerial/sqlite-jdbc/releases) of the SQLite JDBC Driver i.e. https://github.com/xerial/sqlite-jdbc/releases/download/3.40.0.0/sqlite-jdbc-3.40.0.0.jar
2. Drop it in the `/lib` directory
3. Configure the application to load the library by adding this line in your `Application.cfc` file.

    ```
    this.javaSettings = { loadPaths : [ ".\lib" ] };
    ```
4. Restart the server

### Configure the Datasource

You can configure your datasource for Lucee or Adobe Coldfusion using the steps below. You can also use [cfconfig](https://cfconfig.ortusbooks.com/using-the-cli/installation) with CommandBox to do it automatically for you.

For both Lucee and ACF you need to set the JDBC Driver class to `org.sqlite.JDBC`. Then you need to specify the JDBC connection string as `jdbc:sqlite:<your database path>`. i.e. `jdbc:sqlite:C:/data/my_database.db`

**Lucee**
1. Navigate to Datasources in the Lucee administrator
2. Enter datasource name
3. Select Type: Other - JDBC Driver
4. Click Create
5. Enter `org.sqlite.JDBC` for Class
6. Enter the Connection String: `jdbc:sqlite:<db path>`
7. Click Create

**ACF**
1. Navigate to Datasources in the ACF administrator
2. Enter the datasource name under Add New Data Source
3. Select `other` for the datasource driver
4. Click Add
5. Enter `org.sqlite.JDBC` for the Driver Class
6. Use `org.sqlite.JDBC` for the Driver Name
7. Etner the JDBC URL: `jdbc:sqlite:<db path>`
8. Click Submit


## Full Docs

You can browse the full documentation at https://qb.ortusbooks.com
