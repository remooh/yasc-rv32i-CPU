module instruction_memory
#(      parameter ADDR_WIDTH = 14)
(
	input clk,
	input [ADDR_WIDTH-1:0] inst_addr,
	output wire unaligned,
	output reg [31:0] inst_data
);

	reg [31:0] inst_mem[2**(ADDR_WIDTH-2)-1:0];

	always @ (posedge clk)
	begin
		inst_data <= inst_mem[inst_addr[ADDR_WIDTH-1:2]];
	end
	
	assign unaligned = (inst_addr[1:0] != 2'b00) ? 1'b1 : 1'b0;
endmodule
