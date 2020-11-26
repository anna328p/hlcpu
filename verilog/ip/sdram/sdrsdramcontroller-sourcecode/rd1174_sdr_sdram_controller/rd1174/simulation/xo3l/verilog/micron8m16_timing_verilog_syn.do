set PROJ_DIR "ENTER simulation DIRECTORY PATH"

# Example: 
# set PROJ_DIR "C:\rd1174_sdr_sdram_controller\rd1174\simulation"

cd $PROJ_DIR/xo3l/verilog

if {![file exists micron8m16_timing_verilog_syn]} {
    vlib micron8m16_timing_verilog_syn 
}
endif

design create micron8m16_timing_verilog_syn .
design open micron8m16_timing_verilog_syn
adel -all

cd $PROJ_DIR/xo3l/verilog

vlog -dbg ../micron8m16_xo3l_verilog_syn_vo.vo

vlog ../../../testbench/verilog/micron8m16/mt48lc8m16a2.v 
vlog ../../../testbench/verilog/micron8m16/sdr_sdram_controller_wrapper.v	  
vlog ../../../testbench/verilog/micron8m16/sdr_sdram_controller_wrapper_synth.v  
vlog ../../../testbench/verilog/micron8m16/sdram_controller_tb.v


vsim +access +r sdram_controller_tb -L ovi_machxo3l -noglitch +no_tchk_msg -sdfmax sdram_controller_tb_u1/sdram_controller_u1/sdram_controller_u1/ = "../micron8m16_xo3l_verilog_syn_vo.sdf"

add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_data_valid}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_data_req}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_busy}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_init_done}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_ack}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_addr}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_blkaddr}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_casn}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_cke}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_csn}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_dqm}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_rasn}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_wen}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_sdram_clk}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_write_done}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_read_done}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_data}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/o_data}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/io_sdram_dq}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_addr}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_adv}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_clk}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_rst}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_rwn}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_selfrefresh_req}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_loadmod_req}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_burststop_req}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_disable_active}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_disable_precharge}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_precharge_req}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_power_down}
add wave -noreg {/sdram_controller_tb/sdram_controller_tb_u1/i_disable_autorefresh}

run 260 us

