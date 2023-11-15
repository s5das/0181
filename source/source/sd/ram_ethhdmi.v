module ram_ethhdmi(
    input        sys_rst_n        ,
    input        clk_ref          ,
    input [12:0] des_addr         ,
    input [15:0] des_data         ,
    input        eth_wr_ram_en    ,
                             
    input        rstn         ,
    input        pix_clk          ,
    input [12:0] ram_hdmi_des_addr,
                              
    output [15:0]    ram_hdmi_des_data //reg
);
    eth_ram_hdmi u_eth_ram_hdmi (
        .wr_data    (des_data),    // input [15:0]
        .wr_addr    (des_addr),    // input [11:0]
        .wr_en      (eth_wr_ram_en),        // input
        .wr_clk     (clk_ref),      // input
        .wr_rst     (~sys_rst_n),      // input

        .rd_addr    (ram_hdmi_des_addr),    // input [11:0]
        .rd_data    (ram_hdmi_des_data),    // output [15:0]
        .rd_clk     (pix_clk),      // input
        .rd_rst     (1'b0)       // input
    );
endmodule