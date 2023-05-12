module n_bit_memory #(
	parameter N = 32
)
(
	output [N-1:0] r0, r1, rd,
	output [3:0] ri,
	output [1:0] last_op,
	input [N-1:0] r_in,
	input [3:0] rawKey,
	//write enable for register 0, 1, display, last_op
	input [3:0] we,
	//bp will serve as write enable for instruction
	input bp,
	//mux for choosing r0 or r1 when writing rd, 0 for r0, 1 for r1
	input dis_mux_sig,
	input [2:0] reset,
	input clk
);

n_bit_register #(N) R0(r0, r_in, we[0], clk, reset[0]);
n_bit_register #(N) R1(r1, r_in, we[1], clk, reset[1]);

logic [N-1:0] rd_result;
assign rd_result = {N{~dis_mux_sig}}&r0 | {N{dis_mux_sig}}&r1;

n_bit_register #(N) RD(rd, rd_result, we[2], clk, reset[2]);
n_bit_register #4 RI(ri, rawKey, bp, clk, reset[2]);

//combinational circuit for last op input
logic [1:0] last_op_in;
assign last_op_in[1] = ~ri[1];
assign last_op_in[0] = ri[0];

n_bit_register #2 LO(last_op, last_op_in, we[3], clk, reset[2]);

endmodule