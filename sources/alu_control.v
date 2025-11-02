`timescale 1ns / 1ps

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
            2'b00: alu_ctrl_o = 4'b0010;  // LW/SW -> ADD
            2'b01: alu_ctrl_o = 4'b0110;  // BEQ   -> SUB
            2'b10: begin                  // R-type (use funct fields)
                case ({funct7_i, funct3_i})
                    4'b0000: alu_ctrl_o = 4'b0010; // ADD
                    4'b1000: alu_ctrl_o = 4'b0110; // SUB
                    4'b0111: alu_ctrl_o = 4'b0000; // AND
                    4'b0110: alu_ctrl_o = 4'b0001; // OR
                    default: alu_ctrl_o = 4'b0000; // Default: AND
                endcase
            end
            default: alu_ctrl_o = 4'b0000; // NOP/invalid case
        endcase
    end

endmodule