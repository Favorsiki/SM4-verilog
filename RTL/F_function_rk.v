`timescale 1ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company             : 
// Engineer: 			 Favorsiky
// 
// Create Date         : Aug/26/2022
// Module Name:        : F_function_CK
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


module F_function_rk(
	input 			CLK, 				// clock input
	input 			Frk_EN,				// Frk function enable input
	
	input 	[31:0]	X0,					// 32bit data input X0
	input 	[31:0] 	X1,					// 32bit data input X1
	input 	[31:0]	X2,					// 32bit data input X2
	input 	[31:0] 	X3,					// 32bit data input X3
	input 	[31:0] 	CK,					// 32bit round key 
	output 	[31:0]	Y1,					// 32bit data output Y1
	output 	[31:0]	Y2,					// 32bit data output Y2
	output 	[31:0]	Y3,					// 32bit data output Y3
	output 	[31:0]	Y4					// 32bit data output Y4
);

// 	==================================================================
// 	Internal signals
// 	==================================================================
	wire	[31:0] 	wire_xor;			// store the result of X1^X2^X3^CK
	wire	[31:0]	wire_t_func;		// store the result of t(X1^X2^X3^CK)
	wire	[31:0]  wire_L_func;		// store the result of L(t(X1^X2^X3^CK))
	wire	[31:0]	wire_result_Y4;		// store the result of X0^L(t(X1^X2^X3^CK))


// 	==================================================================
// 	Instance of implement
// 	==================================================================
	S_BOX t_sbox1(CLK, wire_xor[31:24], wire_t_func[31:24]);  //S盒模块实例化1。
	S_BOX t_sbox2(CLK, wire_xor[23:16], wire_t_func[23:16]);  //S盒模块实例化2。
	S_BOX t_sbox3(CLK, wire_xor[15:8], wire_t_func[15:8]);    //S盒模块实例化3。
	S_BOX t_sbox4(CLK, wire_xor[7:0], wire_t_func[7:0]);      //S盒模块实例化4。

// 	================================================================================
// 	Equasions
// 	================================================================================

	assign wire_xor =  X1 ^ X2 ^ X3 ^ CK;
	assign wire_L_func = (wire_t_func ^ {wire_t_func[18:0], wire_t_func[31:19]}) ^ {wire_t_func[8:0], wire_t_func[31:9]};	// L function
	assign wire_result_Y4 = X0 ^ wire_L_func;					// F function


	assign Y1 = (Frk_EN == 1'b1) ? X1 : X0;
	assign Y2 = (Frk_EN == 1'b1) ? X2 : X1;
	assign Y3 = (Frk_EN == 1'b1) ? X3 : X2;
	assign Y4 = (Frk_EN == 1'b1) ? wire_result_Y4 : X3;

endmodule
