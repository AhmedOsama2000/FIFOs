module G2B #(
	parameter DATA_LENGTH = 3
)
(
	input  wire [DATA_LENGTH-1:0] DATA_IN,
	output reg  [DATA_LENGTH-1:0] DATA_OUT 
);

integer i;

always @(*) begin
	for (i = 0;i < DATA_LENGTH;i = i + 1) begin
		DATA_OUT[i] = ^(DATA_IN >> i);
	end
end

endmodule