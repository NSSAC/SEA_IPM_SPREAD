#!/bin/bash
function admin(){
psql93 -h zuni.vbi.vt.edu -d ndsslgeo \
   -c "COPY (SELECT grid.grid_id,regions.id,regions.eng_name \
FROM tuta_south_east.grid_p25xp25 AS grid \
LEFT OUTER JOIN adcw_7_2.adc_world_admin_2 AS regions \
ON (ST_CONTAINS(regions.the_geom,ST_CENTROID(grid.geom))=True) \
WHERE ( \
regions.cntry_name='Myanmar' \
OR regions.cntry_name='Bangladesh' \
OR regions.cntry_name='Laos' \
OR regions.cntry_name='Thailand' \
OR regions.cntry_name='Cambodia' \
OR regions.cntry_name='Vietnam' \
OR regions.cntry_name='Malaysia' \
OR regions.cntry_name='Singapore' \
OR regions.cntry_name='Brunei' \
OR regions.cntry_name='Philippines' \
OR regions.cntry_name='Indonesia' \
)) TO STDOUT WITH CSV" >> south_east_asia_adc_id_p25xp25.csv;
}

function p25(){
#psql93 -d ndsslgeo -h zuni.vbi.vt.edu \
## psql -d ndsslgeo \
##    -c "COPY (SELECT grid.grid_id,regions.id,iso_code,regions.eng_name \
## FROM tuta_south_east.grid_p25xp25 AS grid \
## LEFT OUTER JOIN adcw_7_2.adc_world_admin_1 AS regions \
## ON (ST_INTERSECTS(grid.geom,regions.the_geom)=True) \
## WHERE ( \
## regions.cntry_name='Myanmar' \
## OR regions.cntry_name='Bangladesh' \
## OR regions.cntry_name='Laos' \
## OR regions.cntry_name='Thailand' \
## OR regions.cntry_name='Cambodia' \
## OR regions.cntry_name='Vietnam' \
## OR regions.cntry_name='Malaysia' \
## OR regions.cntry_name='Singapore' \
## OR regions.cntry_name='Brunei' \
## OR regions.cntry_name='Philippines' \
## OR regions.cntry_name='Indonesia' \
## )) TO STDOUT WITH CSV" >> south_east_asia_adc_id_p25xp25.csv;
query=$(
cat << EOF
CREATE TEMP TABLE grid_admin(id integer primary key,admin2 text,admin1 text, admin1_iso text,country_iso text); 

INSERT INTO grid_admin (id,admin1,admin1_iso,country_iso)
SELECT grid.grid_id,admin1.eng_name,admin1.iso_code,admin1.cntry_code 
FROM tuta_south_east.grid_p25xp25 AS grid 
LEFT OUTER JOIN adcw_7_2.adc_world_admin_1 AS admin1 
ON (ST_CONTAINS(admin1.the_geom,ST_CENTROID(grid.geom))=True) 
WHERE 
admin1.cntry_name='Myanmar' 
OR admin1.cntry_name='Bangladesh' 
OR admin1.cntry_name='Laos' 
OR admin1.cntry_name='Thailand' 
OR admin1.cntry_name='Cambodia' 
OR admin1.cntry_name='Vietnam' 
OR admin1.cntry_name='Malaysia' 
OR admin1.cntry_name='Singapore' 
OR admin1.cntry_name='Brunei' 
OR admin1.cntry_name='Philippines' 
OR admin1.cntry_name='Indonesia';

CREATE TEMP TABLE ad2(id,admin2) AS
SELECT grid.grid_id,admin2.eng_name 
FROM tuta_south_east.grid_p25xp25 AS grid 
LEFT OUTER JOIN adcw_7_2.adc_world_admin_2 AS admin2 
ON (ST_CONTAINS(admin2.the_geom,ST_CENTROID(grid.geom))=True) 
WHERE 
admin2.cntry_name='Myanmar' 
OR admin2.cntry_name='Bangladesh' 
OR admin2.cntry_name='Laos' 
OR admin2.cntry_name='Thailand' 
OR admin2.cntry_name='Cambodia' 
OR admin2.cntry_name='Vietnam' 
OR admin2.cntry_name='Malaysia' 
OR admin2.cntry_name='Singapore' 
OR admin2.cntry_name='Brunei' 
OR admin2.cntry_name='Philippines' 
OR admin2.cntry_name='Indonesia';

UPDATE grid_admin SET admin2=(SELECT admin2 FROM ad2 
WHERE ad2.id=grid_admin.id);

COPY (SELECT * FROM grid_admin) TO STDOUT WITH CSV
EOF
)

#echo "cell_id,admin2,admin1,admin1_iso,country_iso" > south_east_asia_adc_id_p25xp25.csv;
#psql93 -h zuni.vbi.vt.edu -d ndsslgeo -c "$query" >> south_east_asia_adc_id_p25xp25.csv;

# obtain admins
awk -F, 'NR>1{print $2","$3","$4","$5}' south_east_asia_adc_id_p25xp25.csv | sort | uniq > admins.csv
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
