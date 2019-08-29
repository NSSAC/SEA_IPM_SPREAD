#!/bin/bash
sqlite3 ../../cellular_automata/results/results.db <<! > simulation_output_similarity_score.csv
.mode csv
.header on
SELECT * FROM eval_BGD WHERE 
likelihood>=5.5 
!
