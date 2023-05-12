module n_bit_divider #(
	parameter N = 32
)
(
	output [N-1:0] quotient,
	input [N-1:0] a, b
);

logic [N-1:0] a_comp, b_comp;

n_bit_twos_comp #(N) AC(a_comp, a);
n_bit_twos_comp #(N) BC(b_comp, b);

//4 arrays of sign and ov, each pair for when a > 0 and b > 0,
//a > 0 and b < 0, a < 0 and b > 0, and a < 0 and b < 0 in that order
logic [N-1:0] sign [3:0];
logic [N-1:0] ov [3:0];
logic [N-1:0] temp_quotient [3:0];

genvar j;
generate
	for(j = 0; j < N; j = j+1)
	begin :F
		logic [j:0] temp [3:0];
		logic [j:0] tempsubb [3:0];
	end
endgenerate

genvar i, k;
generate
	for(k = 0; k < 4; k = k+1)
	begin :F1
		for(i = 0; i < N; i = i+1)
		begin :F2
			if (i == 0)
			begin
				assign F[0].temp[k] = a[N-1];
				n_bit_subtractor #(N) D0(F[0].tempsubb[k], sign[k][0], ov[k][0], F[0].temp[k], b);
				assign temp_quotient[k][N-1] = ~sign[k][0];
			end
			else
			begin
				assign F[i].temp[k] = {{i{sign[k][i-1]}}&{F[i-1].temp[k]} | {i{~sign[k][i-1]}}&{F[i-1].tempsubb[k]}, a[N-1-i]};
				n_bit_subtractor #(N) D1(F[i].tempsubb[k], sign[k][i], ov[k][i], F[i].temp[k], b);
				assign temp_quotient[k][N-1-i] = ~sign[k][i];
			end
		end
	end
endgenerate

logic [N-1:0] quotient_1_comp, quotient_2_comp;
n_bit_twos_comp #(N) Q1C(quotient_1_comp, quotient[1]);
n_bit_twos_comp #(N) Q2C(quotient_2_comp, quotient[2]);

assign quotient = {N{~(a[N-1] | b[N-1])}}&temp_quotient[0] | {N{(~a[N-1])&b[N-1]}}&quotient_1_comp | {N{a[N-1]&(~b[N-1])}}&quotient_2_comp | {N{a[N-1]&b[N-1]}}&temp_quotient[3];

endmodule