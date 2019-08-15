#!/bin/sh
if [ -n $i ]; then
  i=2
fi

for tab in session batsession datadict classdict modvars perfstats; do
  echo "\\copy $tab to ${tab}$i.csv with (format csv, header true)"
done | psql -d spm -q
