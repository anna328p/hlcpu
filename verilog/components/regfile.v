module regfile(
    input wire clk,

    input wire         in1_we,
    input wire [3:0]   in1_sel,
    input wire [15:0]  in1_data,

    input wire         in2_we,
    input wire [3:0]   in2_sel,
    input wire [15:0]  in2_data,

    input wire [3:0]   out1_sel,
    output reg [15:0]  out1_data,

    input wire [3:0]   out2_sel,
    output reg [15:0]  out2_data);

reg [15:0] a, b, c, d, ix, iy, sp;

wire [7:0] hx = ix[15:8];
wire [7:0] lx = ix[7:0];
wire [7:0] hy = iy[15:8];
wire [7:0] ly = iy[7:0];

always @(posedge clk) begin
    if (in1_we) begin
        case (in1_sel)
            4'b0001: a  <= in1_data;
            4'b0010: b  <= in1_data;
            4'b0011: c  <= in1_data;
            4'b0100: d  <= in1_data;
            4'b0101: ix <= in1_data;
            4'b0110: iy <= in1_data;
            4'b0111: sp <= in1_data;
            4'b1100: ix[15:8] <= in1_data;
            4'b1101: iy[15:8] <= in1_data;
            4'b1110: ix[7:0]  <= in1_data;
            4'b1111: iy[7:0]  <= in1_data;
            default: a <= a;
        endcase
    end

    if (in2_we) begin
        case (in2_sel)
            4'b0001: a  <= in2_data;
            4'b0010: b  <= in2_data;
            4'b0011: c  <= in2_data;
            4'b0100: d  <= in2_data;
            4'b0101: ix <= in2_data;
            4'b0110: iy <= in2_data;
            4'b0111: sp <= in2_data;
            4'b1100: ix[15:8] <= in2_data;
            4'b1101: iy[15:8] <= in2_data;
            4'b1110: ix[7:0]  <= in2_data;
            4'b1111: iy[7:0]  <= in2_data;
            default: a <= a;
        endcase
    end
end

always @(*)
    case (out1_sel)
        4'b0000: out1_data = 4'b0;
        4'b0001: out1_data = a;
        4'b0010: out1_data = b;
        4'b0011: out1_data = c;
        4'b0100: out1_data = d;
        4'b0101: out1_data = ix;
        4'b0110: out1_data = iy;
        4'b0111: out1_data = sp;
        4'b1100: out1_data = hx;
        4'b1101: out1_data = hy;
        4'b1110: out1_data = lx;
        4'b1111: out1_data = ly;
        default: out1_data = 4'bx;
    endcase

always @(*)
    case (out2_sel)
        4'b0000: out2_data = 4'b0;
        4'b0001: out2_data = a;
        4'b0010: out2_data = b;
        4'b0011: out2_data = c;
        4'b0100: out2_data = d;
        4'b0101: out2_data = ix;
        4'b0110: out2_data = iy;
        4'b0111: out2_data = sp;
        4'b1100: out2_data = hx;
        4'b1101: out2_data = hy;
        4'b1110: out2_data = lx;
        4'b1111: out2_data = ly;
        default: out2_data = 4'bx;
    endcase

endmodule // regfile
