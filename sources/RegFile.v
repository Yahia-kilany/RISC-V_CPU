`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 03:16:09 PM
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


module RegFile#(parameter n=32) (
input clk,
input rst,
input [4:0] readAdd1,
input [4:0] readAdd2, 
input [4:0] writeAdd,
input regWrite,
input [n-1:0] writeData,
output  reg [n-1:0] regread1, 
output reg [n-1:0] regread2
    );
    
    
    reg [n-1:0] register [31:0];
    

    always @(*) begin
    regread1 = register [readAdd1];
    regread2 = register [readAdd2];
    end
    
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
          for( i =0; i<32; i= i+1) begin
              register[i] = 0;
          end
        end
       else if( regWrite && writeAdd != 0) 
         register[writeAdd] = writeData;
   end
   

endmodule
