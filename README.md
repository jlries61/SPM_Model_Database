# SPM_Model_Database
Utilities to create, query, and maintain a PostgreSQL database to store SPM model data 

The intent is to create a set of Perl scripts to perform the functions above, easing the task of tracking the models built in the course of a project.  PostgreSQL was selected as the database engine has having the power and flexibility to perform the tasks required.

## Prerequisites
* Perl 5.  The minimum version used for testing thus far is 5.28.2, but the language is intended to be generic.
* PostgreSQL.  The system is being developed with version 11.4, but older ones will probably work.
* SPM Ultra (non-GUI) 8.3 or higher.  This is proprietary software that must be licenced from [Salford Systems](https://www.salford-systems.com/products/spm).  It should be stressed that GUI SPM will not work for this purpose.
* A Korn compatible shell to run the example scripts.

The following Perl modules are used:
* boolean
* File::Basename
* File::Temp
* Getopt::Long
* JSON::Util
* Pg
* Set::Tiny
* XML::Parser

## How to Create the Database

1.  Create the role (account) to be used for the database, following the instructions in https://www.postgresql.org/docs/11/user-manag.html.  As at present, `addgrv` only knows how to access a local database owned by the user running the script, the role will need the `LOGIN` and `CREATEDB` attributes.
2.  Create the database.  The `createdb` utility can be used for that purpose.  For example:

`$ createdb spm 'SPM Model Database'`

Since `addgrv`  creates the tables when it runs (assuming they do not already exist), we are now ready to add models.

## How to add a grove to the database

The simple case looks something like this:
`$ addgrv BOSALL1.GRV`

This scans the grove BOSALL1.GRV and adds the session settings, performance statistics, and data dictionary to the appropriate
tables, creating them if they do not already exist.  The database used for this purpose is the default `spm`, which must already exist.  To write to another database, a command like the following could have been used instead:

`$ addgrv --db=boston BOSALL1.GRV`

It may be convenient to store model data from multiple projects in the same database.  If so, the `--project` flag could be used, like so:

`addgrv --project=Boston BOSALL1.GRV`

