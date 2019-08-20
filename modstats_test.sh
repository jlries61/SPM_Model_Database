#!/bin/sh

./modstats --db=spm --perfstats=rsquared,mse,mad,mape --modtype=treenet,pathseeker \
           --project=Test --sessflds=mart_s_2_learnrate,bint3_nrecsu,battery_mode,battery_nvalues \
           --sortby=rsquared --target=mv modstat_test.csv
