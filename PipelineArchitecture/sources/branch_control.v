`timescale 1ns / 1ps
`include "defines.v"

/*******************************************************************
*
* Module: branch_control.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
*
* Description:
*   Evaluates branch conditions based on the funct3 field and ALU flags.
*   Determines whether a conditional branch should be taken by interpreting
*   the result of (a - b). Supports all standard RISC-V branch types:
*   BEQ, BNE, BLT, BGE, BLTU, and BGEU.
*
* Change history:
*   11/08/2025 – created and integrated with project (Yahia)
*
*******************************************************************/

module branch_control(
    input wire [2:0] funct3_i,
    input wire zf_i,
    input wire cf_i,
    input wire vf_i,
    input wire sf_i,
    output reg take_branch_o
);
    always @(*) begin
        case(funct3_i) 
            `BR_BEQ : take_branch_o = zf_i; // subtraction result == 0
            `BR_BNE : take_branch_o = ~zf_i;// subtraction result != 0
            `BR_BLT : take_branch_o = (sf_i != vf_i); // valid negative value  
            `BR_BGE : take_branch_o = (sf_i == vf_i); // opposite of BLT
            `BR_BLTU: take_branch_o = ~cf_i; // borrow occured
            `BR_BGEU: take_branch_o = cf_i; // no borrow
            default: take_branch_o = 1'b0;
        endcase
    end
endmodule