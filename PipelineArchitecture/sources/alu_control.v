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
*   Generates a 5-bit ALU control signal based on the 2-bit ALUOp input 
*   from the main control unit and the instruction's funct3 and funct7 fields. 
*   Maps instruction types to specific ALU operations, supporting:
*     - R-type instructions: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
*     - M-type instructions: MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
*     - U-type instructions: LUI, AUIPC
*     - B-type instructions: BEQ, BNE (via SUB)
*
* Change history:
*   10/07/2025 - Initial lab version created
*   11/02/2025 - Adapted and cleaned for project use (Yahia)
*   11/08/2025 - Added support for the rest of the R-Format
*                and the U-format (Ouail)
*   11/24/2025 - Added support for M extension (MUL/DIV operations) (Ouail)
*
*******************************************************************/
module alu_control (
    input  wire [1:0] alu_op_i,     // ALUOp from main control unit
    input  wire [2:0] funct3_i,     // Instruction bits [14:12]
    input  wire [6:0] funct7_i,     // Instruction bits [31:25] (full funct7 now)
    input  wire       isimm_i,
    output reg  [4:0] alu_ctrl_o    // ALU control output (expanded to 5 bits)
);
    always @(*) begin
        case (alu_op_i)
            2'b00: alu_ctrl_o = `ALU_ADD;  // LW/SW/AUIPC -> ADD
            2'b01: alu_ctrl_o = `ALU_SUB;  // Branch   -> SUB
            2'b10: begin                   // R-type (use funct fields)
                // Check if this is M extension (funct7 = 0000001)
                if (funct7_i == `F7_MULDIV) begin
                    case (funct3_i)
                        `F3_MUL   : alu_ctrl_o = `ALU_MUL;
                        `F3_MULH  : alu_ctrl_o = `ALU_MULH;
                        `F3_MULHSU: alu_ctrl_o = `ALU_MULHSU;
                        `F3_MULHU : alu_ctrl_o = `ALU_MULHU;
                        `F3_DIV   : alu_ctrl_o = `ALU_DIV;
                        `F3_DIVU  : alu_ctrl_o = `ALU_DIVU;
                        `F3_REM   : alu_ctrl_o = `ALU_REM;
                        `F3_REMU  : alu_ctrl_o = `ALU_REMU;
                        default   : alu_ctrl_o = `ALU_ADD; // Should not happen
                    endcase
                end else begin
                    // Standard R-type and I-type instructions
                    case (funct3_i)
                        `F3_ADD : alu_ctrl_o = isimm_i? `ALU_ADD                      // I-type (ADDI) → always ADD
                            : (funct7_i[5] ? `ALU_SUB       // R-type SUB (funct7[5] = bit 30)
                            : `ALU_ADD);     // R-type ADD (funct7[5] = 0)
                        `F3_SLL : alu_ctrl_o = `ALU_SLL;    // SLL
                        `F3_SLT : alu_ctrl_o = `ALU_SLT;    // SLT
                        `F3_SLTU: alu_ctrl_o = `ALU_SLTU;   // SLTU
                        `F3_XOR : alu_ctrl_o = `ALU_XOR;    // XOR
                        `F3_SRL : alu_ctrl_o = funct7_i[5] ? `ALU_SRA : `ALU_SRL; // SRL or SRA
                        `F3_OR  : alu_ctrl_o = `ALU_OR;     // OR
                        `F3_AND : alu_ctrl_o = `ALU_AND;    // AND
                        default:  alu_ctrl_o = `ALU_ADD;    // Default/invalid funct3: ADD
                    endcase
                end
            end
            2'b11: alu_ctrl_o = `ALU_PASS; // LUI
            default: alu_ctrl_o = 5'b00000; // Default/invalid OP: ADD
        endcase
    end
endmodule