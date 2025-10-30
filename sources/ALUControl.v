module ALUControl(
    input  [1:0] ALUOp,         // Control signal from Main Control Unit
    input  [2:0] funct3,        // Instruction bits [14:12]
    input        funct7,        // Instruction bit [30]
    output reg [3:0] ALUCtrl    // ALU operation selection
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUCtrl = 4'b0010; // Load/Store -> ADD
            2'b01: ALUCtrl = 4'b0110; // Branch -> SUB
            2'b10: begin              // R-type instructions
                case ({funct7, funct3})
                    4'b0000: ALUCtrl = 4'b0010; // ADD
                    4'b1000: ALUCtrl = 4'b0110; // SUB
                    4'b0111: ALUCtrl = 4'b0000; // AND
                    4'b0110: ALUCtrl = 4'b0001; // OR
                    default: ALUCtrl = 4'bxxxx; // Undefined
                endcase
            end
            default: ALUCtrl = 4'bxxxx;
        endcase
    end

endmodule