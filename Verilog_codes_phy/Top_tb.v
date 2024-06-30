`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2017 11:00:26 PM
// Design Name: 
// Module Name: Top_tb

// 
//////////////////////////////////////////////////////////////////////////////////
/// 16'7FFF===0.9 Multiplication
///16'h6666 ==0.8
//16'h599A==0.7 
//16'h4CCD==0.6
module Top_tb(
    );

reg clk=0;
reg clk1=0;
reg start=0;
reg rst=1;
reg highSNR=1'b0;
reg lowSNR=1'b1;
wire [3:0] dat_out;
wire rt_pw;
wire[9:0] funcE;
wire BITS_O;
wire [1:0]DITS_O;
wire[9:0] correctbits;
wire we_o, stb_o, cyc_o;
reg [31:0]channel_mult = 32'd0;
reg [15:0]channel_mult_value=16'h7FFF;

Top T2(  
        .cl05(clk), .RST_Ii(rst),
      //  .cl05_n(~clk),
        .start1(start),//CYC_I, WE_I, STB_I, //ACK_I,
        .RT_PW(rt_pw),
        .highSNR(highSNR),
        .lowSNR(lowSNR),
        .funcE(funcE),
        .BITS_O(BITS_O),
        .DITS_O(DITS_O),
        .correctbits(correctbits),
        .channel_mult_value(channel_mult_value),
        .DAT_O(dat_out),
        .CYC_O(cyc_o), .STB_O(stb_o),
        .WE_O(we_o)
                       
        );   
always #10 	clk 		= ~clk;
always #20 	clk1 		= ~clk1;
        initial     begin
        
            #200    rst        = 1'b0;
            #40    start    =1'b1;
            #100   start   =1'b0;
            
        end
        
        reg [6:0] datout_cnt = 0;     
          
        initial begin    
            forever begin
                @(posedge clk);
                if ((stb_o)&&(cyc_o)&& (we_o) && (datout_cnt != 7'd104)) begin
                
                    datout_cnt = datout_cnt + 1;            
                    end    
                else if (datout_cnt == 7'd104) datout_cnt = 0;
            end
        end
        
        
        reg [1:0] stop_chk = 0;
        
        initial  begin
            forever begin
                @(posedge clk);                
                if (datout_cnt == 7'd104) begin
                    stop_chk = stop_chk+1;
                end
            end
        end
        
        initial begin
            forever begin
            @(posedge clk);
            if (stop_chk==1)    begin
                
                #40000 rst     =1'b1;
                #400    rst  =1'b0;
        
                #40    start   =1'b1;
                #100   start =1'b0;
                        
                $stop;
                end        
            end
        end  
            
        endmodule

