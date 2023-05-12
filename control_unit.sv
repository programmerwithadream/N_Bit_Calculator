module control_unit(
	output [1:0] alu_mux_sig,
	output [1:0] op_input,
	output op_mux_sig,
	output display_mux_sig,
	//write enable weop, wed, we1, we0
	output [3:0] we,
	//reset for other, r1, r0
	output [2:0] reset,
	input [1:0] keyType,
	input bp,
	input clk
);

//registers holding keyType and delay button pressed from the keypad by one cycle
logic bp_reg;
n_bit_register #1 BP(bp_reg, bp, 1, clk, reset[2]);
logic [1:0] keyType_reg;
n_bit_register #2 KT(keyType_reg, keyType, bp, clk, reset[2]);


enum {WAIT, DIGIT1, DIGIT2, DIGIT3, OP1, OP2, EQ, RESET} states = WAIT;

always_ff @ (posedge clk)
begin
	case (states)
	
		WAIT:
		begin
			if (bp_reg)
			begin
				//entered instruction is a digit
				if (keyType_reg == 0)
				begin					
					states <= DIGIT1;
				end
				//entered instruction is an operation or equal
				else if (keyType_reg[1]^keyType_reg[0])
				begin
					states <= OP1;
				end
				else
				begin
					states <= RESET;
				end
			end
		end
		
		DIGIT1:
		begin
			states <= DIGIT2;
		end
		
		DIGIT2:
		begin
			states <= DIGIT3;
		end
		
		DIGIT3:
		begin
			states <= WAIT;
		end
		
		OP1:
		begin
			states <= OP2;
		end
		
		OP2:
		begin
			//instruction is eq
			if (keyType_reg[1] == 1)
			begin				
				states <= EQ;
			end
			//instruction is op
			else
			begin
				states <= WAIT;
			end
		end
		
		EQ:
		begin
			states <= WAIT;
		end
		
		RESET:
		begin
			states <= WAIT;
		end
		
	endcase
end

always_comb
begin
	
	we = 0;
	reset = 0;
	alu_mux_sig = 0;
	op_input = 0;
	op_mux_sig = 0;
	display_mux_sig = 0;
		
	case(states)
	
		WAIT:
		begin
		
		end
		
		DIGIT1:
		begin
			//set alu input to (1010)2
			//set op_mux_sig to 0 for control to takeover op input
			//set op input from controller to (10)2 which is multiply
			//write register 0 on next clock cycle
			alu_mux_sig = 2'b10;
			op_input = 2'b10;
			op_mux_sig = 0;
			we[0] = 1;
		end
		
		DIGIT2:
		begin
			//set alu input to instruction register
			//set op_mux_sig to 0 for control to take over op input
			//set op input from controller to 00 which is addition
			//write to register 0 on the next cycle
			alu_mux_sig = 2'b01;
			op_input = 2'b00;
			op_mux_sig = 0;
			we[0] = 1;
		end
		
		DIGIT3:
		begin
			//write display register from register 0 next cycle
			display_mux_sig = 0;
			we[2] = 1;
		end
		
		OP1:
		begin
			//set alu input to register 1
			//set alu op from last op register in memory
			//write alu result to register 1 on the next cycle
			//write register last op from instruction register next cycle
			alu_mux_sig = 2'b00;
			op_mux_sig = 1;
			we[1] = 1;
			we[3] = 1;
		end
		
		OP2:
		begin
			//set display register to display from register 1
			//reset register 0 on the next cycle
			display_mux_sig = 1;
			we[2] = 1;			
			reset[0] = 1;
		end
		
		EQ:
		begin
			//reset register 1 on the next cycle
			reset[1] = 1;	
		end
		
		RESET:
		begin
			reset = 3'b111;
		end
	
	endcase
end

endmodule