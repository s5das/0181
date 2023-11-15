module key_config#(
         parameter         ROM_ADDR_WIDTH    =  12,
         parameter         ROM_DATA_WIDTH    =  15,
         parameter         INITIAL_X_NUMS    =  13'd640,
         parameter         INITIAL_Y_NUMS    =  13'd360,
         parameter         DDR_ADDR_WIDTH    =  28
)
(
         input                                     clk,  //ddr_core_100MHz
         input                                     rstn,

         input    wire                             key1,//key to increase x_scale
         input    wire                             key2,//key to decrease x_scale
         input                                     shift,

         output   wire[14:0]                       y_scale,
         output   wire[14:0]                       x_scale,
         output   wire[10:0]                       TARGET_H_NUM,
         output   wire[10:0]                       TARGET_V_NUM
);

reg   [31:0]      time_cnt;
reg   [1:0]       key_scan_r;
reg   [1:0]       key_scan;
reg   [10:0]      h_num_reg;
reg   [10:0]      v_num_reg;
wire  [1:0]       key_trig    =     key_scan_r[1:0]&(~key_scan[1:0]);



always @(posedge clk or negedge rstn) begin
      if(!rstn)
            time_cnt    <=      32'd0;
      else  if(time_cnt ==    32'd2000000)      begin
            time_cnt    <=    32'd0;
            key_scan    <=    {key2,key1};
      end
      else  begin
            time_cnt    <=    time_cnt    +     1'd1;
      end

end

always @(posedge clk ) begin
      key_scan_r  <=    key_scan;
end




always @(posedge clk or negedge rstn) begin
      if(!rstn)   begin
         h_num_reg   <=    11'd640;
         v_num_reg   <=    11'd360;
      end
      else if(key_trig[0]==1'd1)
                  h_num_reg   <=    (shift==1'd0)?(h_num_reg+3'd5):(h_num_reg-3'd5);
      else if(key_trig[1]==1'd1)
                  v_num_reg   <=    (shift==1'd0)?(v_num_reg+3'd5):(v_num_reg-3'd5);
            

end

x_scale_rom x_scale_rom_inst(
      .clk              (clk),
      .rst              (!rstn),
      .addr             (h_num_reg-1'd1),
      .rd_data          (x_scale)
);


y_scale_rom y_scale_rom_inst(
      .clk              (clk),
      .rst              (!rstn),
      .addr             (v_num_reg-1'd1),
      .rd_data          (y_scale)
);


assign   TARGET_H_NUM      =     h_num_reg;
assign   TARGET_V_NUM      =     v_num_reg;



endmodule