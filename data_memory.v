module data_memory
#(      parameter ADDR_WIDTH = 12)
(
	input clk,
	input we,
	input [3:0] mem_op,
	input [ADDR_WIDTH-1:0] data_addr,
	input [31:0] write_data,
	output reg data_valid,
	output reg [31:0] read_data
);

	////////// ALTERA DUAL PORT RAM //////////

	// memory block adressed by byte
	reg [7:0] data_mem[2**ADDR_WIDTH-1:0];
	
	reg we_a, we_b;
	reg [7:0] data_a, data_b, q_a, q_b;
	reg [ADDR_WIDTH-1:0] addr_a, addr_b;
	
	// initialize
	initial
	begin : INIT
		integer i;
		for(i = 0; i < 8; i=i+1)
			data_mem[i] = 8'h00;
	end
	
	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			data_mem[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= data_mem[addr_a];
		end 
	end 
	
	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			data_mem[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= data_mem[addr_b];
		end 
	end
	
	////////// END ALTERA DUAL PORT RAM //////////
	
	
	////////// MEMORY CONTROLLER STATE MACHINE //////////

	// finite state machine
	localparam IDLE	= 0;
	localparam LOWER 	= 1;
	localparam UPPER 	= 2;
	reg[1:0] current_state, next_state, last_state;
	
	reg [31:0] buffer_write;
	reg [15:0] buffer_read;
	reg [ADDR_WIDTH-1:0]  buffer_addr;

	always @(*) begin
		next_state = current_state;
	
		case(current_state)
			IDLE: begin
				last_state = IDLE;
				next_state = IDLE;
				data_valid = 1'b1;
				
				if(buffer_addr != data_addr) begin
					buffer_addr = data_addr;
					buffer_write = write_data;

					next_state = LOWER;
				end
			end

			LOWER: begin
				next_state = UPPER;
				last_state = LOWER;
				data_valid = 1'b0;
				
				addr_a = buffer_addr;
				we_a = we && mem_op[0];
				data_a = buffer_write[7:0];
				
				addr_b = buffer_addr+1;
				we_b = we && mem_op[1];
				data_b = buffer_write[15:8];
			end
			
			UPPER: begin
				next_state = IDLE;
				last_state = UPPER;
				data_valid = 1'b0;
				
				addr_a = buffer_addr+2;
				we_a = we && mem_op[2];
				data_a = buffer_write[23:16];
				
				addr_b = buffer_addr+3;
				we_b = we && mem_op[3];
				data_b = buffer_write[31:24];
				
				buffer_read[7:0] = q_a;
				buffer_read[15:8] = q_b;
			end
		endcase
	end

	
	always @(*) begin
		if(data_valid) begin
			read_data[7:0] = buffer_read[7:0];
			read_data[15:8] = buffer_read[15:8];
			read_data[23:16] = q_a;
			read_data[31:24] = q_b;
		end
	end
	
	always @(posedge clk) begin
		current_state = next_state;
	end
	////////// MEMORY CONTROLLER STATE MACHINE //////////
endmodule
