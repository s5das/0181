`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Myminieye
// Engineer: Ori
// 
// Create Date:    2021-08-06 15:16 
// Design Name:  
// Module Name:    sync_vg
// QQ Group   :    808770961
// Project Name: 
// Target Devices: Gowin
// Tool Versions: 
// Description: 
// 
// Dependencies: 
//    VS     ______                                       ______
//HS  __    |      |_______________¡­¡­____________________|      |
//   |       h_sync  h_bp       h_act                h_fp
//   |__                    _______________________
//DE    |   _______________|                       |_____________
//      |
//      .
//      |
//    __|
//   |  
//   |__ 
//      |
// Revision: v1.0
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define UD #1

module sync_vg # (
    parameter X_BITS=12                ,
    parameter Y_BITS=12                ,
 //MODE_1080p
    parameter V_TOTAL = 12'd750       ,
    parameter V_FP = 12'd5             ,
    parameter V_BP = 12'd20            ,
    parameter V_SYNC = 12'd5           ,
    parameter V_ACT = 12'd720         ,
    parameter H_TOTAL = 12'd1650       ,
    parameter H_FP = 12'd110            ,
    parameter H_BP = 12'd220           ,
    parameter H_SYNC = 12'd40          ,
    parameter H_ACT = 12'd1280         ,
    parameter HV_OFFSET = 12'd0 
)(
    input                   clk,
    input                   rstn,
    output reg              vs_out,
    output reg              hs_out,
    output reg              de_out,
    output reg              de_re,
    output reg [X_BITS-1:0] x_act,
    output reg [Y_BITS-1:0] y_act
);

    reg [X_BITS-1:0] h_count;
    reg [Y_BITS-1:0] v_count;
    
    /* horizontal counter */
    always @(posedge clk)
    begin
        if (!rstn)
            h_count <= `UD 0;
        else
        begin
            if (h_count < H_TOTAL - 1)
                h_count <= `UD h_count + 1;
            else
                h_count <= `UD 0;
        end
    end
    
    /* vertical counter */
    always @(posedge clk)
    begin
        if (!rstn)
            v_count <= `UD 0;
        else
        if (h_count == H_TOTAL - 1)
        begin
            if (v_count == V_TOTAL - 1)
                v_count <= `UD 0;
            else
                v_count <= `UD v_count + 1;
        end
    end
    
    always @(posedge clk)
    begin
        if (!rstn)
            hs_out <= `UD 4'b0;
        else 
            hs_out <= `UD ((h_count < H_SYNC));
    end
    
    always @(posedge clk)
    begin
        if (!rstn)
            vs_out <= `UD 4'b0;
        else 
        begin
            if ((v_count == 0) && (h_count == HV_OFFSET))
                vs_out <= `UD 1'b1;
            else if ((v_count == V_SYNC) && (h_count == HV_OFFSET))
                vs_out <= `UD 1'b0;
            else
                vs_out <= `UD vs_out;
        end
    end
//   //MODE_1080p
//    parameter V_TOTAL = 12'd1125       ,
//    parameter V_FP = 12'd4             ,
//    parameter V_BP = 12'd36            ,
//    parameter V_SYNC = 12'd5           ,
//    parameter V_ACT = 12'd1080         ,
//    parameter H_TOTAL = 12'd2200       ,
//    parameter H_FP = 12'd88            ,
//    parameter H_BP = 12'd148           ,
//    parameter H_SYNC = 12'd44          ,
//    parameter H_ACT = 12'd1920         ,
//    parameter HV_OFFSET = 12'd0   
    always @(posedge clk)
    begin
        if (!rstn)
            de_out <= `UD 4'b0;
        else
            de_out <= (((v_count >= V_SYNC + V_BP) && (v_count <= V_TOTAL - V_FP - 1)) && 
                      ((h_count >= H_SYNC + H_BP) && (h_count <= H_TOTAL - H_FP - 1)));
    end
//////MODE_640*480p £»
//    parameter V_TOTAL_RE = 12'd525;
//    parameter V_FP_RE = 12'd2;//
//    parameter V_BP_RE = 12'd25;//
//    parameter V_SYNC_RE = 12'd2;//
//    parameter V_ACT_RE = 12'd480;//
//
//    parameter H_TOTAL_RE = 12'd800;
//    parameter H_FP_RE = 12'd8;//
//    parameter H_BP_RE = 12'd40;//
//    parameter H_SYNC_RE = 12'd96;//
//    parameter H_ACT_RE = 12'd640;//
////MODE_1024*768p £»
//    parameter V_TOTAL_RE = 12'd806;
//    parameter V_FP_RE = 12'd3;//
//    parameter V_BP_RE = 12'd29;//
//    parameter V_SYNC_RE = 12'd6;//
//    parameter V_ACT_RE = 12'd768;//
//
//    parameter H_TOTAL_RE = 12'd1344;
//    parameter H_FP_RE = 12'd24;//
//    parameter H_BP_RE = 12'd160;//
//    parameter H_SYNC_RE = 12'd136;//
//    parameter H_ACT_RE = 12'd1024;//
  //MODE_720p 
    parameter V_TOTAL_RE = 12'd750;
    parameter V_FP_RE = 12'd5;
    parameter V_BP_RE = 12'd20;
    parameter V_SYNC_RE = 12'd5;
    parameter V_ACT_RE = 12'd720;
    parameter H_TOTAL_RE = 12'd1650;
    parameter H_FP_RE = 12'd110;
    parameter H_BP_RE = 12'd220;
    parameter H_SYNC_RE = 12'd40;//260
    parameter H_ACT_RE = 12'd1280;
    parameter HV_OFFSET_RE = 12'd0;

    always @(posedge clk)
    begin
        if (!rstn)
            de_re <= `UD 4'b0;
        else//192<(h_count:1152)<2111;     41<(v_count:581)<1120  
            de_re <= (((v_count >= V_SYNC + V_BP) && (v_count <= V_TOTAL - V_FP - 1)) && 
                      ((h_count >= H_SYNC + H_BP-1) && (h_count <= H_TOTAL - H_FP -2)));//1280*720P//1280*720P
//
//(((h_count >= 640)&&(h_count <= 1664))&&((v_count >=197)&&(v_count <= 965)));//1024*768P
//(((h_count >= 832)&&(h_count <= 1471))&&((v_count >=341)&&(v_count <= 820)));//640*480P
    end    
    // active pixels counter output
    always @(posedge clk)
    begin
        if (!rstn)
            x_act <= `UD 'd0;
        else 
        begin
        /* X coords ¨C for a backend pattern generator */
            if(h_count > (H_SYNC + H_BP - 1'b1))
                x_act <= `UD (h_count - (H_SYNC + H_BP));
            else
                x_act <= `UD 'd0;
        end
    end
    
    always @(posedge clk)
    begin
        if (!rstn)
            y_act <= `UD 'd0;
        else 
        begin
            /* Y coords ¨C for a backend pattern generator */
            if(v_count > (V_SYNC + V_BP - 1'b1))
                y_act <= `UD (v_count - (V_SYNC + V_BP));
            else
                y_act <= `UD 'd0;
        end
    end
    
endmodule
