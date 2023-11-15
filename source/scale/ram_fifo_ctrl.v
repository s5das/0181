module ram_fifo_ctrl#(
        parameter   H_LEN       =   11,
        parameter   FLOAT_LEN   =   11,
        parameter   INT_LEN     =   4 ,
        parameter   FIX_LEN     =   15
)(
        input                               clk                 ,
        input                               rstn                ,

        input           [FIX_LEN-1'd1:0]    x_scale             ,//horizen scale coefficient 2.8
        input           [FIX_LEN-1'd1:0]    y_scale             ,//vertical scale coefficient  2.8
        output  wire                        row_vaild           ,
        // output  reg     [3:0]            ram_select          ,//0001 0010 0100 1000
        output  wire    [15:0]              out_data            ,
        output  reg     [10:0]              out_addr            ,
        output  wire                        tran_done           , 
        input   wire    [10:0]              dst_row             ,
        input                               fifo_row_rdy        ,
        input           [15:0]              in_data             ,/*synthesis syn_keep=1*/
        output  wire                        rd_en               ,/*synthesis syn_keep=1*/

        input                               wr_req                  //new row data request
);

localparam MUL_OUTPUT_LEN   =   FIX_LEN     +   H_LEN   ;


parameter       H_NUM   =   10'd640;        //input picture horizen scale
parameter       V_NUM   =   10'd360;        //input picture vertical scale



reg         [10:0]                      cnt_row;  /*synthesis syn_preserve=1*/          
reg         [10:0]                      cnt_col; /*synthesis syn_preserve=1*/           
wire        [MUL_OUTPUT_LEN-1'd1:0]     vaild_row_p;        //multipler data vaild
reg         [10:0]                      vaild_row;          //point at row which is vaild now
//wire        [10:0]                    vaild_row_next; 
wire                                    row_done;    /*synthesis syn_keep=1*/ 
reg                                     rd_en_d0;  
wire        [10:0]                      current_row;      /*synthesis syn_keep=1*/ 
reg                                     wr_req_d0;          //
reg                                     no_new_row_flag;
reg                                     no_new_row_flag_d0;

assign  current_row =   cnt_row+1'd1;

always @(posedge clk or negedge rstn) begin
    if(!rstn)   begin
        rd_en_d0            <=      1'd0;
        wr_req_d0           <=      1'd0;
        no_new_row_flag_d0  <=      1'd0;
    end else    begin
        rd_en_d0            <=   rd_en;
        wr_req_d0           <=   wr_req;
        no_new_row_flag_d0  <=   no_new_row_flag;
    end
end


//calculate vaild row which the calculator module need
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        vaild_row       <=11'd0;
    end
    else if(wr_req==1'b1) begin
        vaild_row       <=  (vaild_row_p[FLOAT_LEN-1'd1]==1'b1)?(vaild_row_p[MUL_OUTPUT_LEN-1'd1:FLOAT_LEN]+1):vaild_row_p[MUL_OUTPUT_LEN-1'd1:FLOAT_LEN];
    end
    else    begin
        vaild_row       <=  vaild_row;
    end
end


// assign  vaild_row_next      =   vaild_row+1'd1;

assign  row_done    =   (cnt_col==H_NUM-1'd1)?1'b1:1'b0;

//read from fifo row by row
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        cnt_col<=11'd0;
    else if(rd_en)
        cnt_col<=(cnt_col == H_NUM-1'b1)?11'd0:(cnt_col+1'd1);
end

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        cnt_row<=11'd0;
    else if(row_done==1'b1&&rd_en==1'd1) begin
        cnt_row<=   (cnt_row == V_NUM-1'd1)?11'd0:(cnt_row+1'd1);
    end
end



always @(posedge clk or negedge rstn) begin
    if(!rstn)
        out_addr    <=  11'd1;
    else if(rd_en==1'b1)
        out_addr    <=  (cnt_col == H_NUM-1'd1)?11'd1:(out_addr+1'd1);

end


always @(posedge clk or negedge rstn) begin
    if(!rstn)
        no_new_row_flag<=1'd0;
    else if(wr_req_d0==1'b1)
        no_new_row_flag<=(current_row>vaild_row&&wr_req==1'd1)?1'd1:1'd0;
    else
        no_new_row_flag<=1'd0;
end

//one clk delay
mul_2_8 p(
        .a(y_scale),
        .b(dst_row),
        .p(vaild_row_p),
        .clk(clk),
        .rst(~rstn),
        .ce(1'b1)
);


assign  rd_en       =   (wr_req_d0&&rstn&&fifo_row_rdy&&(current_row==vaild_row||current_row<vaild_row))?1'b1:1'b0;//current

assign  row_vaild   =   (wr_req_d0&&rstn&&fifo_row_rdy&&(current_row==vaild_row))?1'b1:1'b0;//current invaild

assign  out_data    =   in_data;

assign  tran_done   =   (((cnt_col==11'd639)&&(current_row==vaild_row))||(no_new_row_flag==1'd1&&no_new_row_flag_d0==1'd0))?1'b1:1'b0;


endmodule