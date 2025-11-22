`include "defines.v"
`define COMP_REGS(i) (COMP_REGS[(i)*5 +: 5])
/*******************************************************************
*
* Module: decomp_unit_tb
* Project: RISC-V_CPU
* Author: Yahia Kilany
*
* Description:
*   takes in a 16-bit rv32c instruction , converts it to the
*   appropriate 32-bit rv32i instruction.
*
*
* Change history:
*   11-22-2025 completed
*
*******************************************************************/

module decomp_unit(
    input  wire  [15:0] comp_inst_i,
    output reg   [31:0] decomp_inst_o 
);
localparam [8*5-1:0] COMP_REGS = {
    5'd15,
    5'd14,
    5'd13,
    5'd12,
    5'd11,
    5'd10,
    5'd9,
    5'd8
};

    always @(*) begin
        decomp_inst_o = 32'd3;
        case (comp_inst_i[1:0])
            //======================================
            // Quadrant 0 (bits [1:0] = 00)
            //======================================
            2'b00: case(comp_inst_i[`C_funct3])
                    3'b000: begin
                        // C.ADDI4SPN: c.addi4spn rd',uimm -> addi rd', x2, 4*imm
                        decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                        decomp_inst_o[`IR_funct3] = `F3_ADD;
                        decomp_inst_o[`IR_rd]     = `COMP_REGS(comp_inst_i[`C_rsdP]);
                        decomp_inst_o[`IR_rs1]    = 5'd2;
                        decomp_inst_o[31:20]      = {2'b0,comp_inst_i[10:7],
                            comp_inst_i[12:11], comp_inst_i[5],comp_inst_i[6],2'b0};
                    end
                    3'b010:begin
                        // C.LW: c.lw rd', uimm(rs1') -> lw rd', 4*imm(rs1')
                        decomp_inst_o[`IR_opcode] = `OPCODE_Load;
                        decomp_inst_o[`IR_funct3] = `F3_LW;
                        decomp_inst_o[`IR_rd]     = `COMP_REGS(comp_inst_i[`C_rsdP]);
                        decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                        decomp_inst_o[31:20]      = {5'b0, comp_inst_i[5], comp_inst_i[12:10], comp_inst_i[6], 2'b0};
                    end
                    3'b110: begin
                        // C.SW: c.sw rs2', uimm(rs1') -> sw rs2', (4*imm)(rs1')
                        decomp_inst_o[`IR_opcode] = `OPCODE_Store;
                        decomp_inst_o[`IR_funct3] = `F3_SW;
                        decomp_inst_o[`IR_rs2]    = `COMP_REGS(comp_inst_i[`C_rs2P]);
                        decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                        decomp_inst_o[11:7]       = {comp_inst_i[11:10], comp_inst_i[6], 2'b0};
                        decomp_inst_o[31:25]      = {5'b0, comp_inst_i[5],comp_inst_i[12]};
                    end
                    default: decomp_inst_o = 32'd3;
                            
                endcase

            //======================================
            // Quadrant 1 (bits [1:0] = 01)
            //======================================
            2'b01: case(comp_inst_i[`C_funct3])
                    3'b000:begin
                        // C.ADDI / C.NOP: c.addi rd, imm -> addi rd, rd, imm
                        decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                        decomp_inst_o[`IR_funct3] = `F3_ADD;
                        decomp_inst_o[`IR_rd]     = comp_inst_i[`C_rsd];
                        decomp_inst_o[`IR_rs1]    = comp_inst_i[`C_rsd];
                        decomp_inst_o[31:20]      = {{6{comp_inst_i[12]}}, comp_inst_i[12], comp_inst_i[6:2]};
                    end

                    3'b001:begin 
                        // C.JAL: c.jal offset -> jal x1, offset
                        decomp_inst_o[`IR_opcode] = `OPCODE_JAL;
                        decomp_inst_o[`IR_rd]     = 5'd1;
                        {decomp_inst_o[31], decomp_inst_o[19:12], decomp_inst_o[20], decomp_inst_o[30:25], decomp_inst_o[24:21]} = { {10{comp_inst_i[12]}},
                            comp_inst_i[8], comp_inst_i[10:9], comp_inst_i[6], comp_inst_i[7], comp_inst_i[2], comp_inst_i[11], comp_inst_i[5:3]};
                    end

                    3'b010:begin
                        // C.LI: c.li rd, imm -> addi rd, x0, imm
                        decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                        decomp_inst_o[`IR_funct3] = `F3_ADD;
                        decomp_inst_o[`IR_rd]     = comp_inst_i[`C_rsd];
                        decomp_inst_o[`IR_rs1]    = 5'd0;
                        decomp_inst_o[31:20]      = {{6{comp_inst_i[12]}}, comp_inst_i[12], comp_inst_i[6:2]};
                    end

                    3'b011:begin 
                        if(comp_inst_i[`C_rsd]==5'd2) begin
                            // C.ADDI16SP: c.addi16sp imm -> addi x2, x2, imm*16
                            decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                            decomp_inst_o[`IR_funct3] = `F3_ADD;
                            decomp_inst_o[`IR_rd]     = 5'd2;
                            decomp_inst_o[`IR_rs1]    = 5'd2;
                            decomp_inst_o[31:20] = {{3{comp_inst_i[12]}},comp_inst_i[4:3], comp_inst_i[5], comp_inst_i[2], comp_inst_i[6], 4'b0};
                        end
                        else begin
                            // C.LUI: c.lui rd, imm -> lui rd, imm
                            decomp_inst_o[`IR_opcode] = `OPCODE_LUI;
                            decomp_inst_o[`IR_rd]     = comp_inst_i[`C_rsd];
                            decomp_inst_o[31:12] = {{15{comp_inst_i[12]}}, comp_inst_i[6:2]};
                        end
                    end

                    3'b100:begin 
                        case(comp_inst_i[11:10])
                            2'b00: begin
                                // C.SRLI: c.srli rd', shamt -> srli rd', rd', shamt
                                decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                                decomp_inst_o[`IR_funct3] = `F3_SRL;
                                decomp_inst_o[`IR_rd]     = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[31:20]      = {{6'b0}, comp_inst_i[12], comp_inst_i[6:2]};
                            end
                            2'b01: begin
                                // C.SRAI: c.srai rd', shamt -> srai rd', rd', shamt
                                decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                                decomp_inst_o[`IR_funct3] = `F3_SRL;
                                decomp_inst_o[`IR_rd]     = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[31:20]      = {{6'b0}, comp_inst_i[12], comp_inst_i[6:2]};
                                decomp_inst_o[30]         = 1'b1;
                            end
                            2'b10: begin
                                // C.ANDI: c.andi rd', imm -> andi rd', rd', imm
                                decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                                decomp_inst_o[`IR_funct3] = `F3_AND;
                                decomp_inst_o[`IR_rd]     = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[31:20]      = {{6{comp_inst_i[12]}}, comp_inst_i[12], comp_inst_i[6:2]};
                            end
                            2'b11: begin
                                // C.SUB / C.XOR / C.OR / C.AND (R-type arithmetic)
                                decomp_inst_o[`IR_opcode] = `OPCODE_Arith_R;
                                decomp_inst_o[`IR_rd]     = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                                decomp_inst_o[`IR_rs2]    = `COMP_REGS(comp_inst_i[`C_rs2P]);
                                case(comp_inst_i[6:5])
                                    00: begin
                                        // C.SUB: c.sub rd', rs2' -> sub rd', rd', rs2'
                                        decomp_inst_o[`IR_funct3] = `F3_ADD;
                                        decomp_inst_o[30]         =  1'b1;
                                    end

                                    2'b01: begin
                                        // C.XOR: c.xor rd', rs2' -> xor rd', rd', rs2'
                                        decomp_inst_o[`IR_funct3] = `F3_XOR;
                                    end

                                    2'b10: begin
                                        // C.OR: c.or rd', rs2' -> or rd', rd', rs2'
                                        decomp_inst_o[`IR_funct3] = `F3_OR;
                                    end

                                    2'b11:begin
                                        // C.AND: c.and rd', rs2' -> and rd', rd', rs2'
                                        decomp_inst_o[`IR_funct3] = `F3_AND;
                                    end

                                endcase
                            end
                        endcase

                    end

                    3'b101:begin
                        // C.J: c.j offset -> jal x0, offset
                        decomp_inst_o[`IR_opcode] = `OPCODE_JAL;
                        decomp_inst_o[`IR_rd]    = 5'd0;
                        {decomp_inst_o[31], decomp_inst_o[19:12], decomp_inst_o[20], decomp_inst_o[30:25], decomp_inst_o[24:21]} = { {10{comp_inst_i[12]}},
                            comp_inst_i[8], comp_inst_i[10:9], comp_inst_i[6], comp_inst_i[7], comp_inst_i[2], comp_inst_i[11], comp_inst_i[5:3]};
                    end

                    3'b110:begin
                        // C.BEQZ: c.beqz rs1', offset -> beq rs1', x0, offset
                        decomp_inst_o[`IR_opcode] = `OPCODE_Branch;
                        decomp_inst_o[`IR_funct3] = `BR_BEQ;
                        decomp_inst_o[`IR_rs2]    = 5'd0;
                        decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                        {{decomp_inst_o[31]}, decomp_inst_o[7], decomp_inst_o[30:25], decomp_inst_o[11:8]} = {{4{comp_inst_i[12]}}
                            ,comp_inst_i[12], comp_inst_i[6:5], comp_inst_i[2], comp_inst_i[11:10], comp_inst_i[4:3]};
                    end

                    3'b111:begin
                        // C.BNEZ: c.bnez rs1', offset -> bne rs1', x0, offset
                        decomp_inst_o[`IR_opcode] = `OPCODE_Branch;
                        decomp_inst_o[`IR_funct3] = `BR_BNE;
                        decomp_inst_o[`IR_rs2]    = 5'd0;
                        decomp_inst_o[`IR_rs1]    = `COMP_REGS(comp_inst_i[`C_rs1P]);
                        {{decomp_inst_o[31]}, decomp_inst_o[7], decomp_inst_o[30:25], decomp_inst_o[11:8]} = {{4{comp_inst_i[12]}}
                            ,comp_inst_i[12], comp_inst_i[6:5], comp_inst_i[2], comp_inst_i[11:10], comp_inst_i[4:3]};
                    end
            endcase

            //======================================
            // Quadrant 2 (bits [1:0] = 10)
            //======================================
            2'b10: case(comp_inst_i[`C_funct3])
                3'b000:begin
                    // C.SLLI: c.slli rd, shamt -> slli rd, rd, shamt
                    decomp_inst_o[`IR_opcode] = `OPCODE_Arith_I;
                    decomp_inst_o[`IR_funct3] = `F3_SLL;
                    decomp_inst_o[`IR_rd]     = comp_inst_i[`C_rsd];
                    decomp_inst_o[`IR_rs1]    = comp_inst_i[`C_rsd];
                    decomp_inst_o[31:20]      = {{6'b0}, comp_inst_i[12], comp_inst_i[6:2]};
                end
                3'b010:begin
                    // C.LWSP: c.lwsp rd, uimm(x2) -> lw rd, uimm(x2)
                    decomp_inst_o[`IR_opcode] = `OPCODE_Load;
                    decomp_inst_o[`IR_funct3] = `F3_LW;
                    decomp_inst_o[`IR_rd]     = comp_inst_i[`C_rsd];
                    decomp_inst_o[`IR_rs1]    = 5'd2;
                    decomp_inst_o[31:20]      = {4'b0, comp_inst_i[3:2], comp_inst_i[12], comp_inst_i[6:4], 2'b0};
                end
                3'b100: begin
                    if (comp_inst_i[`C_rs1] == 5'd0 && comp_inst_i[`C_rs2]== 5'd0) begin
                        // C.EBREAK: c.ebreak -> ebreak
                        decomp_inst_o[`IR_opcode] = `OPCODE_SYSTEM;
                    end

                    else if (comp_inst_i[`C_rs2] == 5'd0) begin
                        // C.JR / C.JALR: c.jr rs1 -> jalr x0, 0(rs1) / c.jalr rs1 -> jalr x1, 0(rs1)
                        decomp_inst_o[`IR_opcode] = `OPCODE_JALR;
                        decomp_inst_o[`IR_funct3] = 3'd0;
                        decomp_inst_o[`IR_rs1]    = comp_inst_i[`C_rsd];
                        decomp_inst_o[31:20]      = 12'b0;              
                        if (comp_inst_i[12] == 1'b0) begin
                            decomp_inst_o[`IR_rd]     = 5'd0;
                        end 
                        else begin
                            decomp_inst_o[`IR_rd]     = 5'd1;
                        end
                    end

                    else begin
                        // C.MV / C.ADD: c.mv rd, rs2 -> add rd, x0, rs2 / c.add rd, rs2 -> add rd, rd, rs2
                        decomp_inst_o[`IR_opcode] = `OPCODE_Arith_R;
                        decomp_inst_o[`IR_funct3] = `F3_ADD;
                        decomp_inst_o[`IR_rd]     = comp_inst_i[`C_rs1];
                        decomp_inst_o[`IR_rs1]    = 5'd0;
                        decomp_inst_o[`IR_rs2]    = comp_inst_i[`C_rs2];
                        if (comp_inst_i[12] == 1'b0) begin
                            decomp_inst_o[`IR_rs1]    = 5'd0;
                        end else begin
                            decomp_inst_o[`IR_rs1]    = comp_inst_i[`C_rs1P];
                        end
                    end
                end
                3'b110:begin
                    // C.SWSP: c.swsp rs2, uimm(x2) -> sw rs2, uimm(x2)
                    decomp_inst_o[`IR_opcode] = `OPCODE_Store;
                    decomp_inst_o[`IR_funct3] = `F3_SW;
                    decomp_inst_o[`IR_rs2]    = comp_inst_i[`C_rs2];
                    decomp_inst_o[`IR_rs1]    = 5'd2;
                    decomp_inst_o[11:7]       = {comp_inst_i[11:9], 2'b0};
                    decomp_inst_o[31:25]      = {4'b0, comp_inst_i[8:7],comp_inst_i[12]};
                end
                
            endcase
        endcase
    end
endmodule