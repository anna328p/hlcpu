`timescale 1us/1ns
`include "components/alu.v"
`include "components/regfile.v"

module alu_register;

reg clk;
always begin
    clk = 1'b0;
    #20;

    clk = 1'b1;
    #20;
end


reg         in1_we,    in2_we;
reg  [3:0]  in1_sel,   in2_sel;
wire [15:0] in1_data,  in2_data;

reg  [15:0] temp1,     temp2;

reg  [3:0]  out1_sel,  out2_sel;
wire [15:0] out1_data, out2_data;

regfile regs (clk,
    in1_we, in1_sel, in1_data,  
    in2_we, in2_sel, in2_data,
    out1_sel, out1_data, out2_sel, out2_data);


reg select;
reg [2:0] opcode;

wire [15:0] arg1 = out1_data;
wire [15:0] arg2 = out2_data;

wire [15:0] result;
wire cf, of;

alu alu0 (select, opcode, arg1, arg2, result, cf, of);


reg in1_store_tmp;
assign in1_data = in1_store_tmp ? temp1 : result;
assign in2_data = temp2;

initial begin
    #5;
    // cycle 1:

    // configure the ALU
    select <= 0;
    opcode <= 3'b000;
    // set up our arguments
    temp1 <= 15;
    temp2 <= 30;

    // set input ports to registers A and B
    in1_we  <= 1; in2_we  <= 1;
    in1_sel <= 1; in2_sel <= 2;

    // input port 1 is temp1
    in1_store_tmp <= 1;
    // input port 2 is implicitly temp2

    // set regfile output ports to registers A and B
    out1_sel <= 1; out2_sel <= 2;

    // on next posedge, temp1 and temp2 will be in A and B

    #40;
    // cycle 2:

    // connect ALU output to register C
    in2_we <= 0;
    in1_store_tmp <= 0; in1_sel <= 3;
    
    $display("%d %d", out1_data, out2_data);

    #40;
    // cycle 3:

    // get C on output port 1
    in1_we <= 0; out1_sel = 3;

    #5 $display("Result: %d", out1_data);

    $stop;
end

endmodule // alu_register
