set DESIGN_NAME "aes_cipher_top"
set top aes_cipher_top
set CLK "clk"

set clk_pr 4.25

set src_rtl " \
    ../../rtl/aes_cipher_top.v \
    ../../rtl/aes_key_expand_128.v \
    ../../rtl/aes_rcon.v \
    ../../rtl/aes_sbox.v \
"

set search_lib_path "/home/tzg/DFR/paper/LIB"
set target_library "Nangate_45_rechar_slow.db"

# set search_lib_path "/home/tzg/DFR/paper/LIB/NangateOpenCell_45nm_Library/Front_End/Liberty/NLDM"
# set target_library "NangateOpenCellLibrary_slow.db"

# set search_lib_path "/home/tzg/DFR/paper/LIB"
# set target_library "GSCLib_3.0.db"

set_app_var search_path "$search_lib_path"
set_app_var target_library "$search_lib_path/$target_library"
set_app_var link_library "* $target_library"

analyze -f verilog $src_rtl


elaborate $DESIGN_NAME
current_design $DESIGN_NAME
uniquify
link

check_design

ungroup -all -flatten

# Create the clocks
echo "Creating the clock clk"
create_clock [get_ports ${CLK}] -period ${clk_pr} -name CORE_CLK
set_ideal_network [get_ports ${CLK}]

# Set IO delays
echo "Setting input and output delays"
set core_outputs [all_outputs]
set core_inputs  [remove_from_collection [all_inputs] [get_ports clk]]
#set core_inputs  [remove_from_collection $core_inputs [get_ports rst_ni]]

set INPUT_DELAY  [expr 0.1*${clk_pr}]
set OUTPUT_DELAY [expr 0.1*${clk_pr}]
set_load 0.010 [all_outputs] 

set_input_delay  $INPUT_DELAY  $core_inputs  -clock [get_clock]
set_output_delay $OUTPUT_DELAY [all_outputs] -clock [get_clock]



# Define design environments
set op_cond                  "slow"
set rst_drive                0
set avg_load                 0.1
set avg_fo_load              10
set auto_wire_load_selection "true"

# set op_cond                  "typical"
# set rst_drive                0
# set avg_load                 0.1
# set avg_fo_load              10
# set auto_wire_load_selection "true"

set_operating_conditions $op_cond -library "op_cond_slow"
# set_operating_conditions $op_cond -library "NangateOpenCellLibrary"
# set_operating_conditions $op_cond -library "gsclib"
# uniquify -force

compile_ultra -no_autoungroup -no_boundary_optimization -timing
# compile_ultra -no_boundary_optimization -timing

change_name -hier -rule verilog
write -f verilog -hierarchy -output ../../vcs_work/aes_core_final.v

report_timing > ../rpt/${DESIGN_NAME}_timing.rpt
report_area -hierarchy > ../rpt/${DESIGN_NAME}_area.rpt
report_power -nosplit -hierarchy -levels 3 > ../rpt/${DESIGN_NAME}_power.rpt
report_reference -hierarchy > ../rpt/${DESIGN_NAME}_ref.rpt
report_resources -hierarchy > ../rpt/${DESIGN_NAME}_res.rpt

write_sdf ../../vcs_work/aes_core.sdf

exit