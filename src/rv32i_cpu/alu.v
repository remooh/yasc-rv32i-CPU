`include "../rv32i_cpu/defines.v"

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

	assign result =	(alu_op == `ALU_ADD)	? operand_a + operand_b: // add
			(alu_op == `ALU_SUB)	? operand_a - operand_b: // sub
			(alu_op == `ALU_AND)	? operand_a & operand_b: // and
			(alu_op == `ALU_OR)	? operand_a | operand_b: // or
			(alu_op == `ALU_XOR)	? operand_a ^ operand_b: // xor
			(alu_op == `ALU_SLL)	? operand_a << operand_b[4:0]: // sll
			(alu_op == `ALU_SRL)	? operand_a >> operand_b[4:0]: // srl
			(alu_op == `ALU_SRA)	? $signed($signed(operand_a) >>> operand_b[4:0]): // sra
			(alu_op == `ALU_SLT)	? {{DATA_WIDTH-1{1'b0}}, $signed(operand_a) < $signed(operand_b)}: //slt
			(alu_op == `ALU_SLTU)	? {{DATA_WIDTH-1{1'b0}}, operand_a < operand_b}: // sltu
			(alu_op == `ALU_SEQ)	? {{DATA_WIDTH-1{1'b0}}, operand_a == operand_b}: // seq (set if equal)
			{DATA_WIDTH{1'b0}};
endmodule
