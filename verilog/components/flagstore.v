module flagstore(
    input wire clk,
    input wire nrst,
    input wire [0:3] flag_mask,
    input wire [0:3] new_flags,
    output wire eq,
    output wire lt,
    output wire cf,
    output wire of);

reg [0:3] flags;

assign eq = flags[0];
assign lt = flags[1];
assign cf = flags[2];
assign of = flags[3];

always @(*)
    if (!nrst) flags <= 4'b0000;

always @(posedge clk) begin
    if (flag_mask & 4'b1000)
        flags[0] <= new_flags[0];
    if (flag_mask & 4'b0100)
        flags[1] <= new_flags[1];
    if (flag_mask & 4'b0010)
        flags[2] <= new_flags[2];
    if (flag_mask & 4'b0001)
        flags[3] <= new_flags[3];
end

endmodule // flagstore
