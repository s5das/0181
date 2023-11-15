`timescale 1ns / 1ns

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


module image_size_down
#(parameter DATA_WIDTH = 16 )                  
(					 					
 input                        clk_i               ,
 input                        rst_i               ,

 input [15:0]                 width_i             ,
 input [15:0]                 height_i            ,						 

 input [DATA_WIDTH -1'b1:0]   tdata_i             ,
 input                        tvalid_i            ,
 
 output [DATA_WIDTH -1'b1:0]  tdata_o             ,
 output                       tvalid_o
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

wire          rd_trig;
wire          almost_full;
reg           almost_full_1d;
reg   [11:0]  x_cnt;
reg           t_vaild;

always @(posedge clk_i) begin
    if(rst_i)
      almost_full_1d<=1'd0;
    else
      almost_full_1d<=almost_full;
end

assign  rd_trig =  almost_full&(~almost_full_1d);


// assign tdata_o  = tdata;
// assign tvalid_o = tvalid;



always @(posedge clk_i) begin
    if(rst_i)
      x_cnt<=12'd0;
    else  if(rd_trig==1'd1||t_vaild==1'd1)
      x_cnt<=x_cnt+1'd1;
    else
      x_cnt<=12'd0;
end

always @(posedge clk_i) begin
    if(rst_i)
      t_vaild<=1'd0;
    else  if(rd_trig==1'd1)
      t_vaild<=1'd1;
    else  if(x_cnt==width_i[15:1]-1'd1)
      t_vaild<=1'd0;
end

assign    tvalid_o  = t_vaild|rd_trig;
size_down_fifo  size_down_fifo
 (
  .wr_data        (  tdata        ),
  .wr_en          (  tvalid       ),
  .wr_clk         (  clk_i        ),
  .wr_rst         (  rst_i        ),
  .full           (               ),
  .almost_full    (  almost_full  ),
  .rd_data        (  tdata_o      ),
  .rd_en          (  tvalid_o     ),
  .rd_clk         (  clk_i        ),
  .rd_rst         (  rst_i        ),
  .empty          (               ),
  .almost_empty   (               )
);

endmodule
