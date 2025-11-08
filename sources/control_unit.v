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
*
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
    output reg        reg_wr_o       // Register write enable
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
        case (opcode_i)
            `OPCODE_Arith_R: begin // R-type
                alu_op_o     = 2'b10;
                reg_wr_o     = 1'b1;
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

            default: begin // re-imposing the default values
                branch_o      = 1'b0;
                mem_rd_o      = 1'b0;
                mem_to_reg_o  = 1'b0;
                alu_op_o      = 2'b00;
                mem_wr_o      = 1'b0;
                a_sel_o       = 1'b0;
                b_sel_o       = 1'b0;
                reg_wr_o      = 1'b0;

            end
        endcase
    end

endmodule
