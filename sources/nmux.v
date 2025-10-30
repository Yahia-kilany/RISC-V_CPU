`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 02:22:20 PM
// Design Name: 
// Module Name: nmux
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


module nmux #(parameter n=8)( input[n-1:0] a, input[n-1:0] b, input s, output [n-1:0] c);
    genvar i;
    generate 
        for(i=0 ; i <n; i=i+1)begin
            mux  mx(a[i],b[i],s,c[i]);
        end
    endgenerate
endmodule
