`timescale 1ns / 1ps

/*******************************************************************
*
* Module: nmux.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
* Description: 
*   N-bit 2-to-1 multiplexer. Selects each bit from a_i when s_i = 0
*   and from b_i when s_i = 1. Implemented using generate blocks
*   and instances of the 1-bit mux.
*
* Dependencies: 
*   mux.v
*
* Change history:
*   09/30/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module nmux #(parameter N = 8) (
    input  wire          s_i,
    input  wire [N-1:0]  a_i,
    input  wire [N-1:0]  b_i,
    output wire [N-1:0]  c_o
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            mux u_mux (
                .s_i (s_i),
                .a_i (a_i[i]),
                .b_i (b_i[i]),
                .c_o (c_o[i])
            );
        end
    endgenerate
endmodule