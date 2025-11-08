`include "defines.v"
/*******************************************************************
*
* Module: imm_gen.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
 Description:
*   Immediate Generator module for RISC-V instructions.
*   Based on the instruction opcode and format (I, S, B, U, or J),
*   this module extracts and sign-extends the corresponding immediate
*   value to 32 bits.
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*   11/05/2025 – Downloaded from Canvas template and integrated into project (Yahia)
*
*******************************************************************/

module imm_gen (
    input  wire [31:0]  inst_i,
    output reg  [31:0]  gen_o
);

always @(*) begin
	case (`OPCODE)
		`OPCODE_Arith_I   : 	gen_o = { {21{inst_i[31]}}, inst_i[30:25], inst_i[24:21], inst_i[20] }; // I type
		`OPCODE_Store     :     gen_o = { {21{inst_i[31]}}, inst_i[30:25], inst_i[11:8], inst_i[7] };   // S type
		`OPCODE_LUI       :     gen_o = { inst_i[31], inst_i[30:20], inst_i[19:12], 12'b0 };            // U type (LUI)
		`OPCODE_AUIPC     :     gen_o = { inst_i[31], inst_i[30:20], inst_i[19:12], 12'b0 };            // U type (AUIPC)
		`OPCODE_JAL       : 	gen_o = { {12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:25], inst_i[24:21], 1'b0 }; // J type (JAL)
		`OPCODE_JALR      : 	gen_o = { {21{inst_i[31]}}, inst_i[30:25], inst_i[24:21], inst_i[20] };   // I type (JALR)
		`OPCODE_Branch    : 	gen_o = { {20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};// B type
		default           : 	gen_o = { {21{inst_i[31]}}, inst_i[30:25], inst_i[24:21], inst_i[20] };   // I format (default)
	endcase 
end

endmodule