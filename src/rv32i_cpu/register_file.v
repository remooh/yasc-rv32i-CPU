module register_file
#(      parameter DATA_WIDTH = 32)
(
	// Input Ports
	input clk,
	input rd_we,
	input [4:0] rd_addr,
	input [4:0] rs1_addr,
	input [4:0] rs2_addr,
	input [DATA_WIDTH-1:0] rd_data,
	// Output Ports
	output reg [DATA_WIDTH-1:0] rs1_data,
	output reg [DATA_WIDTH-1:0] rs2_data
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] register_file[31:0];
	
	initial 
	begin : INIT
		integer i;
		for(i = 0; i < 32; i=i+1)
			register_file[i] = {DATA_WIDTH{1'b0}};
	end 

	always @ (posedge clk)
	begin
		// Write
		if (rd_we)
			register_file[rd_addr] <= rd_data;

		rs1_data <= register_file[rs1_addr];
		rs2_data <= register_file[rs2_addr];
	end
endmodule
