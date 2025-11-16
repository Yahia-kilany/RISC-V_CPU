`timescale 1ns / 1ps

/*******************************************************************
*
* Module: reg_file.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description: 
*   N-bit 32-entry register file with two read ports and one write port.
*   - Supports asynchronous active-high reset.
*   - Writes occur on rising edge of clk when wr_en_i is high and write address is not zero.
*   - asynchronous read from two read ports (rd_addr1_i and rd_addr2_i).
*   - Internal storage implemented as an array of 32 registers, each N bits wide.
*
* Change history:
*   10/07/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module reg_file #(parameter N = 32) (
    input  wire             clk,         // Core clock
    input  wire             rst,         // Asynchronous active-high reset
    input  wire             wr_en_i,     // Register write enable
    input  wire [4:0]       wr_addr_i,   // Write address
    input  wire [4:0]       rd_addr1_i,  // Read address port 1
    input  wire [4:0]       rd_addr2_i,  // Read address port 2
    input  wire [N-1:0]     wr_data_i,   // Data to be written
    output reg  [N-1:0]     rd_data1_o,  // Data read from port 1
    output reg  [N-1:0]     rd_data2_o   // Data read from port 2
);

    // Internal register storage: 32 registers, each N bits wide
    reg [N-1:0] register_arr [31:0];

    integer i;

    // Combinational read logic
    always @(*) begin
        rd_data1_o = register_arr[rd_addr1_i];
        rd_data2_o = register_arr[rd_addr2_i];
    end

    // Sequential write and reset logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                register_arr[i] <= {N{1'b0}};
            end
        end else if (wr_en_i && (wr_addr_i != 5'd0)) begin
            register_arr[wr_addr_i] <= wr_data_i;
        end
    end

endmodule