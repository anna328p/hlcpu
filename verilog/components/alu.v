`include "components/au.v"
`include "components/lu.v"

module alu(
    input wire select,
    input wire [2:0] opcode,
    input wire [15:0] arg1,
    input wire [15:0] arg2,
    output wire [15:0] result,
    output wire carry,
    output wire overflow);

wire [15:0] au_result;
wire [15:0] lu_result;

au au0 (opcode, arg1, arg2, au_result, carry, overflow);
lu lu0 (opcode, arg1, arg2, lu_result);


assign result = select ? lu_result : au_result;

endmodule // alu
