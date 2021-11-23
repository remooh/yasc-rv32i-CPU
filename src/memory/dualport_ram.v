module dualport_ram
#(      parameter ADDR_WIDTH = 12)
(
	input clk,				// clock

	// Data RAM
	input we,				// write enable
	input [3:0] mem_wmask,			// byte mask for writing
	input [ADDR_WIDTH-1:0] data_addr,	// data address
	input [31:0] data_write,		// data input for writing
	output reg [31:0] data_read,		// data output for reading

	// Instruction ROM
	input [ADDR_WIDTH-1:0] inst_addr,	// instruction address
	output reg [31:0] instruction		// instruction output for reading
);
	// RAM array
	reg [7:0] ram_byte3[2**ADDR_WIDTH-1:0];
	reg [7:0] ram_byte2[2**ADDR_WIDTH-1:0];
	reg [7:0] ram_byte1[2**ADDR_WIDTH-1:0];
	reg [7:0] ram_byte0[2**ADDR_WIDTH-1:0];

	// initialize memory with the contents in ram_byte*.hex
	initial begin
		$readmemh("../memory/ram_byte3.hex", ram_byte3);
		$readmemh("../memory/ram_byte2.hex", ram_byte2);
		$readmemh("../memory/ram_byte1.hex", ram_byte1);
		$readmemh("../memory/ram_byte0.hex", ram_byte0);
	end

	always @ (posedge clk)
	begin
		// Write
		if (we && mem_wmask[3]) begin
			ram_byte3[data_addr] <= data_write[31:24];
		end
		if (we && mem_wmask[2]) begin
			ram_byte2[data_addr] <= data_write[23:16];
		end
		if (we && mem_wmask[1]) begin
			ram_byte1[data_addr] <= data_write[15:8];
		end
		if (we && mem_wmask[0]) begin
			ram_byte0[data_addr] <= data_write[7:0];
		end

		//read
		data_read	<= {ram_byte3[data_addr], ram_byte2[data_addr], ram_byte1[data_addr], ram_byte0[data_addr]};
		instruction	<= {ram_byte3[inst_addr], ram_byte2[inst_addr], ram_byte1[inst_addr], ram_byte0[inst_addr]};
	end

endmodule
