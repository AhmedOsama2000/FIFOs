/*
	THIS FIFO IS DESIGNED SUCH THAT READ AND WRITE CLOCK ARE THE SAME DOMAIN WITH SAME FREQUENCY
*/
module SYNC_FIFO #(
	parameter FIFO_WIDTH    = 8,
	parameter FIFO_DEPTH    = 8,
	parameter POINTER_WIDTH = $clog2(FIFO_DEPTH)
)
(
	// INPUT
	input  wire 				 rst_n,
	input  wire                  CLK,
	input  wire [FIFO_WIDTH-1:0] Data_in,
	input  wire 				 Wr_Req,
	input  wire 				 Rd_Req,

	// OUTPUT
	output reg [FIFO_WIDTH-1:0]  Data_out,
	output wire                  Full,
	output wire                  Empty
);

// Pointers for Write and Read
reg [POINTER_WIDTH:0] wptr;
reg [POINTER_WIDTH:0] rptr;

// Full - Empty Conditions
assign Full  = ({!wptr[POINTER_WIDTH],wptr[POINTER_WIDTH-1:0]} == rptr)? 1'b1:1'b0;

assign Empty = (wptr == rptr)? 1'b1:1'b0;

// FIFO Memory Buffer
reg [FIFO_WIDTH-1:0] FIFO_MEM [FIFO_DEPTH-1:0];

// Write Into FIFO MEM
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		wptr <= 1'b0;
	end
	else if (Wr_Req && !Full) begin
		FIFO_MEM[wptr[POINTER_WIDTH-1:0]] <= Data_in;
		wptr 		   <= wptr + 1'b1;
	end
end

// Read From FIFO MEM
always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		rptr     <= 1'b0;
		Data_out <= 'b0;
	end
	else if (Rd_Req && !Empty) begin
		Data_out <= FIFO_MEM[rptr[POINTER_WIDTH-1:0]];
		rptr     <= rptr + 1'b1;
	end
end

endmodule

