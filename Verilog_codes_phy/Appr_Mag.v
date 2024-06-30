`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIITD
// Engineer:Neelam Singh
// Design Name: OFDM
// Project Name: Reconfigurable PHY
// Target Devices:ZYNQ-7 ZC706 Evaluation Board (xc7z045ffg900-2)
// Module Name:    Appr_Mag 
 
//
//////////////////////////////////////////////////////////////////////////////////
module Appr_Mag #(parameter WIDTH = 16)(
	input 						clk, rst, ena,
	input 	[WIDTH-1:0] 	real_in, imag_in,
	output	[WIDTH:0]		mag,
	output 						val
	
    );

reg	[WIDTH-1:0] real_abs, imag_abs;
reg	ena_abs;
always@(posedge clk)
begin	
	if(rst) begin
		ena_abs 	<= 1'b0;
		real_abs <= 0;
		imag_abs	<= 0;
		end
	else if(ena) begin
		ena_abs 	<= 1'b1;
		real_abs <= (real_in[WIDTH-1])? (~real_in + 1'b1): real_in;
		imag_abs	<= (imag_in[WIDTH-1])? (~imag_in + 1'b1): imag_in;
		end
	else ena_abs <= 1'b0;
end

assign	mag 	= (real_abs > imag_abs)? (real_abs + (imag_abs>>1)): (imag_abs + (real_abs>>1));
assign  	val	= ena_abs;


endmodule
