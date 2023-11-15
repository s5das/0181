module ddr_arbit#(
         parameter   DDR_ADDR_WIDTH    =  28       ,
         parameter   H_NUM             =  640     ,
         parameter   V_NUM             =  360     ,
         parameter   DQ_WIDTH          =  32       ,
         parameter   DDR_DATA_WIDTH    =  255      ,
         parameter   MEM_DQ_WIDTH      =  32          ,
         parameter   M1_LEN_WIDTH      =  32       ,
         parameter   M2_LEN_WIDTH      =  32       ,  
         parameter   M3_LEN_WIDTH      =  32       ,
         parameter   M4_LEN_WIDTH      =  32       ,
         parameter   RD_LEN_WIDTH      =  16       
   )(
         input                               ddr_clk           ,
         input                               rstn              ,


         input                               m1_wr_req         ,
         input    [DDR_ADDR_WIDTH-1'd1:0]    m1_wr_addr        ,
         input    [M1_LEN_WIDTH-1'd1:0]      m1_wr_len         ,
         output    reg                          m1_ddr_wrdy       ,
         output    reg                         m1_ddr_wdone      ,
         input    [8*DQ_WIDTH-1'd1:0]        m1_wr_data        ,
         output    reg                          m1_ddr_wdata_req  ,


         input                               m2_wr_req         ,
         input    [DDR_ADDR_WIDTH-1'd1:0]    m2_wr_addr        ,
         input    [M2_LEN_WIDTH-1'd1:0]      m2_wr_len         ,
         output    reg                      m2_ddr_wrdy       ,
         output    reg                      m2_ddr_wdone      ,
         input    [8*DQ_WIDTH-1'd1:0]        m2_wr_data        ,
         output    reg                      m2_ddr_wdata_req  ,

         input                               m3_wr_req         ,
         input    [DDR_ADDR_WIDTH-1'd1:0]    m3_wr_addr        ,
         input    [M3_LEN_WIDTH-1'd1:0]      m3_wr_len         ,
         output    reg                      m3_ddr_wrdy       ,
         output    reg                      m3_ddr_wdone      ,
         input    [8*DQ_WIDTH-1'd1:0]        m3_wr_data        ,
         output    reg                      m3_ddr_wdata_req  ,

         input                               m4_wr_req         ,
         input    [DDR_ADDR_WIDTH-1'd1:0]    m4_wr_addr        ,
         input    [M4_LEN_WIDTH-1'd1:0]      m4_wr_len         ,
         output    reg                      m4_ddr_wrdy       ,
         output    reg                      m4_ddr_wdone      ,
         input    [8*DQ_WIDTH-1'd1:0]        m4_wr_data        ,
         output    reg                      m4_ddr_wdata_req  ,

         input    [DDR_ADDR_WIDTH-1'd1:0]    m1_rd_addr        ,
         input    [RD_LEN_WIDTH-1'd1:0]      m1_rd_len         ,
         input                               m1_rd_req         ,
         output   [8*DQ_WIDTH-1'd1:0]        m1_rd_data        ,
         output   wire                       m1_rd_ddr_rrdy    ,
         output   wire                       m1_rd_ddr_rdata_en, 
         output   wire                       m1_rd_ddr_rdone   ,

         output   reg                        wr_cmd_en         ,
         output   reg [DDR_ADDR_WIDTH-1'b1:0]wr_cmd_addr       ,
         output   reg [31: 0]                wr_cmd_len        ,
         input                               wr_cmd_ready      ,
         input                               wr_cmd_done       ,// one row down
         output   wire                       wr_bac            ,
         output   reg [MEM_DQ_WIDTH*8-1'b1:0]wr_ctrl_data      ,
         input                               wr_data_re        ,

         output                              rd_cmd_en         ,
         output   [DDR_ADDR_WIDTH-1'b1:0]    rd_cmd_addr       ,
         output   [31: 0]                    rd_cmd_len        ,
         input    [DDR_DATA_WIDTH-1'd1:0]    read_data         ,
         input                               rd_cmd_ready      ,
         input                               rd_cmd_done       , 
         output                              read_en        
);
localparam  IDLE     =  4'b0000;
localparam  CHECK1   =  4'b0001;
localparam  CHECK2   =  4'b0011;
localparam  CHECK3   =  4'b0010;
localparam  CHECK4   =  4'b0110;
localparam  CHECK5   =  4'b0111;
localparam  WR_PRO   =  4'b0101;
localparam  RD_PRO   =  4'b0100;
localparam  SEND     =  4'b1100;


reg [3:0]   state;
reg [3:0]   flag;
always @(posedge ddr_clk or negedge rstn) begin
   if(!rstn)   begin
      state <= IDLE;
      flag  <=  4'b0001;
   end
   else  begin
      case (state)
         IDLE: begin
            case (flag)
               4'b0001: begin
                  state <= CHECK1;
               end
               4'b0010: begin
                  state <= CHECK2;
               end 
               4'b00100: begin
                  state <= CHECK3;
               end
               4'b01000: begin
                  state <= CHECK4;
               end
               // 5'b10000: begin
               //    state <= CHECK5;
               // end
            endcase
         end
         CHECK1:  begin
            if(m1_wr_req==1'b1)  begin
               state<=WR_PRO;
               flag  <=  4'b0001;
            end
            else
               state<=CHECK2;
         end
         CHECK2:  begin
            if(m2_wr_req==1'b1)  begin
               state<=WR_PRO;
               flag  <=  4'b0010;
            end
            else
               state<=CHECK3;
         end
         CHECK3:  begin
            if(m3_wr_req==1'b1)  begin
               state<=WR_PRO;
               flag  <=  4'b0100;
            end
            else
               state<=CHECK4;
         end
         CHECK4:  begin
            if(m4_wr_req==1'b1)  begin
               state<=WR_PRO;
               flag  <=  4'b1000;
            end
            else 
               state<=CHECK1;
         end
         // CHECK5:  begin     
         //    if(m1_rd_req==1'b1)  begin
         //       state<=RD_PRO;
         //       flag  =  5'b10000;
         //    end
         //    else
         //       state<=SEND;
         // end
         WR_PRO:  begin
            if(wr_cmd_done==1'b1)   begin
               state <= SEND;
               flag  <=  {flag[2:0],flag[3]};
            end
            else
               state <= WR_PRO;
         end
         // RD_PRO:  begin
         //    if(rd_cmd_done==1'b1)   begin 
         //       state <= SEND;
         //       flag  =  {flag[3:0],flag[4]};
         //    end
         //    else
         //       state <= RD_PRO;            
         // end
         SEND:    begin
            state <= IDLE;
         end
         default: 
            state <= IDLE;
      endcase
   end
end


always @(*) begin
  if(state==WR_PRO&&flag==4'b0001)begin
     wr_cmd_addr       =  m1_wr_addr; 
     wr_cmd_len        =  m1_wr_len;                
     wr_cmd_en         =  m1_wr_req;              
     wr_ctrl_data      =  m1_wr_data;
     m1_ddr_wrdy       =  wr_cmd_ready;
     m1_ddr_wdone      =  wr_cmd_done;
     m1_ddr_wdata_req  =  wr_data_re;
  end
  else if(state==WR_PRO&&flag==4'b0010)begin
     wr_cmd_addr       =  m2_wr_addr;
     wr_cmd_len        =  m2_wr_len;              
     wr_cmd_en         =  m2_wr_req;               
     wr_ctrl_data      =  m2_wr_data;
     m2_ddr_wrdy       =  wr_cmd_ready;
     m2_ddr_wdone      =  wr_cmd_done;
     m2_ddr_wdata_req  =  wr_data_re;
  end
  else if(state==WR_PRO&&flag==4'b0100)begin
     wr_cmd_addr       =  m3_wr_addr;
     wr_cmd_len        =  m3_wr_len;                
     wr_cmd_en         =  m3_wr_req;               
     wr_ctrl_data      =  m3_wr_data;
     m3_ddr_wrdy       =  wr_cmd_ready;
     m3_ddr_wdone      =  wr_cmd_done;
     m3_ddr_wdata_req  =  wr_data_re;
  end
  else if(state==WR_PRO&&flag==4'b1000)begin
     wr_cmd_addr       =  m4_wr_addr;
     wr_cmd_len        =  m4_wr_len;              
     wr_cmd_en         =  m4_wr_req;                
     wr_ctrl_data      =  m4_wr_data;
     m4_ddr_wrdy       =  wr_cmd_ready;
     m4_ddr_wdone      =  wr_cmd_done;
     m4_ddr_wdata_req  =  wr_data_re;
  end
  else begin
     wr_cmd_addr       =  {DDR_ADDR_WIDTH{1'b0}} ;
     wr_cmd_len        =  32'b0  ;                
     wr_cmd_en         =  1'b0   ;                
     wr_ctrl_data      =  {DDR_DATA_WIDTH{1'b0}};
     m1_ddr_wrdy       =  1'b0;
     m1_ddr_wdone      =  1'b0;
     m1_ddr_wdata_req  =  1'b0;
     m2_ddr_wrdy       =  1'b0;
     m2_ddr_wdone      =  1'b0;
     m2_ddr_wdata_req  =  1'b0;
     m3_ddr_wrdy       =  1'b0;
     m3_ddr_wdone      =  1'b0;
     m3_ddr_wdata_req  =  1'b0;
     m4_ddr_wrdy       =  1'b0;
     m4_ddr_wdone      =  1'b0;
     m4_ddr_wdata_req  =  1'b0;
  end

end

endmodule