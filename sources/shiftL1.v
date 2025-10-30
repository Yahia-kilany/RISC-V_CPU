`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 02:40:56 PM
// Design Name: 
// Module Name: shiftL1
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


module shiftL1 #(parameter n=8)( input [n-1:0] a, output[n-1:0] b);

    assign b = {a[n-2:0],1'b0};

endmodule
