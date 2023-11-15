module scaler_4#(
            parameter   FIX_LEN     =  15,
            parameter   PIX_WIDTH   =  16
)(
            input                            clk,
            input                            rstn,

            input       [FIX_LEN-1'd1:0]     x_scale,
            input       [FIX_LEN-1'd1:0]     y_scale,
            input       [12:0]               TARGET_H_NUM,
            input       [12:0]               TARGET_V_NUM,

            input                            fifo_row_rdy,
            input       [PIX_WIDTH-1'd1:0]   fifo_data,
            output                           rd_en,

            output   wire[PIX_WIDTH-1'd1:0]  pix_data,
            output   wire                    data_vaild,
            output   wire[27:0]              DDR3_ADDR
);

assign   DDR3_ADDR   =  28'h0003_8540;//11'd640*(11'd360-TARGET_V_NUM)


wire        [10:0]      wr_addr;
wire        [15:0]      wr_data;
wire        [15:0]      out_data;
wire                    wr_en;
wire        [10:0]      x_pos;
wire                    wr_req;
wire        [10:0]      dst_row;
reg                     pix_vaild_d0;
reg                     pix_vaild_d1;

rfifo u_rfifo (
    .clk                     ( clk          ),
    .rstn                    ( rstn         ),
    .x_scale                 ( x_scale      ),
    .wr_addr                 ( wr_addr      ),
    .wr_data                 ( wr_data      ),
    .wr_en                   ( wr_en        ),
    .x_pos                   ( x_pos        ),

    .out_data                ( out_data     )
);


ram_fifo_ctrl  ram_fifo_ctrl_inst(
        .clk                 (            clk                  ),
        .rstn                (            rstn                 ),

        .x_scale             (            x_scale              ),//行方向缩放倍数 2_8
        .y_scale             (            y_scale              ),//场方向缩放倍数 2_8
        .row_vaild           (            wr_en                ),//当前数据有效 高电平有效

        .dst_row             (            dst_row              ),
        .out_data            (            wr_data              ),
        .out_addr            (            wr_addr              ),
        .tran_done           (            tran_done            ),//传输完成
        .fifo_row_rdy        (            fifo_row_rdy         ),
        .in_data             (            fifo_data            ),
        .rd_en               (            rd_en                ),
        .wr_req              (            wr_req               ) //一行数据缩放完成
);


calculator_4     u_calculator (
    .clk                     ( clk            ),
    .rstn                    ( rstn           ),
    .x_scale                 ( x_scale        ),
    .y_scale                 ( y_scale        ),
    .TARGET_H_NUM            ( TARGET_H_NUM   ),
    .TARGET_V_NUM            ( TARGET_V_NUM   ),
    .input_data              ( out_data       ),
    .tran_done               ( tran_done      ),

    .dst_row                 ( dst_row        ),
    .wr_req                  ( wr_req         ),
    .x_pos                   ( x_pos          ),
    .out_data                ( pix_data       ),
    .data_vaild              ( pix_vaild      )
);

always @(posedge clk or negedge rstn)   begin
   if(!rstn)   begin
      pix_vaild_d0   <= 1'd0;
      pix_vaild_d1   <= 1'd0;
   end
   else  begin
      pix_vaild_d0   <= pix_vaild;
      pix_vaild_d1   <= pix_vaild_d0;
   end
end
assign   data_vaild  =  pix_vaild;

endmodule