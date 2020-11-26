set PROJ_DIR "ENTER simulation DIRECTORY PATH"

#Example:
#set PROJ_DIR "C:\Users\pranjan\Desktop\Final\rd1010_sdr_sdram_controller\rd1010\simulation"

cd $PROJ_DIR/xp/verilog

if {![file exists timing_verilog]} {
    vlib timing_verilog 
}
endif

design create timing_verilog .
design open timing_verilog
adel -all

cd $PROJ_DIR/xp/verilog

vlog ../../../project/xp/verilog/xp_verilog/xp_verilog_xp_verilog_vo.vo

vlog ../../../Testbench/Verilog/sdr_tb.v


vsim -L ovi_xp -PL pmi_work +access +r sdr_tb -noglitch +no_tchk_msg -sdfmax UUT="../../../project/xp/verilog/xp_verilog/xp_verilog_xp_verilog_vo.sdf"

add wave *
run 105500 ns


