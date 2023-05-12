
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module N_Bit_Calculator(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,

	//////////// Accelerometer //////////
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,

	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================


//number of bits the calculator operates on
localparam N = 20;
localparam desiredFrequency = 1000.0 / 2.0, divisor = 50_000_000 / desiredFrequency;

//clock signal
logic [31:0] clkCounter;
logic clk;

//outputs of keypad
logic [3:0] rawKey;
logic [1:0] keyType;
logic bp;
logic [3:0] col;
//input of keypad
logic [3:0] row;

//outputs of memory
logic [N-1:0] r0, r1, rd;
logic [3:0] ri;
logic [1:0] last_op;

//outputs of alu note extended_result not actually used in implementation
logic [N-1:0] extended_result,result;

//output of control unit
logic [1:0] alu_mux_sig;
logic [1:0] op_input;
logic op_mux_sig;
logic dis_mux_sig;
logic [3:0] we;
logic [2:0] reset;

//interblock wires
logic [1:0] alu_op;
logic [N-1:0] alu_input;

//=======================================================
//  Structural coding
//=======================================================

//constructing slower clk for calculator
always_ff @(posedge MAX10_CLK1_50)
begin
	if (clkCounter == 0)
	begin
		clkCounter <= divisor;
		clk <= ~clk;
	end
	else
	begin
		clkCounter <= clkCounter - 1;
	end
end

//setting pins for keypad
assign GPIO[25] = col[3];
assign GPIO[23] = col[2];
assign GPIO[21] = col[1];
assign GPIO[19] = col[0];
assign row[0] = GPIO[17];
assign row[1] = GPIO[15];
assign row[2] = GPIO[13];
assign row[3] = GPIO[11];

keypad_scanner K0(rawKey, keyType, bp, col, row, clk);

control_unit C0(alu_mux_sig, op_input, op_mux_sig, dis_mux_sig , we, reset, keyType, bp, clk);

n_bit_memory M0(r0, r1, rd, ri, last_op, result, rawKey, we, bp, dis_mux_sig, reset, clk);

//logic for alu op selection and alu input selection
assign alu_op[1] = op_mux_sig&last_op[1] | ~op_mux_sig&op_input[1];
assign alu_op[0] = op_mux_sig&last_op[0] | ~op_mux_sig&op_input[0];

assign alu_input[0] = ~alu_mux_sig[1]&~alu_mux_sig[0]&r1[0] | ~alu_mux_sig[1]&alu_mux_sig[0]&ri[0];
assign alu_input[1] = ~alu_mux_sig[1]&~alu_mux_sig[0]&r1[1] | ~alu_mux_sig[1]&alu_mux_sig[0]&ri[1] | alu_mux_sig[1]&~alu_mux_sig[0];
assign alu_input[2] = ~alu_mux_sig[1]&~alu_mux_sig[0]&r1[2] | ~alu_mux_sig[1]&alu_mux_sig[0]&ri[2];
assign alu_input[3] = ~alu_mux_sig[1]&~alu_mux_sig[0]&r1[3] | ~alu_mux_sig[1]&alu_mux_sig[0]&ri[3] | alu_mux_sig[1]&~alu_mux_sig[0];

always_comb
begin
	for (int i = 4; i < N; i = i+1)
	begin
		alu_input[i] = ~alu_mux_sig[1]&~alu_mux_sig[0]&r1[i];
	end
end

n_bit_alu #(N) A0(extended_result, result, alu_input, r0, alu_op);

display D0(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, rd);

endmodule
