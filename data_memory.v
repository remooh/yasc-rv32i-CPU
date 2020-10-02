module data_memory
#(      parameter ADDR_WIDTH = 12)
(
	input clk,
	input we,
	input [3:0] mem_op,
	input [ADDR_WIDTH-1:0] data_addr,
	input [31:0] data_write,
	output [31:0] data_read
);
	// Variable to hold the registered read address
	reg [ADDR_WIDTH-1:0] data_addr_reg;

	//  RAM array
	reg [7:0] ram_0[2**ADDR_WIDTH-1:0];
	reg [7:0] ram_1[2**ADDR_WIDTH-1:0];
	reg [7:0] ram_2[2**ADDR_WIDTH-1:0];
	reg [7:0] ram_3[2**ADDR_WIDTH-1:0];
	
	always @ (posedge clk)
	begin
		// Write
		if (mem_op[0] && we)
			ram_0[data_addr] <= data_write[7:0];
		if (mem_op[1] && we)
			ram_1[data_addr] <= data_write[15:8];
		if (mem_op[2] && we)
			ram_2[data_addr] <= data_write[23:16];
		if (mem_op[3] && we)
			ram_3[data_addr] <= data_write[31:24];

		data_addr_reg <= data_addr;
	end
	
	assign data_read = {ram_3[data_addr_reg], ram_2[data_addr_reg], ram_1[data_addr_reg], ram_0[data_addr_reg]};

endmodule


//// Quartus Prime Verilog Template
//// Single port RAM with single read/write address and initial contents 
//// specified with an initial block
//
//module single_port_ram_with_init
//#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
//(
//	input [(DATA_WIDTH-1):0] data,
//	input [(ADDR_WIDTH-1):0] addr,
//	input we, clk,
//	output [(DATA_WIDTH-1):0] q
//);
//
//	// Declare the RAM variable
//	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
//
//	// Variable to hold the registered read address
//	reg [ADDR_WIDTH-1:0] addr_reg;
//
//	// Specify the initial contents.  You can also use the $readmemb
//	// system task to initialize the RAM variable from a text file.
//	// See the $readmemb template page for details.
//	initial 
//	begin : INIT
//		integer i;
//		for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
//			ram[i] = {DATA_WIDTH{1'b1}};
//	end 
//
//	always @ (posedge clk)
//	begin
//		// Write
//		if (we)
//			ram[addr] <= data;
//
//		addr_reg <= addr;
//	end
//
//	// Continuous assignment implies read returns NEW data.
//	// This is the natural behavior of the TriMatrix memory
//	// blocks in Single Port mode.  
//	assign q = ram[addr_reg];
//
//endmodule
