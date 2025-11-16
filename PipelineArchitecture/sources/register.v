`timescale 1ns / 1ps

/*******************************************************************
*
* Module: register.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
* Description: 
*   N-bit register with asynchronous active-high reset and write enable.
*   - Output d_o reflects the current stored value.
*   - Internally implemented using N D flip-flops and a write-enable multiplexer.
*
* Dependencies: 
*   dff.v, mux.v
*
* Change history:
*   09/30/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module register #(parameter N = 8) (
    input  wire          clk,     // Core clock
    input  wire          rst,     // Asynchronous active-high reset
    input  wire          wr_en_i, // Write enable input
    input  wire [N-1:0]  d_i,  // Data input
    output wire [N-1:0]  d_o   // Data output
);

    wire [N-1:0] d_w;
    genvar i;

    generate 
        for (i = 0; i < N; i = i + 1) begin
            mux m (
                .s_i (wr_en_i),     // write enable
                .a_i (d_o[i]),   // old value
                .b_i (d_i[i]),   // new value
                .c_o (d_w[i])       // input to D flip-flop
            );

            dff d (
                .clk (clk),
                .rst (rst),
                .d_i (d_w[i]),
                .q_o (d_o[i])
            );
        end
    endgenerate

endmodule
