`timescale 1ns / 1ps

/*******************************************************************
*
* Module: mux16x1.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
* Description: 
*   N-bit 4-to-1 multiplexer for ALU operations (ADD, SUB, AND, OR).
*   Select input s_i chooses the output c_o.
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module mux16x1 #(parameter N = 8) (
    input wire  [3:0]   s_i,
    input wire  [N-1:0] sum_i,
    input wire  [N-1:0] sub_i,
    input wire  [N-1:0] and_i,
    input wire  [N-1:0] or_i,
    output reg  [N-1:0] c_o
);

    always @(*) begin
        case (s_i)
            4'b0010: c_o = sum_i;   // ADD
            4'b0110: c_o = sub_i;   // SUB
            4'b0000: c_o = and_i;   // AND
            4'b0001: c_o = or_i;    // OR
            default: c_o = {N{1'b0}}; //Default to 0
        endcase
    end

endmodule