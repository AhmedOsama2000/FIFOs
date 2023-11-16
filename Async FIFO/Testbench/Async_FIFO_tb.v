module Async_FIFO_tb;

	parameter FIFO_WIDTH = 8;

	// INPUT
	reg 				 wrst_n;
	reg 				 rrst_n;
	reg 				 wCLK;
	reg 				 rCLK;
	reg [FIFO_WIDTH-1:0] D_IN;
	reg 				 Wr_Req;
	reg 				 Rd_Req;
	// OUTPUT
	wire [FIFO_WIDTH-1:0]  D_OUT;
	wire                   Wr_Ack;
	wire                   Full;
	wire                   Empty;

	Async_FIFO DUT (
		.wrst_n(wrst_n),
		.rrst_n(rrst_n),
		.wCLK(wCLK),
		.rCLK(rCLK),
		.D_IN(D_IN),
		.Wr_Req(Wr_Req),
		.Rd_Req(Rd_Req),
		.D_OUT(D_OUT),
		.Wr_Ack(Wr_Ack),
		.Full(Full),
		.Empty(Empty)
	);

	// CLK domain #1
	always begin
		#1
		wCLK = ~wCLK;
	end

	// CLK domain #2
	always begin
		#5
		rCLK = ~rCLK;
	end

	initial begin
		
		wCLK = 1'b0;
		rCLK = 1'b0;
		rrst_n = 1'b0;
		wrst_n = 1'b0;

		repeat (5) @(negedge rCLK);
		rrst_n = 1'b1;
		wrst_n = 1'b1;
		repeat (5) @(negedge rCLK);

		// Write 4 then Read
		@(negedge wCLK);
		Wr_Req = 1'b1;
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge rCLK);
		Wr_Req = 1'b0;
		Rd_Req = 1'b1;

		// Write 4 then Read
		@(negedge wCLK);
		Wr_Req = 1'b1;
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge rCLK);
		Wr_Req = 1'b0;
		Rd_Req = 1'b1;

		// Write 4 then Read
		@(negedge wCLK);
		Wr_Req = 1'b1;
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge wCLK);
		D_IN   = $random;

		@(negedge rCLK);
		Wr_Req = 1'b0;
		Rd_Req = 1'b1;

		@(negedge rCLK);
		$stop;

	end

endmodule