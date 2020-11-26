set PROJ_DIR "ENTER simulation DIRECTORY PATH"

#Example:
#set PROJ_DIR "G:\RD_QA\rd1010_sdr_sdram_controller\rd1010\simulation"

cd $PROJ_DIR/ecp5/verilog

if {![file exists rtl_verilog]} {
    vlib rtl_verilog 
}
endif

design create rtl_verilog .
design open rtl_verilog
adel -all

cd $PROJ_DIR/ecp5/verilog

vlog ../../../Source/Verilog/sdr_ctrl.v
vlog ../../../Source/Verilog/sdr_data.v
vlog ../../../Source/Verilog/sdr_sig.v
vlog ../../../Source/Verilog/sdr_top.v
//vlog ../../Source/Verilog/sdr_par.v

//vlog ../../Testbench/Verilog/sdr_par.v
vlog ../../../Testbench/Verilog/sdr_tb.v

vsim +access +r sdr_tb -PL pmi_work -L ovi_ecp5u

add wave *
add wave sdr_tb/

run 105500 ns