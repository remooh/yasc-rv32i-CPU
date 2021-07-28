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
	// RAM array
	reg [31:0] ram[2**ADDR_WIDTH-1:0];

	//initial
	//begin : INIT
	//	integer i;
	//	for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
	//		ram[i] = 32'b0;
	//end

	// initialize memory with the contents in dmem.hex
	initial begin
		$readmemh("../memory/dmem.hex", ram);
	end

	// workaround to dump the memory contents in the testbench VCD
	generate
		genvar idx;
		for(idx = 0; idx < 128; idx = idx+1) begin: dmem_dump
			wire [31:0] tmp;
			assign tmp = ram[idx];
		end
	endgenerate

	wire [7:0] mask0;
	wire [7:0] mask1;
	wire [7:0] mask2;
	wire [7:0] mask3;

	assign mask0 = (mem_wmask[0] == 1'b1) ? data_write[7:0]   : data_read[7:0];
	assign mask1 = (mem_wmask[1] == 1'b1) ? data_write[15:8]  : data_read[15:8];
	assign mask2 = (mem_wmask[2] == 1'b1) ? data_write[23:16] : data_read[23:16];
	assign mask3 = (mem_wmask[3] == 1'b1) ? data_write[31:24] : data_read[31:24];
	
	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[data_addr] <= {mask3, mask2, mask1, mask0};

	end
	
	assign data_read = ram[data_addr];

endmodule
