`timescale 1ns / 1ps

/*******************************************************************
*
* Module: imm_gen.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
* Description: 
*   Instruction immediate generator. Extracts the immediate field from a 32-bit
*   instruction (I-type, S-type, B-type) and sign-extends it to 32 bits.
*
* Change history:
*   09/30/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module imm_gen (
    input  wire [31:0] inst_i,   // 32-bit instruction
    output reg  [31:0] gen_o     // 32-bit sign-extended immediate
);

    wire [6:0] opcode_w;
    reg  [11:0] imm_r;

    assign opcode_w = inst_i[6:0];

    always @(*) begin
        case (opcode_w)
            7'b0000011: imm_r = inst_i[31:20];                                  // I-type
            7'b0100011: imm_r = {inst_i[31:25], inst_i[11:7]};                  // S-type
            7'b1100011: imm_r = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]}; // B-type
            default:    imm_r = 12'b0;
        endcase

        // Sign-extend to 32 bits
        gen_o = {{20{imm_r[11]}}, imm_r};
    end

endmodule