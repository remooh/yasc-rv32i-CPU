`include "defines.v"

module alu
#(	parameter DATA_WIDTH = 32)
(
	// Input Ports
	input clk,
	input [3:0] alu_op,
	input [DATA_WIDTH-1:0] operand_a,
	input [DATA_WIDTH-1:0] operand_b,

	// Output Ports
	output reg [DATA_WIDTH-1:0] result
);

//	wire signed [DATA_WIDTH-1:0] sign_a;
//	wire signed [DATA_WIDTH-1:0] sign_b;
//	assign

	always@(posedge clk)
	begin
		case(alu_op)
			`ALU_ADD: 	result <= operand_a + operand_b; // add
			`ALU_SUB: 	result <= operand_a - operand_b; // sub
			`ALU_AND: 	result <= operand_a & operand_b; // and
			`ALU_OR:		result <= operand_a | operand_b; // or
			`ALU_XOR:	result <= operand_a ^ operand_b; // xor
			`ALU_SLL:	result <= operand_a << operand_b[4:0]; // sll
			`ALU_SRL:	result <= operand_a >> operand_b; // srl
			`ALU_SRA:	result <= operand_a >>> operand_b; // sra
			`ALU_SLT:	if($signed(operand_a) > $signed(operand_b)) //slt
								result <= 1'b1;
							else
								result <= 1'b0;
			`ALU_SLTU:	if(operand_a > operand_b) // sltu
								result <= 1'b1;
							else
								result <= 1'b0;
			default: 	result <= {DATA_WIDTH{1'b0}};
		endcase
	end
endmodule
