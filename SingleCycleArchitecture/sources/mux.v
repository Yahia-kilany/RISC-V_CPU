`timescale 1ns / 1ps

/*******************************************************************
*
* Module: mux.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
* Description: 
*   2-to-1 multiplexer using gate-level logic.
*   Outputs a_i when s_i = 0 and b_i when s_i = 1.
*
* Change history:
*   09/30/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module mux (
    input  wire s_i,   // select
    input  wire a_i,   // input A
    input  wire b_i,   // input B
    output wire c_o    // output
);
    wire res1_w;
    wire res2_w;

    // Internal logic using gate-level modeling
    and and1 (res1_w, b_i, s_i);
    and and2 (res2_w, a_i, ~s_i);
    or  or1  (c_o, res1_w, res2_w);

endmodule