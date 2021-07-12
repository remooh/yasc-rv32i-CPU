module data_memory
#(      parameter ADDR_WIDTH = 13)
(
	input clk,
	input we,
	input [3:0] mem_wmask,
	input [ADDR_WIDTH-1:0] data_addr,
	input [31:0] data_write,
	output [31:0] data_read
);
	// Variable to hold the registered read address
	reg [ADDR_WIDTH-1:0] data_addr_reg;

	//  RAM array
	reg [31:0] ram[2**ADDR_WIDTH-1:0];

	//initial
	//begin : INIT
	//	integer i;
	//	for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
	//		ram[i] = 32'b0;
	//end

	initial begin
		$readmemh("dmem.hex", ram);
	end

	generate
		genvar idx;
		for(idx = 0; idx < 128; idx = idx+1) begin: dmem_dump
			wire [31:0] tmp;
			assign tmp = ram[idx];
		end
	endgenerate
	
	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[data_addr] <= data_write;

		data_addr_reg <= data_addr;
	end
	
	assign data_read = ram[data_addr_reg];

endmodule