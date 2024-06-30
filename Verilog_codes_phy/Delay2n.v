`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIITD
// Engineer:Neelam Singh
// Module Name :Top_Reconfig-#PHY
// Design Name: OFDM
// Project Name: Reconfigurable PHY
// Target Devices:ZYNQ-7 ZC706 Evaluation Board (xc7z045ffg900-2)
// Module Name:    Delay64 

//
//////////////////////////////////////////////////////////////////////////////////
module Delay2n #(parameter WIDTH = 32, D = 64, B = 6)(
	input  clk, rst, ena,
	input  [WIDTH-1:0] dat_in,	
	output [WIDTH-1:0] dat_out
);
reg [WIDTH-1:0] dat_ram [D-1:0];
reg [B-1:0]  adr_cnt;
reg 			 dat_val;
assign 	  dat_out  = (dat_val)? dat_ram[adr_cnt]: 0;
//integer 	cnt;
always@ (posedge clk)begin
	if(rst) begin
			adr_cnt <= 0;
			//for (cnt = 0; cnt < D; cnt = cnt+1) dat_ram[cnt] <= 0;
		end
	else if (ena) begin
			dat_ram[adr_cnt]	<= dat_in;
			adr_cnt 				<= adr_cnt +1'b1;
		end		
end
always@ (posedge clk)begin
	if(rst) 								dat_val <= 1'b0;
	else if (adr_cnt == {B{1'b1}}) dat_val <= 1'b1;
end
endmodule
