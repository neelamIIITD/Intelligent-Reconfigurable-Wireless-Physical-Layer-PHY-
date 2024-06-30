`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIITD
// Engineer:Neelam Singh
// Design Name: OFDM
// Project Name: Reconfigurable PHY
// Target Devices:ZYNQ-7 ZC706 Evaluation Board (xc7z045ffg900-2)
// Module Name:    Comp_Acc_Sum 

//
//////////////////////////////////////////////////////////////////////////////////
module Comp_Acc_Sum #(parameter WIDTH = 23)(
	input 			clk,rst,
	input 			ena,
	input 			[15:0] a_Re, a_Im,
	input				[15:0] a_d_Re, a_d_Im,
	output signed  [WIDTH-1:0] sum_out_Im, sum_out_Re
   );
	
reg [15:0] ia_Re, ia_Im, ia_d_Re, ia_d_Im;
always @(posedge clk)
begin
	if (rst)			begin
		ia_Re 	<= 16'd0;
		ia_Im 	<= 16'd0;
		ia_d_Re	<= 16'd0;
		ia_d_Im	<= 16'd0;
		end
	else if(ena)	begin
		ia_Re 	<= a_Re;
		ia_Im 	<= a_Im;
		ia_d_Re 	<= a_d_Re;
		ia_d_Im 	<= a_d_Im;
		end
end

reg [2*WIDTH-1:0] sum_reg;
always @(posedge clk)
begin
	if (rst)			sum_reg <= {(2*WIDTH){1'b0}};
	else if(ena)	sum_reg <= {sum_out_Im, sum_out_Re};
end

assign sum_out_Re = $signed(sum_reg[WIDTH-1:0]) + $signed({{(WIDTH-16){ia_Re[15]}},ia_Re}) - $signed({{(WIDTH-16){ia_d_Re[15]}},ia_d_Re}); 
assign sum_out_Im = $signed(sum_reg[2*WIDTH-1:WIDTH]) + $signed({{(WIDTH-16){ia_Im[15]}},ia_Im}) - $signed({{(WIDTH-16){ia_d_Im[15]}},ia_d_Im}); 

endmodule
