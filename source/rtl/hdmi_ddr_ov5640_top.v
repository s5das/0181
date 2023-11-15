`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-03-17  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define UD #1
//浠ヤ笅涓夌�嶆ā�??忎换��??変�?�绉嶏紝浣滀负瑙嗛�戞簮杈撳��??
//`define CMOS_1      //cmos1浣滀负瑙嗛�戣緭鍏ワ��??
//`define CMOS_2      //cmos2浣滀负瑙嗛�戣緭鍏ワ��??
//`define HDMI_IN     //hdmi_in浣滀负瑙嗛�戣緭鍏ワ��??

module hdmi_ddr_ov5640_top#(
	parameter MEM_ROW_ADDR_WIDTH   = 15         ,
	parameter MEM_COL_ADDR_WIDTH   = 10         ,
	parameter MEM_BADDR_WIDTH      = 3          ,
	parameter MEM_DQ_WIDTH         =  32        ,
	parameter MEM_DQS_WIDTH        =  32/8
)(
	input                                sys_clk              ,//50Mhz	
//OV5647
    output  [1:0]                        cmos_init_done       ,//OV5640瀵勫瓨鍣ㄥ垵��??��??寲瀹屾��??
    //coms1	
    inout                                cmos1_scl            ,//cmos1 i2c 
    inout                                cmos1_sda            ,//cmos1 i2c 
    input                                cmos1_vsync          ,//cmos1 vsync
    input                                cmos1_href           ,//cmos1 hsync refrence,data valid
    input                                cmos1_pclk           ,//cmos1 pxiel clock
    input   [7:0]                        cmos1_data           ,//cmos1 data
    output                               cmos1_reset          ,//cmos1 reset
    //coms2
    inout                                cmos2_scl            ,//cmos2 i2c 
    inout                                cmos2_sda            ,//cmos2 i2c 
    input                                cmos2_vsync          ,//cmos2 vsync
    input                                cmos2_href           ,//cmos2 hsync refrence,data valid
    input                                cmos2_pclk           ,//cmos2 pxiel clock
    input   [7:0]                        cmos2_data           ,//cmos2 data
    output                               cmos2_reset          ,//cmos2 reset
//DDR
    output                               mem_rst_n                 ,
    output                               mem_ck                    ,
    output                               mem_ck_n                  ,
    output                               mem_cke                   ,
    output                               mem_cs_n                  ,
    output                               mem_ras_n                 ,
    output                               mem_cas_n                 ,
    output                               mem_we_n                  ,
    output                               mem_odt                   ,
    output      [MEM_ROW_ADDR_WIDTH-1:0] mem_a                     ,
    output      [MEM_BADDR_WIDTH-1:0]    mem_ba                    ,
    inout       [MEM_DQ_WIDTH/8-1:0]     mem_dqs                   ,
    inout       [MEM_DQ_WIDTH/8-1:0]     mem_dqs_n                 ,
    inout       [MEM_DQ_WIDTH-1:0]       mem_dq                    ,
    output      [MEM_DQ_WIDTH/8-1:0]     mem_dm                    ,
    output reg                           heart_beat_led            ,
    output                               ddr_init_done             ,
//MS72xx       
    output                               rstn_out                  ,
    output                               iic_scl                   ,
    inout                                iic_sda                   , 
    output                               iic_tx_scl                ,
    inout                                iic_tx_sda                ,
    output[1:0]                          hdmi_int_led              ,//HDMI鍒濆��??寲瀹屾��??
//HDMI_IN 
    input                                pixclk_in                 ,                            
    input                                vs_in                     ,     
    input                                hs_in                     , 
    input                                de_in                     ,
    input      [7:0]                     r_in                      , 
    input      [7:0]                     g_in                      , 
    input      [7:0]                     b_in                      ,
//HDMI_OUT
    output                               pix_clk                   ,//pixclk                           
    output                               vs_out                    , 
    output                               hs_out                    , 
    output                               de_out                    ,
    output     wire[7:0]                 r_out                     , 
    output     wire[7:0]                 g_out                     , 
    output     wire[7:0]                 b_out                     ,

    input                                key8                      ,
    input                                key1                      ,
    input                                key2                      ,
    input                                key3                      ,
    input                                key4                      ,
    input                                key5                      ,
    input                                key6                      ,
    input                                key7                      ,

    //eth sd
    //SD卡接口
    input               sd_miso     ,  //SD卡SPI串行输入数据信号
    output              sd_clk      ,  //SD卡SPI时钟信号
    output              sd_cs       ,  //SD卡SPI片选信号
    output              sd_mosi     ,  //SD卡SPI串行输出数据信号     

   
    output       phy_rstn,

    input        rgmii_rxc,
    input        rgmii_rx_ctl,
    input [3:0]  rgmii_rxd,
                 
    output       rgmii_txc,
    output       rgmii_tx_ctl,
    output [3:0] rgmii_txd
);
/////////////////////////////////////////////////////////////////////////////////////
// ENABLE_DDR
    parameter CTRL_ADDR_WIDTH = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH;//28
    parameter TH_1S = 27'd33000000;
