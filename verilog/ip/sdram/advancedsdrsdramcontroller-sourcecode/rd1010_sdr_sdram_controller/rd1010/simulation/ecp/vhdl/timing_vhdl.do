set PROJ_DIR "ENTER simulation DIRECTORY PATH"

#Example:
#set PROJ_DIR "C:\Users\pranjan\Desktop\Final\QA\rd1010_sdr_sdram_controller\rd1010\simulation"

cd $PROJ_DIR/ecp/vhdl

if {![file exists timing_vhdl]} {
    vlib timing_vhdl 
}
endif

design create timing_vhdl .
design open timing_vhdl
adel -all

cd $PROJ_DIR/ecp/vhdl

acom -dbg ../../../project/ecp/vhdl/ecp_vhdl/ecp_vhdl_ecp_vhdl_vho.vho
 
acom ../../../Testbench/Vhdl/sdr_par.vhd
acom ../../../Testbench/Vhdl/sdr_tb.vhd

vsim -L ovi_ecp -PL pmi_work +access +r sdr_tb -noglitch +no_tchk_msg -sdfmax UUT="../../../project/ecp/vhdl/ecp_vhdl/ecp_vhdl_ecp_vhdl_vho.sdf"
add wave *
run 105500 ns
