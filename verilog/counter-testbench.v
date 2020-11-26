`timescale 1us/1ns

`include "counter.v"

module counter_bench;

reg do_clk;
reg clk;

always 
begin
    clk = 1'b0; 
    #20;

    clk = 1'b1;
    #20;
end

wire [7:0] value;
reg reset, enable;

counter ctr (clk, reset, enable, value);

initial begin
    #5;
    reset = 0;
    enable = 0;
    #20;

    reset = 1;
    #20;
    enable = 1;
    #20;
end

always @(posedge clk) begin
    #3;
    $display("Value of counter is %d", value);

    if (value == 255)
        $stop;
end

endmodule
