`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 01:39:16 PM
// Design Name: 
// Module Name: CPU
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

    // ---------------------
    // INTERNAL WIRES
    // ---------------------

    //PC wires 
    wire [31:0] pc_in_w;        // next PC value (from mux)
    wire [31:0] pc_out_w;       // current PC value
    wire [31:0] pc_plus_four_w; // PC + 4 (normal sequential flow)



    //register outputs
    wire [31:0] reg_read1_w;    // rs1 read data
    wire [31:0] reg_read2_w;    // rs2 read data

    wire [31:0] imm_w;          // immediate extracted from instruction

    // alu wires
    wire [31:0] alu_in_a_w;     // ALU input A (rs1 or PC)
    wire [31:0] alu_in_b_w;     // ALU input B (rs2 or immediate)
    wire [31:0] alu_out_w;      // ALU computation output

    wire [31:0] pc_branch_w;    // PC + immediate (branch target before selecting)
    wire [31:0] pc_target_w;    // final selected PC target (branch/jump PC)

    wire [31:0] mem_read_data_w;  // data read from memory (load)
    wire [31:0] write_data_w;     // memory output(load) or  alu output 
    wire [31:0] writeback_data_w; // data written back to register file

    wire [3:0]  alu_ctrl_w;     // ALU control signal (operation select)
    wire [2:0]  load_type_w;    // load type (byte, halfword, word, signed/unsigned)
    wire [1:0]  store_type_w;   // store type (byte, halfword, word)
    wire        take_branch_w;  // branch decision

    //Control unit outputs
    wire [1:0]  alu_op_w;       // ALUOp from control unit
    wire        pc_write_en_w;  // PC write enable
    wire        jump_w;         // jump instruction detected
    wire        pc_to_reg_w;    // write PC+4 to rd (e.g. JAL)
    wire        branch_w;       // branch instruction detected
    wire        pc_mux_sel_w;   // select next PC source
    wire        reg_write_w;    // register file write enable
    wire        mem_read_w;     // memory read enable
    wire        mem_write_w;    // memory write enable
    wire        mem_to_reg_w;   // select memory output for writeback
    wire        a_sel_w;        // ALU A-input select (rs1 or PC)
    wire        b_sel_w;        // ALU B-input select (rs2 or immediate)

    //ALU flags
    wire        cf_w;           // carry flag
    wire        zf_w;           // zero flag
    wire        vf_w;           // overflow flag
    wire        sf_w;           // sign flag

    // ---------------------
    // PIPELINE WIRES
    // ---------------------

    // IF/ID register wires
    wire [31:0] if_id_pc_w;      // PC forwarded from IF → ID stage
    wire [31:0] if_id_inst_w;    // instruction forwarded from IF → ID stage

    // ID/EX register wires
    wire [31:0] id_ex_pc_w;      // PC forwarded from ID → EX stage
    wire [31:0] id_ex_reg1_w;    // RS1 register value entering EX
    wire [31:0] id_ex_reg2_w;    // RS2 register value entering EX
    wire [31:0] id_ex_imm_w;     // immediate value entering EX 
    wire [3:0]  id_ex_func_w;    // ALU control / func3+func7 bits
    wire [4:0]  id_ex_rs1_w;     // RS1 index forwarded to EX
    wire [4:0]  id_ex_rs2_w;     // RS2 index forwarded to EX
    wire [4:0]  id_ex_rd_w;      // destination register index forwarded to EX
    wire [11:0] id_ex_ctrl_w;    // EX stage control signals:
                                    // [11]pc_write_en [10]mem_to_reg [9]pc_to_reg [8]reg_write 
                                    // [7]branch [6]mem_read [5]mem_write [4]jump [3]b_sel [2]a_sel [1:0]alu_op   

    // EX/MEM register wires
    wire [31:0] ex_mem_branch_addr_w; // calculated branch/jump target address
    wire [31:0] ex_mem_alu_out_w;     // ALU result forwarded to MEM stage
    wire [31:0] ex_mem_reg2_w;        // RS2 value for store instructions
    wire [31:0] ex_mem_pc_w;          // PC forwarded to MEM (for JAL writeback)
    wire [4:0]  ex_mem_rd_w;          // destination register forwarded to MEM
    wire        ex_mem_take_branch_w; // branch decision resolved in EX stage
    wire [2:0]  ex_mem_load_type_w;   // load type forwarded to MEM
    wire [1:0]  ex_mem_store_type_w;  // store type forwarded to MEM
    wire [7:0]  ex_mem_ctrl_w;        // packed control bits for MEM stage
                                        // [7]pc_write_en [6]mem_to_reg [5]pc_to_reg [4]reg_write 
                                        // [3]branch [2]mem_read [1]mem_write [0]jump  

    // MEM/WB register wires
    wire [31:0] mem_wb_mem_data_w;    // data loaded from memory (MEM → WB)
    wire [31:0] mem_wb_alu_out_w;     // ALU result forwarded from MEM → WB
    wire [31:0] mem_wb_pc_w;            // PC+4 for JAL/JALR writeback
    wire [4:0]  mem_wb_rd_w;          // destination register index at WB
    wire [3:0]  mem_wb_ctrl_w;        // packed WB-stage control signals
                                        // [3]pc_write_en [2]mem_to_reg [1]pc_to_reg [0]reg_write 

    // =================================================
    // PROGRAM COUNTER & INSTRUCTION FETCH
    // =================================================

    register #(.N(32)) pc (
        .clk      (clk),
        .rst      (rst),
        .wr_en_i  (pc_write_en_w),
        .d_i      (pc_in_w),
        .d_o      (pc_out_w)
    );


    rca #(.N(32)) following_pc_adder (
        .a_i   (pc_out_w),
        .b_i   (32'd4),
        .c_i   (1'b0),
        .c_o   (),
        .s_o   (pc_plus_four_w)
    );


    // =================================================
    // IF/ID PIPELINE REGISTER
    // =================================================
    wire [31:0] inst_or_flush_w;
    nmux #(32) flushifid (pc_mux_sel_w,mem_read_data_w,32'b00000000000000000000000000110011,  inst_or_flush_w);

    
    register #(.N(64)) if_id_reg (
        .clk     (~clk),
        .rst     (rst),
        .wr_en_i (1'b1),
        .d_i     ({pc_out_w, mem_read_data_w}),
        .d_o     ({if_id_pc_w, if_id_inst_w})
    );


    // =================================================
    // DECODE STAGE
    // =================================================
    
    
    control_unit ctrl_unit (
        .opcode_i      (if_id_inst_w[`IR_opcode]),
        .branch_o      (branch_w),
        .mem_rd_o      (mem_read_w),
        .mem_to_reg_o  (mem_to_reg_w),
        .alu_op_o      (alu_op_w),
        .mem_wr_o      (mem_write_w),
        .b_sel_o       (b_sel_w),
        .a_sel_o       (a_sel_w),
        .reg_wr_o      (reg_write_w),
        .jump_o        (jump_w),
        .pc_to_reg_o   (pc_to_reg_w),
        .pc_wr_en_o    (pc_write_en_w)
    );

    reg_file #(.N(32)) reg_file_inst (
        .clk        (clk),
        .rst        (rst),
        .rd_addr1_i (if_id_inst_w[`IR_rs1]),
        .rd_addr2_i (if_id_inst_w[`IR_rs2]),
        .wr_addr_i  (mem_wb_rd_w),
        .wr_en_i    (mem_wb_ctrl_w[0]),
        .wr_data_i  (writeback_data_w),
        .rd_data1_o (reg_read1_w),
        .rd_data2_o (reg_read2_w)
    );

    imm_gen imm_gen_inst (
        .inst_i (if_id_inst_w),
        .gen_o  (imm_w)
    );


    // =================================================
    // ID/EX PIPELINE REGISTER
    // =================================================
    wire [11:0] decode_or_flush_w;

    nmux #(.N(12)) flushidex(.a_i({pc_write_en_w, mem_to_reg_w, pc_to_reg_w, reg_write_w,
                     branch_w, mem_read_w, mem_write_w, jump_w,
                     b_sel_w, a_sel_w, alu_op_w}),
                        .b_i(12'd000), .s_i(pc_mux_sel_w), .c_o(decode_or_flush_w));
    
    register #(.N(159)) id_ex_reg (
        .clk     (clk),
        .rst     (rst),
        .wr_en_i (1'b1),
        .d_i     ({
                    decode_or_flush_w,
                    if_id_pc_w,
                    reg_read1_w,
                    reg_read2_w,
                    imm_w,
                    {if_id_inst_w[30], if_id_inst_w[14:12]},
                    if_id_inst_w[19:15],
                    if_id_inst_w[24:20],
                    if_id_inst_w[11:7]
                 }),
        .d_o     ({
                    id_ex_ctrl_w,
                    id_ex_pc_w,
                    id_ex_reg1_w,
                    id_ex_reg2_w,
                    id_ex_imm_w,
                    id_ex_func_w,
                    id_ex_rs1_w,
                    id_ex_rs2_w,
                    id_ex_rd_w
                 })
    );

    
    // =================================================
    // EXECUTE STAGE
    // =================================================
    wire [31:0] forwarding_register1_w, forwarding_register2_w;
    wire forwarda_w, forwardb_w;
    //ALU A
    
    nmux #(.N(32)) alu_a_2_mux (
        .a_i (id_ex_reg1_w),
        .b_i (write_data_w),
        .s_i (forwarda_w),
        .c_o (forwarding_register1_w)
    );
    
    nmux #(.N(32)) alu_a_1_mux (
        .a_i (forwarding_register1_w),
        .b_i (id_ex_pc_w),
        .s_i (id_ex_ctrl_w[2]),
        .c_o (alu_in_a_w)
    );
    
    //ALU B 
    nmux #(.N(32)) alu_b_2_mux (
        .a_i (id_ex_reg2_w),
        .b_i (write_data_w),
        .s_i (forwardb_w),
        .c_o (forwarding_register2_w)
    );
    
    nmux #(.N(32)) alu_b_1_mux (
        .a_i (forwarding_register2_w),
        .b_i (id_ex_imm_w),
        .s_i (id_ex_ctrl_w[3]),
        .c_o (alu_in_b_w)
    );
    
    
    
    
    

    
    
    

    alu_control alu_ctrl_inst (
        .alu_op_i  (id_ex_ctrl_w[1:0]),
        .funct3_i  (id_ex_func_w[2:0]),
        .funct7_i  (id_ex_func_w[3]),
        .alu_ctrl_o(alu_ctrl_w)
    );

    alu alu_inst (
        .a_i        (alu_in_a_w),
        .b_i        (alu_in_b_w),
        .shamt_i    (alu_in_b_w[4:0]),
        .alu_ctrl_i (alu_ctrl_w),
        .c_o        (alu_out_w),
        .cf_o       (cf_w),
        .zf_o       (zf_w),
        .vf_o       (vf_w),
        .sf_o       (sf_w)
    );

    rca #(.N(32)) offset_adder (
        .a_i   (id_ex_pc_w),
        .b_i   (id_ex_imm_w),
        .c_i   (1'b0),
        .c_o   (),
        .s_o   (pc_branch_w)
    );

    branch_control branch_control_inst(
        .funct3_i(id_ex_func_w[2:0]),
        .zf_i(zf_w),
        .cf_i(cf_w),
        .vf_i(vf_w),
        .sf_i(sf_w),
        .take_branch_o(take_branch_w)
    );

    load_store_unit lsu_inst (
        .funct3_i       (id_ex_func_w[2:0]),
        .load_type_o    (load_type_w),
        .store_type_o   (store_type_w)
    );


    // =================================================
    // EX/MEM PIPELINE REGISTER
    // =================================================
    wire [7:0] execute_or_flush_w;

    nmux #(.n(8)) flushexmem(.a_i(id_ex_ctrl_w[11:4]),
                        .b_i(8'h00), .s_i(pc_mux_sel_w), .c_o(execute_or_flush_w));
                        
    register #(.N(147)) ex_mem_reg (
        .clk     (~clk),
        .rst     (rst),
        .wr_en_i (1'b1),
        .d_i     ({
                    id_ex_ctrl_w[11:4],
                    pc_branch_w,
                    take_branch_w,
                    alu_out_w,
                    id_ex_reg2_w,
                    id_ex_rd_w,
                    load_type_w,
                    store_type_w,
                    id_ex_pc_w
                 }),
        .d_o     ({
                    ex_mem_ctrl_w,
                    ex_mem_branch_addr_w,
                    ex_mem_take_branch_w,
                    ex_mem_alu_out_w,
                    ex_mem_reg2_w,
                    ex_mem_rd_w,
                    ex_mem_load_type_w,
                    ex_mem_store_type_w,
                    ex_mem_pc_w
                 })
    );


    // =================================================
    // MEMORY STAGE
    // =================================================
    wire [31:0] unified_addr_w;
    wire        unified_rd_en_w;
    wire [2:0]  unified_load_type_w;

    nmux #(.N(32)) mem_addr_mux (
        .a_i(ex_mem_alu_out_w),             // PC for instruction fetch
        .b_i(pc_out_w),     // ALU result for load/store
        .s_i(clk),
        .c_o(unified_addr_w)
    );

    nmux #(.N(1)) mem_rd_mux (
    .a_i(ex_mem_ctrl_w[2]),                  // always read for instruction fetch
     .b_i(1'b1),      // actual load read enable
    .s_i(clk),
    .c_o(unified_rd_en_w)
    );

    nmux #(.N(3)) load_type_mux (
    .a_i(ex_mem_load_type_w),                 // WORD for instruction fetch
    .b_i(3'b100),     // LSU-decoderd load type
    .s_i(clk),
    .c_o(unified_load_type_w)
);


    data_mem unified_mem_inst (
        .clk           (~clk),
        .rd_en_i       (unified_rd_en_w),
        .wr_en_i       (ex_mem_ctrl_w[1]),
        .addr_i        (unified_addr_w[7:0]),
        .wr_data_i     (ex_mem_reg2_w),
        .store_type_i  (ex_mem_store_type_w),
        .load_type_i   (unified_load_type_w),
        .rd_data_o     (mem_read_data_w)
    );
    
    
    

    forwarding_unit forwading_1(
        forwarda_w, forwardb_w,
        id_ex_rs1_w, id_ex_rs2_w,
        mem_wb_rd_w,
        mem_wb_ctrl_w[0]
    );
    
    assign pc_mux_sel_w = (ex_mem_ctrl_w[3] & ex_mem_take_branch_w) | ex_mem_ctrl_w[0];

        
    nmux #(.N(32)) pc_target_mux (
        .a_i (ex_mem_branch_addr_w),
        .b_i (ex_mem_alu_out_w),
        .s_i (ex_mem_ctrl_w[0]),
        .c_o (pc_target_w)
    );

    nmux #(.N(32)) pc_mux (
        .a_i (pc_plus_four_w),
        .b_i (pc_target_w),
        .s_i (pc_mux_sel_w),
        .c_o (pc_in_w)
    );


    // =================================================
    // MEM/WB PIPELINE REGISTER
    // =================================================


    register #(.N(105)) mem_wb_reg (
        .clk     (clk),
        .rst     (rst),
        .wr_en_i (1'b1),
        .d_i     ({
                    ex_mem_ctrl_w[7:4],
                    mem_read_data_w,
                    ex_mem_alu_out_w,
                    ex_mem_rd_w,
                    ex_mem_pc_w+4
                 }),
        .d_o     ({
                    mem_wb_ctrl_w,
                    mem_wb_mem_data_w,
                    mem_wb_alu_out_w,
                    mem_wb_rd_w,
                    mem_wb_pc_w
                 })
    );


    // =================================================
    // WRITEBACK STAGE
    // =================================================

    nmux #(.N(32)) mem_to_reg_mux (
        .a_i (mem_wb_alu_out_w),
        .b_i (mem_wb_mem_data_w),
        .s_i (mem_wb_ctrl_w[2]),
        .c_o (write_data_w)
    );

    nmux #(.N(32)) pc_to_reg_mux (
        .a_i (write_data_w),
        .b_i (mem_wb_pc_w),
        .s_i (mem_wb_ctrl_w[1]),
        .c_o (writeback_data_w)
    );


    // =================================================
    // LED / 7-SEG OUTPUTS
    // =================================================

    always @(*) begin
        case (led_sel_i)
            2'b00: inst_led_o = mem_read_data_w[15:0];
            2'b01: inst_led_o = mem_read_data_w[31:16];
            2'b10: inst_led_o = {cf_w, vf_w, sf_w, zf_w,
                                 branch_w, mem_read_w, mem_to_reg_w,
                                 mem_write_w, reg_write_w,
                                 pc_mux_sel_w, alu_op_w, alu_ctrl_w};
            2'b11: inst_led_o = {12'b0, a_sel_w, b_sel_w};
            default: inst_led_o = 16'd0;
        endcase

        case (ssd_sel_i)
            4'b0000: ssd_o = pc_out_w[12:0];
            4'b0001: ssd_o = pc_plus_four_w[12:0];
            4'b0010: ssd_o = pc_branch_w[12:0];
            4'b0011: ssd_o = pc_in_w[12:0];
            4'b0100: ssd_o = reg_read1_w[12:0];
            4'b0101: ssd_o = reg_read2_w[12:0];
            4'b0110: ssd_o = write_data_w[12:0];
            4'b0111: ssd_o = imm_w[12:0];
            4'b1000: ssd_o = imm_w[12:0];
            4'b1001: ssd_o = alu_in_b_w[12:0];
            4'b1010: ssd_o = alu_out_w[12:0];
            4'b1011: ssd_o = mem_read_data_w[12:0];
            default: ssd_o = 13'd0;
        endcase
    end

endmodule
