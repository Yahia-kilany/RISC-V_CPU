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
            3'b000: load_type_o = 3'b000; // LB
            3'b001: load_type_o = 3'b010; // LH
            3'b010: load_type_o = 3'b100; // LW
            3'b100: load_type_o = 3'b001; // LBU
            3'b101: load_type_o = 3'b011; // LHU
            default: load_type_o = 3'b100; // default LW
        endcase
    end

    // -----------------------------
    // STORE type decoder
    // -----------------------------
    always @(*) begin
        case (funct3_i)
            2'b00: store_type_o = 2'b00; // SB
            2'b01: store_type_o = 2'b01; // SH
            2'b10: store_type_o = 2'b10; // SW
            default: store_type_o = 2'b10; // default SW
        endcase
    end

endmodule