`timescale 1ns / 1ps
`include "defines.v"
/*******************************************************************
*
* Module: alu_control.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description:
*   Generates 4-bit ALU control signals based on the ALUOp code from the main control unit
*   and the instruction's funct3/funct7 fields. Supports:
*     - R-type operations (ADD, SUB, AND, OR)
*     - Load/store (ADD)
*     - Branch equal (SUB)
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module alu_control (
    input  wire [1:0] alu_op_i,     // ALUOp from main control unit
    input  wire [2:0] funct3_i,     // Instruction bits [14:12]
    input  wire       funct7_i,     // Instruction bit [30]
    output reg  [3:0] alu_ctrl_o    // ALU control output
);

    always @(*) begin
        case (alu_op_i)
            2'b00: alu_ctrl_o = `ALU_ADD;  // LW/SW -> ADD
            2'b01: alu_ctrl_o = `ALU_SUB;  // BEQ   -> SUB
            2'b10: begin                  // R-type (use funct fields)
                case (funct3_i)
                    `F3_ADD : alu_ctrl_o = funct7_i ? ALU_SUB : ALU_ADD; // ADD
                    `F3_SLL : alu_ctrl_o = ALU_SLL; //SLL
                    `F3_SLT : alu_ctrl_o = ALU_SLT // SLT
                    `F3_SLTU: alu_ctrl_o = ALU_SLTU //SLTU
                    `F3_XOR : alu_ctrl_o = ALU_XOR //XOR
                    `F3_SRL : alu_ctrl_o = funct7_i ? ALU_SRA : ALU_SRL //SRL
                    `F3_OR  : alu_ctrl_o = ALU_OR; // OR
                    `F3_AND : alu_ctrl_o = ALU_AND; // AND
                    default: alu_ctrl_o = ALU_ADD; // Default: ADD
                endcase
            end
            2'b11: alu_ctrl_o = `ALU_PASS; // LUI
            default: alu_ctrl_o = 4'b0000; // NOP/invalid case
        endcase
    end

endmodule