`timescale 1ns / 1ps

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
*   Supports R-type, LW, SW, and BEQ instructions.
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module control_unit (
    input  wire [4:0] opcode_i,      // Instruction[6:2]
    output reg        branch_o,      // Branch control
    output reg        mem_rd_o,      // Memory read enable
    output reg        mem_to_reg_o,  // Write-back source select
    output reg [1:0]  alu_op_o,      // ALU operation control
    output reg        mem_wr_o,      // Memory write enable
    output reg        alu_src_o,     // ALU input select
    output reg        reg_wr_o       // Register write enable
);

    always @(*) begin
        // Default values (NOP)
        branch_o      = 1'b0;
        mem_rd_o      = 1'b0;
        mem_to_reg_o  = 1'b0;
        alu_op_o      = 2'b00;
        mem_wr_o      = 1'b0;
        alu_src_o     = 1'b0;
        reg_wr_o      = 1'b0;

        case (opcode_i)
            5'b01100: begin // R-type
                alu_op_o     = 2'b10;
                reg_wr_o     = 1'b1;
            end

            5'b00000: begin // LW
                mem_rd_o     = 1'b1;
                mem_to_reg_o = 1'b1;
                alu_src_o    = 1'b1;
                reg_wr_o     = 1'b1;
            end

            5'b01000: begin // SW
                mem_wr_o     = 1'b1;
                alu_src_o    = 1'b1;
                mem_to_reg_o = 1'b0; // Don't care
            end

            5'b11000: begin // BEQ
                branch_o     = 1'b1;
                alu_op_o     = 2'b01;
                mem_to_reg_o = 1'b0; // Don't care
            end

            default: begin // re=imposing the default values
                branch_o      = 1'b0;
                mem_rd_o      = 1'b0;
                mem_to_reg_o  = 1'b0;
                alu_op_o      = 2'b00;
                mem_wr_o      = 1'b0;
                alu_src_o     = 1'b0;
                reg_wr_o      = 1'b0;
            end
        endcase
    end

endmodule
