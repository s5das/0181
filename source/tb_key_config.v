`timescale  1ns / 1ns

module tb_key_config;

wire GRS_N;

GTP_GRS GRS_INST (
   .GRS_N(1'b1)
);


// key_config Parameters
parameter PERIOD          = 10     ;
parameter ROM_ADDR_WIDTH  = 12     ;
parameter ROM_DATA_WIDTH  = 15     ;
parameter INITIAL_X_NUMS  = 13'd640;
parameter INITIAL_Y_NUMS  = 13'd360;
parameter DDR_ADDR_WIDTH  = 28     ;

// key_config Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   key1                                 = 0 ;
reg   key2                                 = 0 ;
reg   key3                                 = 0 ;
reg   key4                                 = 0 ;

// key_config Outputs
wire[14:0]                       y_scale ;
wire[14:0]                       x_scale ;
wire[10:0]                       TARGET_H_NUM ;
wire[10:0]                       TARGET_V_NUM ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
    key1 <= 1'd1;
    #17;
    key1 <= 1'd0;
    #200;
    key1 <= 1'd1;
    
end

key_config #(
    .ROM_ADDR_WIDTH ( ROM_ADDR_WIDTH ),
    .ROM_DATA_WIDTH ( ROM_DATA_WIDTH ),
    .INITIAL_X_NUMS ( INITIAL_X_NUMS ),
    .INITIAL_Y_NUMS ( INITIAL_Y_NUMS ),
    .DDR_ADDR_WIDTH ( DDR_ADDR_WIDTH ))
 u_key_config (
    .clk                                            ( clk                                             ),
    .rstn                                           ( rstn                                            ),
    .key1                                           ( key1                                            ),
    .key2                                           ( key2                                            ),
    .key3                                           ( key3                                            ),
    .key4                                           ( key4                                            ),

    .y_scale                                       ( y_scale                                          ),
    .x_scale                                       ( x_scale                                          ),
    .TARGET_H_NUM                                  ( TARGET_H_NUM                                     ),
    .TARGET_V_NUM                                  ( TARGET_V_NUM                                     )
);



endmodule