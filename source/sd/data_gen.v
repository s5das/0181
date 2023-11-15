//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           data_gen
// Last modified Date:  2020/05/28 20:28:08
// Last Version:        V1.0
// Descriptions:        ����SD����������ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/05/28 20:28:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module data_gen(
    input                clk           ,  //ʱ���ź�
    input                rst_n         ,  //��λ�ź�,�͵�ƽ��Ч
    input                sd_init_done  ,  //SD����ʼ������ź�
    //дSD���ӿ�
    input                wr_busy       ,  //д����æ�ź�
    input                wr_req        ,  //д���������ź�
    output  reg          wr_start_en   ,  //��ʼдSD�������ź�
    output  reg  [31:0]  wr_sec_addr   ,  //д����������ַ
    output       [15:0]  wr_data       ,  //д����
    //��SD���ӿ�
    input                rd_val_en     ,  //��������Ч�ź�
    input        [15:0]  rd_val_data   ,  //������
    output  reg          rd_start_en   ,  //��ʼдSD�������ź�
    output  reg  [31:0]  rd_sec_addr   ,  //������������ַ
    input                rd_busy       ,
    input                rd_real_busy  ,    
    
    output               error_flag    ,   //SD����д����ı�־

    output reg          eth_wr_ram_en/*synthesis syn_preserve=1*/,
    output reg[12:0]    des_addr/*synthesis syn_preserve=1*/,
    output reg[15:0]    des_data/*synthesis syn_preserve=1*/,
    input [479:0]       eth_data,
    input [6:0]         font_count ,
    input               write_end ,
    output wire          eth_ram_hdmi_wr_rst /*synthesis syn_keep=1*/
    );

//reg define
reg              sd_init_done_d0  ;       //sd_init_done�ź���ʱ����
reg              sd_init_done_d1  ;       
reg              wr_busy_d0       ;       //wr_busy�ź���ʱ����
reg              wr_busy_d1       ;
reg    [15:0]    wr_data_t        ;    
reg    [15:0]    rd_comp_data     ;       //���ڶԶ����������Ƚϵ���ȷ����
reg    [8:0]     rd_right_cnt     ;       //������ȷ���ݵĸ���

//wire define
wire             pos_init_done    ;       //sd_init_done�źŵ�������,��������д���ź�
wire             neg_wr_busy      ;       //wr_busy�źŵ��½���,�����ж�����д�����

