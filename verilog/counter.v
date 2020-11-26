module counter(
	input clock, 
	input wire nrst,
	input wire enable,
	output reg [7:0] count);

always @(posedge clock) begin
	if (!nrst)
		count <= 0;
	else
		count <= count + 1;
end

endmodule // counter
