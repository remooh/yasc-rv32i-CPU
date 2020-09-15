`include "defines.v"

module rv32i_cpu
#(
	parameter IMEM_WIDTH = 16,
	parameter DMEM_WIDTH = 16
)
(
	input clk,
	input reset,
	
	// instruction memory
	output [IMEM_WIDTH-1:0] inst_addr,
	input  [31:0] instruction_data,
	
	// data memory
	output [DMEM_WIDTH-1:0] data_addr,
	output [3:0] data_we,
	output [31:0] data_write,
	input  [31:0] data_read

);
//////////////////// wires and registers ////////////////////
	// register storing instruction information
	reg  [31:0] instruction; 

	// decode fields
	wire [6:0] opcode;
	wire [4:0] rd_addr;
	wire [2:0] funct3;
	wire [4:0] rs1_addr;
	wire [4:0] rs2_addr;
	wire [6:0] funct7;
	wire [31:0] immediate;

	// control unit fields
	wire rs1_to_alu1;
	wire rs2_to_alu2;
	wire [3:0] alu_op;
	wire [2:0] jump_type;
	wire [1:0] regfile_src;
	wire [2:0] mem_read_type;
//	wire [3:0] mem_write_mask;
	
	// program counter fields
	reg update_pc;
	wire [31:0] pc_current;
	wire [31:0] pc_plus_4;
	wire [31:0] pc_next;
	
	// register file fields
	wire rd_we;
	wire [4:0] regfile_addr;
	wire [31:0] rd_data;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;

	// alu fields
	wire [31:0] alu_a;
	wire [31:0] alu_b;
	wire [31:0] alu_result;


//////////////////// instantiate modules ////////////////////
	decode _decode(
		//inputs
		.instruction (instruction),
		//outputs
		.opcode (opcode),
		.rd_addr (rd_addr),
		.funct3 (funct3),
		.rs1_addr (rs1_addr),
		.rs2_addr (rs2_addr),
		.funct7 (funct7),
		.inst_type (inst_type),
		.immediate (immediate)
	);
	
	control_unit _control(
		//inputs
		.opcode (opcode),
		.funct3 (funct3),
		.funct7 (funct7),
		//outputs
		.rs1_to_alu1 (rs1_to_alu1),
		.rs2_to_alu2 (rs2_to_alu2),
		.alu_op (alu_op),
		.jump_type (jump_type),
		.regfile_src (regfile_src),
		.mem_read_type (mem_read_type),
		.mem_write_mask (data_we)
	);
	
	program_counter _pc(
		//inputs
		.addr_offset (immediate),
		.alu_result (alu_result),
		.jump_type (jump_type),
		.update_pc (update_pc),
		//outputs
		.pc_current (pc_current),
		.pc_plus_4 (pc_plus_4),
		.pc_next (pc_next)
	);
	
	register_file _regfile(
		//inputs
		.clk (clk),
		.rd_we (rd_we), 
		.rd_addr (regfile_addr),
		.rs1_addr (rs1_addr),
		.rs2_addr (rs2_addr),
		.rd_data (rd_data),
		//outputs
		.rs1_data (rs1_data),
		.rs2_data (rs2_data)
	);
	
	alu _alu(
		//inputs
		.alu_op (alu_op),
		.operand_a (alu_a),
		.operand_b (alu_b),
		//outputs
		.result (alu_result)
	);
	
//////////////////// internal wiring ////////////////////
	
	// register file
	assign regfile_addr =	(regfile_src != `REG_SRC_NONE) 	? rd_addr : {5{1'b0}};

	assign rd_data = 	(regfile_src == `REG_SRC_ALU) 	? alu_result:
				(regfile_src == `REG_SRC_MEM) 	? data_read:
				(regfile_src == `REG_SRC_IMM) 	? immediate:
				(regfile_src == `REG_SRC_PCP4) 	? pc_plus_4:
				{32{1'b0}};

	// alu 1st operand
	assign alu_a = 	(rs1_to_alu1 == `ALU1_SRC_RS1) ? rs1_data : pc_current;

	// alu 2nd operand
	assign alu_b = 	(rs2_to_alu2 == `ALU2_SRC_RS2) ? rs2_data : immediate;


//////////////////// cpu finite state machine ////////////////////
	localparam IDLE	= 0;
	localparam FETCH = 0;
	localparam DECODE = 0;
	localparam EXECUTE = 0;
	localparam MEMORY_ACCESS = 0;
	localparam MEMORY_ACCESS_WAIT = 0;
	localparam WRITEBACK = 0;
	
	reg [2:0] current_state, next_state;
	
	always @(*) begin
		next_state = current_state; // explicitly stay in current state if not told otherwise
		
		case(current_state)
			IDLE: begin
			end

			FETCH: begin
				// PC
				update_pc = 1'b0;
				
				// fetch instruction
				instruction = instruction_data;

				next_state = DECODE;
			end

			DECODE: begin
				
				next_state = EXECUTE;
			end

		endcase
	end
	
	always @(posedge clk) begin
		current_state <= next_state;

		if (!reset) begin   
			current_state <= IDLE;
		end
	end

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
