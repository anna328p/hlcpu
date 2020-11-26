set PROJ_DIR "ENTER simulation DIRECTORY PATH"

#Example:
#set PROJ_DIR "G:\RD_QA\rd1010_sdr_sdram_controller\rd1010\simulation"

cd $PROJ_DIR/xp2/vhdl

if {![file exists timing_vhdl]} {
    vlib timing_vhdl 
}
endif

design create timing_vhdl .
design open timing_vhdl
adel -all

cd $PROJ_DIR/xp2/vhdl

acom -dbg ../../../project/xp2/vhdl/xp2_vhdl/xp2_vhdl_xp2_vhdl_vho.vho
 
acom ../../../Testbench/Vhdl/sdr_par.vhd
acom ../../../Testbench/Vhdl/sdr_tb.vhd

vsim -L ovi_xp2 -PL pmi_work +access +r sdr_tb -noglitch +no_tchk_msg -sdfmax UUT="../../../project/xp2/vhdl/xp2_vhdl/xp2_vhdl_xp2_vhdl_vho.sdf"
add wave *
run 105500 ns
