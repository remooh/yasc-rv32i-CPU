`include "defines.v"

module decode
(
	// Input Ports
	input clk,
	input [31:0] instruction,

	// Output Ports
	output [6:0] opcode,
	output [4:0] rd_addr,
	output [2:0] funct3,
	output [4:0] rs1_addr,
	output [4:0] rs2_addr,
	output [6:0] funct7,
	
	output [3:0] inst_type,
	output [31:0] immediate,

	output opcode_valid
);

	wire sign;

	// instruction fields assignement
	assign opcode	= instruction[6:0];
	assign rd_addr	= instruction[11:7];
	assign funct3 	= instruction[14:12];
	assign rs1_addr	= instruction[19:15];
	assign rs2_addr	= instruction[24:20];
	assign funct7	= instruction[31:25];
	assign sign	= instruction[31];

	// instruction type
	assign inst_type =	(opcode == `OPCODE_U_LUI) ?	`TYPE_U:
				(opcode == `OPCODE_U_AUIPC) ?	`TYPE_U:
				(opcode == `OPCODE_J_JAL) ?	`TYPE_J:
				(opcode == `OPCODE_I_JALR) ?	`TYPE_I:
				(opcode == `OPCODE_B) ?		`TYPE_B:
				(opcode == `OPCODE_I_LOAD) ?	`TYPE_I:
				(opcode == `OPCODE_S) ?		`TYPE_S:
				(opcode == `OPCODE_I) ?		`TYPE_I:
				(opcode == `OPCODE_R) ?		`TYPE_R:
				(opcode == `OPCODE_I_FENCE) ?	`TYPE_I:
				(opcode == `OPCODE_I_CSR) ?	`TYPE_I:
				`TYPE_INVALID;

	// immediate generator
	assign immediate =	(inst_type == `TYPE_I) ? {{20{sign}}, funct7, rs2_addr}:
				(inst_type == `TYPE_S) ? {{20{sign}}, funct7, rd_addr}:
				(inst_type == `TYPE_U) ? {funct7, rs2_addr, rs1_addr, funct3, {12{1'b0}}}: 
				(inst_type == `TYPE_J) ? {{12{sign}}, rs1_addr, funct3, rs2_addr[0], funct7[5:0], rs2_addr[4:1], 1'b0}:
				(inst_type == `TYPE_B) ? {{20{sign}}, rd_addr[0], funct7[5:0], rd_addr[4:1], 1'b0}: 
				{32{1'b0}};

	assign opcode_valid =	!(opcode == `TYPE_INVALID);
endmodule
