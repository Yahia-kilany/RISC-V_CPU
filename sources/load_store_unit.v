`timescale 1ns / 1ps
`include "defines.v"
/*******************************************************************
*
* Module: load_store_unit.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description: 
*   Handles load/store operations with proper byte/halfword/word access.
*   Formats data based on funct3 (LB, LH, LW, LBU, LHU, SB, SH, SW).
*   Manages byte-level addressing and sign extension.
*   Implements read-modify-write for byte and halfword stores.
*
* Change history:
*   11/08/2025 - Initial version created (ouail)
*   11/08/2025 - Extended to handle store operations with RMW (ouail)

*******************************************************************/
module load_store_unit (
    input  wire        clk,
    input  wire [2:0]  funct3_i,      // Instruction[14:12] - load/store type
    input  wire [31:0] alu_result_i,  // Address from ALU
    input  wire [31:0] write_data_i,  // Data to store (from rs2)
    input  wire        mem_read_i,    // Memory read enable
    input  wire        mem_write_i,   // Memory write enable
    
    // Memory interface
    output wire [7:0]  mem_addr_o,    // Address to memory (word-aligned)
    output reg  [31:0] mem_write_data_o, // Data to write to memory
    output wire        mem_rd_en_o,   // Read enable to memory
    output wire        mem_wr_en_o,   // Write enable to memory
    input  wire [31:0] mem_read_data_i,  // Data from memory
    
    // Output to CPU
    output reg  [31:0] load_data_o    // Formatted load data
);

    // Extract byte offset from address
    wire [1:0] byte_offset = alu_result_i[1:0];
    
    // Word-aligned address (bits [7:2] for your 128-byte memory)
    assign mem_addr_o = alu_result_i[7:2];
    
    // Pass control signals through - control unit handles these
    assign mem_rd_en_o = mem_read_i;
    assign mem_wr_en_o = mem_write_i;
    
    // --- STORE OPERATIONS ---
    // Format store data based on funct3 and byte offset
    // Uses read-modify-write approach for byte/halfword stores
    always @(*) begin
        if (mem_write_i) begin
            case (funct3_i)
                3'b000: begin // SB (Store Byte)
                    case (byte_offset)
                        2'b00: mem_write_data_o = {mem_read_data_i[31:8],  write_data_i[7:0]};
                        2'b01: mem_write_data_o = {mem_read_data_i[31:16], write_data_i[7:0], mem_read_data_i[7:0]};
                        2'b10: mem_write_data_o = {mem_read_data_i[31:24], write_data_i[7:0], mem_read_data_i[15:0]};
                        2'b11: mem_write_data_o = {write_data_i[7:0], mem_read_data_i[23:0]};
                        default: mem_write_data_o = 32'b0;
                    endcase
                end
                
                3'b001: begin // SH (Store Halfword)
                    case (byte_offset[1])
                        1'b0: mem_write_data_o = {mem_read_data_i[31:16], write_data_i[15:0]};
                        1'b1: mem_write_data_o = {write_data_i[15:0], mem_read_data_i[15:0]};
                        default: mem_write_data_o = 32'b0;
                    endcase
                end
                
                3'b010: begin // SW (Store Word)
                    mem_write_data_o = write_data_i;
                end
                
                default: mem_write_data_o = 32'b0;
            endcase
        end else begin
            mem_write_data_o = 32'b0;
        end
    end
    
    // --- LOAD OPERATIONS ---
    // Format loaded data based on funct3 and byte offset
    always @(*) begin
        if (mem_read_i) begin
            case (funct3_i)
                3'b000: begin // LB (Load Byte - sign extended)
                    case (byte_offset)
                        2'b00: load_data_o = {{24{mem_read_data_i[7]}},  mem_read_data_i[7:0]};
                        2'b01: load_data_o = {{24{mem_read_data_i[15]}}, mem_read_data_i[15:8]};
                        2'b10: load_data_o = {{24{mem_read_data_i[23]}}, mem_read_data_i[23:16]};
                        2'b11: load_data_o = {{24{mem_read_data_i[31]}}, mem_read_data_i[31:24]};
                        default: load_data_o = 32'b0;
                    endcase
                end
                
                3'b001: begin // LH (Load Halfword - sign extended)
                    case (byte_offset[1])
                        1'b0: load_data_o = {{16{mem_read_data_i[15]}}, mem_read_data_i[15:0]};
                        1'b1: load_data_o = {{16{mem_read_data_i[31]}}, mem_read_data_i[31:16]};
                        default: load_data_o = 32'b0;
                    endcase
                end
                
                3'b010: begin // LW (Load Word)
                    load_data_o = mem_read_data_i;
                end
                
                3'b100: begin // LBU (Load Byte Unsigned)
                    case (byte_offset)
                        2'b00: load_data_o = {24'b0, mem_read_data_i[7:0]};
                        2'b01: load_data_o = {24'b0, mem_read_data_i[15:8]};
                        2'b10: load_data_o = {24'b0, mem_read_data_i[23:16]};
                        2'b11: load_data_o = {24'b0, mem_read_data_i[31:24]};
                        default: load_data_o = 32'b0;
                    endcase
                end
                
                3'b101: begin // LHU (Load Halfword Unsigned)
                    case (byte_offset[1])
                        1'b0: load_data_o = {16'b0, mem_read_data_i[15:0]};
                        1'b1: load_data_o = {16'b0, mem_read_data_i[31:16]};
                        default: load_data_o = 32'b0;
                    endcase
                end
                
                default: load_data_o = 32'b0;
            endcase
        end else begin
            load_data_o = 32'b0;
        end
    end

endmodule