`timescale 1us/1ns

`include "components/comparator.v"

module cmp_bench;

reg [15:0] in1, in2;
reg sm;
wire eq, lt;

wire signed [15:0] in1s = in1;
wire signed [15:0] in2s = in2;

comparator cmp (in1, in2, sm, eq, lt);

task show ();
    #5 $display("in1 %d (%d) in2 %d (%d) sm %d eq %d lt %d",
        in1, in1s, in2, in2s, sm, eq, lt);
endtask

initial begin
    in1 <= 0;
    in2 <= 0;
    sm <= 0;
    show();

    in1 <= 15;
    show();

    in2 <= 30;
    show();
    
    in2 <= -35;
    show();

    sm <= 1;
    show();

    $stop;
end

endmodule // cmp_bench
