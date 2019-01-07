#!/bin/bash
psql93 -d ndsslgeo -h zuni.vbi.vt.edu <<!
CREATE TABLE tuta_south_east.FAOSTAT_trade_matrix(
ind1 int primary key,
ind2 int,
domain_code text,
domain text,
reporter_country_code int,
reporter_countries text,
partner_countr_code int,
partner_countries text,
element_code int,
element text,
item_code int,
item text,
year_code int,
year int,
unit text,
value int,
flag text,
flag_description text);

\copy tuta_south_east.FAOSTAT_trade_matrix from '../data/south_east_asia_trade_matrix.csv'
csv
!
