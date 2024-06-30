`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIITD
// Engineer:Neelam Singh
// Module Name :Top_Reconfig-#PHY
// Design Name: OFDM
// Project Name: Reconfigurable PHY
// Target Devices:ZYNQ-7 ZC706 Evaluation Board (xc7z045ffg900-2)
// Module Name:    Delay_reg 

//
//////////////////////////////////////////////////////////////////////////////////
module Delay_reg #(parameter WIDTH = 32)(
	input 	clk,rst,
	input 	ena,
	input 	  [WIDTH - 1:0] dat_in,
	output reg [WIDTH - 1:0] dat_out
    );

always @(posedge clk) begin
	if(rst) 			dat_out <= {WIDTH{1'b0}};
	else if (ena) 	dat_out <= dat_in;	
end

endmodule
