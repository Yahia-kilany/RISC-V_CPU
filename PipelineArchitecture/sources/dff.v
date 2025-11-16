`timescale 1ns / 1ps

/*******************************************************************
*
* Module: dff.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama
*
* Description: 
*   D-type flip-flop with asynchronous active-high reset,
*   triggered on the rising edge of the clock.
*
* Change history:
*   09/30/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/
module dff (
    input  wire clk,   // Core clock
    input  wire rst,   // Asynchronous active-high reset
    input  wire d_i,   // Data input
    output reg  q_o    // Data output
);

    // Sequential logic block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q_o <= 1'b0;
        end else begin
            q_o <= d_i;
        end
    end

endmodule
