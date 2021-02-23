`timescale 1ns / 1ps

`include "components/memunit.v"
`include "rd1174/testbench/verilog/micron16m16/mt48lc16m16a2.v"

module mem_bench;

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, mem_bench);
end

reg clk;
always begin
    #3.75 clk = 1'b0;
    #3.75 clk = 1'b1;
end

wire [12:0] Addr;
wire [15:0] Dq;
wire  [1:0] Ba, Dqm;
wire        Clk, Cke, Cs_n, Ras_n, Cas_n, We_n;

reg         nrst, enable, rwn;
reg  [15:0] memaddr, data_in;
wire        ready, data_valid;
wire [15:0] data_out;

memunit mem (clk, nrst,
    memaddr, enable, rwn, data_in,

    ready, data_out, data_valid,

    Addr, Ba, Cas_n, Cke, Cs_n,
    Dqm, Ras_n, We_n, Clk, Dq);

mt48lc16m16a2 ram0 (Dq, Addr, Ba, Clk, Cke, 
    Cs_n, Ras_n, Cas_n, We_n, Dqm);

initial begin
    #1;
    nrst <= 0;
    memaddr <= 0;
    rwn <= 0;
    data_in <= 15;
    
    #15;

    nrst <= 1;
    @(posedge ready) #15;

    $display("memunit ready");

    enable <= 1;
    @(negedge ready);
    $display("begin write");
    enable <= 0;

    @(posedge ready);
    $display("write complete");

    rwn <= 1;

    enable <= 1;
    @(negedge ready);
    $display("begin read");
    enable <= 0;


    @(posedge ready);

    $stop;
end

always @(posedge clk)
    if (data_valid) begin
        $display("read back: %d", data_out);
        #1000;
        $stop;
    end

endmodule // mem_bench;
