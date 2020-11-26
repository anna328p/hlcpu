set PROJ_DIR "ENTER simulation DIRECTORY PATH"

#Example:
#set PROJ_DIR "G:\RD_QA\rd1010_sdr_sdram_controller\rd1010\simulation"

cd $PROJ_DIR/ecp3/vhdl

if {![file exists rtl_verilog]} {
    vlib rtl_verilog 
}
endif

design create rtl_verilog .
design open rtl_verilog
adel -all

cd $PROJ_DIR/ecp3/vhdl

acom ../../../Source/Vhdl/sdr_par.vhd
acom ../../../Source/Vhdl/sdr_ctrl.vhd
acom ../../../Source/Vhdl/sdr_data.vhd
acom ../../../Source/Vhdl/sdr_sig.vhd
acom ../../../Source/Vhdl/sdr_top.vhd


acom ../../../Testbench/Vhdl/sdr_tb.vhd


asim -O5 +access +r sdr_tb -L ovi_ecp3 -PL pmi_work 

add wave *
add wave sdr_tb/
log -r /*
run 105500 ns