# qb
[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors)
[![Build Status](https://img.shields.io/travis/coldbox-modules/qb/master.svg?style=flat-square)](https://travis-ci.org/coldbox-modules/qb)

## Introduction

qb is a fluent query builder for CFML.  It is **heavily** inspired by [Eloquent](https://laravel.com/docs/5.3/eloquent) from [Laravel](https://laravel.com/).

Using qb, you can:

+ Quickly scaffold simple queries
+ Make complex, out-of-order queries possible
+ Abstract away differences between database engines

## Requirements

+ Adobe ColdFusion 11+
+ Lucee 4.5+

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
    [ { value = '5,10,27', cfsqltype = 'CF_SQL_NUMERIC', list = true } ]
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
    [ { value = 'Ja%', cfsqltype = 'CF_SQL_VARCHAR', list = false, null = false } ]
);
```

qb enables you to explore new ways of organizing your code by letting you pass around a query builder object that will compile down to the right SQL without you having to keep track of the order, whitespace, or other SQL gotchas!

Here's a gist with an example of the powerful models you can create with this!
https://gist.github.com/elpete/80d641b98025f16059f6476561d88202

## Full Docs

You can browse the full documentation at https://qb.ortusbooks.com

## Contributors

Thanks goes to these wonderful people ([emoji key](https://github.com/kentcdodds/all-contributors#emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
| [<img src="https://avatars2.githubusercontent.com/u/2583646?v=3" width="100px;"/><br /><sub>Eric Peterson</sub>](https://github.com/elpete)<br />[💻](https://github.com/coldbox-modules/qb/commits?author=elpete "Code") [📖](https://github.com/coldbox-modules/qb/commits?author=elpete "Documentation") | [<img src="https://avatars2.githubusercontent.com/u/148847?v=3" width="100px;"/><br /><sub>John Whish</sub>](http://www.aliaspooryorik.com/blog/)<br />[💬](#question-aliaspooryorik "Answering Questions") [💻](https://github.com/coldbox-modules/qb/commits?author=aliaspooryorik "Code") | [<img src="https://avatars0.githubusercontent.com/u/5429291?v=3" width="100px;"/><br /><sub>Dan Murphy</sub>](https://github.com/murphydan)<br />[🐛](https://github.com/coldbox-modules/qb/issues?q=author%3Amurphydan "Bug reports") [💻](https://github.com/coldbox-modules/qb/commits?author=murphydan "Code") | [<img src="https://avatars3.githubusercontent.com/u/1346234?v=3" width="100px;"/><br /><sub>Tim Brown</sub>](https://github.com/timmaybrown)<br />[💻](https://github.com/coldbox-modules/qb/commits?author=timmaybrown "Code") | [<img src="https://avatars0.githubusercontent.com/u/23514337?v=4" width="100px;"/><br /><sub>BluewaterSolutions</sub>](https://github.com/BluewaterSolutions)<br />[🐛](https://github.com/coldbox-modules/qb/issues?q=author%3ABluewaterSolutions "Bug reports") [💻](https://github.com/coldbox-modules/qb/commits?author=BluewaterSolutions "Code") [📖](https://github.com/coldbox-modules/qb/commits?author=BluewaterSolutions "Documentation") | [<img src="https://avatars1.githubusercontent.com/u/3632399?v=4" width="100px;"/><br /><sub>Tony Junkes</sub>](http://tonyjunkes.com)<br />[📝](#blog-tonyjunkes "Blogposts") [📖](https://github.com/coldbox-modules/qb/commits?author=tonyjunkes "Documentation") |
| :---: | :---: | :---: | :---: | :---: | :---: |
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind welcome!
