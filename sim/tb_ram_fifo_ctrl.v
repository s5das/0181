`timescale 1ps/1ps
module tb_ram_fifo_ctrl();

wire GRS_N;

GTP_GRS GRS_INST (

.GRS_N(1'b1)

);

reg clk;
reg rstn;
initial begin
   clk <= 1'b0;
   rstn<= 1'b0;
   #10;
   rstn<= 1'b1;
end
always #10 clk <= ~clk;


wire     [17:0]       input_x_scale       ;
wire     [17:0]       input_y_scale       ;
wire     [17:0]       output_x_scale      ;
wire     [17:0]       output_y_scale      ;
wire     [9:0]        x_scale             ;
wire     [9:0]        y_scale             ;
wire                  row_vaild           ;
wire     [3:0]        ram_select          ;
wire     [15:0]       out_data            ;
wire     [10:0]       out_addr            ;
wire                  tran_done           ;
reg     [15:0]        in_data             ;
wire                  rd_en               ;
wire                  wr_req              ;


reg      [10:0]       cnt_col             ;
reg      [10:0]       cnt_row             ;

parameter   H_NUM =  8'd200;
assign y_scale = 10'b110000000;
assign x_scale = 10'b110000000;

always @(posedge clk or negedge rstn) begin
   if(!rstn)
      in_data     <=    16'd1;
   else if(rd_en==1'b1) begin
      in_data     <=    in_data+1'd1;
      if(in_data==16'd639)
         in_data     <=    16'd1;
   end
end


ram_fifo_ctrl  ram_fifo_ctrl_inst(
        .clk                 (            clk                  ),
        .rstn                (            rstn                 ),
        .x_scale             (            x_scale              ),//行方向缩放倍数 2_8
        .y_scale             (            y_scale              ),//场方向缩放倍数 2_8
        .row_vaild           (            row_vaild            ),//当前数据有效 高电平有效
        .ram_select          (            ram_select           ),//0001 0010 0100 1000
        .dst_row             (            cnt_row              ),
        .out_data            (            out_data             ),
        .out_addr            (            out_addr             ),
        .tran_done           (            tran_done            ),//传输完成
        .fifo_row_rdy        (            1'b1                 ),
        .in_data             (            in_data              ),
        .rd_en               (            rd_en                ),
        .wr_req              (            wr_req               ) //一行数据缩放完成
);

reg     [1:0]   state;
parameter   INIT  =  2'd0,
            IDLE  =  2'd1,
            START =  2'd2;

reg      wr_req_reg;
assign   wr_req = (state==IDLE)?1'd1:1'd0;

always @(posedge clk or negedge rstn) begin
   if(!rstn)
      state     <=    INIT;
   else begin
      case (state)
         INIT: begin
            if(rstn==1'b1)
               state<=IDLE;
         end
         IDLE: begin
            if(tran_done==1'd1)
               state <= START;
         end
         START:   begin
            if(cnt_col==H_NUM-1'd1)
               state <= IDLE;
         end 
 
      endcase
   end
end

always @(posedge clk or negedge rstn) begin
   if(!rstn)
      cnt_col     <=    11'd0;
   else if(state==START) 
      cnt_col     <=    cnt_col+1'd1;
   else if(state==IDLE)
      cnt_col     <=    11'd0;
end

always @(posedge clk or negedge rstn) begin
   if(!rstn)
      cnt_row     <=    11'd1;
   else if(cnt_col==H_NUM-1'd1) 
      cnt_row     <=    cnt_row+1'd1;
   else
      cnt_row     <=    cnt_row;
end


endmodule