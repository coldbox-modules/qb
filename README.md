# qb

[![Master Branch Build Status](https://img.shields.io/travis/elpete/qb/master.svg?style=flat-square&label=master)](https://travis-ci.org/elpete/qb)
[![Development Branch Build Status](https://img.shields.io/travis/elpete/qb/development.svg?style=flat-square&label=development)](https://travis-ci.org/elpete/qb)

## Introduction

qb is a fluent query builder for ColdBox.  It is **heavily** inspired by [Eloquent](https://laravel.com/docs/5.3/eloquent) from [Laravel](https://laravel.com/)  Using qb, you can:

+ Quickly scaffold simple queries
+ Make complex, out-of-order queries possible
+ Abstract away differences between database engines

## Code Samples

Compare these two examples:

```cfc
// Plain old CFML
q = queryExecute("SELECT * FROM users");

// qb
query = wirebox.getInstance('Builder@qb');
q = query.from('users').get();
```

The differences become even more stark when we introduce more complexity:

```cfc
// Plain old CFML
q = queryExecute(
    "SELECT * FROM posts WHERE published_at IS NOT NULL AND author_id IN ?",
    [ { value = '5,10,27', cfsqltype = 'CF_SQL_NUMERIC', list = true } ]
);

// qb
query = wirebox.getInstance('Builder@qb');
q = query.from('posts')
         .whereNotNull('published_at')
         .whereIn('author_id', [5, 10, 27])
         .get();
```

With Quick you can easily handle setting order by statements before the columns you want or join statements after a where clause:

```cfc
query = wirebox.getInstance('Builder@qb');
q = query.from('posts')
         .orderBy('published_at')
         .select('post_id', 'author_id', 'title', 'body')
         .whereLike('author', 'Ja%')
         .join('authors', 'authors.id', '=', 'posts.author_id')
         .get();

// Becomes

q = queryExecute(
    "SELECT post_id, author_id, title, body FROM posts INNER JOIN authors ON authors.id = posts.author_id WHERE author LIKE ? ORDER BY published_at",
    [ { value = 'Ja%', cfsqltype = 'CF_SQL_VARCHAR', list = false, null = false } ]
);
```

qb enables you to explore new ways of organizing your code by letting you pass around a query builder object that will compile down to the right SQL without you having to keep track of the order, whitespace, or other SQL gotchas!

Here's a gist with an example of the powerful models you can create with this!
https://gist.github.com/elpete/80d641b98025f16059f6476561d88202

## Requirements

+ Adobe ColdFusion 11+
+ Lucee 4.5+

## Installation

Installation is easy through [CommandBox](https://www.ortussolutions.com/products/commandbox) and [ForgeBox](https://www.coldbox.org/forgebox).  Simply type `box install qb` to get started.

## Usage

To start a new query, instantiate a new Builder: `wirebox.getInstance('Builder@qb')`.

By default, qb uses a generic Grammar.  You can specify your specific grammar in ColdBox by setting the `defaultGrammar` in your `moduleSettings`.

```
moduleSettings = {
    qb = {
        defaultGrammar = "MySQLGrammar"
    }
};
```

If you are not using WireBox, just make sure to wire up the `Builder` object with the correct grammar:

```
var grammar = new qb.models.Query.Grammars.MySQLGrammar();
var builder = new qb.models.Query.Builder( grammar );
```

## Docs

Coming soon!