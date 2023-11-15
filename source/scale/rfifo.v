module rfifo#(
        parameter   H_LEN       =   11,
        parameter   FLOAT_LEN   =   11,
        parameter   INT_LEN     =   4 ,
        parameter   FIX_LEN     =   15
)
(
               input          clk                              ,
               input          rstn                             ,


               input          [FIX_LEN-1'd1:0]      x_scale                 ,
               input          [10:0]                wr_addr                 ,
               input          [15:0]                wr_data                 ,
               input                                wr_en                   ,

               input          [H_LEN-1'd1:0]        x_pos                   ,
               output   wire  [15:0]                out_data                 
);

localparam MUL_OUTPUT_LEN   =   FIX_LEN     +   H_LEN   ;

// wire  [10:0]    rd_addr                 ;  
wire  [MUL_OUTPUT_LEN-1'd1:0]    x_index_p               ;//³Ë·¨Æ÷½á¹û
wire  [MUL_OUTPUT_LEN-1'd1:0]    x_index                 ;

assign      x_index   =  (x_index_p[FLOAT_LEN-1'd1]==1'b1)?(x_index_p[MUL_OUTPUT_LEN-1'd1:FLOAT_LEN]+1'd1):x_index_p[MUL_OUTPUT_LEN-1'd1:FLOAT_LEN];
// assign      rd_addr   =  x_index;




ram_fifo  u_ram_fifo (
    .wr_data                 ( wr_data    ),
    .wr_addr                 ( wr_addr    ),
    .wr_en                   ( wr_en      ),
    .wr_clk                  ( clk        ),
    .wr_rst                  ( !rstn     ),
    .rd_addr                 ( x_index    ),
    .rd_clk                  ( clk        ),
    .rd_rst                  ( !rstn      ),

    .rd_data                 ( out_data   )
);


mul_2_8  mul_inst(
      .a(x_scale),
      .b(x_pos),
      .p(x_index_p),
      .clk(clk),
      .rst(~rstn),
      .ce(1'd1)
);

endmodule
