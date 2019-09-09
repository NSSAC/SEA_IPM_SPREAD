#!/bin/bash
cp figs/model_schematic.pdf for_submission
cp figs/pipeline.pdf for_submission
cp figs/spread_analysis.pdf for_submission
cp ../../cellular_automata/results/contour/BGD_model-A.pdf for_submission
cp ../../cellular_automata/results/contour/BGD_model-B_m1_l3.pdf for_submission
cp ../../cellular_automata/results/rf/rf_importance_all_mdi.pdf for_submission
cp ../../clustering/results/agglomerative/rf_k_agglomerative_mse.pdf for_submission
cp ../../cellular_automata/results/contour/MSA_model-A_m2_l1.pdf for_submission
cp ../../cellular_automata/results/contour/MSA_model-B_m1_l3.pdf for_submission
cp ../../cellular_automata/results/contour/TH_model-B_precip1_m1_l3.pdf for_submission
cp ../../cellular_automata/results/contour/TH_model-B_precip1-out-100_m1_l3.pdf for_submission
cp ../../cellular_automata/results/dist_inf_plots/TH_dist_prob_B_box.pdf for_submission
cp refs.bib for_submission
cp mcnitt_tuta.tex for_submission
cp mcnitt_tuta_supplementary.pdf for_submission

pdftk \
    main_diff.pdf \
    supp_diff.pdf \
    cat output for_submission/differences_between_orginal_revised.pdf



## zip mcnitt_tuta_revised_version.zip \
##     mcnitt_tuta.pdf \
##     mcnitt_tuta_supplementary.pdf \
##     differences_between_orginal_revised.pdf \
##     review_response.pdf
