module lu(
    input wire [2:0] opcode,
    input wire [15:0] arg1,
    input wire [15:0] arg2,
    output reg [15:0] result);

always @(*)
case (opcode)
    3'b000:  result =   arg1 & arg2;
    3'b001:  result = ~(arg1 & arg2);
    3'b010:  result =   arg1 | arg2;
    3'b011:  result = ~(arg1 | arg2);
    3'b100:  result =   arg1 ^ arg2;
    3'b101:  result = ~(arg1 ^ arg2);
    3'b110:  result =   arg1;
    3'b111:  result =  ~arg1;
    default: result = 16'bx;
endcase

endmodule // au