/////////////////////////////////////////////////////////////////////////////////////
    reg  [15:0]                 rstn_1ms            ;
    wire                        cmos_scl            ;//cmos i2c clock
    wire                        cmos_sda            ;//cmos i2c data
    wire                        cmos_vsync          ;//cmos vsync
    wire                        cmos_href           ;//cmos hsync refrence,data valid
    wire                        cmos_pclk           ;//cmos pxiel clock
    wire   [7:0]                cmos_data           ;//cmos data
    wire                        cmos_reset          ;//cmos reset
    wire                        initial_en          ;
    wire[15:0]                  cmos1_d_16bit       ;
    wire                        cmos1_href_16bit    ;
    reg [7:0]                   cmos1_d_d0          ;
    reg                         cmos1_href_d0       ;
    reg                         cmos1_vsync_d0      ;
    wire                        cmos1_pclk_16bit    ;
    wire[15:0]                  cmos2_d_16bit       /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                        cmos2_href_16bit    /*synthesis PAP_MARK_DEBUG="1"*/;
    reg [7:0]                   cmos2_d_d0          /*synthesis PAP_MARK_DEBUG="1"*/;
    reg                         cmos2_href_d0       /*synthesis PAP_MARK_DEBUG="1"*/;
    reg                         cmos2_vsync_d0      /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                        cmos2_pclk_16bit    /*synthesis PAP_MARK_DEBUG="1"*/;
    wire[15:0]                  o_rgb565            ;
    wire                        pclk_in_test        ;    
    wire                        vs_in_test          ;
    wire                        de_in_test          ;
    wire[15:0]                  i_rgb565            ;
    wire                        pclk_in_test2        ;    
    wire                        vs_in_test2          ;
    wire                        de_in_test2          ;
    wire[15:0]                  i_rgb5652            ;
    wire                        pclk_in_test3        ;    
    wire                        vs_in_test3          ;
    wire                        de_in_test3          ;
    wire[15:0]                  i_rgb5653            ;
    wire                        de_re               ;
    wire[11:0]                  x_act               ;
    wire[11:0]                  y_act               ;
//axi bus   
    wire [CTRL_ADDR_WIDTH-1:0]  axi_awaddr                 ;
    wire                        axi_awuser_ap              ;
    wire [3:0]                  axi_awuser_id              ;
    wire [3:0]                  axi_awlen                  ;
    wire                        axi_awready                ;/*synthesis PAP_MARK_DEBUG="1"*/
    wire                        axi_awvalid                ;/*synthesis PAP_MARK_DEBUG="1"*/
    wire [MEM_DQ_WIDTH*8-1:0]   axi_wdata                  ;
    wire [MEM_DQ_WIDTH*8/8-1:0] axi_wstrb                  ;
    wire                        axi_wready                 ;/*synthesis PAP_MARK_DEBUG="1"*/
    wire [3:0]                  axi_wusero_id              ;
    wire                        axi_wusero_last            ;
    wire [CTRL_ADDR_WIDTH-1:0]  axi_araddr                 ;
    wire                        axi_aruser_ap              ;
    wire [3:0]                  axi_aruser_id              ;
    wire [3:0]                  axi_arlen                  ;
    wire                        axi_arready                ;/*synthesis PAP_MARK_DEBUG="1"*/
    wire                        axi_arvalid                ;/*synthesis PAP_MARK_DEBUG="1"*/
    wire [MEM_DQ_WIDTH*8-1:0]   axi_rdata                   /* synthesis syn_keep = 1 */;
    wire                        axi_rvalid                  /* synthesis syn_keep = 1 */;
    wire [3:0]                  axi_rid                    ;
    wire                        axi_rlast                  ;
    reg  [26:0]                 cnt                        ;
    reg  [15:0]                 cnt_1                      ;
/////////////////////////////////////////////////////////////////////////////////////
//PLL
    pll u_pll (
        .clkin1   (  sys_clk    ),//50MHz
        .clkout1  (  cfg_clk    ),//10MHz
        .clkout2  (  clk_25M    ),//25M
        .pll_lock (  locked     )
    );
  assign pix_clk = pixclk_in;
