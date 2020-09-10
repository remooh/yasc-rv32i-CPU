module register_file
#(      parameter DATA_WIDTH = 32)
(
	// Input Ports
	input clk,
	input	rd_we,
	input [4:0] rd_addr,
	input [4:0] rs1_addr,
	input [4:0] rs2_addr,
	input [DATA_WIDTH-1:0] rd_data,
	// Output Ports
	output reg [DATA_WIDTH-1:0] rs1_data,
	output reg [DATA_WIDTH-1:0] rs2_data
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] register_file[DATA_WIDTH-1:0];
	
	initial 
	begin : INIT
		integer i;
		for(i = 0; i < DATA_WIDTH; i=i+1)
			register_file[i] = {DATA_WIDTH{1'b0}};
	end 

	always @ (posedge clk)
	begin
	
		// Write
		if (rd_we && (rd_addr != 5'b00000)) // all registers were initialized to 0, do not touch x0
			register_file[rd_addr] <= rd_data;

		rs1_data <= register_file[rs1_addr];
		rs2_data <= register_file[rs2_addr];
	end
endmodule























