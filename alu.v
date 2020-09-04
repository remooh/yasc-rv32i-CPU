`include "defines.v"

module alu
#(	parameter DATA_WIDTH = 32)
(
	// Input Ports
//	input clk,
	input [3:0] alu_op,
	input [DATA_WIDTH-1:0] operand_a,
	input [DATA_WIDTH-1:0] operand_b,

	// Output Ports
	output [DATA_WIDTH-1:0] result
);

	assign result =	(alu_op == `ALU_ADD) 	? operand_a + operand_b: // add
							(alu_op == `ALU_SUB) 	? operand_a - operand_b: // sub
							(alu_op == `ALU_AND) 	? operand_a & operand_b: // and
							(alu_op == `ALU_OR)		? operand_a | operand_b: // or
							(alu_op == `ALU_XOR) 	? operand_a ^ operand_b: // xor
							(alu_op == `ALU_SLL) 	? operand_a << operand_b[4:0]: // sll
							(alu_op == `ALU_SRL) 	? operand_a >> operand_b[4:0]: // srl
							(alu_op == `ALU_SRA) 	? $signed(operand_a) >>> operand_b[4:0]: // sra
							(alu_op == `ALU_SLT) 	? {{31{1'b0}}, $signed(operand_a) < $signed(operand_b)}: //slt
							(alu_op == `ALU_SLTU) 	? {{31{1'b0}}, operand_a < operand_b}: // sltu
							{DATA_WIDTH{1'b0}};

//	always@(posedge clk)
//	begin
//		case(alu_op)
//			`ALU_ADD: 	result <= operand_a + operand_b; // add
//			`ALU_SUB: 	result <= operand_a - operand_b; // sub
//			`ALU_AND: 	result <= operand_a & operand_b; // and
//			`ALU_OR:		result <= operand_a | operand_b; // or
//			`ALU_XOR:	result <= operand_a ^ operand_b; // xor
//			`ALU_SLL:	result <= operand_a << operand_b[4:0]; // sll
//			`ALU_SRL:	result <= operand_a >> operand_b[4:0]; // srl
//			`ALU_SRA:	result <= $signed(operand_a) >>> operand_b[4:0]; // sra
//			`ALU_SLT:	if($signed(operand_a) < $signed(operand_b)) //slt
//								result <= 1'b1;
//							else
//								result <= 1'b0;
//			`ALU_SLTU:	if(operand_a < operand_b) // sltu
//								result <= 1'b1;
//							else
//								result <= 1'b0;
//			default: 	result <= {DATA_WIDTH{1'b0}};
//		endcase
//	end
endmodule
