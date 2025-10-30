`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 01:49:16 PM
// Design Name: 
// Module Name: Top
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


module alu #(parameter n =8)( 
input [n-1:0] A, [n-1:0] B, [3:0] sel,
output zeroflag, [n-1:0] C
    );
    wire [n-1:0] SUM;
    wire [n-1:0] AND;
    wire [n-1:0] OR;
    wire cout;
    assign AND = A & B;
    assign OR = A | B;
    wire [n-1:0] muxout;

    
    nmux#(n) muxx(B,~B,sel[2], muxout);
    
    RCA_module #(n) rca( A,muxout,sel[2], cout ,SUM);
    
    mux16x1 #(n) mux(SUM,SUM,AND, OR, sel,C);
    
    assign zeroflag = C==0 ;
    
endmodule
