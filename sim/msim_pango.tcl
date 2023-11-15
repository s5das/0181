# ----------------------------------------
# Create compilation libraries
vlib usim
vmap usim "C:/Users/23600/Desktop/full_screen/sim/usim"
vlib vsim
vmap vsim "C:/Users/23600/Desktop/full_screen/sim/vsim"
vlib adc
vmap adc "C:/Users/23600/Desktop/full_screen/sim/adc"
vlib adc_e2
vmap adc_e2 "C:/Users/23600/Desktop/full_screen/sim/adc_e2"
vlib ddc_e2
vmap ddc_e2 "C:/Users/23600/Desktop/full_screen/sim/ddc_e2"
vlib ddrc
vmap ddrc "C:/Users/23600/Desktop/full_screen/sim/ddrc"
vlib ddrphy
vmap ddrphy "C:/Users/23600/Desktop/full_screen/sim/ddrphy"
vlib dll_e2
vmap dll_e2 "C:/Users/23600/Desktop/full_screen/sim/dll_e2"
vlib hsst_e2
vmap hsst_e2 "C:/Users/23600/Desktop/full_screen/sim/hsst_e2"
vlib hsstlp_lane
vmap hsstlp_lane "C:/Users/23600/Desktop/full_screen/sim/hsstlp_lane"
vlib hsstlp_pll
vmap hsstlp_pll "C:/Users/23600/Desktop/full_screen/sim/hsstlp_pll"
vlib iolhr_dft
vmap iolhr_dft "C:/Users/23600/Desktop/full_screen/sim/iolhr_dft"
vlib ipal_e1
vmap ipal_e1 "C:/Users/23600/Desktop/full_screen/sim/ipal_e1"
vlib ipal_e2
vmap ipal_e2 "C:/Users/23600/Desktop/full_screen/sim/ipal_e2"
vlib iserdes_e2
vmap iserdes_e2 "C:/Users/23600/Desktop/full_screen/sim/iserdes_e2"
vlib oserdes_e2
vmap oserdes_e2 "C:/Users/23600/Desktop/full_screen/sim/oserdes_e2"
vlib pciegen2
vmap pciegen2 "C:/Users/23600/Desktop/full_screen/sim/pciegen2"


#compile basic library
vlog -incr D:/.PDS2021/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/simulation/*.v -work usim
vlog -incr D:/.PDS2021/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/simulation/modelsim10.2c/*.vp -work usim


#compile basic library
vlog -incr D:/.PDS2021/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/bsim/*.v -work vsim
vlog -incr D:/.PDS2021/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/bsim/modelsim10.2c/*.vp -work vsim


#compile common library
cd "D:/.PDS2021/PDS_2021.4-SP1.2/arch/vendor/pango/verilog/simulation/modelsim10.2c"
vmap adc "C:/Users/23600/Desktop/full_screen/sim/adc"
vlog -incr -f ./filelist_adc_gtp.f -work adc
vmap adc_e2 "C:/Users/23600/Desktop/full_screen/sim/adc_e2"
vlog -incr -f ./filelist_adc_e2_gtp.f -work adc_e2
vmap ddc_e2 "C:/Users/23600/Desktop/full_screen/sim/ddc_e2"
vlog -incr -f ./filelist_ddc_e2_gtp.f -work ddc_e2
vmap ddrc "C:/Users/23600/Desktop/full_screen/sim/ddrc"
vlog -incr -f ./filelist_ddrc_gtp.f -work ddrc -sv -mfcu
vmap ddrphy "C:/Users/23600/Desktop/full_screen/sim/ddrphy"
vlog -incr -f ./filelist_ddrphy_gtp.f -work ddrphy
vmap dll_e2 "C:/Users/23600/Desktop/full_screen/sim/dll_e2"
vlog -incr -f ./filelist_dll_e2_gtp.f -work dll_e2
vmap hsst_e2 "C:/Users/23600/Desktop/full_screen/sim/hsst_e2"
vlog -incr -f ./filelist_hsst_e2_gtp.f -work hsst_e2
vmap hsstlp_lane "C:/Users/23600/Desktop/full_screen/sim/hsstlp_lane"
vlog -incr -f ./filelist_hsstlp_lane_gtp.f -work hsstlp_lane
vmap hsstlp_pll "C:/Users/23600/Desktop/full_screen/sim/hsstlp_pll"
vlog -incr -f ./filelist_hsstlp_pll_gtp.f -work hsstlp_pll
vmap iolhr_dft "C:/Users/23600/Desktop/full_screen/sim/iolhr_dft"
vlog -incr -f ./filelist_iolhr_dft_gtp.f -work iolhr_dft
vmap ipal_e1 "C:/Users/23600/Desktop/full_screen/sim/ipal_e1"
vlog -incr -f ./filelist_ipal_e1_gtp.f -work ipal_e1
vmap ipal_e2 "C:/Users/23600/Desktop/full_screen/sim/ipal_e2"
vlog -incr -f ./filelist_ipal_e2_gtp.f -work ipal_e2
vmap iserdes_e2 "C:/Users/23600/Desktop/full_screen/sim/iserdes_e2"
vlog -incr -f ./filelist_iserdes_e2_gtp.f -work iserdes_e2
vmap oserdes_e2 "C:/Users/23600/Desktop/full_screen/sim/oserdes_e2"
vlog -incr -f ./filelist_oserdes_e2_gtp.f -work oserdes_e2
vmap pciegen2 "C:/Users/23600/Desktop/full_screen/sim/pciegen2"
vlog -incr -f ./filelist_pciegen2_gtp.f -work pciegen2 -sv -mfcu

quit -force

# ----------------------------------------
