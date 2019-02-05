#!/bin/bash
DB="../../../timeline/data/timeline.db";
DATA="../data";

echo "#adc_id,year" > $DATA/seed_Nigeria.csv;
sqlite3 $DB <<! >> $DATA/seed_Nigeria.csv
.mode csv
SELECT state_adc_id,Min(Year) FROM timeline WHERE
YEAR=2016 AND MONTH=1
GROUP by state_adc_id;
!
