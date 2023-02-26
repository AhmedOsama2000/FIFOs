module B2G #(
	parameter DATA_LENGTH = 3
)
(
	input  wire [DATA_LENGTH-1:0] DATA_IN,
	output reg  [DATA_LENGTH-1:0] DATA_OUT 
);

integer i;

always @(*) begin
	for (i = 0;i < DATA_LENGTH - 1;i = i + 1) begin
		DATA_OUT[DATA_LENGTH-i-2] = DATA_IN[DATA_LENGTH-i-1] ^ DATA_IN[DATA_LENGTH-i-2];
	end
	DATA_OUT[DATA_LENGTH-1] = DATA_IN[DATA_LENGTH-1];
end

endmodule