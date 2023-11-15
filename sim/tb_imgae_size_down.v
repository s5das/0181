`timescale 1ns/1ns

module tb_imgae_size_down();

wire GRS_N;

GTP_GRS GRS_INST (
   .GRS_N(1'b1)
);

reg clk;
reg rstn;
initial begin
   clk <= 1'b0;
   rstn<= 1'b0;
   #10;
   rstn<= 1'b1;
   
end
always #10 clk <= ~clk;


wire     [15:0]             width_i       ;
wire     [15:0]             height_i      ;
wire     [15:0]             tdata_i       ;
wire                        tvalid_i      ;
wire     [15:0]             tdata_o       ;
wire                        tvalid_o      ;

assign   width_i  =  16'd1280;
assign   height_i =  16'd720;

reg   [11:0]      x_cnt;
reg   [11:0]      y_cnt;

always @(posedge clk or negedge rstn) begin
   if(!rstn)
      x_cnt<=12'hfff;
   else
      x_cnt<=x_cnt+1'd1;
   if(x_cnt==12'd2200)
      x_cnt<=12'd0;
end

// always @(posedge clk or negedge rstn) begin
//    if(!rstn)
//       y_cnt<=12'hfff;
//    else  if(x_cnt==12'd2199)
//       y_cnt<=y_cnt+1'd1;
//    if(y_cnt==12'd2200)
//       x_cnt<=12'd0;
// end

assign tvalid_i   =  (x_cnt>=110&&x_cnt<=1389)?1'd1:1'd0;

image_size_down   image_size_down_inst                  
(					 					
            .clk_i               (  clk          ),
            .rst_i               (  ~rstn        ),

            .width_i             (  width_i      ),
            .height_i            (  height_i     ),						 

            .tdata_i             (  x_cnt        ),
            .tvalid_i            (  tvalid_i     ),
            
            .tdata_o             (  tdata_o      ),
            .tvalid_o            (  tvalid_o     )
);



endmodule