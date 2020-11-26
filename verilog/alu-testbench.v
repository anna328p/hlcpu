`timescale 1us/1ns

`include "alu.v"

module alu_bench;

reg [4:0] op;
wire [15:0] result;
wire carry;
wire overflow;

wire [2:0] opcode = op[2:0];
wire nau_lu = op[3];
wire signed [15:0] result_s = result;

reg [15:0] arg1, arg2;

alu alu0 (nau_lu, opcode, arg1, arg2, result, carry, overflow);

task test_all (input reg [15:0] t_arg1, input reg [15:0] t_arg2);
    begin
        op = 5'b0;
        arg1 = t_arg1;
        arg2 = t_arg2;
        #5;
        $display("\ntesting all ALU ops\narg1: %d %16b\narg2: %d %16b", arg1, arg1, arg2, arg2);

        while (op < 5'b10000) begin
            $display("sel %d op %d res %d (%d) %16b cf %d of %d",
                nau_lu, opcode, result, result_s, result, carry, overflow);
            op += 1;
            #5;
        end

        $display("");
    end
endtask // test_all

initial begin
    test_all(15, 2);
    test_all(15, -3);
    test_all(2, -3);
    test_all(1<<15, 2);
    test_all(1<<14, 1<<14);

    $stop;
end

endmodule // alu_bench
