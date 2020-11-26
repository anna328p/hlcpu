`timescale 1us/1ns

`include "components/regfile.v"

module regfile_bench;

reg clk;
always begin
    clk = 1'b0;
    #20;

    clk = 1'b1;
    #20;
end


reg [3:0]   in1_sel;
reg [15:0]  in1_data;
reg [3:0]   in2_sel;
reg [15:0]  in2_data;

reg [3:0]   out1_sel;
wire [15:0] out1_data;
reg [3:0]   out2_sel;
wire [15:0] out2_data;

regfile regfile0 (clk,
    in1_sel,  in1_data,  in2_sel,  in2_data,
    out1_sel, out1_data, out2_sel, out2_data);

initial begin
    #15;

    in1_sel <= 4'b0001;
    in1_data <= 16'hDEAD;
    in2_sel <= 4'b0010;
    in2_data <= 16'hBEEF;

    out1_sel <= 4'b0001;
    out2_sel <= 4'b0010;

    $display("out1 %x out2 %x", out1_data, out2_data);

    #10;

    $display("out1 %x out2 %x", out1_data, out2_data);

    in1_sel <= 4'bx;
    in2_sel <= 4'bx;

    #20;

    $display("out1 %x out2 %x", out1_data, out2_data);

    out1_sel <= 4'b0100;
    out2_sel <= 4'b0101;

    #20;

    $display("out1 %x out2 %x", out1_data, out2_data);

    $stop;
end

endmodule // regfile_bench
