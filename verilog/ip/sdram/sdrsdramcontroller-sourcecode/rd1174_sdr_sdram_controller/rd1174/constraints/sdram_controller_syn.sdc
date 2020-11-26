# Synopsys, Inc. constraint file
# /home/govindaraj/SVN/sbt/iCECube2_branch/designs/sdr_sdram_controller/synthesis/constraints/sdram_controller_syn.sdc
# Written on Thu Jan  6 14:51:44 2011
# by Synplify Pro, E-2010.09S-1 Scope Editor

#
# Collections
#

#
# Clocks
#
define_clock   {i_cpu_clk} -name {i_cpu_clk}  -freq 100 -clockgroup default_clkgroup_0
define_clock -disable   {n:U1.U1.o_lfsr_64_done} -name {n:U1.U1.o_lfsr_64_done}  -clockgroup default_clkgroup_1

#
# Clock to Clock
#

#
# Inputs/Outputs
#
define_input_delay -disable      -default -improve 0.00 -route 0.00
define_output_delay -disable     -default -improve 0.00 -route 0.00
define_output_delay -disable     {o_cpu_data_valid} -improve 0.00 -route 0.00
define_output_delay -disable     {o_read_data_req} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdrctl_busyn} -improve 0.00 -route 0.00
define_output_delay -disable     {o_init_done} -improve 0.00 -route 0.00
define_output_delay -disable     {o_cpu_ack} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_addr[11:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_blkaddr[1:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_casn} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_cke} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_csn} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_dqm[1:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_rasn} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_wen} -improve 0.00 -route 0.00
define_output_delay -disable     {o_sdram_clk} -improve 0.00 -route 0.00
define_input_delay -disable      {i_cpu_data[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {o_cpu_data[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {io_sdram_dq[15:0]} -improve 0.00 -route 0.00
define_output_delay -disable     {io_sdram_dq[15:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {i_cpu_addr[21:0]} -improve 0.00 -route 0.00
define_input_delay -disable      {i_cpu_advn} -improve 0.00 -route 0.00
define_input_delay -disable      {i_cpu_rst} -improve 0.00 -route 0.00
define_input_delay -disable      {i_cpu_rwn} -improve 0.00 -route 0.00
define_input_delay -disable      {i_selfrefresh_req} -improve 0.00 -route 0.00
define_input_delay -disable      {i_loadmod_req} -improve 0.00 -route 0.00
define_input_delay -disable      {i_burststop_req} -improve 0.00 -route 0.00
define_input_delay -disable      {i_disable_active} -improve 0.00 -route 0.00
define_input_delay -disable      {i_disable_precharge} -improve 0.00 -route 0.00
define_input_delay -disable      {i_precharge_req} -improve 0.00 -route 0.00

#
# Registers
#

#
# Delay Paths
#

#
# Attributes
#

#
# I/O Standards
#
define_io_standard -disable      -default_input -delay_type input
define_io_standard -disable      -default_output -delay_type output
define_io_standard -disable      -default_bidir -delay_type bidir
define_io_standard -disable      {o_cpu_data_valid} -delay_type output
define_io_standard -disable      {o_read_data_req} -delay_type output
define_io_standard -disable      {o_sdrctl_busyn} -delay_type output
define_io_standard -disable      {o_init_done} -delay_type output
define_io_standard -disable      {o_cpu_ack} -delay_type output
define_io_standard -disable      {o_sdram_addr[11:0]} -delay_type output
define_io_standard -disable      {o_sdram_blkaddr[1:0]} -delay_type output
define_io_standard -disable      {o_sdram_casn} -delay_type output
define_io_standard -disable      {o_sdram_cke} -delay_type output
define_io_standard -disable      {o_sdram_csn} -delay_type output
define_io_standard -disable      {o_sdram_dqm[1:0]} -delay_type output
define_io_standard -disable      {o_sdram_rasn} -delay_type output
define_io_standard -disable      {o_sdram_wen} -delay_type output
define_io_standard -disable      {o_sdram_clk} -delay_type output
define_io_standard -disable      {i_cpu_data[15:0]} -delay_type input
define_io_standard -disable      {o_cpu_data[15:0]} -delay_type output
define_io_standard -disable      {io_sdram_dq[15:0]} -delay_type bidir
define_io_standard -disable      {i_cpu_addr[21:0]} -delay_type input
define_io_standard -disable      {i_cpu_advn} -delay_type input
define_io_standard -disable      {i_cpu_rst} -delay_type input
define_io_standard -disable      {i_cpu_rwn} -delay_type input
define_io_standard -disable      {i_selfrefresh_req} -delay_type input
define_io_standard -disable      {i_loadmod_req} -delay_type input
define_io_standard -disable      {i_burststop_req} -delay_type input
define_io_standard -disable      {i_disable_active} -delay_type input
define_io_standard -disable      {i_disable_precharge} -delay_type input
define_io_standard -disable      {i_precharge_req} -delay_type input

#
# Compile Points
#

#
# Other
#
