module P_SYNC
#(
	parameter BUS_WIDTH  = 3,
	parameter NUM_STAGES = 2
)
(
	input  wire 				CLK,
	input  wire 				rst_n,
	input  wire [BUS_WIDTH-1:0] Async,
	output reg  [BUS_WIDTH-1:0] Sync
);

// Number of stages
reg [NUM_STAGES-1:0] NFFS [BUS_WIDTH-1:0];

integer i;

always @(posedge CLK , negedge rst_n) begin
	
	if(!rst_n) begin
		for (i = 0; i < BUS_WIDTH;i = i + 1) begin
			NFFS[i] <= 0;
		end
	end
	else begin
		for (i = 0;i < BUS_WIDTH;i = i + 1) begin
			NFFS[i] <= {Async[i],NFFS[i][NUM_STAGES-1:1]};
		end
	end

end

always @(*) begin
	
	for (i = 0; i < BUS_WIDTH;i = i + 1) begin
		Sync[i] = NFFS[i][0];
	end

end

endmodule