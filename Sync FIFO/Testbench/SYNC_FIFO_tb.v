module SYNC_FIFO_tb;

	parameter FIFO_WIDTH    = 8;
	parameter FIFO_DEPTH    = 8;
	parameter POINTER_WIDTH = $clog2(FIFO_DEPTH);

	// INPUT
	reg 				  rst_n;
	reg                   CLK;
	reg [FIFO_WIDTH-1:0]  Data_in;
	reg 				  Wr_Req;
	reg 				  Rd_Req;

	// OUTPUT
	wire [FIFO_WIDTH-1:0] Data_out;
	wire                  Full;
	wire                  Empty;

	integer i;

	SYNC_FIFO DUT (
		.rst_n(rst_n),
		.CLK(CLK),
		.Data_in(Data_in),
		.Wr_Req(Wr_Req),
		.Rd_Req(Rd_Req),
		.Data_out(Data_out),
		.Empty(Empty),
		.Full(Full)
	);

	always #5 CLK = !CLK;

	initial begin	
		CLK     = 0;
		rst_n   = 0;
		Data_in = 'b0;
		Wr_Req  = 1'b0;
		Rd_Req  = 1'b0;

		repeat (5) @(negedge CLK);

		Wr_Req = 1'b1;
		rst_n  = 1'b1;

		// Write until the fifo is full
		for (i = 0;i < FIFO_DEPTH;i = i + 1) begin
			Data_in = $random;
			@(negedge CLK);
		end

		@(negedge CLK);
		Wr_Req = 1'b0;
		Rd_Req = 1'b1;
		// Read until it's empty
		repeat (FIFO_DEPTH) @(negedge CLK);

		@(negedge CLK);

		// Random Operations
		for (i = 0;i < 50;i = i + 1) begin
			Wr_Req  = $random;
			Rd_Req  = $random;
			Data_in = $random;
			@(negedge CLK);
		end

		@(negedge CLK);
		$stop;

	end

endmodule
