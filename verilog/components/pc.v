module pc(
    input wire clk,
    input wire nrst,
    input wire we,
    input wire [15:0] data,
    output reg [15:0] count);

always @(*)
    if (!nrst)
        count = 0;

always @(posedge clk)
    if (we)
        count <= data;
    else
        count += 1;

endmodule // pc
