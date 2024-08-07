`timescale 1ns / 1ps
// Company: IIITD
// Engineer:Neelam Singh
// Module Name :Top_Reconfig-#PHY
// Design Name: OFDM
// Project Name: Reconfigurable PHY
// Target Devices:ZYNQ-7 ZC706 Evaluation Board (xc7z045ffg900-2)
//
//////////////////////////////////////////////////////////////////////////////////
module IFFT_Mod(
	input 			CLK_I, RST_I,
	input [31:0] 	DAT_I,
	input 			CYC_I, WE_I, STB_I, 
	output			ACK_O,
	
	output reg [31:0]	DAT_O,
	output reg			CYC_O, STB_O,
	output				WE_O,
	input					ACK_I	
    );
reg [31:0]	idat;
//reg [31:0]  odat;
reg			ival;
reg 			icyc;
wire 			out_halt, ena;
wire			datout_ack;
reg			process_done;	// assert when IFFT's procees has done and begin tranmitting data symbol.
//reg [5:0] 	d_cnt;			//delay counter to delay generating the preamble in order to wait for IFFT computation

wire  		s_dat_val, s_dat_rdy;
wire			m_dat_val, m_dat_rdy, m_dat_tlast;
wire 	[7:0]	m_index;
wire 			event_status_channel_halt, event_data_in_channel_halt,event_data_out_channel_halt;
wire			aresetn;
//wire			frame_start;
wire	[31:0] fft_datout;

assign 	out_halt   = STB_O & (~ACK_I);
assign 	datout_ack = STB_O & ACK_I;
assign 	ena 		= CYC_I & STB_I & WE_I;
assign 	ACK_O 	= ena & (~out_halt) & (s_dat_rdy) ;
//assign 	ACK_O 	= ena & (~out_halt) & (m_dat_val) ; // changed by Neelam

	 
always @(posedge CLK_I) begin
	if(RST_I) 			idat<= 32'd0;
	else if(ACK_O) 	idat <= DAT_I;
end
always @(posedge CLK_I) begin
	if(RST_I) 		ival <= 1'b0;
	else if(ena)	ival <= 1'b1;
	else				ival <= 1'b0;
end

always @(posedge CLK_I)
begin
	if(RST_I)		icyc <= 1'b0;		
	else				icyc <= CYC_I;	
end
always @(posedge CLK_I)
begin
	if(RST_I)													CYC_O <= 1'b0;		
	else if(CYC_I &(~icyc))									CYC_O <= 1'b1;	
	else if((~CYC_I) &(~m_dat_val) &	process_done)	CYC_O <= 1'b0;
end

always @(posedge CLK_I)
begin
	if(RST_I)									process_done <= 1'b0;		
	else if(CYC_I &(~icyc))					process_done <= 1'b0;	
	else if(m_dat_val)						process_done <= 1'b1;
end

always @(posedge CLK_I)
begin
	if(RST_I)									DAT_O <= 32'd0; 	
	else if (m_dat_rdy & (~out_halt))	DAT_O <= fft_datout;		
end
always @(posedge CLK_I)
begin
	if(RST_I)									STB_O <= 1'b0; 	
	else if (m_dat_rdy & (~out_halt))	STB_O <= m_dat_val;	
end
assign	WE_O			= STB_O;


assign		aresetn 	= ~RST_I;
assign   	s_dat_val	= ival & (~out_halt);
assign		m_dat_rdy 	= ~out_halt;

IFFT IFFT_Ins(
	.aclk(CLK_I), 											// input aclk
	//.aclken(aclken), 									// input aclken
	.aresetn(aresetn), 	
	//.s_axis_config_tdata(16'b0101010000010000),								// input aresetn
	.s_axis_config_tdata(16'h3610), 
	// input [23 : 0] s_axis_config_tdata: [14:9] scale; [8]fwd_inv; [5:0]: cp_len
	// scale: shift right 6 bits : 0, 1, 2, 3, inv = 0 
																// config_tdata = 0000 0011 0110 0001 0000
// input [23 : 0] s_axis_config_tdata: [14:9] scale; [8]fwd_inv=0; pad(00)+[5:0]: cp_len=010000
 // pad(000)+scale: shift right 6 bits : 0, 1, 2, 3, inv = 0 
 // config_tdata = 000,0 0,01,1 0,11,0 ,0001 0000
 // cyclic prefix -> on, run time configuration off-> off, data point->64
 //mode selection-> automatic, order -> natural,
	.s_axis_config_tvalid(1'b1), 						// input s_axis_config_tvalid
	.s_axis_config_tready(), 							// ouput s_axis_config_tready
	.s_axis_data_tdata(idat), 							// input [31 : 0] s_axis_data_tdata
	.s_axis_data_tvalid(s_dat_val),					// input s_axis_data_tvalid
	.s_axis_data_tready(s_dat_rdy), 					// ouput s_axis_data_tready
	.s_axis_data_tlast(1'b0), 							// input s_axis_data_tlast
	.m_axis_data_tdata(fft_datout), 					// ouput [31 : 0] m_axis_data_tdata
	.m_axis_data_tvalid(m_dat_val), 					// ouput m_axis_data_tvalid
	.m_axis_data_tready(m_dat_rdy), 					// input m_axis_data_tready
	.m_axis_data_tlast(m_dat_tlast),					// ouput m_axis_data_tlast
	.event_frame_started(event_frame_started), 	// ouput event_frame_started
	.event_tlast_unexpected(), 						// ouput event_tlast_unexpected
	.event_tlast_missing(), 							// ouput event_tlast_missing
	.event_status_channel_halt(event_status_channel_halt), // ouput event_status_channel_halt
	.event_data_in_channel_halt(event_data_in_channel_halt), // ouput event_data_in_channel_halt
	.event_data_out_channel_halt(event_data_out_channel_halt)); // ouput event_data_out_channel_halt
endmodule
	