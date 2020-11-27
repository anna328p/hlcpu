module comparator(
    input wire [15:0] in1,
    input wire [15:0] in2,
    input wire signed_mode,
    output wire eq,
    output wire lt);

wire signed [15:0] in1s = in1;
wire signed [15:0] in2s = in2;

assign eq = in1 == in2;

assign lt = signed_mode ?
                in1s < in2s :
                in1 < in2;

endmodule // comparator
