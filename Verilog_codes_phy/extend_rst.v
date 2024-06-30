`timescale 1ns / 1ps
// Company: IIITD
// Engineer:Neelam Singh
// Design Name: OFDM
// Project Name: Reconfigurable PHY
// Target Devices:ZYNQ-7 ZC706 Evaluation Board (xc7z045ffg900-2)
// Module Name: extend_rst

// 
//////////////////////////////////////////////////////////////////////////////////




module extend_rst(
    input wire clk,
    input wire clk_data,
    output wire clk_data_reg
   
);
       
   (* KEEP = "TRUE" *) reg clk_data_prev = 0;

    always@(posedge clk) begin
        clk_data_prev <= clk_data;
    end    
   
    (* KEEP = "TRUE" *) reg [5:0] clk_data_count_reg=0;
    (* KEEP = "TRUE" *) reg [5:0] clk_data_count_next=0;
    
    always@(posedge clk)
    begin
        clk_data_count_reg = clk_data_count_next;
    end
   
    always@(*)
    begin
        clk_data_count_next = clk_data_count_reg;
        if(clk_data_prev==0 && clk_data ==1'b1 && clk_data_count_reg<3)
            clk_data_count_next = 3;
        else if(clk_data_count_reg >=3)
             clk_data_count_next = clk_data_count_reg+1;  
    end

    assign clk_data_reg = (clk_data_count_reg>=3);
   
endmodule