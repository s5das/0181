module calculator_2#(
      parameter         PIX_WIDTH   =     16,
      parameter         FIX_LEN     =     15,
      parameter         FLOAT_LEN   =     11,
      parameter         INT_LEN     =     4 
      )(
      input                         clk         ,
      input                         rstn        ,

      output   reg      [10:0]      dst_row     ,
      output                        wr_req      ,//row_done

      input             [14:0]      x_scale     ,
      input             [14:0]      y_scale     ,
      input             [12:0]      TARGET_H_NUM,
      input             [12:0]      TARGET_V_NUM,
      input             [15:0]      input_data  ,
      input                         tran_done   ,

      output            [10:0]      x_pos       ,
      output            [15:0]      out_data    ,
      output                        data_vaild  
);

parameter   IDLE        =     4'b0000,
            WAIT        =     4'b0001,
            START       =     4'b0010,
            DONE        =     4'b0100,
            FRAME_DONE  =     4'b1000;


reg   [3:0]       state;
wire              done_trig;
reg   [10:0]      col_cnt;
wire              row_done;
reg               row_done_d1;
reg               row_done_d2;
wire              start_flag;
reg               start_flag_d1;
reg               start_flag_d2;
always @(posedge clk or negedge rstn) begin
      if(!rstn)   begin
            row_done_d1       <=    1'b0;
            row_done_d2       <=    1'b0;
            start_flag_d1     <=    1'b0;
            start_flag_d2     <=    1'b0;
      end
      else  begin
            row_done_d1       <=    row_done;
            row_done_d2       <=    row_done_d1;
            start_flag_d1     <=    start_flag;
            start_flag_d2     <=    start_flag_d1;
      end
end

always @(posedge clk or negedge rstn) begin
      if(!rstn)
            state       <=    IDLE;
      else  begin
             case (state)
                  IDLE  :begin
                        state       <=    WAIT;
                  end  
                  WAIT  :begin
                        if(tran_done==1'b1)
                              state       <=    START;
                        else
                              state       <=    WAIT;
                  end
                  START :begin
                        if(row_done_d2==1'b1)
                              state       <=    DONE;
                        else
                              state       <=    START;
                  end
                  DONE: begin
                        if(dst_row==TARGET_V_NUM)
                              state       <=    FRAME_DONE;
                        else
                              state       <=    IDLE;
                  end
                  FRAME_DONE:begin
                        state       <=    FRAME_DONE;
                  end
             endcase
      end
end

//dst_row increase from TARGET_V_NUM-11'd360 to TARGET_V_NUM
always @(posedge clk or negedge rstn) begin
      if(!rstn)
            col_cnt     <=    1'd1;
      else begin
            if(state==START) begin
                  col_cnt     <=     col_cnt+1'b1;      
            end
            else 
                  col_cnt     <=    1'd1;
      end
end


//col_cnt increase from TARGET_H_NUM-11'd640 when state is start
always @(posedge clk or negedge rstn) begin
      if(!rstn)
            dst_row     <=    (y_scale[FIX_LEN-1'd1:FLOAT_LEN]==4'd0)?(TARGET_V_NUM-11'd359):1'd1;
      else begin
            if(state==DONE) begin
                  dst_row     <=     (dst_row==TARGET_V_NUM)?((y_scale[FIX_LEN-1'd1:FLOAT_LEN]==4'd0)?(TARGET_V_NUM-11'd359):1'd1):(dst_row+1'd1);      
            end
      end
end



assign      wr_req      =     (state==WAIT)?1'b1:1'b0;
assign      row_done    =     (((x_scale[FIX_LEN-1'd1:FLOAT_LEN]==4'd0)&&(col_cnt==11'd640))||(((x_scale[FIX_LEN-1'd1:FLOAT_LEN]>4'd0))&&(col_cnt==11'd640)))?1'b1:1'b0;
assign      start_flag  =     (state==START)?1'b1:1'b0;
assign      data_vaild  =     start_flag&start_flag_d2;
assign      out_data    =     ((col_cnt>TARGET_H_NUM)&&(x_scale[FIX_LEN-1'd1:FLOAT_LEN]>4'd0))?16'd0:input_data;
assign      x_pos       =     col_cnt;



endmodule