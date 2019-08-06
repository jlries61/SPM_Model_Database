#!/bin/ksh
./addgrv.pl --grvpath=Groves --project=Test --dryrun \
            ADLTCART1.GRV ADLTMARS1.GRV BOSALL1.GRV BOSBLEND1.GRV \
            BOSGPS4.GRV BOSIRL1.GRV CREDTN3.GRV \
            BOSMARS1.GRV BOSREG1.GRV BOSTN1.GRV CREDTN1.GRV \
            DIGITCOMB1.GRV DIGITLGT1.GRV DIGITN1.GRV GBRF0.GRV \
            HODGMARS1.GRV HOSRF1.GRV |grep -v '^$' >addtrv_test.sql
