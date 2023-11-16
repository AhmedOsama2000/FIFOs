module Async_FIFO #(
	parameter FIFO_WIDTH    = 8,
	parameter FIFO_DEPTH    = 8,
	parameter POINTER_WIDTH = $clog2(FIFO_DEPTH)
)
(
	// INPUT
	input  wire 				 wrst_n,
	input  wire 				 rrst_n,
	input  wire 				 wCLK,
	input  wire 				 rCLK,
	input  wire [FIFO_WIDTH-1:0] D_IN,
	input  wire 				 Wr_Req,
	input  wire 				 Rd_Req,
	// OUTPUT
	output reg [FIFO_WIDTH-1:0]  D_OUT,
	output reg                   Wr_Ack,
	output wire                  Full,
	output wire                  Empty
);

// Pointers for Write and Read
reg  [POINTER_WIDTH:0] p_wr_b;
reg  [POINTER_WIDTH:0] p_rd_b;
wire [POINTER_WIDTH:0] async_p_wr_g;
wire [POINTER_WIDTH:0] async_p_rd_g;
wire [POINTER_WIDTH:0] sync_p_wr_g;
wire [POINTER_WIDTH:0] sync_p_rd_g;
wire [POINTER_WIDTH:0] sync_p_wr_b;
wire [POINTER_WIDTH:0] sync_p_rd_b;

// Convert From Binary To gray
// Write Pointer
B2G #(
	.DATA_LENGTH(POINTER_WIDTH + 1)
) 
	wbinary_Gray
(
	.DATA_IN(p_wr_b),
	.DATA_OUT(async_p_wr_g)
);
// Read Pointer
B2G #(
	.DATA_LENGTH(POINTER_WIDTH + 1)
) 
	rbinary_Gray
(
	.DATA_IN(p_rd_b),
	.DATA_OUT(async_p_rd_g)
);
// Synchronous Write Pointer
P_SYNC #(
	.BUS_WIDTH(POINTER_WIDTH + 1)
) 
	wpointer_sync
(
	.rst_n(rrst_n),
	.CLK(rCLK),
	.Async(async_p_wr_g),
	.Sync(sync_p_wr_g)
);

// Synchronous Read Pointer
P_SYNC #(
	.BUS_WIDTH(POINTER_WIDTH + 1)
) 
	rpointer_sync
(
	.rst_n(wrst_n),
	.CLK(wCLK),
	.Async(async_p_rd_g),
	.Sync(sync_p_rd_g)
);

// Convert Back to Binary
G2B #(
	.DATA_LENGTH(POINTER_WIDTH + 1)
) 
	gray_binary_wr
(
	.DATA_IN(sync_p_wr_g),
	.DATA_OUT(sync_p_wr_b)
);
G2B #(
	.DATA_LENGTH(POINTER_WIDTH + 1)
) 
	gray_binary_rd
(
	.DATA_IN(sync_p_rd_g),
	.DATA_OUT(sync_p_rd_b)
); 


// Full/Almost-Full - Empty/Almost-Empty
assign Full  = ({!p_wr_b[POINTER_WIDTH],p_wr_b[POINTER_WIDTH-1:0]} == sync_p_rd_b)? 1'b1:1'b0;
assign Empty = ({p_rd_b == sync_p_wr_b})? 1'b1:1'b0;

reg [FIFO_WIDTH-1:0] FIFO_MEM [FIFO_DEPTH-1:0];

// Write Logic
always @(posedge wCLK,negedge wrst_n) begin
	
	if (!wrst_n) begin
		Wr_Ack <= 0;
		p_wr_b <= 'b0;
	end
	else if (Wr_Req && !Full) begin
		FIFO_MEM[p_wr_b[POINTER_WIDTH-1:0]] <= D_IN;
		Wr_Ack		     <= 1'b1;
		p_wr_b 		     <= p_wr_b + 1'b1;
	end
	else begin
		Wr_Ack   	     <= 1'b0;
	end
end

// Read Logic
always @(posedge rCLK,negedge rrst_n) begin
	if (!rrst_n) begin
		p_rd_b <= 'b0;
	end
	else if (Rd_Req && !Empty) begin
		D_OUT <= FIFO_MEM[p_rd_b[POINTER_WIDTH-1:0]];
		p_rd_b  <= p_rd_b + 1'b1;
	end
end

endmodule

