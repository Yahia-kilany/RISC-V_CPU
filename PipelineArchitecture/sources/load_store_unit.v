`timescale 1ns/1ps
`include "defines.v"

module load_store_unit (
    input  wire [2:0] funct3_i,    // instruction funct3
    output reg  [2:0] load_type_o,   // LB/LBU/LH/LHU/LW
    output reg  [1:0] store_type_o   // SB/SH/SW
);

    // -----------------------------
    // LOAD type decoder
    // -----------------------------
    always @(*) begin
        case (funct3_i)
            `F3_LB  : load_type_o = `LOAD_B; // LB
            `F3_LH  : load_type_o = `LOAD_H; // LH
            `F3_LW  : load_type_o = `LOAD_W; // LW
            `F3_LBU : load_type_o = `LOAD_BU; // LBU
            `F3_LHU : load_type_o = `LOAD_HU; // LHU
            default: load_type_o = `LOAD_W; // default LW
        endcase
    end

    // -----------------------------
    // STORE type decoder
    // -----------------------------
    always @(*) begin
        case (funct3_i)
            `F3_SB: store_type_o = `STORE_B; // SB
            `F3_SH: store_type_o = `STORE_H; // SH
            `F3_SW: store_type_o = `STORE_W; // SW
            default: store_type_o = `STORE_W; // default SW
        endcase
    end

endmodule