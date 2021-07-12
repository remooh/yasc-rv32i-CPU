module rvfi_wrapper (
	input clock,
	input reset,
	`RVFI_OUTPUTS
);
	// I-MEM
	(* keep *) wire [31:0] inst_addr;
	(* keep *) `rvformal_rand_reg [31:0] instruction_data;

	// D-MEM
	(* keep *) wire [31:0] data_mem_addr;
	(* keep *) wire [3:0]  data_mem_wmask;
	(* keep *) wire [31:0] data_mem_write;
	(* keep *) wire data_mem_w_en;
	(* keep *) `rvformal_rand_reg [31:0] data_mem_read;

	rv32i_cpu # (
		.IMEM_WIDTH(32),
		.DMEM_WIDTH(32)
	) uut (
		.clk(clock),
		.reset(reset),
		.inst_addr(inst_addr),
		.instruction_data(instruction_data),
		.data_mem_addr(data_mem_addr),
		.data_mem_wmask(data_mem_wmask),
		.data_mem_write(data_mem_write),
		.data_mem_w_en(data_mem_w_en),
		.data_mem_read(data_mem_read),

		`RVFI_CONN
	);
endmodule
