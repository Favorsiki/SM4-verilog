`timescale 1ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company             : 
// Engineer: 			 Favorsiky
// 
// Create Date         : Aug/26/2022
// Module Name:        : top_tb
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

module top_tb;

    reg			    clk		            ;
    reg			    reset_n	            ;
    reg             sm4_en              ;
    reg   [127: 0]  data_in             ;
    reg   [127: 0]  user_key_in         ;
    wire            ready_out           ;
    wire  [127: 0]  result_out          ;
	

    always #1  clk = ~clk;
	
	top uut(.CLK(clk), .RST_N(reset_n), .SM4_EN(sm4_en), .IN_DATA(data_in), .IN_KEY(user_key_in), .OUT_DATA(result_out), .OUT_READY(ready_out));
	
	// 68 1e df 34 d2 06 96 5e 86 b3 e9 4f 53 6e 42 46
	initial begin
		$display($time, " : Simulation begin.");
		clk = 0;
		reset_n = 1'b0;
		sm4_en = 1'b0;
		#10
		sm4_en = 1'b1;
		reset_n = 1'b1;
		data_in = 128'h 01_23_45_67_89_ab_cd_ef_fe_dc_ba_98_76_54_32_10;
		user_key_in = 128'h 01_23_45_67_89_ab_cd_ef_fe_dc_ba_98_76_54_32_10;
		#70 if (ready_out == 1'b1) $display($time, " : ciphertext1 : 0x%32h", result_out);
		#10
		reset_n = 1'b0;
		sm4_en = 1'b0;
		#10
		reset_n = 1'b1;
		sm4_en = 1'b1;
		data_in = 128'h 01_23_45_67_89_ab_cd_ef_fe_dc_ba_98_76_54_32_10;
		user_key_in = 128'h 01_23_45_67_89_ab_cd_ef_fe_dc_ba_98_76_54_32_10;
		#70 if (ready_out == 1'b1) $display($time, " : ciphertext2 : 0x%32h", result_out);
		#10
		$stop;
		
	end 


endmodule
