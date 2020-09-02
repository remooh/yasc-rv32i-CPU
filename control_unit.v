`include "defines.v"

module control_unit
(
	// Input Ports
	input clk,
	input [6:0] opcode,
	input	[2:0] funct3,
	input [6:0] funct7,

	// Output Ports
	output [3:0] alu_op,
	
	output [3:0] mem_write
);

	// alu operation
	assign alu_op = 	(opcode == `OPCODE_R && funct3 == 3'b000 && !funct7[5]) ? 				`ALU_ADD:	// add
							(opcode == `OPCODE_R && funct3 == 3'b000 && funct7[5]) ? 				`ALU_SUB:	// sub
							(opcode == `OPCODE_I && funct3 == 3'b000) ? 									`ALU_ADD:	// addi
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b010) ? 					`ALU_SLT:	// slt, slti
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b011) ? 					`ALU_SLTU:	// sltu, sltiu
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b100) ? 					`ALU_XOR:	// xor, xori
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b110) ? 					`ALU_OR:		// or, ori
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b111) ? 					`ALU_AND:	// and, andi
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b001) ? 					`ALU_SLL:	// sll, slli
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b101 && !funct7[5]) ? 	`ALU_SRL:	// srl, srli
							((opcode == `OPCODE_R || opcode == `OPCODE_I) && funct3 == 3'b101 && funct7[5]) ? 	`ALU_SRA:	// sra, srai
							((opcode == `OPCODE_B) && funct3 == 3'b000) ? `ALU_XOR:	// beq
							((opcode == `OPCODE_B) && funct3 == 3'b001) ? `ALU_XOR:	// bne
							((opcode == `OPCODE_B) && funct3 == 3'b100) ? `ALU_SLT:	// blt
							((opcode == `OPCODE_B) && funct3 == 3'b101) ? `ALU_SLT:	// bge
							((opcode == `OPCODE_B) && funct3 == 3'b110) ? `ALU_SLTU:	// bltu
							((opcode == `OPCODE_B) && funct3 == 3'b111) ? `ALU_SLTU:	// bgeu
							(opcode == `OPCODE_I_JALR) ?	`ALU_ADD:
							(opcode == `OPCODE_I_LOAD) ?	`ALU_ADD:
							(opcode == `OPCODE_S) ? 		`ALU_ADD:
//							(opcode == `) ? `:
//							(opcode == `) ? `:
//							(opcode == `) ? `:
							`ALU_ADD;
							
	assign mem_write = 	((opcode == `OPCODE_S)	&& funct3 == 3'b000) ? 4'b0001:	// sb
								((opcode == `OPCODE_S)	&& funct3 == 3'b001) ? 4'b0011:	// sh
								((opcode == `OPCODE_S)	&& funct3 == 3'b010) ? 4'b1111:	// sw
								4'b0000;
endmodule



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