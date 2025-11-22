`timescale 1ns / 1ps

module forwarding_unit(
    output reg  forwardA, forwardB,
    input  [4:0] ID_EX_RegisterRs1, ID_EX_RegisterRs2,
    input  [4:0]  MEM_WB_RegisterRd,
    input         MEM_WB_RegWrite
);

always @* begin
    // default: no forwarding
    forwardA = 2'b00;
    forwardB = 2'b00;

    // -------------------------
    // ForwardA logic
    // -------------------------


    // MEM hazard (lower priority → only if EX didn't match)
    if (MEM_WB_RegWrite &&
             (MEM_WB_RegisterRd != 0) &&
             (MEM_WB_RegisterRd == ID_EX_RegisterRs1))
        forwardA = 1'b1;

    // -------------------------
    // ForwardB logic
    // -------------------------

    // MEM hazard
    if (MEM_WB_RegWrite &&
             (MEM_WB_RegisterRd != 0) &&
             (MEM_WB_RegisterRd == ID_EX_RegisterRs2))
        forwardB = 1'b1;

end

endmodule
