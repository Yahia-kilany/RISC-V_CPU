`timescale 1ns / 1ps

/*******************************************************************
*
* Module: data_mem.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description: 
*   64×32-bit memory. Asynchronous read, synchronous write.
*
* Change history:
*   09/14/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module data_mem (
    input  wire        clk,      // Core clock
    input  wire        rd_en_i,  // Read enable
    input  wire        wr_en_i,  // Write enable
    input  wire [5:0]  addr_i,   // 6-bit word address
    input  wire [31:0] d_i,      // Write data
    output wire [31:0] d_o       // Read data
);

    // 64 × 32-bit memory array
    reg [31:0] mem_arr [0:63];

    // Asynchronous read
    assign d_o = (rd_en_i) ? mem_arr[addr_i] : 32'd0;

    // Synchronous write
    always @(posedge clk) begin
        if (wr_en_i)
            mem_arr[addr_i] <= d_i;
    end

    // Optional: memory initialization
    initial begin
        mem_arr[0] = 32'd17;
        mem_arr[1] = 32'd9;
        mem_arr[2] = 32'd25;
    end

endmodule