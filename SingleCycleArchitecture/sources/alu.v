`include "defines.v"

/*******************************************************************
*
* Module: alu.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description:
*   N-bit ALU supporting ADD, SUB, AND, OR , shift and logical
*    operations
*
* Dependencies: 
*   nmux.v, rca.v, mux16x1.v
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*   11/05/2025 – Downloaded from Canvas and integrated into project (Yahia)
*******************************************************************/

module alu(
	input   wire [31:0] a_i,
    input   wire [31:0] b_i,
	input   wire [4:0]  shamt_i,
	input   wire [3:0]  alu_ctrl_i,
	output  reg  [31:0] c_o,
	output  wire        cf_o,
    output  wire        zf_o,
    output  wire        vf_o,
    output  wire        sf_o
);

    wire [31:0] add_w;
    wire [31:0] op_b;

    // Conditional inversion for subtraction
    assign op_b = (~b_i);
    assign {cf_o, add_w} = alu_ctrl_i[0] ? (a_i + op_b + 1'b1) : (a_i + b_i);
    
    // Flags
    assign zf_o = (add_w == 0);
    assign sf_o = add_w[31];
    assign vf_o = (a_i[31] ^ (op_b[31]) ^ add_w[31] ^ cf_o);
    
    // Shifter
    wire[31:0] sh_w;
    shifter shifter0(.a_i(a_i), .shamt_i(shamt_i), .type_i(alu_ctrl_i[1:0]),  .c_o(sh_w));

    // ALU operation select
    always @(*) begin
        c_o = 32'b0;
        case (alu_ctrl_i)
            // arithmetic
            `ALU_ADD : c_o = add_w;                        // ADD
            `ALU_SUB : c_o = add_w;                        // SUB
            `ALU_PASS: c_o = b_i;                          // Pass B
            // logic
            `ALU_OR  : c_o = a_i | b_i;                    // OR
            `ALU_AND : c_o = a_i & b_i;                    // AND
            `ALU_XOR : c_o = a_i ^ b_i;                    // XOR
            // shift
            `ALU_SRL : c_o = sh_w;                         // SLL
            `ALU_SRA : c_o = sh_w;                         // SRL
            `ALU_SLL : c_o = sh_w;                         // SRA
            // set less than
            `ALU_SLT : c_o = {31'b0, (sf_o != vf_o)};      // SLT
            `ALU_SLTU: c_o = {31'b0, (~cf_o)};             // SLTU
            default: c_o = 32'b0;
        endcase
    end

endmodule


 
