`include "defines.v"

`ifdef RISCV_FORMAL
`define XLEN 32	// register file width
`define NRET 1	// max number of retired instructions per cycle
`define ILEN 32	// max instruction width
`endif

module rv32i_cpu
#(
	parameter IMEM_WIDTH = 16,
	parameter DMEM_WIDTH = 16
)
(
	input clk,
	input reset,
	
	// instruction memory
	output reg [IMEM_WIDTH-1:0] 	inst_addr,
	input  [31:0] 			instruction_data,
	
	// data memory
	output reg [DMEM_WIDTH-1:0] 	data_mem_addr,
	output reg [3:0] 		data_mem_wmask,
	output reg [31:0] 		data_mem_write,
	input [31:0]			data_mem_read,
	input 				data_mem_valid

`ifdef RISCV_FORMAL
	,
	// Instruction Metadata
	output reg [`NRET         - 1 : 0] rvfi_valid,
	output reg [`NRET *    64 - 1 : 0] rvfi_order,
	output reg [`NRET * `ILEN - 1 : 0] rvfi_insn,
	output reg [`NRET         - 1 : 0] rvfi_trap,
	output reg [`NRET         - 1 : 0] rvfi_halt,
	output reg [`NRET         - 1 : 0] rvfi_intr,
	output reg [`NRET * 2     - 1 : 0] rvfi_mode,
	output reg [`NRET * 2     - 1 : 0] rvfi_ixl,

	// Integer Register Read/Write
	output reg [`NRET *     5 - 1 : 0] rvfi_rs1_addr,
	output reg [`NRET *     5 - 1 : 0] rvfi_rs2_addr,
	output reg [`NRET * `XLEN - 1 : 0] rvfi_rs1_rdata,
	output reg [`NRET * `XLEN - 1 : 0] rvfi_rs2_rdata,
	output reg [`NRET *     5 - 1 : 0] rvfi_rs1_addr,
	output reg [`NRET *     5 - 1 : 0] rvfi_rs2_addr,
	output reg [`NRET * `XLEN - 1 : 0] rvfi_rs1_rdata,
	output reg [`NRET * `XLEN - 1 : 0] rvfi_rs2_rdata,
	output reg [`NRET *     5 - 1 : 0] rvfi_rd_addr,
	output reg [`NRET * `XLEN - 1 : 0] rvfi_rd_wdata,

	// Program Counter
	output reg [`NRET * `XLEN - 1 : 0] rvfi_pc_rdata,
	output reg [`NRET * `XLEN - 1 : 0] rvfi_pc_wdata,

	// Memory Access
	output reg [`NRET * `XLEN   - 1 : 0] rvfi_mem_addr,
	output reg [`NRET * `XLEN/8 - 1 : 0] rvfi_mem_rmask,
	output reg [`NRET * `XLEN/8 - 1 : 0] rvfi_mem_wmask,
	output reg [`NRET * `XLEN   - 1 : 0] rvfi_mem_rdata,
	output reg [`NRET * `XLEN   - 1 : 0] rvfi_mem_wdata
`endif


);
//////////////////// wires and registers ////////////////////
	// register storing instruction information
	reg [31:0] instruction; 
	reg [31:0] data; 

	// decode fields
	wire [6:0] opcode;
	wire [4:0] rd_addr;
	wire [2:0] funct3;
	wire [4:0] rs1_addr;
	wire [4:0] rs2_addr;
	wire [6:0] funct7;
	wire [3:0] inst_type;
	wire [31:0] immediate;
	wire opcode_valid;

	// control unit fields
	wire rs1_to_alu1;
	wire rs2_to_alu2;
	wire [3:0] alu_op;
	wire [2:0] jump_type;
	wire [2:0] regfile_src;
	wire [1:0] mem_op;
	wire [2:0] mem_read_type;
	wire [3:0] mem_write_mask;
	wire funct3_valid;
	
	// program counter fields
	reg update_pc;
	wire [31:0] pc_current;
	wire [31:0] pc_plus_4;
	wire [31:0] pc_next;
	
	// register file fields
	reg rd_we;
	wire [4:0] regfile_waddr;
	wire [31:0] rd_data;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;

	// alu fields
	wire [31:0] alu_a;
	wire [31:0] alu_b;
	wire [31:0] alu_result;

	// sign extend read data
	wire data_mem_sign;
	wire [31:0] data_mem_signed;

	// internal
	wire inst_valid;
	reg [3:0] memory_wait;

