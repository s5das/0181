// Created by IP Generator (Version 2021.4-SP1.2 build 96435)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


size_down_fifo the_instance_name (
  .wr_data(wr_data),              // input [15:0]
  .wr_en(wr_en),                  // input
  .wr_clk(wr_clk),                // input
  .full(full),                    // output
  .wr_rst(wr_rst),                // input
  .almost_full(almost_full),      // output
  .rd_data(rd_data),              // output [15:0]
  .rd_en(rd_en),                  // input
  .rd_clk(rd_clk),                // input
  .empty(empty),                  // output
  .rd_rst(rd_rst),                // input
  .almost_empty(almost_empty)     // output
);
