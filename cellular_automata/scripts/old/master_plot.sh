function spread_BGD(){
#python ../scripts/plot_ca_timeline.py ../results/sim_out/res_r100_b2_k300_s0_sm5_m2_st0_ed2_a-120-5-200.csv -t .1 -s 30 -o ../../docs/figs/spread_BGD.png
python ../scripts/plot_ca_timeline.py ../results/sim_out/BGD/res_precip1_b0_k500_s0_sm5_m1_st0_ed3_a-300-0-50.csv --countries BG -t .8 -s 0 -o ../../docs/figs/spread1_BGD.png
python ../scripts/plot_ca_timeline.py ../results/sim_out/BGD/res_precip1_b0_k500_s0_sm5_m1_st0_ed1_a-400-400-0.csv --countries BG -t .8 -s 0 -o ../../docs/figs/spread2_BGD.png
}

function spread_MYS(){
python ../scripts/plot_ca_timeline.py ../results/sim_out/res_r100_b2_k300_s2_sm5_m2_st0_ed2_a-120-5-200.csv -t .1 -n 60 -o ../../docs/figs/spread_MYS.png
}

function spread_PHL(){
echo 
}

function spread_int_market(){
python ../scripts/plot_ca_timeline.py ../results/sim_out/res_r100_b2_k300_s0_sm5_m2_st0_ed2_a-120-5-200.csv -t .1 -s 30 -o ../../docs/figs/spread_BGD.png
}

function spread_int_short(){
python ../scripts/plot_ca_timeline.py ../results/sim_out/res_r100_b2_k300_s0_sm5_m2_st0_ed2_a-120-5-200.csv -t .1 -s 30 -o ../../docs/figs/spread_BGD.png
}