//閰嶇��??7210
    ms72xx_ctl ms72xx_ctl(
        .clk             (  cfg_clk        ), //input       clk,
        .rst_n           (  rstn_out       ), //input       rstn,
        .init_over_tx    (  init_over_tx   ), //output      init_over,                                
        .init_over_rx    (  init_over_rx   ), //output      init_over,
        .iic_tx_scl      (  iic_tx_scl     ), //output      iic_scl,
        .iic_tx_sda      (  iic_tx_sda     ), //inout       iic_sda
        .iic_scl         (  iic_scl        ), //output      iic_scl,
        .iic_sda         (  iic_sda        )  //inout       iic_sda
    );
   assign    hdmi_int_led    =      {init_over_tx,init_over_rx}; 
    
    always @(posedge cfg_clk)
    begin
    	if(!locked)
    	    rstn_1ms <= 16'd0;
    	else
    	begin
    		if(rstn_1ms == 16'h4710)
    		    rstn_1ms <= rstn_1ms;
    		else
    		    rstn_1ms <= rstn_1ms + 1'b1;
    	end
    end
    
    assign rstn_out = (rstn_1ms == 16'h4710);

/////////////////////////////////////////////////////////////////////////////////////
//OV5640 register configure enable    
    power_on_delay	power_on_delay_inst(
    	.clk_50M                 (sys_clk        ),//input
    	.reset_n                 (1'b1           ),//input	
    	.camera1_rstn            (cmos1_reset    ),//output
    	.camera2_rstn            (cmos2_reset    ),//output	
    	.camera_pwnd             (               ),//output
    	.initial_en              (initial_en     ) //output		
    );
//CMOS1 Camera 
    reg_config	coms1_reg_config(
    	.clk_25M                 (clk_25M            ),//input
    	.camera_rstn             (cmos1_reset        ),//input
    	.initial_en              (initial_en         ),//input		
    	.i2c_sclk                (cmos1_scl          ),//output
    	.i2c_sdat                (cmos1_sda          ),//inout
    	.reg_conf_done           (cmos_init_done[0]  ),//output config_finished
    	.reg_index               (                   ),//output reg [8:0]
    	.clock_20k               (                   ) //output reg
    );

    always@(posedge cmos1_pclk)
        begin
            cmos1_d_d0        <= cmos1_data    ;
            cmos1_href_d0     <= cmos1_href    ;
            cmos1_vsync_d0    <= cmos1_vsync   ;
        end

    cmos_8_16bit cmos1_8_16bit(
    	.pclk           (cmos1_pclk       ),//input
    	.rst_n          (cmos_init_done[0]),//input
    	.pdata_i        (cmos1_d_d0       ),//input[7:0]
    	.de_i           (cmos1_href_d0    ),//input
    	.vs_i           (cmos1_vsync_d0    ),//input
    	
    	.pixel_clk      (cmos1_pclk_16bit ),//output
    	.pdata_o        (cmos1_d_16bit    ),//output[15:0]
    	.de_o           (cmos1_href_16bit ) //output
    );
//CMOS2 Camera 
    reg_config	coms2_reg_config(
    	.clk_25M                 (clk_25M            ),//input
    	.camera_rstn             (cmos2_reset        ),//input
    	.initial_en              (initial_en         ),//input		
    	.i2c_sclk                (cmos2_scl          ),//output
    	.i2c_sdat                (cmos2_sda          ),//inout
    	.reg_conf_done           (cmos_init_done[1]  ),//output config_finished
    	.reg_index               (                   ),//output reg [8:0]
    	.clock_20k               (                   ) //output reg
    );

    always@(posedge cmos2_pclk)
    begin
        cmos2_d_d0     <= cmos2_data    ;
        cmos2_href_d0  <= cmos2_href    ;
        cmos2_vsync_d0 <= cmos2_vsync   ;
    end

    cmos_8_16bit cmos2_8_16bit(
    	.pclk           (cmos2_pclk       ),//input
    	.rst_n          (cmos_init_done[0]),//input
    	.pdata_i        (cmos2_d_d0       ),//input[7:0]
    	.de_i           (cmos2_href_d0    ),//input
    	.vs_i           (cmos2_vsync_d0    ),//input
    	
    	.pixel_clk      (cmos2_pclk_16bit ),//output
    	.pdata_o        (cmos2_d_16bit    ),//output[15:0]
    	.de_o           (cmos2_href_16bit ) //output
    );
//杈撳叆瑙嗛�戞簮��??夋�??//////////////////////////////////////////////////////////////////////////////////////////

assign     pclk_in_test    =    cmos1_pclk_16bit    ;
assign     vs_in_test      =    cmos1_vsync_d0      ;
assign     de_in_test      =    cmos1_href_16bit    ;
assign     i_rgb565        =    {cmos1_d_16bit[4:0],cmos1_d_16bit[10:5],cmos1_d_16bit[15:11]};//{r,g,b}

assign     pclk_in_test2    =    cmos2_pclk_16bit    ;
assign     vs_in_test2      =    cmos2_vsync_d0      ;
assign     de_in_test2      =    cmos2_href_16bit    ;
assign     i_rgb5652        =    {cmos2_d_16bit[4:0],cmos2_d_16bit[10:5],cmos2_d_16bit[15:11]};//{r,g,b}

assign     pclk_in_test3    =    pixclk_in           ;
assign     vs_in_test3      =    vs_in               ;
assign     de_in_test3      =    de_in               ;
assign     i_rgb5653        =    {r_in[7:3],g_in[7:2],b_in[7:3]}        ;



//////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam  H_NUM  = 12'd1280;//width
localparam  V_NUM  = 12'd720; //height



//rgb to gray
wire              down_datav;
wire   [15:0]     down_data;
wire              down_datav2;
wire   [15:0]     down_data2;
wire              down_datav3;
wire   [15:0]     down_data3;

//reg               reset_key;
//
//always @(posedge pclk_in_test2) begin
//    if(rst_key==1'd0)
//        reset_key<=1'd0;
//    else    if(rst_key==1'd1&&vs_in_test2==1'd1)
//        reset_key<=1'd1;
//    else
//        reset_key<=reset_key;
//end

wire     [14:0]      y_scale_reg;
wire     [14:0]      x_scale_reg;
wire     [12:0]      TARGET_H_NUM_reg;
wire     [12:0]      TARGET_V_NUM_reg;
reg               shift;

key_config u_key_config (
    .clk                                       ( core_clk                          ),
    .rstn                                      ( rstn_out                          ),
    .key1                                      ( key5                              ),
    .key2                                      ( key6                              ),
    .shift                                     ( shift                             ),
    .y_scale                                   ( y_scale_reg                       ),
    .x_scale                                   ( x_scale_reg                       ),
    .TARGET_H_NUM                              ( TARGET_H_NUM_reg                  ),
    .TARGET_V_NUM                              ( TARGET_V_NUM_reg                  )
);



//first area scaler

wire   [15:0]        tdata_o_1;/* synthesis syn_keep = 1 */
wire                 tvaild_1;/* synthesis syn_keep = 1 */
wire                 fifo_data_rdy_1;/* synthesis syn_keep = 1 */
wire    [15:0]       fifo_data_1;/* synthesis syn_keep = 1 */
wire                 fifo_rd_en_1; /* synthesis syn_keep = 1 */
wire    [15:0]       scaler_data_out_1;/* synthesis syn_keep = 1 */
wire                 scaler_data_vaild_1;/* synthesis syn_keep = 1 */
wire    [27:0]       DDR3_ADDR_1;/* synthesis syn_keep = 1 */

reg     [14:0]      y_scale_1       =15'd2048;
reg     [14:0]      x_scale_1       =15'd2048;
reg     [12:0]      TARGET_H_NUM_1  =13'd640;
reg     [12:0]      TARGET_V_NUM_1  =13'd360;

always @(posedge pclk_in_test) begin
    if(vs_in_test==1'd1)    begin
        y_scale_1       <=y_scale_reg;
        x_scale_1       <=x_scale_reg;
        TARGET_H_NUM_1  <=TARGET_H_NUM_reg;
        TARGET_V_NUM_1  <=TARGET_V_NUM_reg;
    end
    else    begin
        y_scale_1       <=y_scale_1;
        x_scale_1       <=x_scale_1;
        TARGET_H_NUM_1  <=TARGET_H_NUM_1;
        TARGET_V_NUM_1  <=TARGET_V_NUM_1;

    end
end

image_size_down_without_fifo    image_size_down_without_fifo_1(					 					
                                    .clk_i      (pclk_in_test),
                                    .rst_i      ((!rstn_out) | vs_in_test),
                                    .width_i    (H_NUM),
                                    .height_i   (V_NUM),						 
                                    .tdata_i    (i_rgb565),
                                    .tvalid_i   (de_in_test),
                                    .tdata_o    (tdata_o_1),
                                    .tvalid_o   (tvaild_1)
                            );
scale_fifo  scale_fifo_inst
(
                            .wr_data        (  tdata_o_1      ),
                            .wr_en          (  tvaild_1       ),
                            .wr_clk         (  pclk_in_test ),
                            .wr_rst         (  (!rstn_out) | vs_in_test),
                            .wr_full        (),
                            .rd_data        (  fifo_data_1    ),
                            .rd_en          (  fifo_rd_en_1   ),
                            .rd_clk         (  pclk_in_test     ),
                            .rd_rst         (  (!rstn_out) | vs_in_test),
                            .rd_empty       (  fifo_data_rdy_1),
                            .almost_empty   (               )
);

scaler  scaler_1(
                                    .clk            (pclk_in_test)                  ,
                                    .rstn           (rstn_out & (!vs_in_test)),
                                    .x_scale        (x_scale_1),    //               
                                    .y_scale        (y_scale_1),
                                    .TARGET_H_NUM   (TARGET_H_NUM_1),
                                    .TARGET_V_NUM   (TARGET_V_NUM_1),
                                    .fifo_row_rdy   (!fifo_data_rdy_1),
                                    .fifo_data      (fifo_data_1),
                                    .rd_en          (fifo_rd_en_1),
                                    .pix_data       (scaler_data_out_1),
                                    .data_vaild     (scaler_data_vaild_1),
                                    .DDR3_ADDR      (DDR3_ADDR_1)
);

wire   [15:0]        tdata_o_2;/* synthesis syn_keep = 1 */
wire                 tvaild_2;/* synthesis syn_keep = 1 */
wire                 fifo_data_rdy_2;/* synthesis syn_keep = 1 */
wire    [15:0]       fifo_data_2;/* synthesis syn_keep = 1 */
wire                 fifo_rd_en_2; /* synthesis syn_keep = 1 */
wire    [15:0]       scaler_data_out_2;/* synthesis syn_keep = 1 */
wire                 scaler_data_vaild_2;/* synthesis syn_keep = 1 */
wire    [27:0]       DDR3_ADDR_2;/* synthesis syn_keep = 1 */


reg     [14:0]      y_scale_2       =15'd2048;
reg     [14:0]      x_scale_2       =15'd2048;
reg     [12:0]      TARGET_H_NUM_2  =13'd640;
reg     [12:0]      TARGET_V_NUM_2  =13'd360;

always @(posedge pclk_in_test3) begin
    if(vs_in_test3==1'd1)    begin
        y_scale_2       <=y_scale_reg;
        x_scale_2       <=x_scale_reg;
        TARGET_H_NUM_2  <=TARGET_H_NUM_reg;
        TARGET_V_NUM_2  <=TARGET_V_NUM_reg;
    end
    else    begin
        y_scale_2       <=y_scale_2;
        x_scale_2       <=x_scale_2;
        TARGET_H_NUM_2  <=TARGET_H_NUM_2;
        TARGET_V_NUM_2  <=TARGET_V_NUM_2;

    end
end

image_size_down_without_fifo    image_size_down_without_fifo_2(					 					
                                    .clk_i      (pclk_in_test3),
                                    .rst_i      ((!rstn_out) | vs_in_test3),
                                    .width_i    (H_NUM),
                                    .height_i   (V_NUM),						 
                                    .tdata_i    (i_rgb5653),
                                    .tvalid_i   (de_in_test3),
                                    .tdata_o    (tdata_o_2),
                                    .tvalid_o   (tvaild_2)
                     );
scale_fifo  scale_fifo_inst_2
(
                            .wr_data        (  tdata_o_2      ),
                            .wr_en          (  tvaild_2       ),
                            .wr_clk         (  pclk_in_test3 ),
                            .wr_rst         (  (!rstn_out) | vs_in_test3),
                            .wr_full        (                 ),
                            .rd_data        (  fifo_data_2    ),
                            .rd_en          (  fifo_rd_en_2   ),
                            .rd_clk         (  pclk_in_test3  ),
                            .rd_rst         (  (!rstn_out) | vs_in_test3),
                            .rd_empty       (  fifo_data_rdy_2),
                            .almost_empty   (                 )
);

scaler_2  scaler_2(
                                    .clk            (pclk_in_test3)                  ,
                                    .rstn           (rstn_out & (!vs_in_test3)),
                                    .x_scale        (x_scale_2),    //               
                                    .y_scale        (y_scale_2),
                                    .TARGET_H_NUM   (TARGET_H_NUM_2),
                                    .TARGET_V_NUM   (TARGET_V_NUM_2),
                                    .fifo_row_rdy   (!fifo_data_rdy_2),
                                    .fifo_data      (fifo_data_2),
                                    .rd_en          (fifo_rd_en_2),
                                    .pix_data       (scaler_data_out_2),
                                    .data_vaild     (scaler_data_vaild_2),
                                    .DDR3_ADDR      (DDR3_ADDR_2)
);


wire   [15:0]        tdata_o_3;/* synthesis syn_keep = 1 */
wire                 tvaild_3;/* synthesis syn_keep = 1 */
wire                 fifo_data_rdy_3;/* synthesis syn_keep = 1 */
wire    [15:0]       fifo_data_3;/* synthesis syn_keep = 1 */
wire                 fifo_rd_en_3; /* synthesis syn_keep = 1 */
wire    [15:0]       scaler_data_out_3;/* synthesis syn_keep = 1 */
wire                 scaler_data_vaild_3;/* synthesis syn_keep = 1 */
wire    [27:0]       DDR3_ADDR_3;/* synthesis syn_keep = 1 */


reg     [14:0]      y_scale_3       =15'd2048;
reg     [14:0]      x_scale_3       =15'd2048;
reg     [12:0]      TARGET_H_NUM_3  =13'd640;
reg     [12:0]      TARGET_V_NUM_3  =13'd360;

always @(posedge pclk_in_test3) begin
    if(vs_in_test3==1'd1)    begin
        y_scale_3       <=y_scale_reg;
        x_scale_3       <=x_scale_reg;
        TARGET_H_NUM_3  <=TARGET_H_NUM_reg;
        TARGET_V_NUM_3  <=TARGET_V_NUM_reg;
    end
    else    begin
        y_scale_3       <=y_scale_3;
        x_scale_3       <=x_scale_3;
        TARGET_H_NUM_3  <=TARGET_H_NUM_3;
        TARGET_V_NUM_3  <=TARGET_V_NUM_3;

    end
end

image_size_down_without_fifo    image_size_down_without_fifo_3(					 					
                                    .clk_i      (pclk_in_test3),
                                    .rst_i      ((!rstn_out) | vs_in_test3),
                                    .width_i    (H_NUM),
                                    .height_i   (V_NUM),						 
                                    .tdata_i    (i_rgb5653),
                                    .tvalid_i   (de_in_test3),
                                    .tdata_o    (tdata_o_3),
                                    .tvalid_o   (tvaild_3)
                     );
scale_fifo  scale_fifo_inst_3
(
                            .wr_data        (  tdata_o_3      ),
                            .wr_en          (  tvaild_3       ),
                            .wr_clk         (  pclk_in_test3 ),
                            .wr_rst         (  (!rstn_out) | vs_in_test3),
                            .wr_full        (                 ),
                            .rd_data        (  fifo_data_3    ),
                            .rd_en          (  fifo_rd_en_3   ),
                            .rd_clk         (  pclk_in_test3  ),
                            .rd_rst         (  (!rstn_out) | vs_in_test3),
                            .rd_empty       (  fifo_data_rdy_3),
                            .almost_empty   (                 )
);

scaler_3  scaler_3(
                                    .clk            (pclk_in_test3)                  ,
                                    .rstn           (rstn_out & (!vs_in_test3)),
                                    .x_scale        (x_scale_3),    //               
                                    .y_scale        (y_scale_3),
                                    .TARGET_H_NUM   (TARGET_H_NUM_3),
                                    .TARGET_V_NUM   (TARGET_V_NUM_3),
                                    .fifo_row_rdy   (!fifo_data_rdy_3),
                                    .fifo_data      (fifo_data_3),
                                    .rd_en          (fifo_rd_en_3),
                                    .pix_data       (scaler_data_out_3),
                                    .data_vaild     (scaler_data_vaild_3),
                                    .DDR3_ADDR      (DDR3_ADDR_3)
);


wire   [15:0]        tdata_o_4;/* synthesis syn_keep = 1 */
wire                 tvaild_4;/* synthesis syn_keep = 1 */
wire                 fifo_data_rdy_4;/* synthesis syn_keep = 1 */
wire    [15:0]       fifo_data_4;/* synthesis syn_keep = 1 */
wire                 fifo_rd_en_4; /* synthesis syn_keep = 1 */
wire    [15:0]       scaler_data_out_4;/* synthesis syn_keep = 1 */
wire                 scaler_data_vaild_4;/* synthesis syn_keep = 1 */
wire    [27:0]       DDR3_ADDR_4;/* synthesis syn_keep = 1 */

reg     [14:0]      y_scale_4       =15'd2048;
reg     [14:0]      x_scale_4       =15'd2048;
reg     [12:0]      TARGET_H_NUM_4  =13'd640;
reg     [12:0]      TARGET_V_NUM_4  =13'd360;

always @(posedge pclk_in_test2) begin
    if(vs_in_test2==1'd1)    begin
        y_scale_4       <=y_scale_reg;
        x_scale_4       <=x_scale_reg;
        TARGET_H_NUM_4  <=TARGET_H_NUM_reg;
        TARGET_V_NUM_4  <=TARGET_V_NUM_reg;
    end
    else    begin
        y_scale_4       <=y_scale_4;
        x_scale_4       <=x_scale_4;
        TARGET_H_NUM_4  <=TARGET_H_NUM_4;
        TARGET_V_NUM_4  <=TARGET_V_NUM_4;

    end
end

image_size_down_without_fifo    image_size_down_without_fifo_4(					 					
                                    .clk_i      (pclk_in_test2),
                                    .rst_i      ((!rstn_out) | vs_in_test2),//|(!reset_key)
                                    .width_i    (H_NUM),
                                    .height_i   (V_NUM),						 
                                    .tdata_i    (i_rgb5652),
                                    .tvalid_i   (de_in_test2),
                                    .tdata_o    (tdata_o_4),
                                    .tvalid_o   (tvaild_4)
                     );
scale_fifo  scale_fifo_inst_4
(
                            .wr_data        (  tdata_o_4      ),
                            .wr_en          (  tvaild_4       ),
                            .wr_clk         (  pclk_in_test2 ),
                            .wr_rst         (  (!rstn_out) | vs_in_test2),//|(!reset_key)
                            .wr_full        (                 ),
                            .rd_data        (  fifo_data_4    ),
                            .rd_en          (  fifo_rd_en_4   ),
                            .rd_clk         (  pclk_in_test2  ),
                            .rd_rst         (  (!rstn_out) | vs_in_test2),
                            .rd_empty       (  fifo_data_rdy_4),
                            .almost_empty   (                 )
);

scaler_4  scaler_4(
                                    .clk            (pclk_in_test2)                  ,
                                    .rstn           (rstn_out & (!vs_in_test2)),//&reset_key
                                    .x_scale        (x_scale_4),    //               
                                    .y_scale        (y_scale_4),
                                    .TARGET_H_NUM   (TARGET_H_NUM_4),
                                    .TARGET_V_NUM   (TARGET_V_NUM_4),
                                    .fifo_row_rdy   (!fifo_data_rdy_4),
                                    .fifo_data      (fifo_data_4),
                                    .rd_en          (fifo_rd_en_4),
                                    .pix_data       (scaler_data_out_4),
                                    .data_vaild     (scaler_data_vaild_4),
                                    .DDR3_ADDR      (DDR3_ADDR_4)
);


reg [8:0] hue_factor;
reg [8:0]  v_factor;
wire vs_out1;
wire vs_out2;
wire hs_out1;
wire hs_out2;
wire de_out1;
wire de_out2;
wire [8:0]hsv_h;
wire [8:0]hsv_s;
wire [7:0]hsv_v;
wire[7:0]                 r_out1                     ;   
wire[7:0]                 g_out1                     ;   
wire[7:0]                 b_out1                     ;   
wire[7:0]                 r_out3                     ;   
wire[7:0]                 g_out3                     ;   
wire[7:0]                 b_out3                     ;  


reg mode;

    frame_buf frame_buf(
        .mode           (  mode                 ),
        .ddr_clk        (  core_clk             ),//input                         ddr_clk,
        .ddr_rstn       (  ddr_init_done        ),//input                         ddr_rstn,

        .m1_ADDR_OFFSET  (  DDR3_ADDR_1         ),
        .m1_H_NUM        (  12'd640             ),
        .m1_V_NUM        (  12'd360             ),
        .m1_wr_vin_clk   (  pclk_in_test        ),
        .m1_wr_wr_fsync  (  vs_in_test          ),
        .m1_wr_wr_en     (  scaler_data_vaild_1 ),
        .m1_wr_wr_data   (  scaler_data_out_1   ),
        .m1_wr_init_done (                      ),

        .m2_ADDR_OFFSET  (   DDR3_ADDR_2        ),//32'h0000_0140      ),
        .m2_H_NUM        (   12'd640            ),
        .m2_V_NUM        (   12'd360            ),
        .m2_wr_vin_clk   (   pclk_in_test3      ),
        .m2_wr_wr_fsync  (   vs_in_test3        ),
        .m2_wr_wr_en     (   scaler_data_vaild_2),
        .m2_wr_wr_data   (   scaler_data_out_2  ),
        .m2_wr_init_done (                      ),

        .m3_ADDR_OFFSET  (    DDR3_ADDR_3               ),//32'h0003_8400     ),
        .m3_H_NUM        (    12'd640                   ),
        .m3_V_NUM        (    12'd360                   ),
        .m3_wr_vin_clk   (    pclk_in_test3             ),
        .m3_wr_wr_fsync  (    vs_in_test3               ),
        .m3_wr_wr_en     (    scaler_data_vaild_3       ),
        .m3_wr_wr_data   (    scaler_data_out_3         ),
        .m3_wr_init_done (                              ),

        .m4_ADDR_OFFSET  (    DDR3_ADDR_4               ),//32'h0003_8540     ),
        .m4_H_NUM        (    12'd640                   ),
        .m4_V_NUM        (    12'd360                   ),
        .m4_wr_vin_clk   (    pclk_in_test2              ),
        .m4_wr_wr_fsync  (    vs_in_test2                ),
        .m4_wr_wr_en     (    scaler_data_vaild_4       ),    
        .m4_wr_wr_data   (    scaler_data_out_4         ),
        .m4_wr_init_done (                              ),

        //data_out
        .vout_clk        (     pixclk_in                ),//input                         vout_clk,
        .rd_fsync        (     vs_out1                   ),//input                         rd_fsync,
        .rd_en           (     de_re                    ),//input                         rd_en,
        .vout_de         (                              ),//output                        vout_de,
        .vout_data       (     o_rgb565                 ),//output [PIX_WIDTH- 1'b1 : 0]  vout_data,
        .init_done       (     init_done                ),    
        //axi bus
        .axi_awaddr     (  axi_awaddr           ),// output[27:0]
        .axi_awid       (  axi_awuser_id        ),// output[3:0]
        .axi_awlen      (  axi_awlen            ),// output[3:0]
        .axi_awsize     (                       ),// output[2:0]
        .axi_awburst    (                       ),// output[1:0]
        .axi_awready    (  axi_awready          ),// input
        .axi_awvalid    (  axi_awvalid          ),// output               
        .axi_wdata      (  axi_wdata            ),// output[255:0]
        .axi_wstrb      (  axi_wstrb            ),// output[31:0]
        .axi_wlast      (  axi_wusero_last      ),// input
        .axi_wvalid     (                       ),// output
        .axi_wready     (  axi_wready           ),// input
        .axi_bid        (  4'd0                 ),// input[3:0]
        .axi_araddr     (  axi_araddr           ),// output[27:0]
        .axi_arid       (  axi_aruser_id        ),// output[3:0]
        .axi_arlen      (  axi_arlen            ),// output[3:0]
        .axi_arsize     (                       ),// output[2:0]
        .axi_arburst    (                       ),// output[1:0]
        .axi_arvalid    (  axi_arvalid          ),// output
        .axi_arready    (  axi_arready          ),// input
        .axi_rready     (                       ),// output
        .axi_rdata      (  axi_rdata            ),// input[255:0]
        .axi_rvalid     (  axi_rvalid           ),// input
        .axi_rlast      (  axi_rlast            ),// input
        .axi_rid        (  axi_rid              ) // input[3:0]         
    );

//key7-----s1
//key8-----s3
//key5------s2
//key6------s4
reg   [31:0]      time_cnt;
reg   [3:0]       key_scan_r;
reg   [3:0]       key_scan;
wire  [3:0]       key_trig    =     key_scan_r[3:0]&(~key_scan[3:0]);


always @(posedge core_clk or negedge rstn_out) begin
      if(!rstn_out)
            time_cnt    <=      32'd0;
      else if(time_cnt ==    32'd2000000)      begin
            time_cnt    <=    32'd0;
            key_scan    <=    {key4,key3,key2,key1};
      end  
      else begin
            time_cnt    <=    time_cnt    +     1'd1;
      end
end

always @(posedge core_clk ) begin
      key_scan_r  <=    key_scan;
end

always@(posedge core_clk or negedge rstn_out)begin
    if(!rstn_out)
      shift <= 1'd0;
    else if(key_trig[0])
    begin
      shift <= shift + 1'd1;
    end
end

//色度调节
always@(posedge core_clk or negedge rstn_out)begin
    if(!rstn_out)
      hue_factor <= 8'd0;
    else if(key_trig[1])
    begin
      hue_factor <= (shift==1'd0)?(hue_factor - 9'd8):(hue_factor+9'd8);
    end
end

//亮度调节
always@(posedge core_clk or negedge rstn_out)begin
    if(!rstn_out)
      v_factor <= 8'd0;
    else if(key_trig[2])
    begin
      v_factor <= (shift==1'd0)?(v_factor + 8'd2):(v_factor-8'd2);
    end 
end


//旋转
always@(posedge core_clk or negedge rstn_out)begin
    if(!rstn_out) 
      mode <= 1'd0;
    else if(key_trig[3])
    begin
      mode <= ~mode;
    end  
end


/////////////////////////////////////////////////////////////////////////////////////
//添加字体
reg  [3:0] ram_hdmi_count;
    always @(posedge pixclk_in)
    begin
        if(de_out1&&y_act>=13'd655&&y_act<=718)//&&y_act>=13'd655&&y_act<=718
        begin
            ram_hdmi_des_addr <=(y_act-13'd655)*11'd120+(x_act+2'd2)/5'd16 ;
            if(ram_hdmi_count==4'd15) ram_hdmi_count<=4'd0;
                else ram_hdmi_count <= ram_hdmi_count+1'd1;
        end
    end
///////////////////////////////////////////////////////////////////////////////////// 

// 色调
assign    r_out1={o_rgb565[15:11],3'b0};
assign    g_out1={o_rgb565[10:5],2'b0}; 
assign    b_out1={o_rgb565[4:0],3'b0};  
 
hsv_rgb u_hsv_rgb(
     .clk (pixclk_in),
     .reset_n (rstn_out),
     .i_hsv_h (hsv_h+hue_factor),
     .i_hsv_s (hsv_s),
     .i_hsv_v ((v_factor[8]==1'd1)?(v_factor[7:0]>hsv_v?8'd0:(hsv_v-v_factor[7:0])):((v_factor[7:0]>(8'd255-hsv_v))?8'd255:(hsv_v+v_factor[7:0]))),
     .vs (vs_out2),
     .hs (hs_out2),
     .de (de_out2),
     .rgb_r (r_out3),
     .rgb_g (g_out3),
     .rgb_b (b_out3),
     .rgb_vs (vs_out),
     .rgb_hs (hs_out),
     .rgb_de (de_out)
);

rgb_hsv u_rgb_hsv(
    .clk (pixclk_in),
    .reset_n (rstn_out),
    .rgb_r (r_out1),
    .rgb_g (g_out1),
    .rgb_b (b_out1),
    .vs (vs_out1),
    .hs (hs_out1),
    .de (de_out1),
    .hsv_h (hsv_h),
    .hsv_s (hsv_s),
    .hsv_v (hsv_v),
    .hsv_vs (vs_out2),
    .hsv_hs (hs_out2),
    .hsv_de (de_out2)
);
   assign    r_out=de_out1&&y_act>=13'd655&&y_act<=718&&ram_hdmi_des_data[4'd15-ram_hdmi_count]?8'hff:((((y_scale_reg[14:11]>4'd0)&&(y_act>=(13'd360-(TARGET_V_NUM_reg)))&&(y_act<(13'd360+TARGET_V_NUM_reg)))||y_scale_reg[14:11]==4'd0)?r_out3:8'b0);
   assign    g_out=de_out1&&y_act>=13'd655&&y_act<=718&&ram_hdmi_des_data[4'd15-ram_hdmi_count]?8'hff:((((y_scale_reg[14:11]>4'd0)&&(y_act>=(13'd360-(TARGET_V_NUM_reg)))&&(y_act<(13'd360+TARGET_V_NUM_reg)))||y_scale_reg[14:11]==4'd0)?g_out3:8'b0);
   assign    b_out=de_out1&&y_act>=13'd655&&y_act<=718&&ram_hdmi_des_data[4'd15-ram_hdmi_count]?8'hff:((((y_scale_reg[14:11]>4'd0)&&(y_act>=(13'd360-(TARGET_V_NUM_reg)))&&(y_act<(13'd360+TARGET_V_NUM_reg)))||y_scale_reg[14:11]==4'd0)?b_out3:8'b0); 
 
    // assign    r_out=o_rgb565[7:0];
    // assign    g_out=o_rgb565[7:0];
    // assign    b_out=o_rgb565[7:0];

/////////////////////////////////////////////////////////////////////////////////////
//visa鏃跺��?? 
     sync_vg sync_vg(                            
        .clk            (  pixclk_in              ),//input                   clk,                                 
        .rstn           (  init_done            ),//input                   rstn,                            
        .vs_out         (  vs_out1               ),//output reg              vs_out,                                                                                                                                      
        .hs_out         (  hs_out1               ),//output reg              hs_out,            
        .de_out         (  de_out1               ),//output reg              de_out, 
        .de_re          (  de_re                ),
        .y_act          (  y_act                ),
        .x_act          (    x_act)    
    );  
////////////////////////////////////////////////////////////////////////////////////////////
//50H_ddr    
        DDR3_50H u_DDR3_50H (
             .ref_clk                   (sys_clk            ),
             .resetn                    (rstn_out           ),// input
             .ddr_init_done             (ddr_init_done      ),// output
             .ddrphy_clkin              (core_clk           ),// output
             .pll_lock                  (pll_lock           ),// output

             .axi_awaddr                (axi_awaddr         ),// input [27:0]
             .axi_awuser_ap             (1'b0               ),// input
             .axi_awuser_id             (axi_awuser_id      ),// input [3:0]
             .axi_awlen                 (axi_awlen          ),// input [3:0]
             .axi_awready               (axi_awready        ),// output
             .axi_awvalid               (axi_awvalid        ),// input
             .axi_wdata                 (axi_wdata          ),
             .axi_wstrb                 (axi_wstrb          ),// input [31:0]
             .axi_wready                (axi_wready         ),// output
             .axi_wusero_id             (                   ),// output [3:0]
             .axi_wusero_last           (axi_wusero_last    ),// output
             .axi_araddr                (axi_araddr         ),// input [27:0]
             .axi_aruser_ap             (1'b0               ),// input
             .axi_aruser_id             (axi_aruser_id      ),// input [3:0]
             .axi_arlen                 (axi_arlen          ),// input [3:0]
             .axi_arready               (axi_arready        ),// output
             .axi_arvalid               (axi_arvalid        ),// input
             .axi_rdata                 (axi_rdata          ),// output [255:0]
             .axi_rid                   (axi_rid            ),// output [3:0]
             .axi_rlast                 (axi_rlast          ),// output
             .axi_rvalid                (axi_rvalid         ),// output

             .apb_clk                   (1'b0               ),// input
             .apb_rst_n                 (1'b1               ),// input
             .apb_sel                   (1'b0               ),// input
             .apb_enable                (1'b0               ),// input
             .apb_addr                  (8'b0               ),// input [7:0]
             .apb_write                 (1'b0               ),// input
             .apb_ready                 (                   ), // output
             .apb_wdata                 (16'b0              ),// input [15:0]
             .apb_rdata                 (                   ),// output [15:0]
             .apb_int                   (                   ),// output

             .mem_rst_n                 (mem_rst_n          ),// output
             .mem_ck                    (mem_ck             ),// output
             .mem_ck_n                  (mem_ck_n           ),// output
             .mem_cke                   (mem_cke            ),// output
             .mem_cs_n                  (mem_cs_n           ),// output
             .mem_ras_n                 (mem_ras_n          ),// output
             .mem_cas_n                 (mem_cas_n          ),// output
             .mem_we_n                  (mem_we_n           ),// output
             .mem_odt                   (mem_odt            ),// output
             .mem_a                     (mem_a              ),// output [14:0]
             .mem_ba                    (mem_ba             ),// output [2:0]
             .mem_dqs                   (mem_dqs            ),// inout [3:0]
             .mem_dqs_n                 (mem_dqs_n          ),// inout [3:0]
             .mem_dq                    (mem_dq             ),// inout [31:0]
             .mem_dm                    (mem_dm             ),// output [3:0]
             //debug
             .debug_data                (                   ),// output [135:0]
             .debug_slice_state         (                   ),// output [51:0]
             .debug_calib_ctrl          (                   ),// output [21:0]
             .ck_dly_set_bin            (                   ),// output [7:0]
             .force_ck_dly_en           (1'b0               ),// input
             .force_ck_dly_set_bin      (8'h05              ),// input [7:0]
             .dll_step                  (                   ),// output [7:0]
             .dll_lock                  (                   ),// output
             .init_read_clk_ctrl        (2'b0               ),// input [1:0]
             .init_slip_step            (4'b0               ),// input [3:0]
             .force_read_clk_ctrl       (1'b0               ),// input
             .ddrphy_gate_update_en     (1'b0               ),// input
             .update_com_val_err_flag   (                   ),// output [3:0]
             .rd_fake_stop              (1'b0               ) // input
       );

//蹇冭烦淇″彿
     always@(posedge core_clk) begin
        if (!ddr_init_done)
            cnt <= 27'd0;
        else if ( cnt >= TH_1S )
            cnt <= 27'd0;
        else
            cnt <= cnt + 27'd1;
     end

     always @(posedge core_clk)
        begin
        if (!ddr_init_done)
            heart_beat_led <= 1'd1;
        else if ( cnt >= TH_1S )
            heart_beat_led <= ~heart_beat_led;
    end
                 
/////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////
    top_sd_rw u_top_sd_rw(
    .sys_clk                        (  sys_clk           ),
    .sys_rst_n                      (  rstn_out         ),
                                                          
    .sd_miso                        (    sd_miso         ),
    .sd_clk                         (    sd_clk          ),
    .sd_cs                          (    sd_cs           ), 
    .sd_mosi                        (    sd_mosi         ),
    .led                            (    led             ),
    
    .clk_ref                        (    clk_ref         ),
    .eth_wr_ram_en                  (    eth_wr_ram_en   ),
    .des_addr                       (    des_addr        ),
    .des_data                       (    des_data        ),
    .eth_ram_hdmi_wr_rst            (eth_ram_hdmi_wr_rst),

    .phy_rstn                       (phy_rstn     ),                                          
                                                                                             
    .rgmii_rxc                      (rgmii_rxc    ),
    .rgmii_rx_ctl                   (rgmii_rx_ctl ),
    .rgmii_rxd                      (rgmii_rxd    ),
                                                  
    .rgmii_txc                      (rgmii_txc    ),
    .rgmii_tx_ctl                   (rgmii_tx_ctl ),
    .rgmii_txd                      (rgmii_txd    )
    );
    wire        clk_ref            ;
    wire [12:0] des_addr           ;
    wire [15:0] des_data           ;
    wire        eth_wr_ram_en      ;
                                    
    wire        rstn_out           /*synthesis syn_keep=1*/ ;
//    wire [12:0] ram_hdmi_des_addr  ;
    reg   [12:0] ram_hdmi_des_addr  /*synthesis syn_preserve=1*/  ;                             
    wire [15:0] ram_hdmi_des_data  ;
 
    ram_ethhdmi u_ram_ethhdmi(
        .sys_rst_n           (rstn_out       ),    
        .clk_ref             (clk_ref          ),
        .des_addr            (des_addr         ),
        .des_data            (des_data         ),
        .eth_wr_ram_en       (eth_wr_ram_en    ),
                            
        .rstn                (rstn_out         ),
        .pix_clk             (pix_clk          ),
        .ram_hdmi_des_addr   (ram_hdmi_des_addr),
                            
        .ram_hdmi_des_data   (ram_hdmi_des_data)
    );

/////////////////////////////////////////////////////////////////////////////////////
endmodule
