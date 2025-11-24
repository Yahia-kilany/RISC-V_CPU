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
*   10/14/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module data_mem (
    input  wire        clk,
    input  wire        rd_en_i,
    input  wire        wr_en_i,
    input  wire [7:0] addr_i,      // byte address
    input  wire [31:0] wr_data_i,
    input  wire [2:0]  load_type_i,   // LB/LBU/LH/LHU
    input  wire [1:0]  store_type_i,  // SB/SH/SW
    output reg  [31:0] rd_data_o
);
    
    reg [7:0] mem [0:255]; // example 1KB memory

    // Read
    always @(*) begin
        if (rd_en_i) begin
            case (load_type_i)
                `LOAD_B: rd_data_o = {{24{mem[addr_i][7]}}, mem[addr_i]};           // LB
                `LOAD_BU: rd_data_o = {24'b0, mem[addr_i]};                          // LBU
                `LOAD_H: rd_data_o = {{16{mem[addr_i+1][7]}}, mem[addr_i+1], mem[addr_i]}; // LH
                `LOAD_HU: rd_data_o = {16'b0, mem[addr_i+1], mem[addr_i]};           // LHU
                `LOAD_W: rd_data_o = {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]};           // LW
                default: rd_data_o = {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]}; // default LW
            endcase
        end else begin
            rd_data_o = 32'b0;
        end
    end

    // Write
    always @(posedge clk) begin
        if (wr_en_i) begin
            case (store_type_i)
                `STORE_B: mem[addr_i] <= wr_data_i[7:0];                // SB
                `STORE_H: begin                                        // SH
                    mem[addr_i]   <= wr_data_i[7:0];
                    mem[addr_i+1] <= wr_data_i[15:8];
                end
                `STORE_W: begin                                        // SW
                    mem[addr_i]   <= wr_data_i[7:0];
                    mem[addr_i+1] <= wr_data_i[15:8];
                    mem[addr_i+2] <= wr_data_i[23:16];
                    mem[addr_i+3] <= wr_data_i[31:24];
                end
            endcase
        end
    end
 integer i;

initial begin
                // Initialize all memory to 0
        for (i = 0; i < (4*1024); i = i + 2) begin
            {mem[i+1],mem[i]} = 16'b0000000000000001; // C.NOP
        end
        $readmemh("C:/Users/OMEN/Desktop/Mememe/college/semester 8/computer architecture/project 1/RISC-V_CPU/PipelineArchitecture/testcases/lab.mem",mem);
    end

endmodule