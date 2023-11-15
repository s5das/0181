`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 胡狼FPGA
// 
// Create Date: 2021/4/27 18:45:36
// Design Name: 
// Module Name: image_size_down
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module image_size_down_without_fifo
                    #(parameter DATA_WIDTH = 16 )                  
                    (					 					
                     input        clk_i,
                     input        rst_i,
					 
                     input [15:0] width_i,
                     input [15:0] height_i,						 
					 
                     input [DATA_WIDTH -1:0] tdata_i,
                     input                   tvalid_i,
                     
                     output [DATA_WIDTH -1:0] tdata_o,
                     output                   tvalid_o
                     );
                     
//-----------pixels in one line----------
reg[15:0] col_cnt;
wire tlast;

assign tlast = tvalid_i && (col_cnt == (width_i - 1));
    
always @(posedge clk_i) begin
  if(rst_i)begin
    col_cnt <= 16'd0;
  end else if(tlast) begin
    col_cnt <= 16'd0;
  end else if(tvalid_i) begin
    col_cnt <= col_cnt + 1;
  end
end

wire col_down_valid;
assign col_down_valid = tvalid_i && col_cnt[0];


//-----------lines in one frame----------   
reg[15:0] row_cnt;
always @(posedge clk_i) begin
  if(rst_i)begin
    row_cnt <= 16'd0;
  end else if(tlast && (row_cnt == (height_i - 1))) begin
    row_cnt <= 16'd0;
  end else if(tlast) begin
    row_cnt <= row_cnt + 1;
  end
end

wire row_down_valid;

//assign row_down_valid = tvalid_i;
assign row_down_valid = tvalid_i && row_cnt[0];




reg[23:0] tdata;
reg       tvalid;
always@(posedge clk_i)begin
  tdata  <= tdata_i;
  tvalid <= col_down_valid & row_down_valid;
end

assign tdata_o  = tdata;
assign tvalid_o = tvalid;

endmodule
