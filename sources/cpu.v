`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 01:39:16 PM
// Design Name: 
// Module Name: DFlipFlop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module cpu (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  led_sel_i,
    input  wire [3:0]  ssd_sel_i,
    output reg  [15:0] inst_led_o,
    output reg  [12:0] ssd_o
);

    // Internal Signals
    wire [31:0] pc_in_w;
    wire [31:0] pc_out_w;
    wire [31:0] inst_w;
    wire [31:0] write_data_w;
    wire [31:0] reg_read1_w;
    wire [31:0] reg_read2_w;
    wire [31:0] imm_w;
    wire [31:0] alu_in_b_w;
    wire [31:0] alu_in_a_w;
    wire [31:0] alu_out_w;
    wire [31:0] pc_branch_w;
    wire [31:0] data_read_w;
    wire [31:0] offset_w;
    wire        branch_w;
    wire        mem_read_w;
    wire        mem_to_reg_w;
    wire [1:0]  alu_op_w;
    wire        mem_write_w;
    wire        a_sel_w;
    wire        b_sel_w;
    wire        reg_write_w;
    wire        zero_w;
    wire        pc_mux_sel_w;
    wire [3:0]  alu_ctrl_w;
    wire        take_branch_w
    wire         cf_w;
    wire         zf_w;
    wire         vf_w;
    wire         sf_w;


    // Program Counter
    register #(.N(32)) pc (
        .clk (clk),
        .rst (rst),
        .wr_en_i(1'b1),
        .d_i   (pc_in_w),
        .d_o   (pc_out_w)
    );

    // Instruction Memory
    inst_mem inst_mem_inst (
        .addr_i (pc_out_w[`IR_opcode]),
        .data_o (inst_w)
    );

    // Control Unit
    control_unit ctrl_unit (
        .opcode_i   (inst_w[`IR_opcode]),
        .branch_o   (branch_w),
        .mem_rd_o (mem_read_w),
        .mem_to_reg_o(mem_to_reg_w),
        .alu_op_o   (alu_op_w),
        .mem_wr_o(mem_write_w),
        .alu_src_o  (b_sel_w),
        .reg_wr_o(reg_write_w)
    );

    // Register File
    reg_file #(.N(32)) reg_file_inst (
        .clk      (clk),
        .rst      (rst),
        .rd_addr1_i(inst_w[`IR_rs1]),
        .rd_addr2_i(inst_w[`IR_rs2]),
        .wr_addr_i(inst_w[`IR_rd]),
        .wr_en_i (reg_write_w),
        .wr_data_i(write_data_w),
        .rd_data1_o(reg_read1_w),
        .rd_data2_o(reg_read2_w)
    );

    // Immediate Generator
    imm_gen imm_gen_inst (
        .inst_i (inst_w),
        .gen_o  (imm_w)
    );
        // ALU Input a Mux
    nmux #(.N(32)) alu_a_mux (
        .a_i (reg_read1_w),
        .b_i (pc_out_w),
        .s_i (a_sel_w),
        .c_o (alu_in_a_w)
    );
    // ALU Input b Mux
    nmux #(.N(32)) alu_b_mux (
        .a_i (reg_read2_w),
        .b_i (imm_w),
        .s_i (b_sel_w),
        .c_o (alu_in_b_w)
    );

    // ALU Control
    alu_control alu_ctrl_inst (
        .alu_op_i  (alu_op_w),
        .funct3_i  (inst_w[`IR_funct3]),
        .funct7_i  (inst_w[30]),
        .alu_ctrl_o(alu_ctrl_w)
    );

    // ALU
    alu alu_inst (
        .a_i        (alu_in_a_w),
        .b_i        (alu_in_b_w),
        .shamt_i    (inst_w[`IR_shamt]),   // shift amount from instruction
        .alu_ctrl_i (alu_ctrl_w),
        .c_o        (alu_out_w),
        .cf_o       (cf_w),
        .zf_o       (zf_w),
        .vf_o       (vf_w),
        .sf_o       (sf_w)
    );

    // Shift Left 1 (for branch offset)
    shift_l1 #(32) shift_imm (
        .a_i (imm_w),
        .b_o (offset_w)
    );

    // Branch Address Adder
    rca #(.N(32)) offset_adder (
        .a_i   (pc_out_w),
        .b_i   (offset_w),
        .c_i (1'b0),
        .c_o(),
        .s_o (pc_branch_w)
    );

    assign pc_mux_sel_w = branch_w & take_branch_w;

    branch_control branch_control_inst( 
        .funct3_i(inst_i[IR_funct3]),
        .zf_i(zf_w),
        .cf_i(cf_w),
        .vf_i(vf_w), 
        .sf_i(sf_w), 
        .take_branch_o(take_branch_w) 
    );

    // Next PC Mux (Branch or PC+4)
    nmux #(.N(32)) pc_mux (
        .a_i (pc_out_w + 32'd4),
        .b_i (pc_branch_w),
        .s_i (pc_mux_sel_w),
        .c_o (pc_in_w)
    );

    // Data Memory
    data_mem data_mem_inst (
        .clk     (clk),
        .rd_en_i   (mem_read_w),
        .wr_en_i   (mem_write_w),
        .addr_i    (alu_out_w[7:2]),
        .d_i       (reg_read2_w),
        .d_o       (data_read_w)
    );

    // Write Back Mux (ALU or Memory)
    nmux #(.N(32)) mem_to_reg_mux (
        .a_i (alu_out_w),
        .b_i (data_read_w),
        .s_i (mem_to_reg_w),
        .c_o (write_data_w)
    );

    // LED and 7-Segment Display
    always @(*) begin
        case (led_sel_i)
            2'b00: inst_led_o = inst_w[15:0];
            2'b01: inst_led_o = inst_w[31:16];
            2'b10: inst_led_o = {cf_w, vf_w, sf_w, zf_w, branch_w, mem_read_w, mem_to_reg_w,
                                 mem_write_w, reg_write_w, pc_mux_sel_w, alu_op_w, alu_ctrl_w};
            2'b11: inst_led_o = {12'b0, a_sel_o, b_sel_o}
            default: inst_led_o = 16'd0;
        endcase

        case (ssd_sel_i)
            4'b0000: ssd_o = pc_out_w[12:0];
            4'b0001: ssd_o = pc_out_w[12:0] + 13'd4;
            4'b0010: ssd_o = pc_branch_w[12:0];
            4'b0011: ssd_o = pc_in_w[12:0];
            4'b0100: ssd_o = reg_read1_w[12:0];
            4'b0101: ssd_o = reg_read2_w[12:0];
            4'b0110: ssd_o = write_data_w[12:0];
            4'b0111: ssd_o = imm_w[12:0];
            4'b1000: ssd_o = offset_w[12:0];
            4'b1001: ssd_o = alu_in_b_w[12:0];
            4'b1010: ssd_o = alu_out_w[12:0];
            4'b1011: ssd_o = data_read_w[12:0];
            default: ssd_o = 13'd0;
        endcase
    end

endmodule