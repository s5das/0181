module rfifo(
               input          clk                     ,
               input          rstn                    ,
               input          b_rst                   ,
               input          b_clk                   ,

               input          [9:0]    x_scale                 ,
               input          [3:0]    ram_select              ,
               input          [10:0]   wr_addr                 ,
               input          [15:0]   wr_data                 ,
               input                   wr_en                   ,

               input                   rd_en                   ,
               input          [10:0]   x_pos                   ,
               output   reg   [15:0]   x1_data                 ,
               output   reg   [15:0]   x2_data                 ,
               output   reg   [15:0]   x3_data                 ,
               output   reg   [15:0]   x4_data                 
);


wire  [10:0]    rd_addr                 ;    
wire  [10:0]    rd_addr2                ;  
wire  [20:0]    x_index_p               ;//�˷������
wire  [20:0]    x_index                 ;




reg   [10:0]    a_rd_addr_0001;
reg   [10:0]    b_rd_addr_0001;
reg   [10:0]    a_wr_addr_0001;

reg   [10:0]    a_rd_addr_0010;
reg   [10:0]    b_rd_addr_0010;
reg   [10:0]    a_wr_addr_0010;

reg   [10:0]    a_rd_addr_0100;
reg   [10:0]    b_rd_addr_0100;
reg   [10:0]    a_wr_addr_0100;

reg   [10:0]    a_rd_addr_1000;
reg   [10:0]    b_rd_addr_1000;
reg   [10:0]    a_wr_addr_1000;



//ram �˿�
wire  [10:0]    a_addr_ram_0001        ;
wire  [15:0]   a_wr_data_ram_0001     ;
wire  [15:0]   a_rd_data_ram_0001     ;
wire           a_wr_en_ram_0001       ;
wire  [10:0]    b_addr_ram_0001        ;
wire  [15:0]   b_wr_data_ram_0001     ;
wire  [15:0]   b_rd_data_ram_0001     ;



wire  [10:0]    a_addr_ram_0010        ;
wire  [15:0]   a_wr_data_ram_0010     ;
wire  [15:0]   a_rd_data_ram_0010     ;
wire           a_wr_en_ram_0010       ; 
wire  [10:0]    b_addr_ram_0010        ;
wire  [15:0]   b_wr_data_ram_0010     ;
wire  [15:0]   b_rd_data_ram_0010     ;



wire  [10:0]    a_addr_ram_0100        ;
wire  [15:0]   a_wr_data_ram_0100     ;
wire  [15:0]   a_rd_data_ram_0100     ;
wire           a_wr_en_ram_0100       ; 
wire  [10:0]    b_addr_ram_0100        ;
wire  [15:0]   b_wr_data_ram_0100     ;
wire  [15:0]   b_rd_data_ram_0100     ; 



wire  [10:0]    a_addr_ram_1000        ;
wire  [15:0]   a_wr_data_ram_1000     ;
wire  [15:0]   a_rd_data_ram_1000     ;
wire           a_wr_en_ram_1000       ; 
wire  [10:0]    b_addr_ram_1000        ;
wire  [15:0]   b_wr_data_ram_1000     ;
wire  [15:0]   b_rd_data_ram_1000     ; 



