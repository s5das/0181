`timescale 1ns/1ns
module tb_rfifo();

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


wire                wr_done                  ;
wire                rd_done                  ;
reg         [1:0]   row_cnt                  ;
wire                one_row_done             ;

wire        [9:0]    x_scale                 ;
reg         [3:0]    ram_select              ;
reg         [10:0]   wr_addr                 ;
reg         [15:0]   wr_data                 ;
wire                 wr_en                   ;
wire                 rd_en                   ;
reg         [10:0]   x_pos                   ;
wire        [15:0]   x1_data                 ;
wire        [15:0]   x2_data                 ;
wire        [15:0]   x3_data                 ;
wire        [15:0]   x4_data                 ;



reg     [1:0]   state;
parameter   INIT   =  2'd0,
            WRITE  =  2'd1,
            READ   =  2'd2;
parameter   H_NUM =  9'd427;
assign      x_scale = 10'b110000000;

always @(posedge clk or negedge rstn) begin
   if(!rstn)
      wr_data     <=    16'd1;
   else if(wr_en==1'b1) begin
      wr_data     <=    wr_data+1'd1;
      if(wr_data==16'd640)
         wr_data     <=    16'd1;
   end
end

always @(posedge clk or negedge rstn) begin
   if(!rstn)
      wr_addr     <=    16'd1;
   else if(wr_en==1'b1) begin
      wr_addr     <=    wr_addr+1'd1;
      if(wr_addr==16'd640)
         wr_addr     <=    16'd1;
   end
end

 assign  one_row_done     =   (wr_data==16'd640)?1'd1:1'd0;
 //assign  wr_done     =   (wr_data==16'd640)?1'd1:1'd0;
assign  wr_done          =   (one_row_done==1'd1&&row_cnt==2'd1);
assign  wr_en            =   (state==WRITE)?1'd1:1'd0;
assign  rd_en            =   (state==READ)?1'd1:1'd0;
assign  rd_done          =   (x_pos==H_NUM)?1'd1:1'd0;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        row_cnt     <=    16'd0;
    else if(one_row_done==1'b1) begin
        row_cnt     <=    row_cnt+1'd1;
    end
    else if(row_cnt==2'd2)
        row_cnt     <=    16'd0;
end


always @(posedge clk or negedge rstn) begin
    if(!rstn)
        x_pos     <=    16'd0;
    else if(rd_en==1'b1) begin
        x_pos     <=    x_pos+1'd1;
        if(x_pos==H_NUM)
            x_pos     <=    10'd0;
    end
end

wire    [10:0]   x_pos_b;
assign      x_pos_b =   x_pos;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        ram_select<=4'd1;
    else if(one_row_done==1'b1)
        ram_select<={ram_select[2:0],ram_select[3]};
    else
        ram_select<=ram_select;
end

rfifo   r_fifo_inst(
               .clk         (      clk         )              ,
               .rstn        (      rstn        )              ,
               .b_rst       (      rstn        )              ,
               .b_clk       (      clk         )              ,

               .x_scale     (      x_scale     )              ,
               .ram_select  (      ram_select  )              ,
               .wr_addr     (      wr_addr     )              ,
               .wr_data     (      wr_data     )              ,
               .wr_en       (      wr_en       )              ,

               .rd_en       (      rd_en       )              ,
               .x_pos       (      x_pos_b       )              ,
               .x1_data     (      x1_data     )              ,
               .x2_data     (      x2_data     )              ,
               .x3_data     (      x3_data     )              ,
               .x4_data     (      x4_data     )              
);



always @(posedge clk or negedge rstn) begin
   if(!rstn)
      state     <=    INIT;
   else begin
      case (state)
         INIT: begin
            if(rstn==1'b1)
               state<=WRITE;
         end
         WRITE: begin
            if(wr_done==1'd1)
               state <= READ;
         end
         READ:   begin
            if(rd_done==1'd1)
               state <= WRITE;
         end 
 
      endcase
   end
end

endmodule