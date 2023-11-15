module calculator(
      input                   clk         ,
      input                   rstn        ,

      output         [11:0]   dst_row     ,
      output                  wr_req      ,//row_done
      input          [15:0]   x1_data     ,
      input          [15:0]   x2_data     ,
      input          [15:0]   x3_data     ,
      input          [15:0]   x4_data     ,
      input                   tran_done   ,

      output         [15:0]   out_data    ,
      output                  data_vaild  

);

always @(posedge clk or negedge rstn) begin
      

end

   
endmodule