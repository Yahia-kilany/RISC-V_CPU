`timescale 1ns / 1ps

/*******************************************************************
*
* Module: inst_mem.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
* Description: 
*   Instruction memory module.
*   Provides 32-bit instructions for a 64-word memory.
*   Address input (addr_i) selects which instruction (data_o) to output asynchronous.
*
* Change history:
*   10/14/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module inst_mem (
    input  wire [7:0]  addr_i, 
    output wire [31:0] data_o
);

    reg [31:0] mem_r [0:255];

    assign data_o = mem_r[addr_i];

    initial begin
    $readmemh("C:/Users/OMEN/Desktop/Mememe/college/semester 8/computer architecture/project 1/RISC-V_CPU/TestCases/AssemblyHex.hex", mem_r);
    end


endmodule