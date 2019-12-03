[![General Assembly Logo](https://camo.githubusercontent.com/1a91b05b8f4d44b5bbfb83abac2b0996d8e26c92/687474703a2f2f692e696d6775722e636f6d2f6b6538555354712e706e67)](https://generalassemb.ly/education/web-development-immersive)

# SQL

An introduction to relational databases.

## Objectives

By the end of this, developers should be able to:

- Create a database table
- Insert a row or rows into a database table
- Retrieve a row or rows from a database table
- Modify a database table after creation
- Update a row or rows in a database table
- Delete a row or rows from a database table

## Installation

### Mac

Install postgres via homebrew
```
brew install postgres
```
Start postgres
```
brew services start postgres
```
wait a few seconds to allow the service to start
```
sleep 3s
```
create database with current system username `whoami`
```  
createdb
```

### Ubuntu

install postgres and build dependency
```
sudo apt-get install -y postgresql libpq-dev
```
create user in postgres with name of current  system user
```
sudo -u postgres createuser "$(whoami)" -s
```
create database with name of current system 
user
```  
sudo -u postgres createdb "$(whoami)"
```
start postgres server
```
sudo service postgresql start
```

### Windows

```
psql -c "UPDATE pg_database SET datistemplate=FALSE WHERE datname='template1';" &> /dev/null
psql -c "DROP DATABASE template1;" &> /dev/null
psql -c "CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';" &> /dev/null
psql -c "UPDATE pg_database SET datistemplate=TRUE WHERE datname='template1';" &> /dev/null
psql -c "\c template1;" &> /dev/null
psql -c "VACUUM FREEZE;" &> /dev/null
```

### Everyone
Resource bashrc
```
source ~/.bashrc
source ~/.bash_profile
```

install postgres gem for rails
```
gem install pg
```

## Introduction

Why are we talking about SQL?

Most applications need a [data store](https://en.wikipedia.org/wiki/Data_store)
to persist important information. A relational database is the most common
datastore for a web application. SQL is the language of relational databases.

At it's simplest, a relational database is a mechanism to store and retrieve
data in a tabular form.

Spreadsheets are a good analogy. Individual sheets as tables and the whole
spreadsheet as a database. See **[this
link](https://docs.google.com/spreadsheets/d/19rHAb5JW3m25gCxh_WhFqJmYC59gLd0Gt5TZtu7al8E/edit#gid=0)**
for an example.

Why is this important?

Database tables are a good place to store key/value pairs, as long as the values
are simple types (e.g. string, number). The keys are the column names and the
values are stored in each row. That maps well to simple JSON objects. A group of
rows from one table maps well to a JSON array.

What about more complicated data?

Database tables can reference other tables which allows arbitrary nesting of
groups of simple types. This is something we'll be looking at more closely
later.

### Relational Database Management System ([RDBMS](http://en.wikipedia.org/wiki/Relational_database_management_system))

A **[Database
Server](http://upload.wikimedia.org/wikipedia/commons/5/57/RDBMS_structure.png)**
is a set of processes and files that manage the databases that store the tables.
Sticking with our previous analogy a database server would map to Google Sheets.

### Verb Equivalence

**[CRUD](http://en.wikipedia.org/wiki/Create,_read,_update_and_delete)**
_(create, read, update and delete)_, SQL, HTTP, and Rails Controller action.

| CRUD   | SQL    | HTTP   | action     |
|:-------|:-------|:-------|:-----------|
| Create | INSERT | POST   | create     |
| Read   | SELECT | GET    | index/show |
| Update | UPDATE | PATCH  | update     |
| Delete | DELETE | DELETE | destroy    |

## PostgreSQL

We'll be using **[PostgreSQL](https://www.postgresql.org/)**, a popular open
source database server, which should already be installed on your computer.

_On Macs_ you can run `brew services list` to see if PostgreSQL is running.

- If the server isn't running, `status` not `started`, please start it using
  `brew services start postgresql`.

_On Linux_ `service --status-all | grep postgresql` to check if it's running.
(it will return [ + ] if it's running and [ - ] if it's not.

- To start it if it's not running, do `sudo service postgresql start`.

## Code along: CREATE DATABASE

We'll use `sql-crud` as the database to hold our tables and
**[psql](https://www.postgresql.org/docs/11/app-psql.html)** to
interact with it.  `psql` is PostgreSQL's command line client which lets us
execute SQL commands interactively (REPL-like) and from scripts.  It also has
some built in commands we'll find useful.

```bash
$ psql sql-crud
psql: FATAL:  database "sql-crud" does not exist
$
```

But first we need to create the database.  We'll use the **[CREATE
DATABASE](https://www.postgresql.org/docs/11/sql-createdatabase.html)**
command from within `psql`.  This is a
**[SQL](https://www.postgresql.org/docs/11/sql.html)** _(Structure
Query Language - see also the [Wikipedia article](http://en.wikipedia.org/wiki/SQL))_
command and requires that we wrap the database name in double quotes (i.e.
`create database "sql-crud";`). A `-` is not allowed as a name character in SQL
unless the name is surrounded with double-quotes.

If we want to remove a database - be careful, this is unrecoverable - we use the
[DROP
DATABASE](https://www.postgresql.org/docs/11/sql-dropdatabase.html)
command.

If we run `psql` without a parameter it will connect to our default database,
usually named with our login.

```sh
psql
```

```sql
 (11.2)
Type "help" for help.

and=> CREATE DATABASE "sql-crud";
CREATE DATABASE
and=>
```

Once we've created the database we can access it using the psql built-in command
`\c` (for connect):

```sql
and=> \c sql-crud
You are now connected to database "sql-crud" as user "and".
sql-crud=>
```

Or we can access it from the command line using the `psql` command and passing
the database name as an argument:

```sh
psql sql-crud
```

```sql
psql (11.2)
Type "help" for help.

sql-crud=>
```

`psql` has help for both its built-in commands and for SQL.

```sql
psql (11.2)
Type "help" for help.

sql-crud=> help
You are using psql, the command-line interface to PostgreSQL.
Type:  \copyright for distribution terms
       \h for help with SQL commands
       \? for help with psql commands
       \g or terminate with semicolon to execute query
       \q to quit
sql-crud=>
```

Let's look at some of the help for `psql` commands.

- `\l` lists all the databases created on the server we're connected to.
- `\d` (and its variations) shows information about the
 objects in the current database.
- `\i` reads commands from a file

Now let's make sure we're in the right database:

```sql
sql-crud=> select current_catalog;
 current_database
------------------
 sql-crud
(1 row)

sql-crud=>
```

We'll run all our SQL commands against the same database, so it's important that
we consistently use `sql-crud`.

## Tables

We create a table to define the names and types of data we want to store.

PostgreSQL's documentation is extensive and excellent, and we'll want to make
use of it throughout the lesson.

- [Table basics](https://www.postgresql.org/docs/11/ddl-basics.html)
    \- a brief overview of tables in an RDBMS.
- [Data Types](https://www.postgresql.org/docs/11/datatype.html)
    \- the data types available in PostgreSQL.
- [CREATE TABLE](https://www.postgresql.org/docs/11/sql-createtable.html)
    \- detailed documentation of PostgreSQL's version of the SQL `CREATE TABLE`
    command.
- [DROP TABLE](https://www.postgresql.org/docs/11/sql-droptable.html)
    \- detailed documentation of PostgreSQL's version of the SQL `DROP TABLE`
    command.

Note well, `DROP TABLE` is unrecoverable if it executes successfully.

### Code Along: CREATE TABLE

By convention (the one we'll use throughout), tables are named with the
pluralization of the name of the object whose data they hold. So for example, if
each row of data is about a person, then the table is called people. By another
convention, each table will have an `id` column that uniquely identifies each
row. This unique `id` is the `PRIMARY KEY` of the table.

We'll create a table to hold books. We'll use the first line of `data/books.csv`
for the column names.

What data-types should we use for each column?

We'll save the SQL statement to create the books table in
`scripts/library/000_create_table_books.sql`. We can execute the commands in the
file using `psql <db-name> --file=<path-to-file>` or from the psql prompt using
`\i <file>`.

## Bulk load data

- [COPY](https://www.postgresql.org/docs/11/sql-copy.html)
    \- detailed documentation of PostgreSQL's `COPY` command for loading data
    in bulk.

For inserting bulk data, PostgreSQL provides the `COPY` command. We won't use
that command directly, as it executes relative to the server installation,
rather we'll use `psql`'s meta-command `\copy` allowing us to load data relative
to where we run `psql`. Bulk loading is something available with most RDBMSs,
but the specific commands and capabilities vary.

### Code Along: COPY

Note that string literals in SQL statements are delimited by single quotes, i.e.
`'`. To include a single quote in a string literal, double it, e.g. `'That''s
interesting'`. This is not an issue when loading from a valid CSV file using
PostgreSQL's `COPY` command or psql's `\copy` command.

Now we'll load data in bulk from `data/books.csv` using `\copy`. We'll store
that command in `scripts/library/020_bulk_load_books.psql`

## Retrieving rows from a table

This is about the _query_ part of Structured _Query_ Language. Query statements
can run from almost trivial to highly complex. They provide a mechanism to
retrieve and summarize the data in your database.

- [Queries](https://www.postgresql.org/docs/11/queries.html) - TOC
    of the Queries section of PostgreSQL's documentation for `The SQL Language`.
- [SELECT](https://www.postgresql.org/docs/11/sql-select.html) -
    detailed documentation of PostgreSQL's version of the SQL `SELECT` command.

### Code Along: SELECT

Let's build some queries to see what we can learn about the books
in the database.

----

## Lab: CREATE, COPY, and SELECT

**CREATE TABLE:** Create a table to hold information about ingredients.
Use the first row of `data/ingredients.csv` for the names of the columns
other than `id`. Use `scripts/cookbook/000_create_table_ingredients.sql` to
store the SQL statement.

**COPY:** Bulk load `data/ingredients.csv`.

**SELECT:** Write a query to get the count of ingredients by unit.

----

## Removing Rows from a Table

- [Deleting Data](https://www.postgresql.org/docs/11/dml-delete.html)
    \- overview of removing rows from a table
- [DELETE](https://www.postgresql.org/docs/11/sql-delete.html) -
    detailed documentation of PostgreSQL's version of the SQL `DELETE` command.
- [TRUNCATE](https://www.postgresql.org/docs/11/sql-truncate.html) -
    detailed documentation of PostgreSQL's `TRUNCATE` command.

### Code along: DELETE

Let's remove the patients who's given and family names start with the same
letter.

Note, `TRUNCATE <table name>;` is functionally equivalent to `DELETE FROM <table
name>;`, it will remove all the rows from the table.

## Changing the Structure of a Table

- [Modifying Tables](https://www.postgresql.org/docs/11/ddl-alter.html)
    \- overview of changing tables.
- [ALTER TABLE](https://www.postgresql.org/docs/11/sql-altertable.html)
    \- detailed documentation of PostgreSQL's version of the SQL `ALTER TABLE`
    command.

### Code Along: ALTER TABLE

We'll add the column `isbn` to books.

## Changing the Data in Rows of a Table

- [Updating Data](https://www.postgresql.org/docs/11/dml-update.html)
    \- overview of changing rows
- [UPDATE](https://www.postgresql.org/docs/11/sql-update.html) -
    detailed documentation of PostgreSQL's version of the SQL `UPDATE` command.

### Code Along: UPDATE

We'll update the isbn for some books.

## Adding Rows to a Table

- [Inserting Data](https://www.postgresql.org/docs/11/dml-insert.html)
    \- overview of adding rows to a table.
- [INSERT](https://www.postgresql.org/docs/11/sql-insert.html)
    \- detailed documentation of PostgreSQL's version of the SQL `INSERT INTO`
    command.

### Code Along: INSERT INTO

First we'll use variations of `INSERT` to add a few rows to books. We'll store
the the commands in `scripts/library/010_insert_into_books.sql`.

----

## Lab: DELETE, ALTER, UPDATE, and INSERT

**DELETE:** Remove ingredients you wouldn't keep in your kitchen or pantry.

**ALTER TABLE:** Add columns for macro-nutrients to ingredients.

**UPDATE:** Update macro-nutrients for some ingredients.

**INSERT INTO:** Add an ingredient to the `ingredients` table using `INSERT`.

## Additional Resources

- [SQL Wikipedia article](https://en.wikipedia.org/wiki/SQL)
- [Books.csv source](https://en.wikipedia.org/wiki/List_of_best-selling_books#List_of_best-selling_single-volume_books)
- [Select Star SQL](https://selectstarsql.com/)

## [License](LICENSE)

1. All content is licensed under a CC­BY­NC­SA 4.0 license.
1. All software code is licensed under GNU GPLv3. For commercial use or
    alternative licensing, please contact legal@ga.co.
