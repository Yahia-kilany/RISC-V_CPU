`timescale 1ns / 1ps
/*******************************************************************
*
* Module: alu.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description:
*   N-bit ALU supporting ADD, SUB, AND, OR operations.
*   Uses a ripple carry adder for arithmetic and logic operations.
*   sel_i selects the operation; zero_o is set if the result is zero.
*
* Dependencies: 
*   nmux.v, rca.v, mux16x1.v
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module alu #(parameter N = 8) (
    input  wire [3:0]   sel_i,     // ALU control input
    input  wire [N-1:0] a_i,       // Operand A
    input  wire [N-1:0] b_i,       // Operand B
    output wire          zero_o,   // Zero flag
    output wire [N-1:0]  c_o       // ALU output
);

    // Internal signals
    wire [N-1:0] sum_w;
    wire [N-1:0] and_w;
    wire [N-1:0] or_w;
    wire [N-1:0] b_mux_w;
    wire          cout_w;

    // Logical operations
    assign and_w = a_i & b_i;
    assign or_w  = a_i | b_i;

    // Select between B and ~B for ADD/SUB
    nmux #(.N(N)) b_mux_inst (
        .s_i (sel_i[2]),
        .a_i (b_i),
        .b_i (~b_i),
        .c_o (b_mux_w)
    );

    // Ripple Carry Adder (for ADD/SUB)
    rca #(.N(N)) rca_inst (
        .a_i    (a_i),
        .b_i    (b_mux_w),
        .c_i  (sel_i[2]),   // sel[2]=1 -> subtraction
        .c_o (cout_w),
        .s_o  (sum_w)
    );

    // ALU operation multiplexer
    mux16x1 #(.N(N)) alu_mux (
        .s_i   (sel_i),
        .sum_i (sum_w),
        .sub_i (sum_w),   // same as sum_w (ADD/SUB handled internally)
        .and_i (and_w),
        .or_i  (or_w),
        .c_o   (c_o)
    );

    // Zero flag
    assign zero_o = (c_o == {N{1'b0}});

endmodule