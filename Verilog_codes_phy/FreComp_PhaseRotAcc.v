`timescale 1ns / 1ps
// Company: IIITD
// Engineer:Neelam Singh
// Module Name :Top_Reconfig-#PHY
// Design Name: OFDM
// Project Name: Reconfigurable PHY
// Target Devices:ZYNQ-7 ZC706 Evaluation Board (xc7z045ffg900-2)
// Module Name:    FreComp_PhaseRotAcc 

//
//////////////////////////////////////////////////////////////////////////////////
module FreComp_PhaseRotAcc(
    input clk,
    input rst,
    input ld,
    input acc,
	 input ce,
	 input [15:0] phase_ld,
    input [15:0] phase_in,
    output [15:0] phase_out,
    output reg phase_out_rdy
    );
parameter L 			= 6;  			//log2(64)
parameter Pi 			= 16'h648B;	//pi in 3Q16 (format 3.13)
parameter ifre_off	= 16'h096D;	   //pre integer frequency offset in 3Q16 (format 3.13) = -2*pi*n_off / NFFT; 
												//n_off is chosen -12 to limit integer frequency offset  -14 : 18 normalized frequency offset

//reg phase_out_rdy;	 

reg signed [15:0] phase_in_lat;
reg signed [15:0] phase_rot;

wire signed [15:0] phase_rot_acc  = phase_rot + phase_in_lat;
wire signed [15:0] phase_rot_adj1 = ($signed(phase_rot_acc >>> 1) - $signed(Pi)) <<1;
wire signed [15:0] phase_rot_adj2 = ($signed(phase_rot_acc >>> 1) + $signed(Pi)) <<1;
wire acc_gt_pi = ($signed(phase_rot_acc) > $signed(Pi));
wire acc_lt_pi = ($signed(phase_rot_acc) < $signed(-Pi));


always @(posedge clk)
begin
	if(rst)				phase_in_lat <= 16'd0; 
	else if (ld) 		phase_in_lat <= $signed(ifre_off) + ($signed(phase_in) >>> L);		
end

always @(posedge clk)
begin
	if(rst)	begin
			phase_rot 		<= 16'd0; 
			phase_out_rdy  <= 1'b0;
			end
	else if (ce) begin
		if (ld)		begin
			phase_rot 		<= $signed(phase_ld); 		
			phase_out_rdy  <= 1'b1;			
			end
		else if (acc) begin
			if 		(acc_gt_pi) 	phase_rot <= phase_rot_adj1; 
			else if 	(acc_lt_pi) 	phase_rot <= phase_rot_adj2; 
			else							phase_rot <= phase_rot_acc;	
			phase_out_rdy  <= 1'b1;			
			end
		else 	phase_out_rdy  <= 1'b0;
	end
end

assign phase_out = phase_rot;

endmodule
