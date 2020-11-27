`timescale 1us/1ns

`include "components/pc.v"

module pc_bench;

reg clk;
reg nrst;
reg [15:0] data;
wire [15:0] count;
reg we;

reg [3:0] ncounts;

pc pc0 (clk, nrst, we, data, count);

always begin
    clk = 1'b0; 
    #20;

    clk = 1'b1;
    #20;
end

initial begin
    nrst <= 0;
    #5;
    nrst <= 1;
    #5;
    
    for (ncounts = 0; ncounts < 5; ncounts++) begin
        $display("pc %x", count);
        #40;
    end

    we <= 1;
    data <= 16'hDEAD;
    #40;
    we <= 0;

    for (ncounts = 0; ncounts < 5; ncounts++) begin
        $display("pc %x", count);
        #40;
    end
    $stop;
end

endmodule // pc_bench
