# SPM_Model_Database
Utilities to create, query, and maintain a PostgreSQL database to store SPM model data 

The intent is to create a set of Perl scripts to perform the functions above, easing the task of tracking the models built in the course of a project (which may run into the hundreds).  PostgreSQL was selected as the database engine as having the power and flexibility to perform the tasks required.

## Legalities
The scripts and documents included in this package (except for LICENSE) are copyright 2019, John L. Ries; but distributed under the terms of the GNU General Public License version 3, as published by the Free Software Foundation, or at the recipient's option, any later version.  See the file LICENSE in this repository for details.  The SPM grove files included in this distribution for testing and demonstration purposes are hereby released to the public domain.

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

After running this initial job, you can check the database to verify that the appropriate tables were created, like so:

```
spm=> \dt
          List of relations
 Schema |    Name    | Type  | Owner 
--------+------------+-------+-------
 public | batsession | table | jries
 public | classdict  | table | jries
 public | datadict   | table | jries
 public | modvars    | table | jries
 public | perfstats  | table | jries
 public | session    | table | jries
(6 rows)
```

You could create a quick data dictionary, like so:

```
spm=> select * from datadict where Grove='BOSALL1';
 project |  grove  | fieldname |   optype    | datatype |                              label                               
---------+---------+-----------+-------------+----------+------------------------------------------------------------------
 Test    | BOSALL1 | CRIM      | continuous  | double   | Per capita crime rate by town
 Test    | BOSALL1 | ZN        | continuous  | double   | Proportion of residential land zoned for lots over 25,000 sq.ft.
 Test    | BOSALL1 | INDUS     | continuous  | double   | Proportion of non-retail business acres per town.
 Test    | BOSALL1 | CHAS      | categorical | integer  | Tract bounds Charles River?
 Test    | BOSALL1 | NOX       | continuous  | double   | Nitric oxides concentration (parts per 10 million)
 Test    | BOSALL1 | RM        | continuous  | double   | Average number of rooms per dwelling
 Test    | BOSALL1 | AGE       | continuous  | double   | Proportion of owner-occupied units built prior to 1940
 Test    | BOSALL1 | DIS       | continuous  | double   | Weighted distances to five Boston employment centres
 Test    | BOSALL1 | RAD       | continuous  | double   | Index of accessibility to radial highways
 Test    | BOSALL1 | TAX       | continuous  | double   | Full-value property-tax rate per $10,000
 Test    | BOSALL1 | PT        | continuous  | double   | Pupil-teacher ratio by town
 Test    | BOSALL1 | B         | continuous  | double   | 1000(Bk - 0.63)^2 where Bk is the proportion of blacks by town
 Test    | BOSALL1 | LSTAT     | continuous  | double   | % lower status of the population
 Test    | BOSALL1 | MV        | continuous  | double   | Median value of owner-occupied homes in $1000's
 Test    | BOSALL1 | WT        | continuous  | double   | 
(15 rows)
```

To compare performance among the various models within the grove, one could do this:

```
spm=> select modelid,modeltype,mse,rmse,mad,mape,rsquared from perfstats where grove='BOSALL1' and sampleid='test' order by rsquared desc;
 modelid | modeltype  |   mse   |  rmse   |   mad   |   mape   | rsquared 
---------+------------+---------+---------+---------+----------+----------
 2       | rf         | 10.5105 |   3.242 | 1.98557 | 0.097268 |   0.8445
 0       | cart       |  13.472 | 3.67042 | 2.57948 | 0.127097 | 0.795443
 3       | mars       | 19.4722 | 4.41274 | 2.85223 | 0.152734 | 0.704335
 1       | treenet    | 19.9561 | 4.46722 | 2.22087 | 0.100015 | 0.696988
 4       | pathseeker | 27.8391 | 5.27627 | 3.35394 | 0.159816 | 0.577293
 5       | regression | 28.4477 | 5.33364 | 3.49347 | 0.170381 | 0.568051
(6 rows)
```

We see here all of the common regression performance stats for the test sample, in descending order of R-squared.

## Getting Help

The script `addgrv` has built-in documentation (POD) which can be read via the `perldoc` command like so:

```
$ perldoc addgrv
```
This will bring up a document that looks much like a UNIX manpage.

To inquire of the developer, post an [issue](https://github.com/jlries61/SPM_Model_Database/issues).

## Future Plans

The file `todos.txt`  will always contain the current todo list, but here is a summary

* The script `addgrv` is incomplete at the present time.  The most glaring omissions are the current lack of a means to access a database remotely or one that the current user does not own.  There is also no ability to add new fields to the tables once they have been created, or to update existing records in the database.  These issues will be addressed in the near future.
* There will be a utility to generate a model summary including grove and model IDs, model type, user created memos, key settings, and user-selected performance stats.
* There will be a utility to generate a data dictionary for a project or one or more individual groves.
* There will be a utility to generate a command sequence to reproduce a requested model.

## Database Structure

There are currently six tables as follows:

Session
: Main session settings table (one record per grove).

BatSession
: Session battery settings table (one record per grove).  This table includes all settings with names prefixed with `BATTERY_`.

DataDict
: Main data dictionary (one record per field per grove).

ClassDict
: Supplemental data dictionary documenting the values of categorical fields (one record per value per field per grove).

ModVars
: Documents the fields used in each model, giving their functions and the relative importance of each predictor
(one record per field per model per grove).

PerfStats
: Contains the available performance statistics for each model.  There is one field for each statistic used, but since
not all performance statistics are computed for every model type, there are likely to be more statistic fields than are computed for any given model (one record per model per grove).

For details, see the documentation for `addgrv` (`perldoc addgrv`).
