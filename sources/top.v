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


module top(input rclk, clkssd, rst, [1:0] ledSel,[3:0] ssdSel,output [15:0] instLed , [3:0] anode,[6:0] Led_out);
wire [12:0] ssdLed;
cpu riscv(.clk(rclk),.rst(rst), .led_sel_i(ledel),.ssd_sel_i(ssdSel), .inst_led_o(instLed), .ssd_o(ssdLed));
four_digit_seven_segment_driver FDSSDO(
    .clk(clkssd),
    .num(ssdLed),
    .Anode(anode),
    .LED_out(Led_out)
);
endmodule
