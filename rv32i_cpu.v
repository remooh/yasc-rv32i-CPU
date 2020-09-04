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
	input  [31:0] instruction,
	
	// data memory
	output [DMEM_WIDTH-1:0] data_addr,
	output [3:0] data_we,
	output [31:0] data_write,
	input  [31:0] data_read

);

	// cpu finite state machine
	localparam IDLE             = 0;
	
	reg [2:0] current_state, next_state;
	
	always @(*) begin
		next_state = current_state; // explicitly stay in current state if not told otherwise
		
		case(current_state)
			IDLE: begin
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
