`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2025 02:03:52 PM
// Design Name: 
// Module Name: RCA_module
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


module RCA_module #(parameter n = 8)(
input [n-1:0] A, [n-1:0] B, cin,
output cout, [n-1:0] S
    );
    
    wire [n:0] adder_cout;
    assign adder_cout[0] = cin ;
    
    genvar i;
    generate 
    for(i=0; i<n; i = i+1) begin
     Full_Adder inst(
     .A(A[i]),
     .B(B[i]),
     .cin(adder_cout[i]),
     .cout(adder_cout[i+1]),
     .S(S[i])
     ) ;
    end
    endgenerate
   
    assign  cout = adder_cout[n];
endmodule
