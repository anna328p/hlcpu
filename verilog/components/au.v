module au(
    input wire [2:0] opcode,
    input wire [15:0] arg1,
    input wire [15:0] arg2,
    output wire [15:0] result,
    output wire carry,
    output wire overflow);

wire signed [15:0] arg1s = arg1;

reg [16:0] tmp_out;

always @(*) begin
    case (opcode)
        3'b000:  tmp_out = arg1 + arg2;   // ADD
        3'b001:  tmp_out = arg1 - arg2;   // SUB
        3'b010:  tmp_out = arg1;          // NOP (handled elsewhere)
        3'b011:  tmp_out = arg1;          // NOP (handled elsewhere)
        3'b100:  tmp_out = arg1 << arg2;  // SHL
        3'b101:  tmp_out = arg1 >> arg2;  // SHR
        3'b110:  tmp_out = (arg1 << arg2) | (arg1 >> (16 - arg2)); // RTL
        3'b111:  tmp_out = arg1s >>> arg2; // SAR
        default: tmp_out = 16'bx;
    endcase
end

assign carry    = tmp_out[16];

wire s1 = arg1[15];
wire s2 = arg2[15];
wire so = tmp_out[15];

assign overflow = ~opcode[2] &
    (~s1 & ~s2 &  so) |
    (~s1 &  s2 &  so) |
    ( s1 & ~s2 & ~so) |
    ( s1 &  s2 & ~so);

assign result = tmp_out[15:0];

endmodule // au
