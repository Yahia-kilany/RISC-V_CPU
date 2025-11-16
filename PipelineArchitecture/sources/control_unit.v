`timescale 1ns / 1ps
`include "defines.v"
/*******************************************************************
*
* Module: control_unit.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description:
*   Generates control signals for the CPU based on the 5-bit opcode.
*   Signals include ALU operation, branch, memory access, and register write.
*   Supports R-type, LW, SW, B-type  and U-type instructions.
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*   11/08/2025 - Added support for B-type and U-type (Yahia)
*   11/09/2025 - Added support for I-type, JAL, and sys calls (Ouail)
*******************************************************************/

module control_unit (
    input  wire [4:0] opcode_i,      // Instruction[6:2]
    output reg        branch_o,      // Branch control
    output reg        mem_rd_o,      // Memory read enable
    output reg        mem_to_reg_o,  // Write-back source select
    output reg [1:0]  alu_op_o,      // ALU operation control
    output reg        mem_wr_o,      // Memory write enable
    output reg        a_sel_o,       // ALU input a select
    output reg        b_sel_o,       // ALU input b select
    output reg        reg_wr_o,       // Register write enable
    output reg        jump_o,        // Jump control (for JAL/JALR)
    output reg        pc_to_reg_o,    // Write PC+4 to register
    output reg        pc_wr_en_o
);

    always @(*) begin
        // Default values (NOP)
        branch_o      = 1'b0;
        mem_rd_o      = 1'b0;
        mem_to_reg_o  = 1'b0;
        alu_op_o      = 2'b00;
        mem_wr_o      = 1'b0;
        b_sel_o       = 1'b0;
        reg_wr_o      = 1'b0;
        a_sel_o       = 1'b0;
        pc_wr_en_o    = 1'b1;
        jump_o = 1'b0;
        pc_to_reg_o = 1'b0;
        case (opcode_i)
            `OPCODE_Arith_R: begin // R-type
                alu_op_o     = 2'b10;
                reg_wr_o     = 1'b1;
            end
            
            `OPCODE_Arith_I: begin // I-type arithmetic (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
                alu_op_o     = 2'b10;  // Let ALU control decode funct3/funct7
                b_sel_o      = 1'b1;   // Select immediate
                reg_wr_o     = 1'b1;
                a_sel_o      = 1'b0;   // rs1
            end
            
            `OPCODE_Load: begin // LW
                mem_rd_o     = 1'b1;
                mem_to_reg_o = 1'b1;
                b_sel_o    = 1'b1;
                reg_wr_o     = 1'b1;
            end

            `OPCODE_Store: begin // SW
                mem_wr_o     = 1'b1;
                b_sel_o    = 1'b1;
                mem_to_reg_o = 1'b0; // Don't care
            end

            `OPCODE_Branch: begin // BEQ
                branch_o     = 1'b1;
                alu_op_o     = 2'b01;
                mem_to_reg_o = 1'b0; // Don't care
            end
            
            `OPCODE_LUI: begin // LUI 
                reg_wr_o = 1'b1;
                alu_op_o = 2'b11; 
                b_sel_o = 1'b1; 
            end 
            
            `OPCODE_AUIPC:begin //AUIPC 
                reg_wr_o = 1'b1; 
                alu_op_o = 2'b00; 
                b_sel_o = 1'b1; 
                a_sel_o = 1'b1; 
            end
            
            `OPCODE_SYSTEM: begin // SYSTEM instructions (ECALL, EBREAK)
                pc_wr_en_o = 1'b0;
                branch_o      = 1'b0;
                mem_rd_o      = 1'b0;
                mem_to_reg_o  = 1'b0;
                alu_op_o      = 2'b00;
                mem_wr_o      = 1'b0;
                a_sel_o       = 1'b0;
                b_sel_o       = 1'b0;
                reg_wr_o      = 1'b0;
//                pc_wr_en_o = 1'b0;
                
            end
            
            `OPCODE_JAL: begin // JAL (Jump and Link)
                jump_o       = 1'b1;
                reg_wr_o     = 1'b1;
                pc_to_reg_o  = 1'b1;   
                b_sel_o      = 1'b1;   // Immediate
                alu_op_o     = 2'b00;  // ADD for target address (PC + imm)
                a_sel_o      = 1'b1;   // PC
            end
            
            
            default: begin // re-imposing the default values
                branch_o      = 1'b0;
                mem_rd_o      = 1'b0;
                mem_to_reg_o  = 1'b0;
                alu_op_o      = 2'b00;
                mem_wr_o      = 1'b0;
                a_sel_o       = 1'b0;
                b_sel_o       = 1'b0;
                reg_wr_o      = 1'b0;
                pc_wr_en_o = 1'b1;
                jump_o = 1'b0;
                pc_to_reg_o = 1'b0;
            end
        endcase
    end

endmodule
