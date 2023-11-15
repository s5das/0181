//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           top_sd_rw
// Last modified Date:  2020/05/28 20:28:08
// Last Version:        V1.0
// Descriptions:        SD卡读写顶层模块
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/05/28 20:28:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_sd_rw(
    input               sys_clk     ,  //系统时钟
    input               sys_rst_n   ,  //系统复位，低电平有效
    
    //SD卡接口
    input               sd_miso     ,  //SD卡SPI串行输入数据信号
    output              sd_clk      ,  //SD卡SPI时钟信号
    output              sd_cs       ,  //SD卡SPI片选信号
    output              sd_mosi     ,  //SD卡SPI串行输出数据信号
   
    //LED
    output      [3:0]   led         ,   //LED灯

    output              clk_ref     ,
    output              eth_wr_ram_en,
    output   [12:0]   des_addr,
    output   [15:0]   des_data  ,
    output            eth_ram_hdmi_wr_rst ,
    
    output       phy_rstn,

    input        rgmii_rxc,
    input        rgmii_rx_ctl,
    input [3:0]  rgmii_rxd,
                 
    output       rgmii_txc,
    output       rgmii_tx_ctl,
    output [3:0] rgmii_txd 
    );

//wire define
wire             clk_ref        ;
wire             clk_ref_180deg ;
wire             rst_n          ;
wire             locked         ;
wire             wr_start_en    ;      //开始写SD卡数据信号
wire     [31:0]  wr_sec_addr    ;      //写数据扇区地址    
wire     [15:0]  wr_data        ;      //写数据            
wire             rd_start_en    ;      //开始写SD卡数据信号
wire     [31:0]  rd_sec_addr    ;      //读数据扇区地址    
wire             error_flag     ;      //SD卡读写错误的标志
wire             wr_busy        ;      //写数据忙信号
wire             wr_req         ;      //写数据请求信号
wire             rd_busy        /*synthesis syn_keep=1*/ ;      //读忙信号
wire             rd_val_en      ;      //数据读取有效使能信号
wire     [15:0]  rd_val_data    ;      //读数据
wire             sd_init_done   ;      //SD卡初始化完成信号


parameter       LOCAL_MAC = 48'he1_e1_e1_e1_e1_e1;
parameter       LOCAL_IP  = 32'hC0_A8_01_0B;//192.168.1.11  //--10
parameter       LOCL_PORT = 16'h1F90;    //8080   //1234
parameter       DEST_IP   = 32'hC0_A8_01_69;//192.168.1.105
parameter       DEST_PORT = 16'h1F90 ;
//*****************************************************
//**                    main code
//*****************************************************

assign  rst_n = sys_rst_n & locked;

pll_sd pll_clk_inst(
    .clkin1     (sys_clk),
    .pll_rst    (b0),
    .clkout0    (clk_ref),
    .clkout1    (clk_ref_180deg),
                
    .pll_lock   (locked)
    );
     
//产生SD卡测试数据  
data_gen u_data_gen(
    .clk             (clk_ref),
    .rst_n           (rst_n),
    .sd_init_done    (sd_init_done),
    .wr_busy         (wr_busy),
    .wr_req          (wr_req),
    .wr_start_en     (wr_start_en),
    .wr_sec_addr     (wr_sec_addr),
    .wr_data         (wr_data),
    .rd_val_en       (rd_val_en),
    .rd_val_data     (rd_val_data),
    .rd_start_en     (rd_start_en),
    .rd_sec_addr     (rd_sec_addr),
    .error_flag      (error_flag),
    .eth_wr_ram_en   (eth_wr_ram_en) ,
    .des_addr        (des_addr     ) ,
    .des_data        (des_data     ) ,
    .rd_busy           (rd_busy) ,
    .rd_real_busy     (rd_real_busy),
    .eth_data            (eth_data),
    .font_count      (font_count),
    .write_end           (write_end),
    .eth_ram_hdmi_wr_rst (eth_ram_hdmi_wr_rst)
    );     
