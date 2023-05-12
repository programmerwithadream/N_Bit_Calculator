//op=00 => addition, op = 01 => subtraction, op=10 => multiplication, op=11 => division
module n_bit_alu #(
	parameter N = 32
)
(
	output [N-1:0] extended_result, result,
	input [N-1:0] a, b,
	input [1:0] op
);

logic [N-1:0] sum, difference, quotient;
logic [2*N-1:0] product;
logic sumcout, sumov,  diffsign, diffov;

n_bit_adder #(N) D0(sum, sumcout, sumov, a, b, 0);
n_bit_subtractor #(N) D1(difference, diffsign, diffov, a, b);
n_bit_multiplier #(N) D2(product, a, b);
n_bit_divider #(N) D3(quotient, a, b);

//extended_result stores the extra bits from the multiplication but isn't used for the calculator
assign extended_result = {N{op[1]&~op[0]}}&product[2*N-1:N];
assign result = {N{~op[1]&~op[0]}}&sum | {N{~op[1]&op[0]}}&difference | {N{op[1]&~op[0]}}&product | {N{op[1]&op[0]}}&quotient;

endmodule