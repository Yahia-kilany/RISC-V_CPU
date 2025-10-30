`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 02:00:42 PM
// Design Name: 
// Module Name: mux16x1
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


module mux16x1 #(parameter n=8)( input[n-1:0] SUM, input[n-1:0] SUB, input[n-1:0] AND, input[n-1:0] OR, input[3:0] s, output reg [n-1:0] c);

always @(*) begin
if(s == 4'b0010) begin c = SUM; end
else if(s == 4'b0110) begin c = SUB; end
else if(s == 4'b0000) begin c= AND; end
else if(s == 4'b0001) begin c = OR; end
else begin c =0; end
end
endmodule

