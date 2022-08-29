`timescale 1ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company             : 
// Engineer: 			 Favorsiky
// 
// Create Date         : Aug/26/2022
// Module Name:        : top
// Project Name        : SM4_verilog
// Target Devices:     : 
// Tool versions       : 
// Description         : 
//
// Dependencies        : 
//
// Version             : 0.1
// Last Uodate         : Aug/26/2022
// Additional Comments : 
//////////////////////////////////////////////////////////////////////////////////

module top(
	input 			CLK,				// clock input
	input 			RST_N,				// reset input
	
	input 			SM4_EN,				// enable the SM4 module
	input 	[127:0]	IN_DATA,			// 128bit plaintext data input
	input	[127:0] IN_KEY,				// 128bit crypto key data
	
	output	[127:0] OUT_DATA,			// 128bit ciphertext data output
	output 			OUT_READY			// info that the output data is correct
);

// 	==================================================================
// 	Internal signals
// 	==================================================================
	reg 	[31:0]		x1_l;			// X0 input of crypto instance 
	reg 	[31:0]		x2_l;			// X1 input of crypto instance
	reg 	[31:0]		x3_l;			// X2 input of crypto instance
	reg 	[31:0]		x4_l;			// X3 input of crypto instance
	reg 	[31:0]		x1_m;			// Y0 output of crypto instance
	reg 	[31:0]		x2_m;			// Y1 output of crypto instance
	reg 	[31:0]		x3_m;			// Y2 output of crypto instance
	reg 	[31:0]		x4_m;			// Y3 output of crypto instance
	wire 	[31:0]		x1_r;			// middle register of crypto instance
	wire 	[31:0]		x2_r;			// middle register of crypto instance
	wire 	[31:0]		x3_r;			// middle register of crypto instance
	wire 	[31:0]		x4_r;			// middle register of crypto instance
	
	reg 	[31:0]		y1_l;			// X0 input of Roundkey Expansion instance 
	reg 	[31:0]		y2_l;			// X1 input of Roundkey Expansion instance
	reg 	[31:0]		y3_l;			// X2 input of Roundkey Expansion instance
	reg 	[31:0]		y4_l;			// X3 input of Roundkey Expansion instance
	reg 	[31:0]		y1_m;			// Y0 output of Roundkey Expansion instance
	reg 	[31:0]		y2_m;			// Y1 output of Roundkey Expansion instance
	reg 	[31:0]		y3_m;			// Y2 output of Roundkey Expansion instance
	reg 	[31:0]		y4_m;			// Y3 output of Roundkey Expansion instance
	wire 	[31:0]		y1_r;			// middle register of Roundkey Expansion instance
	wire 	[31:0]		y2_r;			// middle register of Roundkey Expansion instance
	wire 	[31:0]		y3_r;			// middle register of Roundkey Expansion instance
	wire 	[31:0]		y4_r;			// middle register of Roundkey Expansion instance
	
	reg 	[5:0] 		round_cnt;		// present of Finit State Machine
	reg 	[5:0] 		next_cnt;		// iterator of round_cnt
	reg		[31:0]		reg_ck;			// The CK of the Roundkey Expansion instance
	reg 				enc_en;			// enable the Frk function and F function 
	reg 				out_ready;		// info that the ciphertext is correct
	

// 	==================================================================
// 	Instance of implement
// 	==================================================================
	F_function_rk rk_exp(.CLK(CLK), .Frk_EN(enc_en), .X0(y1_l), .X1(y2_l), .X2(y3_l), .X3(y4_l), .CK(reg_ck), .Y1(y1_r), .Y2(y2_r), .Y3(y3_r), .Y4(y4_r));
	F_function encrypto(.CLK(CLK), .F_EN(enc_en), .X0(x1_l), .X1(x2_l), .X2(x3_l), .X3(x4_l), .RK(y4_r), .Y1(x1_r), .Y2(x2_r), .Y3(x3_r), .Y4(x4_r));

// 	================================================================================
// 	Equasions
// 	================================================================================	
	
	
	// middle_register_value transfer to input_register_value 
	always @(posedge CLK) begin
		if (SM4_EN == 1'b1) begin
			x1_l = x1_m;
			x2_l = x2_m;
			x3_l = x3_m;
			x4_l = x4_m;
			y1_l = y1_m;
			y2_l = y2_m;
			y3_l = y3_m;
			y4_l = y4_m;
		end 			
	end
	
	// output_register_value transfer to middle_register_value
	always @(negedge CLK) begin
		if (!RST_N) begin 
			x1_m = 32'h00; x2_m = 32'h00; x3_m = 32'h00; x4_m = 32'h00;
			y1_m = 32'h00; y2_m = 32'h00; y3_m = 32'h00; y4_m = 32'h00;
		end 
		else if (enc_en == 1'b1) begin
			x1_m = x1_r;
			x2_m = x2_r;
			x3_m = x3_r;
			x4_m = x4_r;
			y1_m = y1_r;
			y2_m = y2_r;
			y3_m = y3_r;
			y4_m = y4_r;
		end 
		else if (round_cnt == 6'h00) begin
			x1_m = IN_DATA[127:96]; x2_m = IN_DATA[95:64]; 
			x3_m = IN_DATA[63:32];  x4_m = IN_DATA[31:0];
			y1_m = IN_KEY[127:96] ^ 32'hA3B1BAC6;
			y2_m = IN_KEY[95:64] ^ 32'h56AA3350;
			y3_m = IN_KEY[63:32] ^ 32'h677D9197;
			y4_m = IN_KEY[31:0] ^ 32'hB27022DC;
		end 
	end
	
	// FSM implement
	always @(posedge CLK or negedge RST_N) begin
		if (!RST_N) begin								// deal with the reset event
			enc_en = 1'b0;
			next_cnt = 6'h00;
			out_ready = 1'b0;
		end 
		else if (SM4_EN == 1'b1) begin
			round_cnt = next_cnt;
			case (round_cnt)
				6'h00 : begin enc_en = 1'b0; next_cnt = 6'h01; out_ready = 1'b0; end 
				6'h01 : begin enc_en = 1'b1; next_cnt = 6'h02; reg_ck = 32'h00070e15;end
				6'h02 : begin reg_ck = 32'h1c232a31;next_cnt = 6'h03; end
				6'h03 : begin reg_ck = 32'h383f464d;next_cnt = 6'h04; end
				6'h04 : begin reg_ck = 32'h545b6269;next_cnt = 6'h05; end
				6'h05 : begin reg_ck = 32'h70777e85;next_cnt = 6'h06; end
				6'h06 : begin reg_ck = 32'h8c939aa1;next_cnt = 6'h07; end
				6'h07 : begin reg_ck = 32'ha8afb6bd;next_cnt = 6'h08; end
				6'h08 : begin reg_ck = 32'hc4cbd2d9;next_cnt = 6'h09; end
				6'h09 : begin reg_ck = 32'he0e7eef5;next_cnt = 6'h0a; end
				6'h0a : begin reg_ck = 32'hfc030a11;next_cnt = 6'h0b; end
				6'h0b : begin reg_ck = 32'h181f262d;next_cnt = 6'h0c; end
				6'h0c : begin reg_ck = 32'h343b4249;next_cnt = 6'h0d; end
				6'h0d : begin reg_ck = 32'h50575e65;next_cnt = 6'h0e; end
				6'h0e : begin reg_ck = 32'h6c737a81;next_cnt = 6'h0f; end
				6'h0f : begin reg_ck = 32'h888f969d;next_cnt = 6'h10; end
				6'h10 : begin reg_ck = 32'ha4abb2b9;next_cnt = 6'h11; end
				6'h11 : begin reg_ck = 32'hc0c7ced5;next_cnt = 6'h12; end
				6'h12 : begin reg_ck = 32'hdce3eaf1;next_cnt = 6'h13; end
				6'h13 : begin reg_ck = 32'hf8ff060d;next_cnt = 6'h14; end
				6'h14 : begin reg_ck = 32'h141b2229;next_cnt = 6'h15; end
				6'h15 : begin reg_ck = 32'h30373e45;next_cnt = 6'h16; end
				6'h16 : begin reg_ck = 32'h4c535a61;next_cnt = 6'h17; end
				6'h17 : begin reg_ck = 32'h686f767d;next_cnt = 6'h18; end
				6'h18 : begin reg_ck = 32'h848b9299;next_cnt = 6'h19; end
				6'h19 : begin reg_ck = 32'ha0a7aeb5;next_cnt = 6'h1a; end
				6'h1a : begin reg_ck = 32'hbcc3cad1;next_cnt = 6'h1b; end
				6'h1b : begin reg_ck = 32'hd8dfe6ed;next_cnt = 6'h1c; end
				6'h1c : begin reg_ck = 32'hf4fb0209;next_cnt = 6'h1d; end
				6'h1d : begin reg_ck = 32'h10171e25;next_cnt = 6'h1e; end
				6'h1e : begin reg_ck = 32'h2c333a41;next_cnt = 6'h1f; end
				6'h1f : begin reg_ck = 32'h484f565d;next_cnt = 6'h20; end
				6'h20 : begin reg_ck = 32'h646b7279;next_cnt = 6'h21; end
				6'h21 : begin enc_en = 1'b0; out_ready = 1'b1; end 
			endcase
		end 
	end 

	assign OUT_DATA = (out_ready == 1'b1) ? {x4_m, x3_m, x2_m, x1_m} : 128'h0;
	assign OUT_READY = (out_ready == 1'b1) ? 1'b1 : 1'b0;

endmodule
