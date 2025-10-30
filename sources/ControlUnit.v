module ControlUnit (
    input  [4:0] opcode,      // Inst[6:2]
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);

    always @(*) begin
        // Default values (safe)
        Branch   = 0;
        MemRead  = 0;
        MemtoReg = 0;
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 0;
        RegWrite = 0;

        case (opcode)
            5'b01100: begin // R-format
                Branch   = 0;
                MemRead  = 0;
                MemtoReg = 0;
                ALUOp    = 2'b10;
                MemWrite = 0;
                ALUSrc   = 0;
                RegWrite = 1;
            end

            5'b00000: begin // LW
                Branch   = 0;
                MemRead  = 1;
                MemtoReg = 1;
                ALUOp    = 2'b00;
                MemWrite = 0;
                ALUSrc   = 1;
                RegWrite = 1;
            end

            5'b01000: begin // SW
                Branch   = 0;
                MemRead  = 0;
                MemtoReg = 1'bx; // Don't care
                ALUOp    = 2'b00;
                MemWrite = 1;
                ALUSrc   = 1;
                RegWrite = 0;
            end

            5'b11000: begin // BEQ
                Branch   = 1;
                MemRead  = 0;
                MemtoReg = 1'bx; // Don't care
                ALUOp    = 2'b01;
                MemWrite = 0;
                ALUSrc   = 0;
                RegWrite = 0;
            end

            default: begin
                // Default "NOP" behavior
                Branch   = 0;
                MemRead  = 0;
                MemtoReg = 0;
                ALUOp    = 2'b00;
                MemWrite = 0;
                ALUSrc   = 0;
                RegWrite = 0;
            end
        endcase
    end

endmodule
