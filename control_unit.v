`include "defines.v"

module control_unit
(
	// Input Ports
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,

	// Output Ports
	output [2:0] alu_src,
	output [3:0] alu_op,
	
	output [2:0] jump_type,
	
	output [1:0] regfile_src,
	
	output [2:0] mem_read_type,
	output [3:0] mem_write_mask
);

	// alu operation
	assign alu_op = 	(opcode == `OPCODE_R && funct3 == 3'b000 && !funct7[5])					? `ALU_ADD:  // add
							(opcode == `OPCODE_R && funct3 == 3'b000 && funct7[5])					? `ALU_SUB:  // sub
							(opcode == `OPCODE_I && funct3 == 3'b000)										? `ALU_ADD:  // addi
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b010) 	? `ALU_SLT:  // slt, slti
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b011) 	? `ALU_SLTU: // sltu, sltiu
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b100) 	? `ALU_XOR:  // xor, xori
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b110) 	? `ALU_OR:   // or, ori
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b111) 	? `ALU_AND:  // and, andi
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b001) 	? `ALU_SLL:  // sll, slli
							((opcode == `OPCODE_R || opcode == `OPCODE_I) 
								&& funct3 == 3'b101 && !funct7[5]) 											? `ALU_SRL:  // srl, srli
							((opcode == `OPCODE_R || opcode == `OPCODE_I) 
								&& funct3 == 3'b101 && funct7[5]) 											? `ALU_SRA:  // sra, srai
							((opcode == `OPCODE_B) && funct3 == 3'b000) 									? `ALU_XOR:	 // beq
							((opcode == `OPCODE_B) && funct3 == 3'b001) 									? `ALU_XOR:	 // bne
							((opcode == `OPCODE_B) && funct3 == 3'b100) 									? `ALU_SLT:	 // blt
							((opcode == `OPCODE_B) && funct3 == 3'b101) 									? `ALU_SLT:	 // bge
							((opcode == `OPCODE_B) && funct3 == 3'b110) 									? `ALU_SLTU: // bltu
							((opcode == `OPCODE_B) && funct3 == 3'b111) 									? `ALU_SLTU: // bgeu
							(opcode == `OPCODE_I_JALR) 														? `ALU_ADD:  // jalr
							(opcode == `OPCODE_I_LOAD) 														? `ALU_ADD:
							(opcode == `OPCODE_S)																? `ALU_ADD:
							`ALU_NONE;

	// 2nd alu operand source
	assign alu_src =	(opcode == `OPCODE_U_AUIPC) 	? `ALU_SRC_IMM:
							(opcode == `OPCODE_B) 			? `ALU_SRC_RS2:
							(opcode == `OPCODE_I_LOAD) 	? `ALU_SRC_IMM:
							(opcode == `OPCODE_S) 			? `ALU_SRC_IMM:
							(opcode == `OPCODE_I) 			? `ALU_SRC_IMM:
							(opcode == `OPCODE_R) 			? `ALU_SRC_RS2:
							`ALU_SRC_NONE;

	// jump condition
	assign jump_type =	(opcode == `OPCODE_J_JAL) 							? `JUMP_JAL:
								(opcode == `OPCODE_I_JALR) 						? `JUMP_JALR:
								((opcode == `OPCODE_B) && funct3 == 3'b000)  ? `JUMP_IF_0:	// beq
								((opcode == `OPCODE_B) && funct3 == 3'b001)  ? `JUMP_IF_1:	// bne
								((opcode == `OPCODE_B) && funct3 == 3'b100)  ? `JUMP_IF_1:	// blt
								((opcode == `OPCODE_B) && funct3 == 3'b101)  ? `JUMP_IF_0:	// bge
								((opcode == `OPCODE_B) && funct3 == 3'b110)  ? `JUMP_IF_1:	// bltu
								((opcode == `OPCODE_B) && funct3 == 3'b111)  ? `JUMP_IF_0:	// bgeu
								`JUMP_NONE;
	
	// register file rd source
	assign regfile_src = (opcode == `OPCODE_U_LUI) 		? `REG_SRC_ALU:
								(opcode == `OPCODE_U_AUIPC) 	? `REG_SRC_ALU:
								(opcode == `OPCODE_J_JAL) 		? `REG_SRC_PCp4:
								(opcode == `OPCODE_I_JALR) 	? `REG_SRC_PCp4:
								(opcode == `OPCODE_I_LOAD) 	? `REG_SRC_MEM:
								(opcode == `OPCODE_I) 			? `REG_SRC_ALU:
								(opcode == `OPCODE_R) 			? `REG_SRC_ALU:
								`REG_SRC_NONE;
	
	// load operation type
	assign mem_read_type = 	((opcode == `OPCODE_I_LOAD) && funct3 == 3'b000) ? `MEM_RD_BYTE:	// lb
									((opcode == `OPCODE_I_LOAD) && funct3 == 3'b001) ? `MEM_RD_HALF:	// lh
									((opcode == `OPCODE_I_LOAD) && funct3 == 3'b010) ? `MEM_RD_WORD:	// lw
									((opcode == `OPCODE_I_LOAD) && funct3 == 3'b100) ? `MEM_RD_B_U:	// lbu
									((opcode == `OPCODE_I_LOAD) && funct3 == 3'b101) ? `MEM_RD_H_U:	// lhu
									`MEM_RD_NONE;

	// store operation type				
	assign mem_write_mask = 	((opcode == `OPCODE_S) && funct3 == 3'b000) ? `MEM_WR_BYTE:	// sb
										((opcode == `OPCODE_S) && funct3 == 3'b001) ? `MEM_WR_HALF:	// sh
										((opcode == `OPCODE_S) && funct3 == 3'b010) ? `MEM_WR_WORD:	// sw
										`MEM_WR_NONE;
endmodule


//	assign x =  (opcode == `OPCODE_U_LUI) 		? `:
//					(opcode == `OPCODE_U_AUIPC) 	? `:
//					(opcode == `OPCODE_J_JAL) 		? `:
//					(opcode == `OPCODE_I_JALR) 	? `:
//					(opcode == `OPCODE_B) 			? `:
//					(opcode == `OPCODE_I_LOAD) 	? `:
//					(opcode == `OPCODE_S) 			? `:
//					(opcode == `OPCODE_I) 			? `:
//					(opcode == `OPCODE_R) 			? `:
//					`;

//	always @(*) begin
//		if				(opcode == `OPCODE_U_LUI) 		begin
//
//		end else if	(opcode == `OPCODE_U_AUIPC) 	begin
//
//		end else if	(opcode == `OPCODE_J_JAL) 		begin
//
//		end else if	(opcode == `OPCODE_I_JALR) 	begin
//
//		end else if	(opcode == `OPCODE_B) 			begin
//
//		end else if	(opcode == `OPCODE_I_LOAD) 	begin
//
//		end else if	(opcode == `OPCODE_S) 			begin
//
//		end else if	(opcode == `OPCODE_I) 			begin
//
//		end else if	(opcode == `OPCODE_R) 			begin
//
//		end else if	(opcode == `OPCODE_I_FENCE) 	begin
//
//		end else if	(opcode == `OPCODE_I_CSR) 		begin
//
//		end else begin
//
//		end
//	end
