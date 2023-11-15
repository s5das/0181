//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           top_sd_rw
// Last modified Date:  2020/05/28 20:28:08
// Last Version:        V1.0
// Descriptions:        SD����д����ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/05/28 20:28:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_sd_rw(
    input               sys_clk     ,  //ϵͳʱ��
    input               sys_rst_n   ,  //ϵͳ��λ���͵�ƽ��Ч
    
    //SD���ӿ�
    input               sd_miso     ,  //SD��SPI�������������ź�
    output              sd_clk      ,  //SD��SPIʱ���ź�
    output              sd_cs       ,  //SD��SPIƬѡ�ź�
    output              sd_mosi     ,  //SD��SPI������������ź�
   
    //LED
    output      [3:0]   led         ,   //LED��

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
wire             wr_start_en    ;      //��ʼдSD�������ź�
wire     [31:0]  wr_sec_addr    ;      //д����������ַ    
wire     [15:0]  wr_data        ;      //д����            
wire             rd_start_en    ;      //��ʼдSD�������ź�
wire     [31:0]  rd_sec_addr    ;      //������������ַ    
wire             error_flag     ;      //SD����д����ı�־
wire             wr_busy        ;      //д����æ�ź�
wire             wr_req         ;      //д���������ź�
wire             rd_busy        /*synthesis syn_keep=1*/ ;      //��æ�ź�
wire             rd_val_en      ;      //���ݶ�ȡ��Чʹ���ź�
wire     [15:0]  rd_val_data    ;      //������
wire             sd_init_done   ;      //SD����ʼ������ź�


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
     
//����SD����������  
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
//SD���������ģ��
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref           (clk_ref),
    .clk_ref_180deg    (clk_ref_180deg),
    .rst_n             (rst_n),
    //SD���ӿ�
    .sd_miso           (sd_miso),
    .sd_clk            (sd_clk),
    .sd_cs             (sd_cs),
    .sd_mosi           (sd_mosi),
    //�û�дSD���ӿ�
    .wr_start_en       (wr_start_en),
    .wr_sec_addr       (wr_sec_addr),
    .wr_data           (wr_data),
    .wr_busy           (wr_busy),
    .wr_req            (wr_req),
    //�û���SD���ӿ�
    .rd_start_en       (rd_start_en),
    .rd_sec_addr       (rd_sec_addr),
    .rd_busy           (rd_busy),
    .rd_val_en         (rd_val_en),
    .rd_val_data       (rd_val_data),    
    
    .sd_init_done      (sd_init_done)
//    .rd_real_busy       (rd_real_busy)
    );

//led��ʾ 
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