`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2025 03:22:47 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(input rclk, clkssd, rst, [1:0] ledSel,[3:0] ssdSel,output [15:0] instLed , [3:0] anode,[6:0] led_out);
wire [12:0] ssdLed;

clk_divider_2 divider (
    .clk_i(rclk),
    .rst_i(reset),
    .clk_o(sclk)
);
cpu riscv(.clk(sclk),.rst(rst), .led_sel_i(ledel),.ssd_sel_i(ssdSel), .inst_led_o(instLed), .ssd_o(ssdLed));
four_digit_seven_segment_driver FDSSDO(
    .clk(clkssd),
    .num_i(ssdLed),
    .anode_o(anode),
    .seg_o(led_out)
);
endmodule
