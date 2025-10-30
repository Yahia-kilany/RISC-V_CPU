`timescale 1ns / 1ps

module ImmGen (
    output reg [31:0] gen_out,
    input      [31:0] inst
);
    wire [1:0] opcodebits;
    assign opcodebits = inst[6:5];

    reg [11:0] immediate;

    always @(*) begin

        case (opcodebits)
            2'b00: immediate = inst[31:20];                            // I-type
            2'b01: immediate = {inst[31:25], inst[11:7]};              // S-type
            2'b11: immediate = {inst[31], inst[7],inst[30:25], inst[11:8]};  // B-type-like
            default: immediate = 0;
        endcase
        
        gen_out = { {20{immediate[11]}}, immediate };

    end

endmodule
