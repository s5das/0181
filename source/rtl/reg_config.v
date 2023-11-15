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
//camera中寄存器的配置程序
 module reg_config(     
		  input clk_25M,
		  input camera_rstn,
		  input initial_en,
		  output reg_conf_done,
		  output i2c_sclk,
		  inout i2c_sdat,
		  output reg clock_20k,
		  output reg [8:0]reg_index
	  );

     reg [15:0]clock_20k_cnt;
     reg [1:0]config_step;	  
     reg [31:0]i2c_data;
     reg [23:0]reg_data;
     reg start;
	 reg reg_conf_done_reg;
	  
     i2c_com u1(.clock_i2c(clock_20k),
               .camera_rstn(camera_rstn),
               .ack(ack),
               .i2c_data(i2c_data),
               .start(start),
               .tr_end(tr_end),
               .i2c_sclk(i2c_sclk),
               .i2c_sdat(i2c_sdat));

assign reg_conf_done=reg_conf_done_reg;
//产生i2c控制时钟-20khz    
always@(posedge clk_25M)   
begin
   if(!camera_rstn) begin
        clock_20k<=0;
        clock_20k_cnt<=0;
   end
   else if(clock_20k_cnt<1249)
      clock_20k_cnt<=clock_20k_cnt+1'b1;
   else begin
         clock_20k<=!clock_20k;
         clock_20k_cnt<=0;
   end
end