`ifdef RISCV_FORMAL
	wire [3:0] data_read_mask;
	reg [63:0] rvformal_order;
`endif

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
		.immediate (immediate),
		.opcode_valid (opcode_valid)
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
		.mem_op (mem_op),
		.mem_read_type (mem_read_type),
		.mem_write_mask (mem_write_mask),
		.funct3_valid (funct3_valid)
	);
	
	program_counter _pc(
		//inputs
		.clk (clk),
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
		.rd_addr (regfile_waddr),
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

	// sign extend input data
	assign data_mem_sign = 	(mem_read_type == `MEM_RD_BYTE) ? data[7]:
				(mem_read_type == `MEM_RD_HALF) ? data[7]:
				1'b0;

	assign data_mem_signed =(mem_read_type == `MEM_RD_BYTE)	? {{24{data_mem_sign}}, data[7:0]}:	// lb
				(mem_read_type == `MEM_RD_HALF)	? {{16{data_mem_sign}}, data[15:0]}:	// lh
				(mem_read_type == `MEM_RD_B_U) 	? {{24{1'b0}}, data[7:0]}:		// lbu
				(mem_read_type == `MEM_RD_H_U) 	? {{16{1'b0}}, data[15:0]}:		// lhu
				data;									// lw

	// register file
	assign regfile_waddr =	((regfile_src != `REG_SRC_NONE) && funct3_valid) 	? rd_addr : {5{1'b0}};

	assign rd_data = 	(regfile_waddr != 5'b0 && regfile_src == `REG_SRC_ALU) 	? alu_result:
				(regfile_waddr != 5'b0 && regfile_src == `REG_SRC_MEM) 	? data_mem_signed:
				(regfile_waddr != 5'b0 && regfile_src == `REG_SRC_IMM) 	? immediate:
				(regfile_waddr != 5'b0 && regfile_src == `REG_SRC_PCP4)	? pc_plus_4:
				{32{1'b0}};

	// alu 1st operand
	assign alu_a = 	(rs1_to_alu1 == `ALU1_SRC_RS1) ? rs1_data : pc_current;

	// alu 2nd operand
	assign alu_b = 	(rs2_to_alu2 == `ALU2_SRC_RS2) ? rs2_data : immediate;

`ifdef RISCV_FORMAL
	assign data_read_mask =	(mem_read_type == `MEM_RD_BYTE)	? 4'b0001:
				(mem_read_type == `MEM_RD_HALF)	? 4'b0011:
				(mem_read_type == `MEM_RD_B_U) 	? 4'b0001:
				(mem_read_type == `MEM_RD_H_U) 	? 4'b0011:
				(mem_read_type == `MEM_RD_WORD)	? 4'b1111:
				4'b0000;
`endif

//////////////////// cpu finite state machine ////////////////////
	localparam IDLE	= 0;
	localparam FETCH = 1;
	localparam DECODE = 2;
	localparam EXECUTE = 3;
	localparam MEMORY_WAIT = 4;
	localparam WRITE_BACK = 5;

	localparam MAX_WAIT = 3;
	
	reg [3:0] current_state, next_state;
	initial current_state = IDLE;
	initial next_state = IDLE;
	
	always @(*) begin
		next_state = current_state; // explicitly stay in current state if not told otherwise
		
		// default assignements
		memory_wait = 0;	// memory access wait
		rd_we = 1'b0;		// regfile write enable
		update_pc = 1'b0;	// update program counter

`ifdef RISCV_FORMAL
		rvfi_valid <= 1'b0;
`endif

		case(current_state)
			IDLE: begin
				next_state = FETCH;
			end

			FETCH: begin
				next_state = DECODE;

				
				// fetch instruction
				instruction = instruction_data;

			end

			DECODE: begin
				next_state = EXECUTE;
			end

			EXECUTE: begin
				next_state = WRITE_BACK;

				data_mem_addr = 32'b0;
				data_mem_write = 32'b0;
				data_mem_wmask = 4'b0;

				if(mem_op != `MEM_OP_NONE) begin
					data_mem_addr = alu_result;
				end
				if(mem_op == `MEM_OP_LOAD) begin
					next_state = MEMORY_WAIT;
				end else if(mem_op == `MEM_OP_STORE) begin
					data_mem_write = rs2_data;
					data_mem_wmask = mem_write_mask;
				end
			end

			MEMORY_WAIT: begin
//				next_state = MEMORY_WAIT;
//				if(data_mem_valid)
//					next_state = WRITE_BACK;
//				else
//					memory_wait = memory_wait + 4'h1;
				next_state = WRITE_BACK;
			end

			WRITE_BACK: begin
				next_state = FETCH;

				inst_addr = pc_next;

				// regfile write enable
				rd_we = 1'b1;

				// update program counter
				update_pc = 1'b1;

				if(mem_op == `MEM_OP_LOAD) begin
					data = data_mem_read;
				end
`ifdef RISCV_FORMAL
				// Instruction Metadata
				rvfi_valid = 1'b1;
				rvfi_order = rvformal_order;
				rvfi_insn = instruction;
				rvfi_trap = 1'b0;
				if(!opcode_valid || (mem_op != `MEM_OP_NONE && alu_result[1:0] != 2'b00))
					rvfi_trap = 1'b1;
				rvfi_halt = 1'b0;
				rvfi_intr = 1'b0;
				rvfi_mode = 2'b11; // current privilege level: Machine mode (level 3)
				rvfi_ixl = 2'b01; // current machine XLEN (MXL): 1 (32 bit)

				// Integer Register Read/Write
				rvfi_rs1_addr = rs1_addr;
				rvfi_rs2_addr = rs2_addr;
				rvfi_rs1_rdata = rs1_data;
				rvfi_rs2_rdata = rs2_data;
				rvfi_rd_addr = regfile_waddr;
				rvfi_rd_wdata = rd_data;

				// Program Counter
				rvfi_pc_rdata = pc_current;
				rvfi_pc_wdata = inst_addr;

				// Memory Access
				rvfi_mem_addr = data_mem_addr;
				rvfi_mem_rmask = data_read_mask;
				rvfi_mem_wmask = data_mem_wmask;
				rvfi_mem_rdata = data_mem_signed;
				rvfi_mem_wdata = data_mem_write;
`endif
			end

		endcase
	end
	
	always @(posedge clk) begin
		current_state <= next_state;

		if (reset) begin   
			current_state <= IDLE;
`ifdef RISCV_FORMAL
			rvformal_order <= {`NRET*64{1'b0}};
`endif
		end

`ifdef RISCV_FORMAL
		if(current_state == FETCH) begin
			rvformal_order <= rvformal_order + (`NRET*64)'h1;
		end
`endif
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
