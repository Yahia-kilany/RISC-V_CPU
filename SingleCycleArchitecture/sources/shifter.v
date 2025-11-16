`timescale 1ns / 1ps
`include "defines.v"

/*******************************************************************
*
* Module: branch_control.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
*
* Description:
*   Determines whether a branch instruction should be taken based on
*   the funct3 field and the ALU status flags. Supports all RISC-V
*   conditional branch types (BEQ, BNE, BLT, BGE, BLTU, BGEU).
*   Uses the flags of the ALU to evaluate the condition.
*
* Change history:
*   11/08/2025 – created and finalized for use 
*
*******************************************************************/

module shifter (
    input wire [31:0] a_i,
    input wire [4:0]  shamt_i,
    input wire [3:0]  type_i,
    output reg [31:0]c_o)
;

    always @(*) begin
        case(type_i)
            `ALU_SLL : c_o = a_i << shamt_i;
            `ALU_SRL : c_o = a_i >> shamt_i;
            `ALU_SRA : c_o = $signed(a_i) >>> shamt_i;
            default:  c_o = 32'b0;
        endcase
    end


endmodule