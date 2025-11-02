`timescale 1ns / 1ps

/*******************************************************************
*
* Module: full_adder.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description: 
*   1-bit full adder.
*   Computes sum (s_o) and carry-out (c_o) from inputs a_i, b_i, and carry-in c_i.
*
*
* Change history:
*   09/23/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module full_adder (
    input  wire a_i,   // Input bit A
    input  wire b_i,   // Input bit B
    input  wire c_i,   // Carry-in
    output wire s_o,   // Sum output
    output wire c_o    // Carry-out
);

    // Combinational logic
    assign s_o = a_i ^ b_i ^ c_i;
    assign c_o = (a_i & b_i) | (a_i & c_i) | (b_i & c_i);

endmodule

