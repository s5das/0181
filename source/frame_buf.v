module frame_buf # (
    parameter                     MEM_ROW_WIDTH        = 15    ,
    parameter                     MEM_COLUMN_WIDTH     = 10    ,
    parameter                     MEM_BANK_WIDTH       = 3     ,
    parameter                     CTRL_ADDR_WIDTH = MEM_ROW_WIDTH + MEM_BANK_WIDTH + MEM_COLUMN_WIDTH,
    parameter                     MEM_DQ_WIDTH         = 32    ,
    parameter                     DQ_WIDTH             = 32    ,
    parameter                     H_NUM                = 12'd1280,//12'd1920,
    parameter                     V_NUM                = 12'd720,//12'd1080,//12'd106,//
    parameter                     PIX_WIDTH            = 16    ,//24
    parameter                     M1_LEN_WIDTH         = 16      
)(
    input                         mode                ,
    input   [31:0]                m1_ADDR_OFFSET      ,            
    input   [11:0]                m1_H_NUM            ,            
    input   [11:0]                m1_V_NUM            ,
    input                         m1_wr_vin_clk       ,
    input                         m1_wr_wr_fsync      ,
    input                         m1_wr_wr_en         ,
    input  [PIX_WIDTH- 1'b1 : 0]  m1_wr_wr_data       ,
    output reg                    m1_wr_init_done=0   ,

    input   [31:0]                m2_ADDR_OFFSET      ,
    input   [11:0]                m2_H_NUM            ,
    input   [11:0]                m2_V_NUM            ,
    input                         m2_wr_vin_clk       ,
    input                         m2_wr_wr_fsync      ,
    input                         m2_wr_wr_en         ,
    input  [PIX_WIDTH- 1'b1 : 0]  m2_wr_wr_data       ,
    output reg                    m2_wr_init_done=0   ,

    input   [31:0]                m3_ADDR_OFFSET      ,
    input   [11:0]                m3_H_NUM            ,
    input   [11:0]                m3_V_NUM            ,
    input                         m3_wr_vin_clk       ,
    input                         m3_wr_wr_fsync      ,
    input                         m3_wr_wr_en         ,
    input  [PIX_WIDTH- 1'b1 : 0]  m3_wr_wr_data       ,
    output reg                    m3_wr_init_done=0   ,

    input   [31:0]                m4_ADDR_OFFSET      ,
    input   [11:0]                m4_H_NUM            ,
    input   [11:0]                m4_V_NUM            ,
    input                         m4_wr_vin_clk       ,
    input                         m4_wr_wr_fsync      ,
    input                         m4_wr_wr_en         ,
    input  [PIX_WIDTH- 1'b1 : 0]  m4_wr_wr_data       ,
    output reg                    m4_wr_init_done=0   ,
    
    input                         ddr_clk             ,
    input                         ddr_rstn            ,
    
    input                         vout_clk            ,
    input                         rd_fsync            ,
    input                         rd_en               ,
    output                        vout_de             ,
    output [PIX_WIDTH- 1'b1 : 0]  vout_data           ,
    output reg                    init_done=0         ,
    
    output [CTRL_ADDR_WIDTH-1:0]  axi_awaddr          ,
    output [3:0]                  axi_awid            ,
    output [3:0]                  axi_awlen           ,
    output [2:0]                  axi_awsize          ,
    output [1:0]                  axi_awburst         ,
    input                         axi_awready         ,
    output                        axi_awvalid         ,

    output [MEM_DQ_WIDTH*8-1:0]   axi_wdata           ,
    output [MEM_DQ_WIDTH -1 :0]   axi_wstrb           ,
    input                         axi_wlast           ,
    output                        axi_wvalid          ,
    input                         axi_wready          ,
    input  [3 : 0]                axi_bid             ,                                      

    output [CTRL_ADDR_WIDTH-1:0]  axi_araddr          ,
    output [3:0]                  axi_arid            ,
    output [3:0]                  axi_arlen           ,
    output [2:0]                  axi_arsize          ,
    output [1:0]                  axi_arburst         ,
    output                        axi_arvalid         ,
    input                         axi_arready         ,

    output                        axi_rready          ,
    input  [MEM_DQ_WIDTH*8-1:0]   axi_rdata           ,
    input                         axi_rvalid          ,
    input                         axi_rlast           ,
    input  [3:0]                  axi_rid            
);

parameter LEN_WIDTH       = 32;
parameter LINE_ADDR_WIDTH = 22;//19;//1440 * 1080 = 1 555 200 = 21'h17BB00
parameter FRAME_CNT_WIDTH = CTRL_ADDR_WIDTH - LINE_ADDR_WIDTH;

            
wire                                m1_wr_req         ;
wire   [CTRL_ADDR_WIDTH-1'd1:0]     m1_wr_addr        ;
wire   [M1_LEN_WIDTH-1'd1:0]        m1_wr_len         ;
wire                                m1_ddr_wrdy       ;
wire                                m1_ddr_wdone      ;
wire   [8*DQ_WIDTH-1'd1:0]          m1_wr_data        ;
wire                                m1_ddr_wdata_req  ;

wire                                m2_wr_req         ;
wire   [CTRL_ADDR_WIDTH-1'd1:0]     m2_wr_addr        ;
wire   [M1_LEN_WIDTH-1'd1:0]        m2_wr_len         ;
wire                                m2_ddr_wrdy       ;
wire                                m2_ddr_wdone      ;
wire   [8*DQ_WIDTH-1'd1:0]          m2_wr_data        ;
wire                                m2_ddr_wdata_req  ; 

wire                                m3_wr_req         ;
wire     [CTRL_ADDR_WIDTH-1'd1:0]   m3_wr_addr        ;
wire     [M1_LEN_WIDTH-1'd1:0]      m3_wr_len         ;
wire                                m3_ddr_wrdy       ;
wire                                m3_ddr_wdone      ;
wire     [8*DQ_WIDTH-1'd1:0]        m3_wr_data        ;
wire                                m3_ddr_wdata_req  ; 

wire                                m4_wr_req         ;
wire   [CTRL_ADDR_WIDTH-1'd1:0]     m4_wr_addr        ;
wire   [M1_LEN_WIDTH-1'd1:0]        m4_wr_len         ;
wire                                m4_ddr_wrdy       ;
wire                                m4_ddr_wdone      ;
wire   [8*DQ_WIDTH-1'd1:0]          m4_wr_data        ;
wire                                m4_ddr_wdata_req  ; 

wire                                wr_cmd_en         ;
wire     [CTRL_ADDR_WIDTH-1:0]      wr_cmd_addr       ;
wire     [31:0]                     wr_cmd_len        ;
wire                                wr_cmd_ready      ;
wire                                wr_cmd_done       ;
wire                                wr_bac            ;       
wire     [MEM_DQ_WIDTH*8-1:0]       wr_ctrl_data      ;
wire                                wr_data_re        ;

wire                                frame_wirq        ;
wr_buf #(
        .ADDR_WIDTH       (  CTRL_ADDR_WIDTH  ),//parameter                     ADDR_WIDTH      = 6'd27,
        //.ADDR_OFFSET      (  32'd0            ),//parameter                     ADDR_OFFSET     = 32'h0000_0000,
        .ALL_H_NUM        (  H_NUM            ),//parameter                     H_NUM           = 12'd1920,
        .ALL_V_NUM        (  V_NUM            ),//parameter                     V_NUM           = 12'd1080,
        .DQ_WIDTH         (  MEM_DQ_WIDTH     ),//parameter                     DQ_WIDTH        = 7'd32,
        .LEN_WIDTH        (  LEN_WIDTH        ),//parameter                     LEN_WIDTH       = 6'd16,
        .PIX_WIDTH        (  PIX_WIDTH        ),//parameter                     PIX_WIDTH       = 6'd24,
        .LINE_ADDR_WIDTH  (  LINE_ADDR_WIDTH  ),//parameter                     LINE_ADDR_WIDTH = 4'd19,
        .FRAME_CNT_WIDTH  (  FRAME_CNT_WIDTH  ) //parameter                     FRAME_CNT_WIDTH = 4'd8
    ) wr_buf_1 (                                       
        .ddr_clk          (  ddr_clk          ),//input                         ddr_clk,
        .ddr_rstn         (  ddr_rstn         ),//input                         ddr_rstn,
        .ADDR_OFFSET      (  m1_ADDR_OFFSET   ),
        .H_NUM            (  m1_H_NUM         ),
        .V_NUM            (  m1_V_NUM         ),                          
        .wr_clk           (  m1_wr_vin_clk    ),//input                         wr_clk,
        .wr_fsync         (  m1_wr_wr_fsync   ),//input                         wr_fsync,
        .wr_en            (  m1_wr_wr_en      ),//input                         wr_en,
        .wr_data          (  m1_wr_wr_data    ),//input  [PIX_WIDTH- 1'b1 : 0]  wr_data,
        
        .rd_bac           (                   ),//input                         rd_bac,                                      
        .ddr_wreq         (  m1_wr_req       ),//output                        ddr_wreq,
        .ddr_waddr        (  m1_wr_addr       ),//output [ADDR_WIDTH- 1'b1 : 0] ddr_waddr,
        .ddr_wr_len       (  m1_wr_len        ),//output [LEN_WIDTH- 1'b1 : 0]  ddr_wr_len,
        .ddr_wrdy         (  m1_ddr_wrdy      ),//input                         ddr_wrdy,
        .ddr_wdone        (  m1_ddr_wdone     ),//input                         ddr_wdone,
        .ddr_wdata        (  m1_wr_data       ),//output [8*DQ_WIDTH- 1'b1 : 0] ddr_wdata,
        .ddr_wdata_req    (  m1_ddr_wdata_req ),//input                         ddr_wdata_req,
                                              
        .frame_wcnt       (                   ),//output [FRAME_CNT_WIDTH-1 :0] frame_wcnt,
        .frame_wirq       (   frame_wirq      ) //output                        frame_wirq
    );

wr_buf #(
        .ADDR_WIDTH       (  CTRL_ADDR_WIDTH  ),//parameter                     ADDR_WIDTH      = 6'd27,
        //.ADDR_OFFSET      (  32'd0            ),//parameter                     ADDR_OFFSET     = 32'h0000_0000,
        .ALL_H_NUM        (  H_NUM            ),//parameter                     H_NUM           = 12'd1920,
        .ALL_V_NUM        (  V_NUM            ),//parameter                     V_NUM           = 12'd1080,
        .DQ_WIDTH         (  MEM_DQ_WIDTH     ),//parameter                     DQ_WIDTH        = 7'd32,
        .LEN_WIDTH        (  LEN_WIDTH        ),//parameter                     LEN_WIDTH       = 6'd16,
        .PIX_WIDTH        (  PIX_WIDTH        ),//parameter                     PIX_WIDTH       = 6'd24,
        .LINE_ADDR_WIDTH  (  LINE_ADDR_WIDTH  ),//parameter                     LINE_ADDR_WIDTH = 4'd19,
        .FRAME_CNT_WIDTH  (  FRAME_CNT_WIDTH  ) //parameter                     FRAME_CNT_WIDTH = 4'd8
    ) wr_buf_2 (                                       
        .ddr_clk          (  ddr_clk          ),//input                         ddr_clk,
        .ddr_rstn         (  ddr_rstn         ),//input                         ddr_rstn,

        .ADDR_OFFSET      (  m2_ADDR_OFFSET   ),
        .H_NUM            (  m2_H_NUM         ),
        .V_NUM            (  m2_V_NUM         ),                                               
        .wr_clk           (  m2_wr_vin_clk    ),//input                         wr_clk,
        .wr_fsync         (  m2_wr_wr_fsync   ),//input                         wr_fsync,
        .wr_en            (  m2_wr_wr_en      ),//input                         wr_en,
        .wr_data          (  m2_wr_wr_data    ),//input  [PIX_WIDTH- 1'b1 : 0]  wr_data,
        
        .rd_bac           (                   ),//input                         rd_bac,                                      
        .ddr_wreq         (  m2_wr_req        ),//output                        ddr_wreq,
        .ddr_waddr        (  m2_wr_addr       ),//output [ADDR_WIDTH- 1'b1 : 0] ddr_waddr,
        .ddr_wr_len       (  m2_wr_len        ),//output [LEN_WIDTH- 1'b1 : 0]  ddr_wr_len,
        .ddr_wrdy         (  m2_ddr_wrdy      ),//input                         ddr_wrdy,
        .ddr_wdone        (  m2_ddr_wdone     ),//input                         ddr_wdone,
        .ddr_wdata        (  m2_wr_data       ),//output [8*DQ_WIDTH- 1'b1 : 0] ddr_wdata,
        .ddr_wdata_req    (  m2_ddr_wdata_req ),//input                         ddr_wdata_req,
                                              
        .frame_wcnt       (                   ),//output [FRAME_CNT_WIDTH-1 :0] frame_wcnt,
        .frame_wirq       (                   ) //output                        frame_wirq
    );
   
wr_buf #(
        .ADDR_WIDTH       (  CTRL_ADDR_WIDTH  ),//parameter                     ADDR_WIDTH      = 6'd27,
        //.ADDR_OFFSET      (  32'd0            ),//parameter                     ADDR_OFFSET     = 32'h0000_0000,
        .ALL_H_NUM        (  H_NUM            ),//parameter                     H_NUM           = 12'd1920,
        .ALL_V_NUM        (  V_NUM            ),//parameter                     V_NUM           = 12'd1080,
        .DQ_WIDTH         (  MEM_DQ_WIDTH     ),//parameter                     DQ_WIDTH        = 7'd32,
        .LEN_WIDTH        (  LEN_WIDTH        ),//parameter                     LEN_WIDTH       = 6'd16,
        .PIX_WIDTH        (  PIX_WIDTH        ),//parameter                     PIX_WIDTH       = 6'd24,
        .LINE_ADDR_WIDTH  (  LINE_ADDR_WIDTH  ),//parameter                     LINE_ADDR_WIDTH = 4'd19,
        .FRAME_CNT_WIDTH  (  FRAME_CNT_WIDTH  ) //parameter                     FRAME_CNT_WIDTH = 4'd8
    ) wr_buf_3 (                                       
        .ddr_clk          (  ddr_clk          ),//input                         ddr_clk,
        .ddr_rstn         (  ddr_rstn         ),//input                         ddr_rstn,

        .ADDR_OFFSET      (  m3_ADDR_OFFSET   ),
        .H_NUM            (  m3_H_NUM         ),
        .V_NUM            (  m3_V_NUM         ), 
        .wr_clk           (  m3_wr_vin_clk    ),//input                         wr_clk,
        .wr_fsync         (  m3_wr_wr_fsync   ),//input                         wr_fsync,
        .wr_en            (  m3_wr_wr_en      ),//input                         wr_en,
        .wr_data          (  m3_wr_wr_data    ),//input  [PIX_WIDTH- 1'b1 : 0]  wr_data,
        
        .rd_bac           (                   ),//input                         rd_bac,                                      
        .ddr_wreq         (  m3_wr_req        ),//output                        ddr_wreq,
        .ddr_waddr        (  m3_wr_addr       ),//output [ADDR_WIDTH- 1'b1 : 0] ddr_waddr,
        .ddr_wr_len       (  m3_wr_len        ),//output [LEN_WIDTH- 1'b1 : 0]  ddr_wr_len,
        .ddr_wrdy         (  m3_ddr_wrdy      ),//input                         ddr_wrdy,
        .ddr_wdone        (  m3_ddr_wdone     ),//input                         ddr_wdone,
        .ddr_wdata        (  m3_wr_data       ),//output [8*DQ_WIDTH- 1'b1 : 0] ddr_wdata,
        .ddr_wdata_req    (  m3_ddr_wdata_req ),//input                         ddr_wdata_req,
                                              
        .frame_wcnt       (                   ),//output [FRAME_CNT_WIDTH-1 :0] frame_wcnt,
        .frame_wirq       (                   ) //output                        frame_wirq
    );

wr_buf #(
        .ADDR_WIDTH       (  CTRL_ADDR_WIDTH  ),//parameter                     ADDR_WIDTH      = 6'd27,
        //.ADDR_OFFSET      (  32'd0            ),//parameter                     ADDR_OFFSET     = 32'h0000_0000,
        .ALL_H_NUM        (  H_NUM            ),//parameter                     H_NUM           = 12'd1920,
        .ALL_V_NUM        (  V_NUM            ),//parameter                     V_NUM           = 12'd1080,
        .DQ_WIDTH         (  MEM_DQ_WIDTH     ),//parameter                     DQ_WIDTH        = 7'd32,
        .LEN_WIDTH        (  LEN_WIDTH        ),//parameter                     LEN_WIDTH       = 6'd16,
        .PIX_WIDTH        (  PIX_WIDTH        ),//parameter                     PIX_WIDTH       = 6'd24,
        .LINE_ADDR_WIDTH  (  LINE_ADDR_WIDTH  ),//parameter                     LINE_ADDR_WIDTH = 4'd19,
        .FRAME_CNT_WIDTH  (  FRAME_CNT_WIDTH  ) //parameter                     FRAME_CNT_WIDTH = 4'd8
    ) wr_buf_4 (                                       
        .ddr_clk          (  ddr_clk          ),//input                         ddr_clk,
        .ddr_rstn         (  ddr_rstn         ),//input                         ddr_rstn,

        .ADDR_OFFSET      (  m4_ADDR_OFFSET   ),
        .H_NUM            (  m4_H_NUM         ),
        .V_NUM            (  m4_V_NUM         ),                                               
        .wr_clk           (  m4_wr_vin_clk    ),//input                         wr_clk,
        .wr_fsync         (  m4_wr_wr_fsync   ),//input                         wr_fsync,
        .wr_en            (  m4_wr_wr_en      ),//input                         wr_en,
        .wr_data          (  m4_wr_wr_data    ),//input  [PIX_WIDTH- 1'b1 : 0]  wr_data,
        
        .rd_bac           (                   ),//input                         rd_bac,                                      
        .ddr_wreq         (  m4_wr_req        ),//output                        ddr_wreq,
        .ddr_waddr        (  m4_wr_addr       ),//output [ADDR_WIDTH- 1'b1 : 0] ddr_waddr,
        .ddr_wr_len       (  m4_wr_len        ),//output [LEN_WIDTH- 1'b1 : 0]  ddr_wr_len,
        .ddr_wrdy         (  m4_ddr_wrdy      ),//input                         ddr_wrdy,
        .ddr_wdone        (  m4_ddr_wdone     ),//input                         ddr_wdone,
        .ddr_wdata        (  m4_wr_data       ),//output [8*DQ_WIDTH- 1'b1 : 0] ddr_wdata,
        .ddr_wdata_req    (  m4_ddr_wdata_req ),//input                         ddr_wdata_req,
                                              
        .frame_wcnt       (                   ),//output [FRAME_CNT_WIDTH-1 :0] frame_wcnt,
        .frame_wirq       (                   ) //output                        frame_wirq
    );
wire                        rd_cmd_en   ;
wire [CTRL_ADDR_WIDTH-1:0]  rd_cmd_addr ;
wire [LEN_WIDTH- 1'b1: 0]   rd_cmd_len  ;
wire                        rd_cmd_ready;
wire                        rd_cmd_done;
                            
wire                        read_ready  = 1'b1;
wire [MEM_DQ_WIDTH*8-1:0]   read_rdata  ;
wire                        read_en;
    rd_buf #(
        .ADDR_WIDTH       (  CTRL_ADDR_WIDTH  ),//parameter                     ADDR_WIDTH      = 6'd27,
        .ADDR_OFFSET      (  32'h0000_0000    ),//parameter                     ADDR_OFFSET     = 32'h0000_0000,
        .H_NUM            (  H_NUM            ),//parameter                     H_NUM           = 12'd1920,
        .V_NUM            (  V_NUM            ),//parameter                     V_NUM           = 12'd1080,
        .DQ_WIDTH         (  MEM_DQ_WIDTH     ),//parameter                     DQ_WIDTH        = 7'd32,
        .LEN_WIDTH        (  LEN_WIDTH        ),//parameter                     LEN_WIDTH       = 6'd16,
        .PIX_WIDTH        (  PIX_WIDTH        ),//parameter                     PIX_WIDTH       = 6'd24,
        .LINE_ADDR_WIDTH  (  LINE_ADDR_WIDTH  ),//parameter                     LINE_ADDR_WIDTH = 4'd19,
        .FRAME_CNT_WIDTH  (  FRAME_CNT_WIDTH  ) //parameter                     FRAME_CNT_WIDTH = 4'd8
    ) rd_buf (
        .mode            (  mode              ),
        .ddr_clk         (  ddr_clk           ),//input                         ddr_clk,
        .ddr_rstn        (  ddr_rstn          ),//input                         ddr_rstn,

        .vout_clk        (  vout_clk          ),//input                         vout_clk,
        .rd_fsync        (  rd_fsync          ),//input                         rd_fsync,
        .rd_en           (  rd_en             ),//input                         rd_en,
        .vout_de         (  vout_de           ),//output                        vout_de,
        .vout_data       (  vout_data         ),//output [PIX_WIDTH- 1'b1 : 0]  vout_data,
        
        .init_done       (  init_done         ),//input                         init_done,
      
        .ddr_rreq        (  rd_cmd_en         ),//output                        ddr_rreq,
        .ddr_raddr       (  rd_cmd_addr       ),//output [ADDR_WIDTH- 1'b1 : 0] ddr_raddr,
        .ddr_rd_len      (  rd_cmd_len        ),//output [LEN_WIDTH- 1'b1 : 0]  ddr_rd_len,
        .ddr_rrdy        (  rd_cmd_ready      ),//input                         ddr_rrdy,
        .ddr_rdone       (  rd_cmd_done       ),//input                         ddr_rdone,
                                              
        .ddr_rdata       (  read_rdata        ),//input [8*DQ_WIDTH- 1'b1 : 0]  ddr_rdata,
        .ddr_rdata_en    (  read_en           ) //input                         ddr_rdata_en,
    );
    always @(posedge ddr_clk)
    begin
        if(frame_wirq)
            init_done <= 1'b1;
        else
            init_done <= init_done;
    end 
ddr_arbit#(
         .DDR_ADDR_WIDTH (5'd28  )     ,
         .DQ_WIDTH       (6'd32  )     ,
         .DDR_DATA_WIDTH (8'd255 )     ,
         .MEM_DQ_WIDTH   (32     )     ,
         .M1_LEN_WIDTH   (4'd16  )     ,
         .M2_LEN_WIDTH   (4'd16  )     ,  
         .M3_LEN_WIDTH   (4'd16  )     ,
         .M4_LEN_WIDTH   (4'd16  )     ,
         .RD_LEN_WIDTH   (4'd16  )     
   )ddr_arbit(
         .ddr_clk             (     ddr_clk        ),
         .rstn                (     ddr_rstn       ),
         
         .m1_wr_req           (     m1_wr_req            ),
         .m1_wr_addr          (     m1_wr_addr           ),
         .m1_wr_len           (     m1_wr_len            ),
         .m1_ddr_wrdy         (     m1_ddr_wrdy          ),
         .m1_ddr_wdone        (     m1_ddr_wdone         ),
         .m1_wr_data          (     m1_wr_data           ),
         .m1_ddr_wdata_req    (     m1_ddr_wdata_req     ),

         .m2_wr_req           (     m2_wr_req            ),
         .m2_wr_addr          (     m2_wr_addr           ),
         .m2_wr_len           (     m2_wr_len            ),
         .m2_ddr_wrdy         (     m2_ddr_wrdy          ),
         .m2_ddr_wdone        (     m2_ddr_wdone         ),
         .m2_wr_data          (     m2_wr_data           ),
         .m2_ddr_wdata_req    (     m2_ddr_wdata_req     ),

         .m3_wr_req           (     m3_wr_req            ),
         .m3_wr_addr          (     m3_wr_addr           ),
         .m3_wr_len           (     m3_wr_len            ),
         .m3_ddr_wrdy         (     m3_ddr_wrdy          ),
         .m3_ddr_wdone        (     m3_ddr_wdone         ),
         .m3_wr_data          (     m3_wr_data           ),
         .m3_ddr_wdata_req    (     m3_ddr_wdata_req     ),

         .m4_wr_req           (     m4_wr_req            ),
         .m4_wr_addr          (     m4_wr_addr           ),
         .m4_wr_len           (     m4_wr_len            ),
         .m4_ddr_wrdy         (     m4_ddr_wrdy          ),
         .m4_ddr_wdone        (     m4_ddr_wdone         ),
         .m4_wr_data          (     m4_wr_data           ),
         .m4_ddr_wdata_req    (     m4_ddr_wdata_req     ),

         .m1_rd_addr          (                          ),
         .m1_rd_len           (                          ),
         .m1_rd_req           (                          ),
         .m1_rd_data          (                          ),
         .m1_rd_ddr_rrdy      (                          ),
         .m1_rd_ddr_rdata_en  (                          ),
         .m1_rd_ddr_rdone     (                          ),

         .wr_cmd_en           (      wr_cmd_en           ),
         .wr_cmd_addr         (      wr_cmd_addr         ),
         .wr_cmd_len          (      wr_cmd_len          ),
         .wr_cmd_ready        (      wr_cmd_ready        ),
         .wr_cmd_done         (      wr_cmd_done         ),// one row down
         .wr_bac              (      wr_bac              ),
         .wr_ctrl_data        (      wr_ctrl_data        ),
         .wr_data_re          (      wr_data_re          ),

         .rd_cmd_en           (                          ),
         .rd_cmd_addr         (                          ),
         .rd_cmd_len          (                          ),
         .read_data           (                          ),
         .rd_cmd_ready        (                          ),
         .rd_cmd_done         (                          ),
         .read_en             (                          )
);

   wr_rd_ctrl_top#(
        .CTRL_ADDR_WIDTH  (  CTRL_ADDR_WIDTH  ),//parameter                    CTRL_ADDR_WIDTH      = 28,
        .MEM_DQ_WIDTH     (  MEM_DQ_WIDTH     ) //parameter                    MEM_DQ_WIDTH         = 16
    )wr_rd_ctrl_top (                         
        .clk              (  ddr_clk          ),//input                        clk            ,            
        .rstn             (  ddr_rstn         ),//input                        rstn           ,            
                                              
        .wr_cmd_en        (  wr_cmd_en        ),//input                        wr_cmd_en   ,
        .wr_cmd_addr      (  wr_cmd_addr      ),//input  [CTRL_ADDR_WIDTH-1:0] wr_cmd_addr ,
        .wr_cmd_len       (  wr_cmd_len       ),//input  [31£º0]               wr_cmd_len  ,
        .wr_cmd_ready     (  wr_cmd_ready     ),//output                       wr_cmd_ready,
        .wr_cmd_done      (  wr_cmd_done      ),//output                       wr_cmd_done,
        .wr_bac           (  wr_bac           ),//output                       wr_bac,                                     
        .wr_ctrl_data     (  wr_ctrl_data     ),//input  [MEM_DQ_WIDTH*8-1:0]  wr_ctrl_data,
        .wr_data_re       (  wr_data_re       ),//output                       wr_data_re  ,
                                              
        .rd_cmd_en        (  rd_cmd_en        ),//input                        rd_cmd_en   ,
        .rd_cmd_addr      (  rd_cmd_addr      ),//input  [CTRL_ADDR_WIDTH-1:0] rd_cmd_addr ,
        .rd_cmd_len       (  rd_cmd_len       ),//input  [31£º0]               rd_cmd_len  ,
        .rd_cmd_ready     (  rd_cmd_ready     ),//output                       rd_cmd_ready, 
        .rd_cmd_done      (  rd_cmd_done      ),//output                       rd_cmd_done,
                                              
        .read_ready       (  read_ready       ),//input                        read_ready  ,    
        .read_rdata       (  read_rdata       ),//output [MEM_DQ_WIDTH*8-1:0]  read_rdata  ,    
        .read_en          (  read_en          ),//output                       read_en     ,                                          
        // write channel                        
        .axi_awaddr       (  axi_awaddr       ),//output [CTRL_ADDR_WIDTH-1:0] axi_awaddr     ,  
        .axi_awid         (  axi_awid         ),//output [3:0]                 axi_awid       ,
        .axi_awlen        (  axi_awlen        ),//output [3:0]                 axi_awlen      ,
        .axi_awsize       (  axi_awsize       ),//output [2:0]                 axi_awsize     ,
        .axi_awburst      (  axi_awburst      ),//output [1:0]                 axi_awburst    , //only support 2'b01: INCR
        .axi_awready      (  axi_awready      ),//input                        axi_awready    ,
        .axi_awvalid      (  axi_awvalid      ),//output                       axi_awvalid    ,
                                              
        .axi_wdata        (  axi_wdata        ),//output [MEM_DQ_WIDTH*8-1:0]  axi_wdata      ,
        .axi_wstrb        (  axi_wstrb        ),//output [MEM_DQ_WIDTH -1 :0]  axi_wstrb      ,
        .axi_wlast        (  axi_wlast        ),//output                       axi_wlast      ,
        .axi_wvalid       (  axi_wvalid       ),//output                       axi_wvalid     ,
        .axi_wready       (  axi_wready       ),//input                        axi_wready     ,
        .axi_bid          (  4'd0             ),//input  [3 : 0]               axi_bid        , // Master Interface Write Response.
        .axi_bresp        (  2'd0             ),//input  [1 : 0]               axi_bresp      , // Write response. This signal indicates the status of the write transaction.
        .axi_bvalid       (  1'b0             ),//input                        axi_bvalid     , // Write response valid. This signal indicates that the channel is signaling a valid write response.
        .axi_bready       (                   ),//output                       axi_bready     ,
                                              
        // read channel                          
        .axi_araddr       (  axi_araddr       ),//output [CTRL_ADDR_WIDTH-1:0] axi_araddr     ,    
        .axi_arid         (  axi_arid         ),//output [3:0]                 axi_arid       ,
        .axi_arlen        (  axi_arlen        ),//output [3:0]                 axi_arlen      ,
        .axi_arsize       (  axi_arsize       ),//output [2:0]                 axi_arsize     ,
        .axi_arburst      (  axi_arburst      ),//output [1:0]                 axi_arburst    ,
        .axi_arvalid      (  axi_arvalid      ),//output                       axi_arvalid    , 
        .axi_arready      (  axi_arready      ),//input                        axi_arready    , //only support 2'b01: INCR
                                              
        .axi_rready       (  axi_rready       ),//output                       axi_rready     ,
        .axi_rdata        (  axi_rdata        ),//input  [MEM_DQ_WIDTH*8-1:0]  axi_rdata      ,
        .axi_rvalid       (  axi_rvalid       ),//input                        axi_rvalid     ,
        .axi_rlast        (  axi_rlast        ),//input                        axi_rlast      ,
        .axi_rid          (  axi_rid          ),//input  [3:0]                 axi_rid        ,
        .axi_rresp        (  2'd0             ) //input  [1:0]                 axi_rresp      
    );

endmodule