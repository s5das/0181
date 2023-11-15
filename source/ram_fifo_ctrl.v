//该模块将摄像头数据送入ram中
module ram_fifo_ctrl(
        input                   clk                 ,
        input                   rstn                ,

        input           [17:0]  input_x_scale       ,//目标列数
        input           [17:0]  input_y_scale       ,//目标行数
        input           [17:0]  output_x_scale      ,
        input           [17:0]  output_y_scale      ,
        input           [9:0]   x_scale             ,//行方向缩放倍数 2_8
        input           [9:0]   y_scale             ,//场方向缩放倍数 2_8
        output  wire            row_vaild           ,//当前数据有效 高电平有效
        output  reg     [3:0]   ram_select          ,//0001 0010 0100 1000
        output  wire    [15:0]  out_data            ,
        output  reg     [10:0]  out_addr            ,
        output  wire            tran_done           ,//传输完成
        input   wire    [10:0]  dst_row             ,
        input                   fifo_row_rdy        ,
        input           [15:0]  in_data             ,
        output  wire            rd_en               ,

        input                   wr_req//一行数据缩放完成
);
parameter       H_NUM   =   10'd640;        //列宽
parameter       V_NUM   =   10'd360;        //行高

reg         [10:0]              cnt_row;        //已经写入的行计数
reg         [10:0]              cnt_col;        //已经写入的列计数
wire        [20:0]              vaild_row_p;    //乘法器有效行
reg         [10:0]              vaild_row;      //有效行
wire        [10:0]              vaild_row_next; //有效行相邻行
wire                            row_done;       //写入一行
reg                             rd_en_d0;       //rd_en打拍产生传输完成信号
wire        [10:0]              current_row;
reg                             wr_req_d0;

assign  current_row =   cnt_row+1'd1;

always @(posedge clk or negedge rstn) begin
    if(!rstn)   begin
        rd_en_d0       <=  11'd0;
        wr_req_d0      <=   11'd0;
    end else    begin
        rd_en_d0       <=   rd_en;
        wr_req_d0      <=   wr_req;
    end
end


//计算有效行
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        vaild_row       <=11'd0;
    end
    else if(wr_req==1'b1) begin//完成一行的缩放收到数据处理的请求更新一次有效行 
        vaild_row       <=  (vaild_rowm_p[7]==1'b1)?(vaild_row_p[20:8]+1):vaild_row_p[20:8];
    end
    else    begin
        vaild_row       <=  vaild_row;
    end
end
assign  vaild_row_next      =   vaild_row+1'd1;

assign  row_done    =   (cnt_col==H_NUM-1'd1)?1'b1:1'b0;

//行计数和列计数
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        cnt_col<=11'd0;
    else if(rd_en)
        cnt_col<=cnt_col+1'd1;
    if(cnt_col == H_NUM-1'b1)
        cnt_col<=11'd0;
end

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        cnt_row<=11'd0;
    else if(row_done==1'b1) begin
        cnt_row<=cnt_row+1'd1;
        if(cnt_row == V_NUM-1)
        cnt_row<=11'd0;
    end
end


always @(posedge clk or negedge rstn) begin
    if(!rstn)
        ram_select<=4'd1;
    else if(row_done==1'b1)
        ram_select<={ram_select[2:0],ram_select[3]};
    else
        ram_select<=ram_select;
end


always @(posedge clk or negedge rstn) begin
    if(!rstn)
        out_addr<=11'd0;
    else if(rd_en==1'b1)
        out_addr<=out_addr+1'd1;
    if(cnt_col == H_NUM-1'd1)
        out_addr<=11'd0;
end
//一个时钟周期
mul_2_8 p(
        .a(y_scale),
        .b(dst_row),
        .p(vaild_row_p),
        .clk(clk),
        .rst(~rstn),
        .ce(1'b1)
);


assign  rd_en       =   (wr_req_d0&&rstn&&fifo_row_rdy&&(current_row==vaild_row||current_row==vaild_row_next||current_row<vaild_row))?1'b1:1'b0;//当数据准备好了并且当前写入行为有效行

assign  row_vaild   =   (wr_req_d0&&rstn&&fifo_row_rdy&&(current_row==vaild_row||current_row==vaild_row_next))?1'b1:1'b0;//当前行无效时，输出数据无效
assign  out_data    =   in_data;

assign  tran_done   =   (rd_en==1'd0&&rd_en_d0==1'd1)?1'b1:1'b0;

endmodule