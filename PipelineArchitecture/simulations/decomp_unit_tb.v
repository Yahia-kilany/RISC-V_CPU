`timescale 1ns / 1ps
/*******************************************************************
*
* Module: decomp_unit_tb
* Project: RISC-V_CPU
* Author: Yahia Kilany
*
* Description:
*   a testbench containing all the rv32c instruction to test the 
*   decomp unit
*
* Change history:
*   11-22-2025 completed
*
*******************************************************************/



module decomp_unit_tb;

    // Testbench signals
    reg  [15:0] comp_inst_i;
    wire [31:0] decomp_inst_o;

    // Instantiate the DUT
    decomp_unit dut (
        .comp_inst_i(comp_inst_i),
        .decomp_inst_o(decomp_inst_o)
    );

    initial begin
        // Initialize
        comp_inst_i = 16'b0;

        // Apply test vectors in hex
        #5 comp_inst_i = 16'h4212;  // c.lwsp x4, 4
        #5 comp_inst_i = 16'hc496;  // c.swsp x5, 72
        #5 comp_inst_i = 16'h5444;  // c.lw x9, 44(x8)
        #5 comp_inst_i = 16'hc06c;  // c.sw x11, 68(x8)
        #5 comp_inst_i = 16'ha80d;  // c.j 50
        #5 comp_inst_i = 16'h2099;  // c.jal 70
        #5 comp_inst_i = 16'h8f82;  // c.jr x31
        #5 comp_inst_i = 16'h9a02;  // c.jalr x20
        #5 comp_inst_i = 16'hdcf5;  // c.beqz x9, -4
        #5 comp_inst_i = 16'hfffd;  // c.bnez x15, -2
        #5 comp_inst_i = 16'h517d;  // c.li x2, -1
        #5 comp_inst_i = 16'h7ff9;  // c.lui x31, -2
        #5 comp_inst_i = 16'h1ffd;  // c.addi x31, -1
        #5 comp_inst_i = 16'h717d;  // c.addi16sp -16
        #5 comp_inst_i = 16'h0f86;  // c.slli x31, 13
        #5 comp_inst_i = 16'h067c;  // c.addi4spn x15, 780
        #5 comp_inst_i = 16'h83e9;  // c.srli x15, 26
        #5 comp_inst_i = 16'h9781;  // c.srai x15, 32
        #5 comp_inst_i = 16'h9b81;  // c.andi x15, -32
        #5 comp_inst_i = 16'h8ff6;  // c.mv x31, x29
        #5 comp_inst_i = 16'h9ffe;  // c.add x31, x31
        #5 comp_inst_i = 16'h8ffd;  // c.and x15, x15
        #5 comp_inst_i = 16'h8ec1;  // c.or x13, x8
        #5 comp_inst_i = 16'h8f31;  // c.xor x14, x12
        #5 comp_inst_i = 16'h8e09;  // c.sub x12, x10
        #5 comp_inst_i = 16'h0001;  // c.nop
        #5 comp_inst_i = 16'h9002;  // c.ebreak
        #10 $finish;
    end
endmodule