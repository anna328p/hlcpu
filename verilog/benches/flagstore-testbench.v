`timescale 1us/1ns

`include "components/flagstore.v"

module flagstore_bench;

reg clk;
always begin
    clk = 1'b0;
    #20;

    clk = 1'b1;
    #20;
end

reg nrst;
reg [0:3] flag_mask;
reg [0:3] new_flags;

wire eq, lt, cf, of;

flagstore flags (clk, nrst, flag_mask, new_flags, eq, lt, cf, of);

initial begin
    $display("eq %d lt %d cf %d of %d", eq, lt, cf, of);
    nrst <= 1;
    #15;
    nrst <= 0;
    #40;
    $display("eq %d lt %d cf %d of %d", eq, lt, cf, of);
    flag_mask = 4'b0011;
    new_flags = 4'bxx11;

    #40;
    $display("eq %d lt %d cf %d of %d", eq, lt, cf, of);

    flag_mask = 4'b1100;
    new_flags = 4'b11xx;

    #40;
    $display("eq %d lt %d cf %d of %d", eq, lt, cf, of);

    flag_mask = 4'b0101;
    new_flags = 4'b0000;

    #40;
    $display("eq %d lt %d cf %d of %d", eq, lt, cf, of);

    $stop;
end

endmodule // flagstore_bench