wire rd_real_busy /*synthesis syn_keep=1*/ ;
assign rd_real_busy=0;
//SD卡顶层控制模块
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref           (clk_ref),
    .clk_ref_180deg    (clk_ref_180deg),
    .rst_n             (rst_n),
    //SD卡接口
    .sd_miso           (sd_miso),
    .sd_clk            (sd_clk),
    .sd_cs             (sd_cs),
    .sd_mosi           (sd_mosi),
    //用户写SD卡接口
    .wr_start_en       (wr_start_en),
    .wr_sec_addr       (wr_sec_addr),
    .wr_data           (wr_data),
    .wr_busy           (wr_busy),
    .wr_req            (wr_req),
    //用户读SD卡接口
    .rd_start_en       (rd_start_en),
    .rd_sec_addr       (rd_sec_addr),
    .rd_busy           (rd_busy),
    .rd_val_en         (rd_val_en),
    .rd_val_data       (rd_val_data),    
    
    .sd_init_done      (sd_init_done)
//    .rd_real_busy       (rd_real_busy)
    );

//led警示 
led_alarm #(
    .L_TIME      (25'd25_000_000)
    )  
   u_led_alarm(
    .clk            (clk_ref),
    .rst_n          (rst_n),
    .led            (led),
    .error_flag     (error_flag)
    ); 

ethernet_test#( 
        .LOCAL_MAC         (LOCAL_MAC),
        .LOCAL_IP          (LOCAL_IP ),
        .LOCL_PORT         (LOCL_PORT),
        .DEST_IP           (DEST_IP  ),
        .DEST_PORT         (DEST_PORT)
    )ethernet_test(
        .clk_50m            (sys_clk      ),  
                                          
        .phy_rstn           (phy_rstn     ),                                          
                                                                                 
        .rgmii_rxc          (rgmii_rxc    ),
        .rgmii_rx_ctl       (rgmii_rx_ctl ),
        .rgmii_rxd          (rgmii_rxd    ),
                                          
        .rgmii_txc          (rgmii_txc    ),
        .rgmii_tx_ctl       (rgmii_tx_ctl ),
        .rgmii_txd          (rgmii_txd    ),
        
        .rgmii_clk          (rgmii_clk    ),
        .eth_sd_wr_en       (eth_sd_wr_en ),
        .eth_sd_wr_data     (eth_sd_wr_data),
        .font_count         (font_count)    ,
        .eth_sd_wr_end      (eth_sd_wr_end) ,
        .eth_sd_fifo_rst           (eth_sd_fifo_rst),
        .eth_data            (eth_data)  ,
        .write_end           (write_end) 
    );
wire     write_end/*synthesis syn_keep=1*/;     
wire [6:0]    font_count     /*synthesis syn_keep=1*/ ;
wire [479:0]  eth_data  /*synthesis syn_keep=1*/ ;

wire          eth_sd_wr_end0/*synthesis syn_keep=1*/;
assign eth_sd_wr_end0 = eth_sd_wr_end;

wire          eth_sd_wr_en   /*synthesis syn_keep=1*/ ;
wire [31:0]   eth_sd_wr_data /*synthesis syn_keep=1*/ ;
wire          eth_sd_rd_en   /*synthesis syn_keep=1*/ ;
wire [31:0]   eth_sd_rd_data /*synthesis syn_keep=1*/ ; 

eth_sd_fifo u_eth_sd_fifo (
  .wr_clk        (rgmii_clk),                // input
  .wr_rst        (eth_sd_fifo_rst),                // input
  .wr_en         (eth_sd_wr_en),                  // input
  .wr_data       (eth_sd_wr_data),              // input [31:0]

  .rd_clk        (clk_ref),                // input
  .rd_rst        (~rst_n),                // input
  .rd_en         (eth_sd_rd_en),                  // input
  .rd_data       (eth_sd_rd_data)              // output [31:0]
);
endmodule