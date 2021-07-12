`timescale 1ns / 1ns

module rv32i_cpu_tb();
	reg clk;
	reg reset;
	wire [31:0] inst_addr;
	wire [31:0] inst_data;
	wire [31:0] dmem_addr;
	wire [31:0] dmem_rdata;
	wire [31:0] dmem_wdata;
	wire [3:0] dmem_wmask;
	wire dmem_we;
	
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
	
	instruction_memory _imem(
		.addr(inst_addr[13:2]),
	    	.clk(clk),
	    	.q(inst_data)
	);
	
	data_memory _dmem(
		.clk(clk),
		.we(dmem_we),
		.mem_wmask(dmem_wmask), 
		.data_addr(dmem_addr[14:2]),
		.data_write(dmem_wdata),
		.data_read(dmem_rdata)
	);
	
	always #10 clk = ~clk;
	initial begin
	
		$dumpfile("rv32i_cpu_tb.vcd");
		$dumpvars(0,rv32i_cpu_tb);
		
		reset = 1;
		clk = 0;
		
		#20
		reset = 0;
		
		#10000000
		reset = 1;
		#20
		
		$stop;
	end

endmodule
