module n_bit_multiplier #(
	parameter N = 32
)
(
	output [2*N-1:0] product,
	input [N-1:0] a, b
);

logic [N-1:0] temp [3*(N-1):0];
logic [N-2:0] cout;
logic [N-2:0] ov;

genvar i;
generate
	for(i = 0; i < N-1; i = i+1)
	begin :F1
		if (i == 0)
		begin
			assign product[0] = a[0]&b[0];
			assign temp[0] = a&{N{b[0]}};
			assign temp[1] = {1'b0, temp[0][N-1:1]};
			assign temp[2] = a&{N{b[1]}};
			n_bit_adder #(N) D0(temp[3], cout[0], ov[0], temp[2], temp[1], 0);
		end
		else
		begin
			assign product[i] = temp[3*i][0];
			assign temp[3*i+1] = {cout[i-1], temp[3*i][N-1:1]};
			assign temp[3*i+2] = a&{N{b[i+1]}};
			n_bit_adder #(N) D1(temp[3*i+3], cout[i], ov[i], temp[3*i+2], temp[3*i+1], 0);
		end
	end
endgenerate

assign product[2*N-2:N-1] = temp[3*(N-1)];
assign product[2*N-1] = cout[N-2];

endmodule