//*****************************************************
//**                    main code
//*****************************************************
assign  eth_ram_hdmi_wr_rst=neg_write_end|(~rst_n);
assign  pos_init_done = (~sd_init_done_d1) & sd_init_done_d0;
assign  neg_wr_busy = wr_busy_d1 & (~wr_busy_d0);
//wr_data_t�仯��Χ0~256;wr_data��Χ:0~255
assign  wr_data = (wr_data_t > 16'd0)  ? test_data_0[12'd4095-(wr_data_t-1'b1)*5'd16-:16]  : 16'd0;//(wr_data_t - 1'b1)
//��256����ȷ������,˵����д���Գɹ�,error_flag = 0
assign  error_flag = (rd_right_cnt == (9'd256))  ?  1'b1 : 1'b0;
reg [4095:0] test_data_0={8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,
                          8'h00,8'h40,8'h00,8'h00,8'h00,8'h70,8'h60,8'h00,
                          8'h00,8'h60,8'hE0,8'h00,8'h00,8'hE0,8'hC0,8'h00,
                          8'h00,8'hC0,8'hC0,8'h00,8'h00,8'hC1,8'h80,8'h00,
                          8'h01,8'h81,8'h80,8'h18,8'h01,8'h03,8'hFF,8'hFC,
                          8'h03,8'h03,8'h00,8'h18,8'h03,8'h86,8'h10,8'h30,
                          8'h07,8'h84,8'h0C,8'h20,8'h0D,8'h8C,8'h08,8'h40,
                          8'h09,8'h88,8'h08,8'h00,8'h11,8'h90,8'h08,8'h00,
                          8'h11,8'h81,8'h88,8'h00,8'h21,8'h83,8'h88,8'h80,
                          8'h01,8'h83,8'h08,8'h40,8'h01,8'h83,8'h08,8'h20,
                          8'h01,8'h86,8'h08,8'h30,8'h01,8'h86,8'h08,8'h18,
                          8'h01,8'h8C,8'h08,8'h1C,8'h01,8'h88,8'h08,8'h0C,
                          8'h01,8'h90,8'h08,8'h0C,8'h01,8'h90,8'h08,8'h0C,
                          8'h01,8'hA0,8'h08,8'h00,8'h01,8'h80,8'h08,8'h00,
                          8'h01,8'h80,8'hF8,8'h00,8'h01,8'h80,8'h38,8'h00,
                          8'h01,8'h00,8'h10,8'h00,8'h00,8'h00,8'h00,8'h00,
                          8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,
                          8'h00,8'h40,8'h00,8'h00,8'h00,8'h70,8'h60,8'h00,
                          8'h00,8'h60,8'hE0,8'h00,8'h00,8'hE0,8'hC0,8'h00,
                          8'h00,8'hC0,8'hC0,8'h00,8'h00,8'hC1,8'h80,8'h00,
                          8'h01,8'h81,8'h80,8'h18,8'h01,8'h03,8'hFF,8'hFC,
                          8'h03,8'h03,8'h00,8'h18,8'h03,8'h86,8'h10,8'h30,
                          8'h07,8'h84,8'h0C,8'h20,8'h0D,8'h8C,8'h08,8'h40,
                          8'h09,8'h88,8'h08,8'h00,8'h11,8'h90,8'h08,8'h00,
                          8'h11,8'h81,8'h88,8'h00,8'h21,8'h83,8'h88,8'h80,
                          8'h01,8'h83,8'h08,8'h40,8'h01,8'h83,8'h08,8'h20,
                          8'h01,8'h86,8'h08,8'h30,8'h01,8'h86,8'h08,8'h18,
                          8'h01,8'h8C,8'h08,8'h1C,8'h01,8'h88,8'h08,8'h0C,
                          8'h01,8'h90,8'h08,8'h0C,8'h01,8'h90,8'h08,8'h0C,
                          8'h01,8'hA0,8'h08,8'h00,8'h01,8'h80,8'h08,8'h00,
                          8'h01,8'h80,8'hF8,8'h00,8'h01,8'h80,8'h38,8'h00,
                          8'h01,8'h00,8'h10,8'h00,8'h00,8'h00,8'h00,8'h00,
                          8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,
                          8'h00,8'h40,8'h00,8'h00,8'h00,8'h70,8'h60,8'h00,
                          8'h00,8'h60,8'hE0,8'h00,8'h00,8'hE0,8'hC0,8'h00,
                          8'h00,8'hC0,8'hC0,8'h00,8'h00,8'hC1,8'h80,8'h00,
                          8'h01,8'h81,8'h80,8'h18,8'h01,8'h03,8'hFF,8'hFC,
                          8'h03,8'h03,8'h00,8'h18,8'h03,8'h86,8'h10,8'h30,
                          8'h07,8'h84,8'h0C,8'h20,8'h0D,8'h8C,8'h08,8'h40,
                          8'h09,8'h88,8'h08,8'h00,8'h11,8'h90,8'h08,8'h00,
                          8'h11,8'h81,8'h88,8'h00,8'h21,8'h83,8'h88,8'h80,
                          8'h01,8'h83,8'h08,8'h40,8'h01,8'h83,8'h08,8'h20,
                          8'h01,8'h86,8'h08,8'h30,8'h01,8'h86,8'h08,8'h18,
                          8'h01,8'h8C,8'h08,8'h1C,8'h01,8'h88,8'h08,8'h0C,
                          8'h01,8'h90,8'h08,8'h0C,8'h01,8'h90,8'h08,8'h0C,
                          8'h01,8'hA0,8'h08,8'h00,8'h01,8'h80,8'h08,8'h00,
                          8'h01,8'h80,8'hF8,8'h00,8'h01,8'h80,8'h38,8'h00,
                          8'h01,8'h00,8'h10,8'h00,8'h00,8'h00,8'h00,8'h00,
                          8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,
                          8'h00,8'h40,8'h00,8'h00,8'h00,8'h70,8'h60,8'h00,
                          8'h00,8'h60,8'hE0,8'h00,8'h00,8'hE0,8'hC0,8'h00,
                          8'h00,8'hC0,8'hC0,8'h00,8'h00,8'hC1,8'h80,8'h00,
                          8'h01,8'h81,8'h80,8'h18,8'h01,8'h03,8'hFF,8'hFC,
                          8'h03,8'h03,8'h00,8'h18,8'h03,8'h86,8'h10,8'h30,
                          8'h07,8'h84,8'h0C,8'h20,8'h0D,8'h8C,8'h08,8'h40,
                          8'h09,8'h88,8'h08,8'h00,8'h11,8'h90,8'h08,8'h00,
                          8'h11,8'h81,8'h88,8'h00,8'h21,8'h83,8'h88,8'h80,
                          8'h01,8'h83,8'h08,8'h40,8'h01,8'h83,8'h08,8'h20,
                          8'h01,8'h86,8'h08,8'h30,8'h01,8'h86,8'h08,8'h18,
                          8'h01,8'h8C,8'h08,8'h1C,8'h01,8'h88,8'h08,8'h0C,
                          8'h01,8'h90,8'h08,8'h0C,8'h01,8'h90,8'h08,8'h0C,
                          8'h01,8'hA0,8'h08,8'h00,8'h01,8'h80,8'h08,8'h00,
                          8'h01,8'h80,8'hF8,8'h00,8'h01,8'h80,8'h38,8'h00,
                          8'h01,8'h00,8'h10,8'h00,8'h00,8'h00,8'h00,8'h00
};
//reg[479:0] eth_data={
//                     8'hBA,8'hC3, 8'hBA,8'hC4,8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,
//                     8'hBA,8'hC3, 8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,
//                     8'hBA,8'hC3, 8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,
//                     8'hBA,8'hC3, 8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,
//                     8'hBA,8'hC3, 8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,
//                     8'hBA,8'hC3, 8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3,8'hBA,8'hC3      
//};
//reg[6:0] font_count=7'd60;
//sd_init_done�ź���ʱ����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sd_init_done_d0 <= 1'b0;
        sd_init_done_d1 <= 1'b0;
    end
    else begin
        sd_init_done_d0 <= sd_init_done;
        sd_init_done_d1 <= sd_init_done_d0;
    end        
end

//�� rd_busy �źŽ�����ʱ���ģ� ���ڲ� rd_busy �źŵ��½���
reg  rd_busy_d0;  
reg  rd_busy_d1;     
assign neg_rd_busy = rd_busy_d1 &(~rd_busy_d0);
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        rd_busy_d0 <= 1'b0;
        rd_busy_d1 <= 1'b0;
    end
    else begin
        rd_busy_d0 <= rd_real_busy;
        rd_busy_d1 <= rd_busy_d0;
    end
end

//SD��д���źſ���
reg init_already;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_start_en <= 1'b0;
        wr_sec_addr <= 32'd0;
        init_already <= 1'b0;
    end    
    else begin
        if(pos_init_done) begin
            wr_start_en <= 1'b0;
            wr_sec_addr <= 32'd20000;        //����ָ��һ��������ַ
            init_already <= 1'b1;
        end    
        else
            wr_start_en <= 1'b0;
    end    
end 

//SD��д����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wr_data_t <= 16'b0;
    else if(wr_req) 
        wr_data_t <= wr_data_t + 16'b1;
    
end

//wr_busy�ź���ʱ����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_busy_d0 <= 1'b0;
        wr_busy_d1 <= 1'b0;
    end    
    else begin
        wr_busy_d0 <= wr_busy;
        wr_busy_d1 <= wr_busy_d0;
    end
end 

//write_end�ź���ʱ����
reg write_end_1d;
reg write_end_2d;
wire neg_write_end;
assign neg_write_end=write_end_2d&(~write_end_1d);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        write_end_1d <= 1'b0;
        write_end_2d <= 1'b0;
    end    
    else begin
        write_end_1d <= write_end;
        write_end_2d <= write_end_1d;
    end
end 
//SD�������źſ���
reg       sd_start_already;
reg [6:0] rd_sd_fifo_count;
reg        sd_busy        ;
reg [1:0]  ascii_or_gbk   ;
reg [7:0]  eth_data_1d    ;
reg [6:0]  eth_data_count ;
reg        eth_en;
parameter   ascii_addr          =   32'd12_713_984   ;   //24832����
parameter   gbk_addr            =   32'd12_779_520   ;   //24960����
parameter   ascii_BytesPerFont  =   10'd256     ;   
parameter   gbk_BytesPerFont    =   10'd512    ;
reg                     gbk_msb_ready       ;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_start_en <= 1'b0;
        rd_sec_addr <= 32'd0; 
        sd_start_already <= 1'b0;
        sd_busy <= 1'b0;
        eth_data_count <= 7'd0;
        des_addr_0 <= 12'd0;
        eth_en <= 1'b0;
    end
    else begin
//        if(init_already&&(~sd_busy)) begin
//            rd_start_en <= 1'b1;
//            rd_sec_addr <= 32'd24960+data_count;
//            sd_busy <= 1'b1;
//            data_count <= data_count+7'd1;
//            if(eth_sd_rd_data<32'd12_779_520)
//                 ascii_or_gbk <= ((eth_sd_rd_data[8:0] >=9'd255 )? 2'd2:2'd1);
//            else
//                 ascii_or_gbk <= 2'd0;        //oΪgbk��1λascii��һ����2Ϊascii�ڶ���
//        end
        if(neg_write_end)
        begin   
            eth_en <= 1'b1;
            eth_data_count <= 7'd0;
            des_addr_0 <= 12'd0;
            rd_start_en <= 1'b0;
            rd_sec_addr <= 32'd0;
        end
        else; 
        if(init_already&&(~sd_busy)&&eth_en)//
        begin
             eth_data_count <= eth_data_count+7'd1;         
             if(gbk_msb_ready==1'b0)                                                                                                                  
             begin                                                                                                                                    
                 if (eth_data[9'd479-4'd8*eth_data_count-:8] <=  8'h80) //&&test_cnt>1'b0    487  497                                                                                   
                 begin                                                                                                                                
                     rd_sec_addr   <=(eth_data[9'd479-4'd8*eth_data_count-:8]*ascii_BytesPerFont+ascii_addr)/10'd512 ;  //��1��ʼ�洢                                                    
//                     font_count0  <=  font_count0+1;                                                                                                  
//                     eth_sd_wr_en <= 1'b1; 
                     sd_busy  <= 1'b1; 
                     rd_start_en <= 1'b1; 
                     if(eth_data[9'd479-4'd8*eth_data_count-4'd7]) ascii_or_gbk <= 2'd2;
                     else   ascii_or_gbk <= 2'd1;                                                                                                       
                 end                                                                                                                                  
                 else                                                                                                                                 
                 begin                                                                                                                                
                     eth_data_1d  <=  eth_data[9'd479-4'd8*eth_data_count-:8];                                                                                       
                     gbk_msb_ready   <=  1'b1;                                                                                                        
//                     eth_sd_wr_en <= 1'b0;                                                                                                            
                 end                                                                                                                                  
             end                                                                                                                                      
             else                                                                                                                                     
             begin                                                                                                                                    
                 gbk_msb_ready   <=  1'b0;                                                                                                            
//                 font_count0  <=  font_count0+1; 
                 ascii_or_gbk  <= 2'd0;                                                                                                     
                 rd_sec_addr  <= (((eth_data_1d-8'h81)*190+(eth_data[9'd479-4'd8*eth_data_count-:8]-8'h40)-eth_data[9'd479-4'd8*eth_data_count-:8]/8'd128)*gbk_BytesPerFont+gbk_addr)/10'd512 ;    
//                 eth_sd_wr_en <= 1'b1; 
                 sd_busy  <= 1'b1;
                 rd_start_en <= 1'b1; 
            end                                                                                                                           
        end   
        else
        begin
            rd_start_en <= 1'b0;
            if(sd_rd_end_1d&&(~sd_rd_end))
            begin
                 sd_busy<=1'b0;
                 ascii_or_gbk <=2'd0;
                 if(ascii_or_gbk==2'd1||ascii_or_gbk==2'd2)
                   des_addr_0 <= des_addr_0+13'd2;
                 else
                   des_addr_0 <= des_addr_0+13'd4;      
            end         
            else;
            if(eth_data_count>=7'd60) 
            begin
              eth_en <= 1'b1;
              eth_data_count <= 7'd0;
              des_addr_0 <=13'd0;
            end
            else;    
        end        
    end    
end    

//�����ݴ���ʱ������־
reg ji1_ou0;
reg [12:0]des_addr_0;
reg [12:0]sd_ycount;
reg [1:0] wei_count;
reg       sd_rd_end;
reg       sd_rd_end_1d;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_comp_data <= 16'd0;
        rd_right_cnt <= 9'd0;
        sd_ycount <= 12'd0;
        des_addr <= 13'd0;
        ji1_ou0 <= 1'b0;
        eth_wr_ram_en<=1'b0;
        sd_rd_end<=1'b0;
        sd_rd_end_1d <= 1'b0;
        wei_count <=2'd0;
    end     
    else begin
        sd_rd_end_1d <= sd_rd_end;
        if(rd_val_en) begin//rd_val_en  rd_comp_data <= 16'd255
            //ʹ�ܺ�����
            if((ascii_or_gbk==2'd1&&rd_comp_data>8'd127)||(ascii_or_gbk==2'd2&&rd_comp_data<=8'd127))
                eth_wr_ram_en<=1'b0;
            else
                eth_wr_ram_en<=1'b1;

            des_data<=rd_val_data;//16'd0+{rd_comp_data[7:0],rd_comp_data[7:0]}
            
            //����λ��
            if((ascii_or_gbk==2'd0&&wei_count==2'd3)||(ascii_or_gbk==2'd1&&wei_count==2'd1)) 
            begin
                wei_count <= 1'b0;
                sd_ycount <= sd_ycount+7'd120;
            end
            else if(ascii_or_gbk==2'd2&&wei_count==2'd1)//&&wei_count==2'd1
            begin
                if(rd_comp_data<=8'd128)
                begin
                    sd_ycount <= 13'd0;
                    wei_count <= 1'b0;
                end
                else
                begin
                    
                    sd_ycount <= sd_ycount+7'd120;
                    wei_count <= 1'b0;
                end
            end
            else    
                wei_count <= wei_count +1'b1;
            des_addr <= sd_ycount+des_addr_0+wei_count;

            //����
            rd_comp_data <= rd_comp_data + 16'd1;
            if(rd_val_data == test_data_0[12'd4095-(rd_comp_data)*5'd16-:16])
                rd_right_cnt <= rd_right_cnt + 9'd1; 
             else; 
        end
        else
        begin
              if(rd_comp_data>=16'd256&&rd_comp_data<=16'd300)
              rd_comp_data <= rd_comp_data + 16'd1;
              else if(rd_comp_data>16'd300)
              begin
                  rd_comp_data <= 16'd0;
                  sd_rd_end<=1'b1;
                  sd_ycount <= 12'd0;
                  des_addr <= 13'd0; 
                  wei_count <=2'd0; 
                  eth_wr_ram_en<=1'b0;  
              end
              else;
              if(sd_rd_end) sd_rd_end<=1'b0;
              else;
        end     
    end        
end

endmodule