`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 01:45:34 PM
// Design Name: 
// Module Name: Reg
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


module  Reg #(parameter n = 8) (input clk, input rst ,input load,
 input[n-1:0] Data,
 output [n-1:0] Q);
 wire[n-1:0] D;
 
 genvar i;
  generate 
    for(i=n-1;i>=0;i=i-1) begin
        mux m( Q[i], Data[i],load,D[i]);
        DFlipFlop d(clk,rst, D[i], Q[i]);
        end
 endgenerate
endmodule
