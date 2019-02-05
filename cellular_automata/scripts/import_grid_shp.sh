#!/bin/bash
shp2pgsql -s 4326 ../data/world_grid/world_grid_pt5_degree_clipped_by_countries_adcw72.shp tuta_south_east.grid_p5xp5 ndsslgeo > grid.sql
psql -d ndsslgeo -f grid.sql
