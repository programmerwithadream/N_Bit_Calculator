module keypad_scanner(
	output [3:0] rawKey,
	output [1:0] keyType,
	output bp,
	output [3:0] col,
	input [3:0] row,
	input clk
);

logic [31:0] counter;
logic [3:0] onehot;
logic [1:0] columnNumber;

logic [2:0] bpCounter;



always_ff @(posedge clk)
begin
	if (bpCounter != 0)
	begin
		if (bpCounter != 3'b111 | row == 4'b1111)
		begin
			bpCounter <= bpCounter + 1;
			bp <= 0;
		end
	end
	else
	begin
		//increment only if rows are all high
		if (row == 4'b1111)
		begin
			columnNumber <= columnNumber + 1;
			
			case (columnNumber)
			0: onehot <= 4'b0111;
			1: onehot <= 4'b1011;
			2: onehot <= 4'b1101;
			3: onehot <= 4'b1110;
			endcase
		end
		else
		begin
			//button just pressed
			bp <= 1;
			bpCounter <= bpCounter + 1;
		end
	end
end 

assign col = onehot;

always_comb begin
	if (row != 4'b1111)
	begin
		
		case (columnNumber)
		
			0:
			begin
				if (row[0] == 0)
				begin
					rawKey = 14;
				end
				else if (row[1] == 0)
				begin
					rawKey = 7;
				end
				else if (row[2] == 0)
				begin
					rawKey = 4;
				end
				else
				begin
					rawKey = 1;
				end
			end
			
			3:
			begin
				if (row[0] == 0)
				begin
					rawKey = 0;
				end
				else if (row[1] == 0)
				begin
					rawKey = 8;
				end
				else if (row[2] == 0)
				begin
					rawKey = 5;
				end
				else
				begin
					rawKey = 2;
				end
			end
			
			2:
			begin
				if (row[0] == 0)
				begin
					rawKey = 15;
				end
				else if (row[1] == 0)
				begin
					rawKey = 9;
				end
				else if (row[2] == 0)
				begin
					rawKey = 6;
				end
				else
				begin
					rawKey = 3;
				end
			end
			
			1:
			begin
				if (row[0] == 0)
				begin
					rawKey = 13;
				end
				else if (row[1] == 0)
				begin
					rawKey = 12;
				end
				else if (row[2] == 0)
				begin
					rawKey = 11;
				end
				else
				begin
					rawKey = 10;
				end
			end
			
		endcase
		
	end
	else
	begin
		rawKey = 0;
	end
	
end

assign keyType[1] = rawKey[3]&rawKey[2]&rawKey[1];
assign keyType[0] = rawKey[3]&rawKey[2]&~rawKey[1] | rawKey[3]&rawKey[1]&rawKey[0] | rawKey[3]&~rawKey[2]&rawKey[1];

endmodule