////iic寄存器配置过程控制    
always@(posedge clock_20k)    
begin
   if(!camera_rstn) begin
       config_step<=0;
       start<=0;
       reg_index<=0;
		 reg_conf_done_reg<=0;
   end
   else begin
      if(reg_conf_done_reg==1'b0) begin          //如果camera初始化未完成
			  if(reg_index<304) begin               //配置前302个寄存器
					 case(config_step)
					 0:begin
						i2c_data<={8'h78,reg_data};       //OV5640 IIC Device address is 0x78   
						start<=1;                         //i2c写开始
						config_step<=1;                  
					 end
					 1:begin
						if(tr_end) begin                  //i2c写结束               					
							 start<=0;
							 config_step<=2;
						end
					 end
					 2:begin
						  reg_index<=reg_index+1'b1;       //配置下一个寄存器
						  config_step<=0;
					 end
					 endcase
				end
			 else 
				reg_conf_done_reg<=1'b1;                //OV5640寄存器初始化完成
      end
   end
 end
			
////iic需要配置的寄存器值  			
always@(reg_index)   
 begin
    case(reg_index)
	 0    :reg_data   <=24'h310311 ;//      10'd  0: lut_data <= {8'h78 , 24'h310311}; 
	 1    :reg_data   <=24'h300882 ;//      10'd  1: lut_data <= {8'h78 , 24'h300882};
	 2    :reg_data   <=24'h300842 ;//      10'd  2: lut_data <= {8'h78 , 24'h300842};
	 3    :reg_data   <=24'h310303 ;//      10'd  3: lut_data <= {8'h78 , 24'h310303};
	 4    :reg_data   <=24'h3017ff ;//      10'd  4: lut_data <= {8'h78 , 24'h3017ff};
	 5    :reg_data   <=24'h3018ff ;//      10'd  5: lut_data <= {8'h78 , 24'h3018ff};
	 6    :reg_data   <=24'h30341A ;//      10'd  6: lut_data <= {8'h78 , 24'h30341A};
	 7    :reg_data   <=24'h303713 ;//      10'd  7: lut_data <= {8'h78 , 24'h303713};
	 8    :reg_data   <=24'h310801 ;//      10'd  8: lut_data <= {8'h78 , 24'h310801};
	 9    :reg_data   <=24'h363036 ;//      10'd  9: lut_data <= {8'h78 , 24'h363036};
	 10   :reg_data  <=24'h36310e ;//       10'd 10: lut_data <= {8'h78 , 24'h36310e};
	 11   :reg_data  <=24'h3632e2 ;//       10'd 11: lut_data <= {8'h78 , 24'h3632e2};
	 12   :reg_data  <=24'h363312 ;//       10'd 12: lut_data <= {8'h78 , 24'h363312};
	 13   :reg_data  <=24'h3621e0 ;//       10'd 13: lut_data <= {8'h78 , 24'h3621e0};
	 14   :reg_data  <=24'h3704a0 ;//       10'd 14: lut_data <= {8'h78 , 24'h3704a0};
	 15   :reg_data  <=24'h37035a ;//       10'd 15: lut_data <= {8'h78 , 24'h37035a};
	 16   :reg_data  <=24'h371578 ;//       10'd 16: lut_data <= {8'h78 , 24'h371578};
	 17   :reg_data  <=24'h371701 ;//       10'd 17: lut_data <= {8'h78 , 24'h371701};
	 18   :reg_data  <=24'h370b60 ;//       10'd 18: lut_data <= {8'h78 , 24'h370b60};
	 19   :reg_data  <=24'h37051a ;//       10'd 19: lut_data <= {8'h78 , 24'h37051a};
	 20   :reg_data  <=24'h390502 ;//       10'd 20: lut_data <= {8'h78 , 24'h390502};
	 21   :reg_data  <=24'h390610 ;//       10'd 21: lut_data <= {8'h78 , 24'h390610};
	 22   :reg_data  <=24'h39010a ;//       10'd 22: lut_data <= {8'h78 , 24'h39010a};
	 23   :reg_data  <=24'h373112 ;//       10'd 23: lut_data <= {8'h78 , 24'h373112};
	 24   :reg_data  <=24'h360008 ;//       10'd 24: lut_data <= {8'h78 , 24'h360008};
	 25   :reg_data  <=24'h360133 ;//       10'd 25: lut_data <= {8'h78 , 24'h360133};
	 26   :reg_data  <=24'h302d60 ;//       10'd 26: lut_data <= {8'h78 , 24'h302d60};
	 27   :reg_data  <=24'h362052 ;//       10'd 27: lut_data <= {8'h78 , 24'h362052};
	 28   :reg_data  <=24'h371b20 ;//       10'd 28: lut_data <= {8'h78 , 24'h371b20};
	 29   :reg_data  <=24'h471c50 ;//       10'd 29: lut_data <= {8'h78 , 24'h471c50};
	 30   :reg_data  <=24'h3a1343 ;//       10'd 30: lut_data <= {8'h78 , 24'h3a1343};
	 31   :reg_data  <=24'h3a1800 ;//       10'd 31: lut_data <= {8'h78 , 24'h3a1800};
	 32   :reg_data  <=24'h3a19f8 ;//       10'd 32: lut_data <= {8'h78 , 24'h3a19f8};
	 33   :reg_data  <=24'h363513 ;//       10'd 33: lut_data <= {8'h78 , 24'h363513};
	 34   :reg_data  <=24'h363603 ;//       10'd 34: lut_data <= {8'h78 , 24'h363603};
	 35   :reg_data  <=24'h363440 ;//       10'd 35: lut_data <= {8'h78 , 24'h363440};
	 36   :reg_data  <=24'h362201 ;///      10'd 36: lut_data <= {8'h78 , 24'h362201};
	 37   :reg_data  <=24'h3c0134 ;//       10'd 37: lut_data <= {8'h78 , 24'h3c0134};
	 38   :reg_data  <=24'h3c0428 ;//       10'd 38: lut_data <= {8'h78 , 24'h3c0428};
	 39   :reg_data  <=24'h3c0598 ;//       10'd 39: lut_data <= {8'h78 , 24'h3c0598};
	 40   :reg_data  <=24'h3c0600 ;//       10'd 40: lut_data <= {8'h78 , 24'h3c0600};
     41   :reg_data  <=24'h3c0708 ;//       10'd 41: lut_data <= {8'h78 , 24'h3c0708};//``
	 42   :reg_data  <=24'h3c0800 ;//       10'd 42: lut_data <= {8'h78 , 24'h3c0800};
	 43   :reg_data  <=24'h3c091c ;//       10'd 43: lut_data <= {8'h78 , 24'h3c091c};
	 44   :reg_data  <=24'h3c0a9c ;//       10'd 44: lut_data <= {8'h78 , 24'h3c0a9c};
	 45   :reg_data  <=24'h3c0b40 ;//       10'd 45: lut_data <= {8'h78 , 24'h3c0b40};
	 46   :reg_data  <=24'h381000 ;//       10'd 46: lut_data <= {8'h78 , 24'h381000};
	 47   :reg_data  <=24'h381110 ;//       10'd 47: lut_data <= {8'h78 , 24'h381110};
	 48   :reg_data  <=24'h381200 ;//       10'd 48: lut_data <= {8'h78 , 24'h381200};
	 49   :reg_data  <=24'h370864 ;//       10'd 49: lut_data <= {8'h78 , 24'h370864};
	 50   :reg_data  <=24'h400102 ;//       10'd 50: lut_data <= {8'h78 , 24'h400102};
	 51   :reg_data  <=24'h40051a ;//       10'd 51: lut_data <= {8'h78 , 24'h40051a};
	 52   :reg_data  <=24'h300000 ;//       10'd 52: lut_data <= {8'h78 , 24'h300000};
	 53   :reg_data  <=24'h3004ff ;//       10'd 53: lut_data <= {8'h78 , 24'h3004ff};
	 54   :reg_data  <=24'h300e58 ;//       10'd 54: lut_data <= {8'h78 , 24'h300e58};
	 55   :reg_data  <=24'h302e00 ;//       10'd 55: lut_data <= {8'h78 , 24'h302e00};
	 56   :reg_data  <=24'h430060 ;//       10'd 56: lut_data <= {8'h78 , 24'h430060};
	 57   :reg_data  <=24'h501f01 ;//       10'd 57: lut_data <= {8'h78 , 24'h501f01};
	 58   :reg_data  <=24'h440e00 ;//       10'd 58: lut_data <= {8'h78 , 24'h440e00};
	 59   :reg_data  <=24'h5000a7 ;////     10'd 59: lut_data <= {8'h78 , 24'h5000a7};//``
	 60   :reg_data  <=24'h3a0f30 ;//       10'd 60: lut_data <= {8'h78 , 24'h3a0f30};
	 61   :reg_data  <=24'h3a1028 ;//       10'd 61: lut_data <= {8'h78 , 24'h3a1028};
	 62   :reg_data  <=24'h3a1b30 ;//       10'd 62: lut_data <= {8'h78 , 24'h3a1b30};//``
	 63   :reg_data  <=24'h3a1e26 ;//       10'd 63: lut_data <= {8'h78 , 24'h3a1e26};//``
	 64   :reg_data  <=24'h3a1160 ;//       10'd 64: lut_data <= {8'h78 , 24'h3a1160};//``
	 65   :reg_data  <=24'h3a1f14 ;//       10'd 65: lut_data <= {8'h78 , 24'h3a1f14};
	 66   :reg_data  <=24'h580023 ;//       10'd 66: lut_data <= {8'h78 , 24'h580023};
	 67   :reg_data  <=24'h580114 ;//       10'd 67: lut_data <= {8'h78 , 24'h580114};
	 68   :reg_data  <=24'h58020f ;//       10'd 68: lut_data <= {8'h78 , 24'h58020f};
	 69   :reg_data  <=24'h58030f ;//       10'd 69: lut_data <= {8'h78 , 24'h58030f};
	 70   :reg_data  <=24'h580412 ;//       10'd 70: lut_data <= {8'h78 , 24'h580412};
	 71   :reg_data  <=24'h580526 ;//       10'd 71: lut_data <= {8'h78 , 24'h580526};
	 72   :reg_data  <=24'h58060c ;//       10'd 72: lut_data <= {8'h78 , 24'h58060c};
	 73   :reg_data  <=24'h580708 ;//       10'd 73: lut_data <= {8'h78 , 24'h580708};
	 74   :reg_data  <=24'h580805 ;//       10'd 74: lut_data <= {8'h78 , 24'h580805};
	 75   :reg_data  <=24'h580905 ;//       10'd 75: lut_data <= {8'h78 , 24'h580905};
	 76   :reg_data  <=24'h580a08 ;//       10'd 76: lut_data <= {8'h78 , 24'h580a08};
	 77   :reg_data  <=24'h580b0d ;//       10'd 77: lut_data <= {8'h78 , 24'h580b0d};
	 78   :reg_data  <=24'h580c08 ;//       10'd 78: lut_data <= {8'h78 , 24'h580c08};
	 79   :reg_data  <=24'h580d03 ;//       10'd 79: lut_data <= {8'h78 , 24'h580d03};
	 80   :reg_data  <=24'h580e00 ;//       10'd 80: lut_data <= {8'h78 , 24'h580e00};
	 81   :reg_data  <=24'h580f00 ;//       10'd 81: lut_data <= {8'h78 , 24'h580f00};
	 82   :reg_data  <=24'h581003 ;//       10'd 82: lut_data <= {8'h78 , 24'h581003};
	 83   :reg_data  <=24'h581109 ;//       10'd 83: lut_data <= {8'h78 , 24'h581109};
	 84   :reg_data  <=24'h581207 ;//       10'd 84: lut_data <= {8'h78 , 24'h581207};
	 85   :reg_data  <=24'h581303 ;//       10'd 85: lut_data <= {8'h78 , 24'h581303};
	 86   :reg_data  <=24'h581400 ;//       10'd 86: lut_data <= {8'h78 , 24'h581400};
	 87   :reg_data  <=24'h581501 ;//       10'd 87: lut_data <= {8'h78 , 24'h581501};
	 88   :reg_data  <=24'h581603 ;//       10'd 88: lut_data <= {8'h78 , 24'h581603};
	 89   :reg_data  <=24'h581708 ;//       10'd 89: lut_data <= {8'h78 , 24'h581708};
	 90   :reg_data  <=24'h58180d ;//       10'd 90: lut_data <= {8'h78 , 24'h58180d};
	 91   :reg_data  <=24'h581908 ;//       10'd 91: lut_data <= {8'h78 , 24'h581908};
	 92   :reg_data  <=24'h581a05 ;//       10'd 92: lut_data <= {8'h78 , 24'h581a05};
	 93   :reg_data  <=24'h581b06 ;//       10'd 93: lut_data <= {8'h78 , 24'h581b06};
	 94   :reg_data  <=24'h581c08 ;//       10'd 94: lut_data <= {8'h78 , 24'h581c08};
	 95   :reg_data  <=24'h581d0e ;//       10'd 95: lut_data <= {8'h78 , 24'h581d0e};
	 96   :reg_data  <=24'h581e29 ;//       10'd 96: lut_data <= {8'h78 , 24'h581e29};
	 97   :reg_data  <=24'h581f17 ;//       10'd 97: lut_data <= {8'h78 , 24'h581f17};
	 98   :reg_data  <=24'h582011 ;//       10'd 98: lut_data <= {8'h78 , 24'h582011};
	 99   :reg_data  <=24'h582111 ;//       10'd 99: lut_data <= {8'h78 , 24'h582111};
	 100  :reg_data <=24'h582215 ;//        10'd100: lut_data <= {8'h78 , 24'h582215};
	 101  :reg_data <=24'h582328 ;//        10'd101: lut_data <= {8'h78 , 24'h582328};
	 102  :reg_data <=24'h582446 ;//        10'd102: lut_data <= {8'h78 , 24'h582446};
	 103  :reg_data <=24'h582526 ;//        10'd103: lut_data <= {8'h78 , 24'h582526};
	 104  :reg_data <=24'h582608 ;//        10'd104: lut_data <= {8'h78 , 24'h582608};
	 105  :reg_data <=24'h582726 ;//        10'd105: lut_data <= {8'h78 , 24'h582726};
	 106  :reg_data <=24'h582864 ;//        10'd106: lut_data <= {8'h78 , 24'h582864};
	 107  :reg_data <=24'h582926 ;//        10'd107: lut_data <= {8'h78 , 24'h582926};
	 108  :reg_data <=24'h582a24 ;//        10'd108: lut_data <= {8'h78 , 24'h582a24};
	 109  :reg_data <=24'h582b22 ;//        10'd109: lut_data <= {8'h78 , 24'h582b22};
	 110  :reg_data <=24'h582c24 ;//        10'd110: lut_data <= {8'h78 , 24'h582c24};
	 111  :reg_data <=24'h582d24 ;//        10'd111: lut_data <= {8'h78 , 24'h582d24};
	 112  :reg_data <=24'h582e06 ;//        10'd112: lut_data <= {8'h78 , 24'h582e06};
	 113  :reg_data <=24'h582f22 ;//        10'd113: lut_data <= {8'h78 , 24'h582f22};
	 114  :reg_data <=24'h583040 ;//        10'd114: lut_data <= {8'h78 , 24'h583040};
	 115  :reg_data <=24'h583142 ;//        10'd115: lut_data <= {8'h78 , 24'h583142};
	 116  :reg_data <=24'h583224 ;//        10'd116: lut_data <= {8'h78 , 24'h583224};
	 117  :reg_data <=24'h583326 ;//        10'd117: lut_data <= {8'h78 , 24'h583326};
	 118  :reg_data <=24'h583424 ;//        10'd118: lut_data <= {8'h78 , 24'h583424};
	 119  :reg_data <=24'h583522 ;//        10'd119: lut_data <= {8'h78 , 24'h583522};
	 120  :reg_data <=24'h583622 ;//        10'd120: lut_data <= {8'h78 , 24'h583622};
	 121  :reg_data <=24'h583726 ;//        10'd121: lut_data <= {8'h78 , 24'h583726};
	 122  :reg_data <=24'h583844 ;//        10'd122: lut_data <= {8'h78 , 24'h583844};
	 123  :reg_data <=24'h583924 ;//        10'd123: lut_data <= {8'h78 , 24'h583924};
	 124  :reg_data <=24'h583a26 ;//        10'd124: lut_data <= {8'h78 , 24'h583a26};
	 125  :reg_data <=24'h583b28 ;//        10'd125: lut_data <= {8'h78 , 24'h583b28};
	 126  :reg_data <=24'h583c42 ;//        10'd126: lut_data <= {8'h78 , 24'h583c42};
	 127  :reg_data <=24'h583dce ;//        10'd127: lut_data <= {8'h78 , 24'h583dce};
	 128  :reg_data <=24'h5180ff ;//        10'd128: lut_data <= {8'h78 , 24'h5180ff};
	 129  :reg_data <=24'h5181f2 ;//        10'd129: lut_data <= {8'h78 , 24'h5181f2};
	 130  :reg_data <=24'h518200 ;//        10'd130: lut_data <= {8'h78 , 24'h518200};
	 131  :reg_data <=24'h518314 ;//        10'd131: lut_data <= {8'h78 , 24'h518314};
	 132  :reg_data <=24'h518425 ;//        10'd132: lut_data <= {8'h78 , 24'h518425};
	 133  :reg_data <=24'h518524 ;//        10'd133: lut_data <= {8'h78 , 24'h518524};
	 134  :reg_data <=24'h518609 ;//        10'd134: lut_data <= {8'h78 , 24'h518609};
	 135  :reg_data <=24'h518709 ;//        10'd135: lut_data <= {8'h78 , 24'h518709};
	 136  :reg_data <=24'h518809 ;//        10'd136: lut_data <= {8'h78 , 24'h518809};
	 137  :reg_data <=24'h518975 ;//        10'd137: lut_data <= {8'h78 , 24'h518975};
	 138  :reg_data <=24'h518a54 ;//        10'd138: lut_data <= {8'h78 , 24'h518a54};
	 139  :reg_data <=24'h518be0 ;//        10'd139: lut_data <= {8'h78 , 24'h518be0};
	 140  :reg_data <=24'h518cb2 ;//        10'd140: lut_data <= {8'h78 , 24'h518cb2};
	 141  :reg_data <=24'h518d42 ;//        10'd141: lut_data <= {8'h78 , 24'h518d42};
	 142  :reg_data <=24'h518e3d ;//        10'd142: lut_data <= {8'h78 , 24'h518e3d};
	 143  :reg_data <=24'h518f56 ;//        10'd143: lut_data <= {8'h78 , 24'h518f56};
	 144  :reg_data <=24'h519046 ;//        10'd144: lut_data <= {8'h78 , 24'h519046};
	 145  :reg_data <=24'h5191f8 ;//        10'd145: lut_data <= {8'h78 , 24'h5191f8};
	 146  :reg_data <=24'h519204 ;//        10'd146: lut_data <= {8'h78 , 24'h519204};
	 147  :reg_data <=24'h519370 ;//        10'd147: lut_data <= {8'h78 , 24'h519370};
	 148  :reg_data <=24'h5194f0 ;//        10'd148: lut_data <= {8'h78 , 24'h5194f0};
	 149  :reg_data <=24'h5195f0 ;//        10'd149: lut_data <= {8'h78 , 24'h5195f0};
	 150  :reg_data <=24'h519603 ;//        10'd150: lut_data <= {8'h78 , 24'h519603};
	 151  :reg_data <=24'h519701 ;//        10'd151: lut_data <= {8'h78 , 24'h519701};
	 152  :reg_data <=24'h519804 ;//        10'd152: lut_data <= {8'h78 , 24'h519804};
	 153  :reg_data <=24'h519912 ;//        10'd153: lut_data <= {8'h78 , 24'h519912};
	 154  :reg_data <=24'h519a04 ;//        10'd154: lut_data <= {8'h78 , 24'h519a04};
	 155  :reg_data <=24'h519b00 ;//        10'd155: lut_data <= {8'h78 , 24'h519b00};
	 156  :reg_data <=24'h519c06 ;//        10'd156: lut_data <= {8'h78 , 24'h519c06};
	 157  :reg_data <=24'h519d82 ;//        10'd157: lut_data <= {8'h78 , 24'h519d82};
	 158  :reg_data <=24'h519e38 ;//        10'd158: lut_data <= {8'h78 , 24'h519e38};
	 159  :reg_data <=24'h548001 ;//        10'd159: lut_data <= {8'h78 , 24'h548001};
	 160  :reg_data <=24'h548108 ;//        10'd160: lut_data <= {8'h78 , 24'h548108};
	 161  :reg_data <=24'h548214 ;//        10'd161: lut_data <= {8'h78 , 24'h548214};
	 162  :reg_data <=24'h548328 ;//        10'd162: lut_data <= {8'h78 , 24'h548328};
	 163  :reg_data <=24'h548451 ;//        10'd163: lut_data <= {8'h78 , 24'h548451};
	 164  :reg_data <=24'h548565 ;//        10'd164: lut_data <= {8'h78 , 24'h548565};
	 165  :reg_data <=24'h548671 ;//        10'd165: lut_data <= {8'h78 , 24'h548671};
	 166  :reg_data <=24'h54877d ;//        10'd166: lut_data <= {8'h78 , 24'h54877d};
	 167  :reg_data <=24'h548887 ;//        10'd167: lut_data <= {8'h78 , 24'h548887};
	 168  :reg_data <=24'h548991 ;//        10'd168: lut_data <= {8'h78 , 24'h548991};
	 169  :reg_data <=24'h548a9a ;//        10'd169: lut_data <= {8'h78 , 24'h548a9a};
	 170  :reg_data <=24'h548baa ;//        10'd170: lut_data <= {8'h78 , 24'h548baa};
	 171  :reg_data <=24'h548cb8 ;//        10'd171: lut_data <= {8'h78 , 24'h548cb8};
	 172  :reg_data <=24'h548dcd ;//        10'd172: lut_data <= {8'h78 , 24'h548dcd};
	 173  :reg_data <=24'h548edd ;//        10'd173: lut_data <= {8'h78 , 24'h548edd};
	 174  :reg_data <=24'h548fea ;//        10'd174: lut_data <= {8'h78 , 24'h548fea};
	 175  :reg_data <=24'h54901d ;//        10'd175: lut_data <= {8'h78 , 24'h54901d};
	 176  :reg_data <=24'h53811e ;//        10'd176: lut_data <= {8'h78 , 24'h53811e};
	 177  :reg_data <=24'h53825b ;//        10'd177: lut_data <= {8'h78 , 24'h53825b};
	 178  :reg_data <=24'h538308 ;//        10'd178: lut_data <= {8'h78 , 24'h538308};
	 179  :reg_data <=24'h53840a ;//        10'd179: lut_data <= {8'h78 , 24'h53840a};
	 180  :reg_data <=24'h53857e ;//        10'd180: lut_data <= {8'h78 , 24'h53857e};
	 181  :reg_data <=24'h538688 ;//        10'd181: lut_data <= {8'h78 , 24'h538688};
	 182  :reg_data <=24'h53877c ;//        10'd182: lut_data <= {8'h78 , 24'h53877c};
	 183  :reg_data <=24'h53886c ;//        10'd183: lut_data <= {8'h78 , 24'h53886c};
	 184  :reg_data <=24'h538910 ;//        10'd184: lut_data <= {8'h78 , 24'h538910};
	 185  :reg_data <=24'h538a01 ;//        10'd185: lut_data <= {8'h78 , 24'h538a01};
	 186  :reg_data <=24'h538b98 ;///       10'd186: lut_data <= {8'h78 , 24'h538b98};
	 187  :reg_data <=24'h558006 ;//        10'd187: lut_data <= {8'h78 , 24'h558006};
	 188  :reg_data <=24'h558340 ;//        10'd188: lut_data <= {8'h78 , 24'h558340};
	 189  :reg_data <=24'h558410 ;//        10'd189: lut_data <= {8'h78 , 24'h558410};
	 190  :reg_data <=24'h558910 ;//        10'd190: lut_data <= {8'h78 , 24'h558910};
	 191  :reg_data <=24'h558a00 ;//        10'd191: lut_data <= {8'h78 , 24'h558a00};
	 192  :reg_data <=24'h558bf8 ;//        10'd192: lut_data <= {8'h78 , 24'h558bf8};
	 193  :reg_data <=24'h501d40 ;//        10'd193: lut_data <= {8'h78 , 24'h501d40};
	 194  :reg_data <=24'h530008 ;//        10'd194: lut_data <= {8'h78 , 24'h530008};
	 195  :reg_data <=24'h530130 ;//        10'd195: lut_data <= {8'h78 , 24'h530130};
	 196  :reg_data <=24'h530210 ;//        10'd196: lut_data <= {8'h78 , 24'h530210};
	 197  :reg_data <=24'h530300 ;//        10'd197: lut_data <= {8'h78 , 24'h530300};
	 198  :reg_data <=24'h530408 ;//        10'd198: lut_data <= {8'h78 , 24'h530408};
	 199  :reg_data <=24'h530530 ;//        10'd199: lut_data <= {8'h78 , 24'h530530};
	 200  :reg_data <=24'h530608 ;//        10'd200: lut_data <= {8'h78 , 24'h530608};
	 201  :reg_data <=24'h530716 ;//        10'd201: lut_data <= {8'h78 , 24'h530716};
	 202  :reg_data <=24'h530908 ;//        10'd202: lut_data <= {8'h78 , 24'h530908};
	 203  :reg_data <=24'h530a30 ;//        10'd203: lut_data <= {8'h78 , 24'h530a30};
	 204  :reg_data <=24'h530b04 ;//        10'd204: lut_data <= {8'h78 , 24'h530b04};
	 205  :reg_data <=24'h530c06 ;//        10'd205: lut_data <= {8'h78 , 24'h530c06};
	 206  :reg_data <=24'h502500 ;//        10'd206: lut_data <= {8'h78 , 24'h502500};
	 207  :reg_data <=24'h300802 ;///       10'd207: lut_data <= {8'h78 , 24'h300802};   
//720 30帧/秒, night mode 5fps ;//         
//input clock=24Mhz,PCLK=84Mhz ;//         
	 208  :reg_data <=24'h303521 ;//        10'd208: lut_data <= {8'h78 , 24'h303511};
	 209  :reg_data <=24'h303669 ;//        10'd209: lut_data <= {8'h78 , 24'h303646}; 
                                  //        10'd210: lut_data <= {8'h78 , 24'h3c0708}; 
	 211  :reg_data <=24'h382047 ;//        10'd211: lut_data <= {8'h78 , 24'h382047}; 
	 212  :reg_data <=24'h382100 ;//        10'd212: lut_data <= {8'h78 , 24'h382100}; 
	 213  :reg_data <=24'h381431 ;//        10'd213: lut_data <= {8'h78 , 24'h381431}; 
	 214  :reg_data <=24'h381531 ;//        10'd214: lut_data <= {8'h78 , 24'h381531}; 
	 215  :reg_data <=24'h380000 ;//        10'd215: lut_data <= {8'h78 , 24'h380000}; 
	 216  :reg_data <=24'h380100 ;//        10'd216: lut_data <= {8'h78 , 24'h380100}; 
	 217  :reg_data <=24'h380200 ;//        10'd217: lut_data <= {8'h78 , 24'h380200}; 
	 218  :reg_data <=24'h3803fa ;//        10'd218: lut_data <= {8'h78 , 24'h380304}; 
	 219  :reg_data <=24'h38040a ;//        10'd219: lut_data <= {8'h78 , 24'h38040a}; 
	 220  :reg_data <=24'h38053f ;//        10'd220: lut_data <= {8'h78 , 24'h38053f}; 
	 221  :reg_data <=24'h380606 ;//        10'd221: lut_data <= {8'h78 , 24'h380607}; 
	 222  :reg_data <=24'h3807a9 ;//        10'd222: lut_data <= {8'h78 , 24'h38079b}; 
	 223  :reg_data <=24'h380805 ;//        10'd223: lut_data <= {8'h78 , 24'h380802}; 
	 224  :reg_data <=24'h380900 ;//        10'd224: lut_data <= {8'h78 , 24'h380980}; 
	 225  :reg_data <=24'h380a02 ;//        10'd225: lut_data <= {8'h78 , 24'h380a01}; 
	 226  :reg_data <=24'h380bd0 ;//        10'd226: lut_data <= {8'h78 , 24'h380be0}; 
	 227  :reg_data <=24'h380c07 ;//        10'd227: lut_data <= {8'h78 , 24'h380c07}; 
	 228  :reg_data <=24'h380d64 ;//        10'd228: lut_data <= {8'h78 , 24'h380d68}; 
	 229  :reg_data <=24'h380e02 ;//        10'd229: lut_data <= {8'h78 , 24'h380e03}; 
	 230  :reg_data <=24'h380fe4 ;//        10'd230: lut_data <= {8'h78 , 24'h380fd8}; 
	 231  :reg_data <=24'h381304 ;//        10'd231: lut_data <= {8'h78 , 24'h381306}; 
	 232  :reg_data <=24'h361800 ;//        10'd232: lut_data <= {8'h78 , 24'h361800}; 
	 233  :reg_data <=24'h361229 ;//        10'd233: lut_data <= {8'h78 , 24'h361229}; 
	 234  :reg_data <=24'h370952 ;//        10'd234: lut_data <= {8'h78 , 24'h370952}; 
	 235  :reg_data <=24'h370c03 ;//        10'd235: lut_data <= {8'h78 , 24'h370c03}; 
	 236  :reg_data <=24'h3a0202 ;//        10'd236: lut_data <= {8'h78 , 24'h3a0217}; 
	 237  :reg_data <=24'h3a03e0 ;//        10'd237: lut_data <= {8'h78 , 24'h3a0310}; 
	 281  :reg_data <=24'h3a0800 ;//        
	 282  :reg_data <=24'h3a096f ;//        
	 283  :reg_data <=24'h3a0a00 ;//        
	 284  :reg_data <=24'h3a0b5c ;//        
	 285  :reg_data <=24'h3a0e06 ;//        
	 286  :reg_data <=24'h3a0d08 ;//        
	 287  :reg_data <=24'h3a1402 ;//        10'd238: lut_data <= {8'h78 , 24'h3a1417}; 
	 288  :reg_data <=24'h3a15e0 ;//        10'd239: lut_data <= {8'h78 , 24'h3a1510}; 
	 289  :reg_data <=24'h400402 ;//        10'd240: lut_data <= {8'h78 , 24'h400402}; 
	 290  :reg_data <=24'h30021c ;//        10'd241: lut_data <= {8'h78 , 24'h30021c}; 
	 291  :reg_data <=24'h3006c3 ;//        10'd242: lut_data <= {8'h78 , 24'h3006c3}; 
	 292  :reg_data <=24'h471303 ;//        10'd243: lut_data <= {8'h78 , 24'h471303}; 
	 293  :reg_data <=24'h440704 ;//        10'd244: lut_data <= {8'h78 , 24'h440704}; 
	 294  :reg_data <=24'h460b37 ;//        10'd245: lut_data <= {8'h78 , 24'h460b35};   
     295  :reg_data <=24'h460c20 ;//        10'd246: lut_data <= {8'h78 , 24'h460c22};  
	 296  :reg_data <=24'h483716 ;//        10'd247: lut_data <= {8'h78 , 24'h483722}; 
	 297  :reg_data <=24'h382404 ;//        10'd248: lut_data <= {8'h78 , 24'h382402}; 
	 298  :reg_data <=24'h500183 ;//        10'd249: lut_data <= {8'h78 , 24'h5001a3}; 
	 299  :reg_data <=24'h350300 ;//        10'd250: lut_data <= {8'h78 , 24'h350300}; 
//
//	 300  :reg_data <=24'h301602 ;//
//	 301  :reg_data <=24'h3b070a ;//	 
//	 302  :reg_data <=24'h3b0083 ;//
//	 303  :reg_data <=24'h3b0000 ;//
	 default:reg_data<=24'hffffff;//         10'd251: lut_data <= {8'hff , 24'hffffff}
    endcase      
end	 



endmodule