assign      a_wr_en_ram_0001     =  (ram_select==4'b0001)?wr_en:1'b0;
assign      a_wr_en_ram_0010     =  (ram_select==4'b0010)?wr_en:1'b0;
assign      a_wr_en_ram_0100     =  (ram_select==4'b0100)?wr_en:1'b0;
assign      a_wr_en_ram_1000     =  (ram_select==4'b1000)?wr_en:1'b0;

assign      a_wr_data_ram_0001   =  (ram_select==4'b0001)?wr_data:16'b0;
assign      a_wr_data_ram_0010   =  (ram_select==4'b0010)?wr_data:16'b0;
assign      a_wr_data_ram_0100   =  (ram_select==4'b0100)?wr_data:16'b0;
assign      a_wr_data_ram_1000   =  (ram_select==4'b1000)?wr_data:16'b0;

assign      a_addr_ram_0001      =  (wr_en==1'b1)?a_wr_addr_0001:a_rd_addr_0001;
assign      a_addr_ram_0010      =  (wr_en==1'b1)?a_wr_addr_0010:a_rd_addr_0010;
assign      a_addr_ram_0100      =  (wr_en==1'b1)?a_wr_addr_0100:a_rd_addr_0100;
assign      a_addr_ram_1000      =  (wr_en==1'b1)?a_wr_addr_1000:a_rd_addr_1000;

assign      b_addr_ram_0001      =  b_rd_addr_0001;
assign      b_addr_ram_0010      =  b_rd_addr_0010;
assign      b_addr_ram_0100      =  b_rd_addr_0100;
assign      b_addr_ram_1000      =  b_rd_addr_1000;


always @(*) begin
   if(wr_en==1'b1)   begin
      a_wr_addr_0001   <=    wr_addr;
      a_wr_addr_0010   <=    wr_addr;
      a_wr_addr_0100   <=    wr_addr;
      a_wr_addr_1000   <=    wr_addr; 
   end
   else if(rd_en==1'b1) begin
      case (ram_select)
         4'b0010:begin
            a_rd_addr_0001   <=  rd_addr;
            b_rd_addr_0001   <=  rd_addr2;
            
            a_rd_addr_1000   <=  rd_addr;
            b_rd_addr_1000   <=  rd_addr2;
            
            a_rd_addr_0010   <=  10'd0;
            b_rd_addr_0010   <=  10'd0;
            a_rd_addr_0100   <=  10'd0;
            b_rd_addr_0100   <=  10'd0;       

         end
         4'b0100:begin
            a_rd_addr_0010   <=  rd_addr;
            b_rd_addr_0010   <=  rd_addr2;
            
            a_rd_addr_0001   <=  rd_addr;
            b_rd_addr_0001   <=  rd_addr2;
            
            a_rd_addr_0100   <=  10'd0;
            b_rd_addr_0100   <=  10'd0;
            a_rd_addr_1000   <=  10'd0;
            b_rd_addr_1000   <=  10'd0;   
         end
         4'b1000:begin
            a_rd_addr_0100   <=  rd_addr;
            b_rd_addr_0100   <=  rd_addr2;
            
            a_rd_addr_0010   <=  rd_addr;
            b_rd_addr_0010   <=  rd_addr2;
            
            a_rd_addr_0001   <=  10'd0;
            b_rd_addr_0001   <=  10'd0;
            a_rd_addr_1000   <=  10'd0;
            b_rd_addr_1000   <=  10'd0;   
         end
         4'b0001:begin
            a_rd_addr_1000   <=  rd_addr;
            b_rd_addr_1000   <=  rd_addr2;
            
            a_rd_addr_0100   <=  rd_addr;
            b_rd_addr_0100   <=  rd_addr2;
            
            a_rd_addr_0010   <=  10'd0;
            b_rd_addr_0010   <=  10'd0;
            a_rd_addr_0001   <=  10'd0;
            b_rd_addr_0001   <=  10'd0;   
         end 
      endcase
   end
end



assign      x_index   =  (x_index_p[7]==1'b1)?(x_index_p[20:8]+1'd1):x_index_p[20:8];
assign      rd_addr   =  x_index;
assign      rd_addr2  =  x_index+1'd1;

always @(*) begin
   case (ram_select)
      4'b0001: begin
         x1_data  <=    a_rd_data_ram_0100;
         x2_data  <=    b_rd_data_ram_0100;
         x3_data  <=    a_rd_data_ram_1000;
         x4_data  <=    b_rd_data_ram_1000;
      end
       4'b0010: begin
         x1_data  <=    a_rd_data_ram_1000;
         x2_data  <=    b_rd_data_ram_1000;
         x3_data  <=    a_rd_data_ram_0001;
         x4_data  <=    b_rd_data_ram_0001;
      end
      4'b0100: begin
         x1_data  <=    a_rd_data_ram_0001;
         x2_data  <=    b_rd_data_ram_0001;
         x3_data  <=    a_rd_data_ram_0010;
         x4_data  <=    b_rd_data_ram_0010;
      end
      4'b1000: begin
         x1_data  <=    a_rd_data_ram_0010;
         x2_data  <=    b_rd_data_ram_0010;
         x3_data  <=    a_rd_data_ram_0100;
         x4_data  <=    b_rd_data_ram_0100;
      end     
   endcase
end
ram_fifo    ram_fifo_inst_0001(
      .a_addr        (        a_addr_ram_0001        ),
      .a_wr_data     (        a_wr_data_ram_0001     ),
      .a_rd_data     (        a_rd_data_ram_0001     ),
      .a_wr_en       (        a_wr_en_ram_0001       ),  
      .a_rst         (        ~rstn                   ),
      .a_clk         (        clk                    ),
      .b_addr        (        b_addr_ram_0001        ),
      .b_wr_data     (        b_wr_data_ram_0001     ),
      .b_rd_data     (        b_rd_data_ram_0001     ),
      .b_wr_en       (        1'b0                   ),   
      .b_rst         (        ~rstn                   ),
      .b_clk         (        clk                    )
);

ram_fifo    ram_fifo_inst_0010(
      .a_addr        (        a_addr_ram_0010        ),
      .a_wr_data     (        a_wr_data_ram_0010     ),
      .a_rd_data     (        a_rd_data_ram_0010     ),
      .a_wr_en       (        a_wr_en_ram_0010       ),  
      .a_rst         (        ~rstn                   ),
      .a_clk         (        clk                    ),
      .b_addr        (        b_addr_ram_0010        ),
      .b_wr_data     (        b_wr_data_ram_0010     ),
      .b_rd_data     (        b_rd_data_ram_0010     ),
      .b_wr_en       (        1'b0                   ),   
      .b_rst         (        ~rstn                   ),
      .b_clk         (        clk                    )
);

ram_fifo    ram_fifo_inst_0100(
      .a_addr        (        a_addr_ram_0100        ),
      .a_wr_data     (        a_wr_data_ram_0100     ),
      .a_rd_data     (        a_rd_data_ram_0100     ),
      .a_wr_en       (        a_wr_en_ram_0100       ),  
      .a_rst         (        ~rstn                   ),
      .a_clk         (        clk                    ),
      .b_addr        (        b_addr_ram_0100        ),
      .b_wr_data     (        b_wr_data_ram_0100     ),
      .b_rd_data     (        b_rd_data_ram_0100     ),
      .b_wr_en       (        1'b0                   ),   
      .b_rst         (        ~rstn                   ),
      .b_clk         (        clk                    )
);

ram_fifo    ram_fifo_inst_1000(
      .a_addr        (        a_addr_ram_1000        ),
      .a_wr_data     (        a_wr_data_ram_1000     ),
      .a_rd_data     (        a_rd_data_ram_1000     ),
      .a_wr_en       (        a_wr_en_ram_1000       ),  
      .a_rst         (        ~rstn                   ),
      .a_clk         (        clk                    ),
      .b_addr        (        b_addr_ram_1000        ),
      .b_wr_data     (        b_wr_data_ram_1000     ),
      .b_rd_data     (        b_rd_data_ram_1000     ),
      .b_wr_en       (        1'b0                   ),   
      .b_rst         (        ~rstn                   ),
      .b_clk         (        clk                    )
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
