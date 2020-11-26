set PROJ_DIR "ENTER simulation DIRECTORY PATH"

# Example: 
# set PROJ_DIR "C:\rd1174_sdr_sdram_controller\rd1174\simulation"


cd $PROJ_DIR/xo3l/verilog/

if {![file exists micron4m32_rtl_verilog]} {
    vlib micron4m32_rtl_verilog 
}
endif

design create micron4m32_rtl_verilog .
design open micron4m32_rtl_verilog
adel -all

cd $PROJ_DIR/xo3l/verilog/

vlog ../../../source/verilog/micron4m32/autorefresh_counter.v 	 
vlog ../../../source/verilog/micron4m32/delay_gen150us.v 
vlog ../../../source/verilog/micron4m32/lfsr_count255.v 
vlog ../../../source/verilog/micron4m32/lfsr_count64.v 
vlog ../../../source/verilog/micron4m32/sdram_control_fsm.v 
vlog ../../../source/verilog/micron4m32/sdram_controller.v

vlog ../../../testbench/verilog/micron4m32/mt48lc4m32b2.v 
vlog ../../../testbench/verilog/micron4m32/sdr_sdram_controller_wrapper.v	  
vlog ../../../testbench/verilog/micron4m32/sdr_sdram_controller_wrapper_synth.v  
vlog ../../../testbench/verilog/micron4m32/sdram_controller_tb.v

vsim -O5 -L ovi_machxo3l +access +r sdram_controller_tb


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

run 260us

