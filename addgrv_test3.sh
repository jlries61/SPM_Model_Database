#!/bin/sh
DB=spm
TABLIST="session, batsession, perfstats, datadict, classdict, modvars"
GROVES="ADLTCART1.GRV ADLTMARS1.GRV BOSALL1.GRV BOSBLEND1.GRV \
        BOSGPS4.GRV BOSIRL1.GRV CREDTN3.GRV \
        BOSMARS1.GRV BOSREG1.GRV BOSTN1.GRV CREDTN1.GRV \
        DIGITCOMB1.GRV DIGITLGT1.GRV DIGITN1.GRV GBRF0.GRV \
        HODGMARS1.GRV HOSRF1.GRV"
psql -d $DB -c "drop table if exists $TABLIST"

for grove in $GROVES; do
  ./addgrv --db=$DB --grvpath=Groves --project=Test --override $grove
done

export i=3
./dumpdb.sh
