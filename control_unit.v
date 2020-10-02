`include "defines.v"

module control_unit
(
	// Input Ports
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,

	// Output Ports
	output rs1_to_alu1,
	output rs2_to_alu2,
	output [3:0] alu_op,
	
	output [2:0] jump_type,
	
	output [2:0] regfile_src,
	
	output [1:0] mem_op,
	output [2:0] mem_read_type,
	output [3:0] mem_write_mask,

	output funct3_valid
);

	// alu operation
	assign alu_op = (opcode == `OPCODE_R && funct3 == 3'b000 && !funct7[5])			? `ALU_ADD:  // add
			(opcode == `OPCODE_R && funct3 == 3'b000 && funct7[5])			? `ALU_SUB:  // sub
			(opcode == `OPCODE_I && funct3 == 3'b000)				? `ALU_ADD:  // addi
			((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b010) 	? `ALU_SLT:  // slt, slti
			((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b011) 	? `ALU_SLTU: // sltu, sltiu
			((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b100) 	? `ALU_XOR:  // xor, xori
			((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b110) 	? `ALU_OR:   // or, ori
			((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b111) 	? `ALU_AND:  // and, andi
			((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b001) 	? `ALU_SLL:  // sll, slli
			((opcode == `OPCODE_R || opcode == `OPCODE_I)
				&& funct3 == 3'b101 && !funct7[5])				? `ALU_SRL:  // srl, srli
			((opcode == `OPCODE_R || opcode == `OPCODE_I)
				&& funct3 == 3'b101 && funct7[5])				? `ALU_SRA:  // sra, srai
			((opcode == `OPCODE_B) && funct3 == 3'b000)				? `ALU_SEQ:  // beq
			((opcode == `OPCODE_B) && funct3 == 3'b001)				? `ALU_SEQ:  // bne
			((opcode == `OPCODE_B) && funct3 == 3'b100)				? `ALU_SLT:  // blt
			((opcode == `OPCODE_B) && funct3 == 3'b101)				? `ALU_SLT:  // bge
			((opcode == `OPCODE_B) && funct3 == 3'b110)				? `ALU_SLTU: // bltu
			((opcode == `OPCODE_B) && funct3 == 3'b111)				? `ALU_SLTU: // bgeu
			(opcode == `OPCODE_U_AUIPC)						? `ALU_ADD:  // auipc
			(opcode == `OPCODE_I_JALR)						? `ALU_ADD:  // jalr
			(opcode == `OPCODE_I_LOAD)						? `ALU_ADD:  // load
			(opcode == `OPCODE_S)							? `ALU_ADD:  // store
			`ALU_NONE;

	// 1st alu operand source
	assign rs1_to_alu1 =	(opcode == `OPCODE_U_AUIPC)	? `ALU1_SRC_PC:
				`ALU1_SRC_RS1;

	// 2nd alu operand source
	assign rs2_to_alu2 =	(opcode == `OPCODE_B)		? `ALU2_SRC_RS2:
				(opcode == `OPCODE_R)		? `ALU2_SRC_RS2:
				`ALU2_SRC_IMM;

	// jump condition
	assign jump_type =	(opcode == `OPCODE_J_JAL)			? `JUMP_JAL:	// jal
				(opcode == `OPCODE_I_JALR)			? `JUMP_JALR:	// jalr
				((opcode == `OPCODE_B) && funct3 == 3'b000)	? `JUMP_IF_1:	// beq
				((opcode == `OPCODE_B) && funct3 == 3'b001)	? `JUMP_IF_0:	// bne
				((opcode == `OPCODE_B) && funct3 == 3'b100)	? `JUMP_IF_1:	// blt
				((opcode == `OPCODE_B) && funct3 == 3'b101)	? `JUMP_IF_0:	// bge
				((opcode == `OPCODE_B) && funct3 == 3'b110)	? `JUMP_IF_1:	// bltu
				((opcode == `OPCODE_B) && funct3 == 3'b111)	? `JUMP_IF_0:	// bgeu
				`JUMP_NONE;
	
	// register file rd source
	assign regfile_src =	(opcode == `OPCODE_U_LUI)	? `REG_SRC_IMM:
				(opcode == `OPCODE_U_AUIPC)	? `REG_SRC_ALU:
				(opcode == `OPCODE_J_JAL)	? `REG_SRC_PCP4:
				(opcode == `OPCODE_I_JALR)	? `REG_SRC_PCP4:
				(opcode == `OPCODE_I_LOAD)	? `REG_SRC_MEM:
				(opcode == `OPCODE_I)		? `REG_SRC_ALU:
				(opcode == `OPCODE_R)		? `REG_SRC_ALU:
				`REG_SRC_NONE;
	
	// memory operation type
	assign mem_op = 	(opcode == `OPCODE_I_LOAD)	? `MEM_OP_LOAD:
				(opcode == `OPCODE_S)		? `MEM_OP_STORE:
				`MEM_OP_NONE;
	
	// load operation type
	assign mem_read_type = 	((opcode == `OPCODE_I_LOAD) && (funct3 == 3'b000)) ? `MEM_RD_BYTE:	// lb
				((opcode == `OPCODE_I_LOAD) && (funct3 == 3'b001)) ? `MEM_RD_HALF:	// lh
				((opcode == `OPCODE_I_LOAD) && (funct3 == 3'b010)) ? `MEM_RD_WORD:	// lw
				((opcode == `OPCODE_I_LOAD) && (funct3 == 3'b100)) ? `MEM_RD_B_U:	// lbu
				((opcode == `OPCODE_I_LOAD) && (funct3 == 3'b101)) ? `MEM_RD_H_U:	// lhu
				`MEM_RD_NONE;

	// store operation type				
	assign mem_write_mask = 	((opcode == `OPCODE_S) && (funct3 == 3'b000)) ? `MEM_WR_BYTE:	// sb
					((opcode == `OPCODE_S) && (funct3 == 3'b001)) ? `MEM_WR_HALF:	// sh
					((opcode == `OPCODE_S) && (funct3 == 3'b010)) ? `MEM_WR_WORD:	// sw
					`MEM_WR_NONE;

	// check if the instruction is valid
	assign funct3_valid =	((opcode == `OPCODE_I_JALR) && (funct3 != 3'b000))		? 1'b0:
				((opcode == `OPCODE_B) && (jump_type == `JUMP_NONE))		? 1'b0:
				((opcode == `OPCODE_I_LOAD) && (mem_read_type == `MEM_RD_NONE))	? 1'b0:
				((opcode == `OPCODE_S) && (mem_write_mask == `MEM_WR_NONE))	? 1'b0:
				1'b1;
endmodule
