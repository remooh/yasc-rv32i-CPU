`include "../rv32i_cpu/alu.v"
`include "../rv32i_cpu/control_unit.v"
`include "../rv32i_cpu/decode.v"
`include "../rv32i_cpu/defines.v"
`include "../rv32i_cpu/program_counter.v"
`include "../rv32i_cpu/register_file.v"
`include "../rv32i_cpu/rv32i_cpu.v"

`include "../memory/dualport_ram.v"

`timescale 1ns / 1ns

// simulation end && dump memory
`define FINISH_SIM_ADDR 32'hDEAD10CC
`define DUMP_SIZE 32'h4000

module rv32i_cpu_tb();
	reg clk;
	reg reset;
	wire [31:0] inst_addr;
	wire [31:0] inst_data;
	wire [31:0] dmem_addr;
	wire [31:0] data_addr;
	wire [31:0] dmem_rdata;
	wire [31:0] dmem_wdata;
	wire [3:0] dmem_wmask;
	wire dmem_we;

	reg  [31:0] dump_addr;
	reg sim_finished;
	integer file;
	
	rv32i_cpu _rv32i_cpu(
		.clk(clk),
		.reset(reset),
		.inst_addr(inst_addr),
		.instruction_data(inst_data),
		.data_mem_addr(dmem_addr),
		.data_mem_wmask(dmem_wmask),
		.data_mem_write(dmem_wdata),
		.data_mem_w_en(dmem_we),
		.data_mem_read(dmem_rdata)
	);

	dualport_ram _memory(
		.clk(clk),
		.we(dmem_we && !sim_finished && (dmem_addr != 32'hDEAD10CC)),
		.mem_wmask(dmem_wmask),
		.data_addr(data_addr[13:2]),
		.data_write(dmem_wdata),
		.data_read(dmem_rdata),
		.inst_addr(inst_addr[13:2]),
		.instruction(inst_data)
	);

	assign data_addr = sim_finished ? dump_addr : dmem_addr;

	always #5 clk = ~clk;

	initial begin
		//setup testbench
		$dumpfile("rv32i_cpu_tb.vcd");
		$dumpvars(0,rv32i_cpu_tb);

		// file to dump memory content
		file = $fopen("memorydump.hex","w");

		//initial conditions
		sim_finished = 1'b0;
		dump_addr = 32'hFFFFFFFC; // when overflow will start at 0
		reset = 1'b1;
		clk = 1'b0;
		
		#20
		reset = 1'b0;
		
		#100000000
		reset = 1'b1;
		$finish;
	end

	always @ (posedge clk)
	begin

		if (dmem_we && (dmem_addr == `FINISH_SIM_ADDR)) begin
			sim_finished = 1'b1;
			reset = 1'b1;
		end

		if (sim_finished) begin
			//increment address
			dump_addr = dump_addr + 4;

			//dump memory if in range
			if ((dump_addr > 32'h4) && (dump_addr <= `DUMP_SIZE + 4)) begin
				$display("memdump: addr = %h data = %h", data_addr-4, dmem_rdata);
				$fwrite(file, "%h\n", dmem_rdata);
			end

			//exit when finished
			if (dump_addr == `DUMP_SIZE + 4) begin
				$fclose(file);
				$finish;
			end
		end
	end

endmodule
