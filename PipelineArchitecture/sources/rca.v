`timescale 1ns / 1ps

/*******************************************************************
*
* Module: rca.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
* Description: 
*   N-bit ripple carry adder. Computes the sum of inputs a_i and b_i
*   with carry-in c_i, producing sum output s_o and carry-out c_o.
*   Implemented using N instances of 1-bit full adders in a generate block.
*
* Dependencies: 
*   full_adder.v
*
* Change history:
*   09/23/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module rca #(parameter N = 8) (
    input  wire [N-1:0] a_i,    // Operand A
    input  wire [N-1:0] b_i,    // Operand B
    input  wire         c_i,   // Carry-in
    output wire [N-1:0] s_o,   // Sum output
    output wire         c_o    // Carry-out
);

    // Internal carry chain
    wire [N:0] carry_w;

    assign carry_w[0] = c_i;

    // Generate N full adders
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            full_adder fa_inst (
                .a_i (a_i[i]),
                .b_i (b_i[i]),
                .c_i (carry_w[i]),
                .s_o (s_o[i]),
                .c_o (carry_w[i+1])
            );
        end
    endgenerate

    // Final carry-out
    assign c_o = carry_w[N];

endmodule