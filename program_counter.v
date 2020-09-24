`include "defines.v"

module program_counter
#(	parameter DATA_WIDTH = 32)
(
	// Input Ports
	input clk,
	input [DATA_WIDTH-1:0] addr_offset,
	input [DATA_WIDTH-1:0] alu_result,
	input [2:0] jump_type,
	
	input update_pc,
	
	// Output Ports
	output [DATA_WIDTH-1:0] pc_current,
	output [DATA_WIDTH-1:0] pc_plus_4,
	output [DATA_WIDTH-1:0] pc_next
);

	// program counter
	reg [DATA_WIDTH-1:0] program_counter;
	assign pc_current = program_counter;

	wire [DATA_WIDTH-1:0] pc_offset;
	wire [DATA_WIDTH-1:0] jalr_addr;
	
	assign pc_plus_4 = program_counter + 32'h4;
	assign pc_offset = program_counter + addr_offset;
	assign jalr_addr = alu_result & {DATA_WIDTH-1'b1, 1'b0}; // alu result with lsb set to zero
	
	assign pc_next =	(jump_type == `JUMP_IF_0 && alu_result[0] == 1'b0) ? pc_offset:
				(jump_type == `JUMP_IF_1 && alu_result[0] == 1'b1) ? pc_offset:
				(jump_type == `JUMP_JAL) ? pc_offset:
				(jump_type == `JUMP_JALR) ? jalr_addr:
				(jump_type == `JUMP_ZERO) ? {DATA_WIDTH{1'b0}}:
				pc_plus_4;
	
	always @ (posedge clk) begin
		if(update_pc) begin
			program_counter <= pc_next;
		end
	end

endmodule
