# SPM_Model_Database
Utilities to create, query, and maintain a PostgreSQL database to store SPM model data

The intent is to create a set of Perl scripts to perform the functions above, easing the task of tracking the models built in the course of a project (which may run into the hundreds).  PostgreSQL was selected as the database engine as having the power and flexibility to perform the tasks required.

## Legalities
The scripts and documents included in this package (except for LICENSE) are copyright 2019, John L. Ries; but distributed under the terms of the GNU General Public License version 3, as published by the Free Software Foundation, or at the recipient's option, any later version.  See the file LICENSE in this repository for details.  The SPM grove files included in this distribution for testing and demonstration purposes are hereby released to the public domain.

## Prerequisites
* Perl 5.  The minimum version used for testing thus far is 5.28.2, but the language is intended to be generic.
* PostgreSQL.  The system is being developed with version 11.4, but older ones will probably work.
* SPM Ultra (non-GUI) 8.3 or higher.  This is proprietary software that must be licenced from [Salford Systems](https://www.salford-systems.com/products/spm).  It should be stressed that GUI SPM will not work for this purpose.
* A POSIX compatible shell to run the example scripts.

The following Perl modules are used:

* boolean
* English
* File::Basename
* File::Temp
* Getopt::Long
* JSON::Util
* Pg
* Set::Tiny
* Text::CSV
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

We see here all of the common regression performance stats for the test sample, in descending order
of R-squared.

## The `modstats` Script

The `modstats` script produces a text dataset that reports model performance statistics and session
fields stored in the database.  An example follows:

```
$ ./modstats --perfstats=rsquared,mse,mad,mape --sortby=rsquared --target=mv
grove,modelid,modeltype,npred,rsquared,mse,mad,mape
BOSALL1,3,mars,13,0.878065,11.8345,2.44874,0.129566
BOSALL1,2,rf,7,0.860291,12.3289,2.31097,0.117031
BOSMARS1,0,mars,8,0.851642,11.5927,2.46569,0.130708
BOSALL1,1,treenet,13,0.850215,14.5376,2.47233,0.127288
BOSALL1,2,rf,7,0.8445,10.5105,1.98557,0.097268
BOSALL1,0,cart,13,0.835607,15.9553,2.86514,0.15798
BOSBLEND1,0,treenet,12,0.824946,15.489,2.43309,0.119649
BOSTN1,0,treenet,12,0.822828,14.9568,2.45891,0.124338
BOSBLEND1,0,treenet,12,0.815388,11.2928,2.67238,0.159835
BOSMARS1,0,mars,8,0.80643,15.1256,2.69864,0.144769
BOSIRL1,0,treenet,10,0.800703,12.1911,2.7995,0.171631
BOSALL1,0,cart,13,0.795443,13.472,2.57948,0.127097
BOSTN1,0,treenet,12,0.789279,17.7696,2.73602,0.137756
BOSIRL1,0,treenet,10,0.769713,20.3762,2.92661,0.150874
BOSALL1,5,regression,13,0.768027,22.5143,3.40429,0.172683
BOSALL1,4,pathseeker,13,0.744858,24.763,3.42158,0.168796
BOSGPS4,7,pathseeker,12,0.740637,21.8953,3.27032,0.164163
BOSGPS4,6,pathseeker,12,0.740637,21.8953,3.27032,0.164163
BOSGPS4,5,pathseeker,12,0.740637,21.8953,3.27032,0.164163
BOSGPS4,4,pathseeker,12,0.734964,22.3742,3.30957,0.166367
BOSGPS4,3,pathseeker,12,0.734964,22.3742,3.30957,0.166367
BOSGPS4,2,pathseeker,10,0.734173,22.441,3.31299,0.166687
BOSREG1,0,regression,13,0.72377,21.5846,3.2823,0.16659
BOSGPS4,1,pathseeker,8,0.723461,23.3453,3.34479,0.167422
BOSGPS4,7,pathseeker,12,0.721399,23.5194,3.37764,0.170727
BOSGPS4,5,pathseeker,12,0.721399,23.5194,3.37764,0.170727
BOSGPS4,6,pathseeker,12,0.721399,23.5194,3.37764,0.170727
BOSGPS4,2,pathseeker,10,0.716269,23.9525,3.40824,0.172848
BOSGPS4,3,pathseeker,12,0.714559,24.0968,3.41836,0.173191
BOSGPS4,4,pathseeker,12,0.714559,24.0968,3.41836,0.173191
BOSGPS4,0,pathseeker,7,0.709691,24.5077,3.39709,0.172773
BOSGPS4,1,pathseeker,8,0.705067,24.8981,3.42498,0.173123
BOSALL1,3,mars,13,0.704335,19.4722,2.85223,0.152734
BOSALL1,1,treenet,13,0.696988,19.9561,2.22087,0.100015
BOSGPS4,0,pathseeker,7,0.690422,26.1344,3.50305,0.180099
BOSALL1,4,pathseeker,13,0.577293,27.8391,3.35394,0.159816
BOSALL1,5,regression,13,0.568051,28.4477,3.49347,0.170381
BOSIRL1,1,pathseeker,10,0.174541,73.0379,6.20121,0.331078
BOSIRL1,1,pathseeker,10,0.0908666,55.6121,5.68566,0.381071
```

## Getting Help

The script `addgrv` has built-in documentation (POD) which can be read via the `perldoc` command like
so:

```
$ perldoc addgrv
```
This will bring up a document that looks much like a UNIX manpage.

The script `modstats` has like documentation.

To inquire of the developer, post an [issue](https://github.com/jlries61/SPM_Model_Database/issues).

## Future Plans

The file `todos.txt`  will always contain the current todo list, but here is a summary

* The script `addgrv` is incomplete at the present time.  The most glaring omissions are the current lack of a means to access a database remotely or one that the current user does not own.  These issues will be addressed in the near future.
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
