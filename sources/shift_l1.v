`timescale 1ns / 1ps

/*******************************************************************
*
* Module: shift_l1.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description:
*   N-bit logical left shifter by 1.
*   - Input: a_i [N-1:0]
*   - Output: b_o [N-1:0] = a_i << 1
*   - Implements a single-bit left shift using concatenation.
*
*
* Change history:
*   09/30/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module shift_l1 #(parameter N=8)( 
    input [N-1:0] a_i, // input
    output[N-1:0] b_o  // output = input << 1
);

    assign b_o = {a_i[N-2:0],1'b0};

endmodule
