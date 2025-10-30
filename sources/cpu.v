`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 02:33:23 PM
// Design Name: 
// Module Name: cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu( input clk,rst, [1:0] ledSel,[3:0] ssdSel, output reg [15:0] instLed, reg [12:0] ssd );
wire [31:0] pc_in ;
wire [31:0] pc_out;
wire [31:0] inst;
wire [31:0] writeData;
wire [31:0] regread1;
wire [31:0] regread2;
wire [31:0] imm;
wire [31:0] inAluB;
wire [31:0] aluOut;
wire [31:0] pcBranch;
wire [31:0] dataRead;
wire Branch;     
wire MemRead;    
wire MemtoReg;   
wire [1:0] ALUOp;
wire MemWrite;   
wire ALUSrc;     
wire RegWrite;
wire zero;    
wire [31:0] offset;
wire muxPc;
wire [3:0]ALUCtrl;
Reg  #(.n(32)) pc (.clk(clk), .rst(rst) ,.load(1'b1),.Data(pc_in),.Q(pc_out));

InstMem meminst(.addr(pc_out[7:2]), .data_out(inst));

ControlUnit  ctrlUnit(
   .opcode(inst[6:2]),
     .Branch(Branch),
     .MemRead(MemRead),
     .MemtoReg(MemtoReg),
     .ALUOp(ALUOp),
     .MemWrite(MemWrite),
     .ALUSrc(ALUSrc),
     .RegWrite(RegWrite)
);

RegFile #(.n(32))regfile (
.clk(clk),
.rst(rst),
.readAdd1(inst[19:15]),
.readAdd2(inst[24:20]), 
.writeAdd(inst[11:7]),
.regWrite(RegWrite),
.writeData(writeData),
.regread1(regread1), 
.regread2(regread2));

ImmGen generator(.gen_out(imm),
    .inst(inst));


nmux #(.n(32)) alusrc(.a(regread2),.b(imm), .s(ALUSrc), .c(inAluB));

ALUControl aluctrl(
.ALUOp(ALUOp),         // Control signal from Main Control Unit
.funct3(inst[14:12]),        // Instruction bits [14:12]
.funct7(inst[30]),        // Instruction bit [30]
.ALUCtrl(ALUCtrl)    // ALU operation selection
);

alu #(.n(32)) Alu ( 
.A(regread1), .B(inAluB),.sel(ALUCtrl),
.zeroflag(zero), .C(aluOut));

shiftL1 #(32) shiftimm(imm,offset);

RCA_module #(.n(32)) offsetAdder(
.A(pc_out), .B(offset), .cin(0),
.cout(), .S(pcBranch));

assign muxPc = Branch & zero;

nmux #(.n(32)) Pcmux (.a(pc_out+4),.b(pcBranch), .s(muxPc), .c(pc_in));

DataMem datamem
(.clk(clk), .MemRead(MemRead), .MemWrite(MemWrite),
.addr(aluOut[7:2]), .data_in(regread2), .data_out(dataRead));
nmux #(.n(32)) memReg (.a(aluOut),.b(dataRead), .s(MemtoReg), .c(writeData));

always @(*) begin
case (ledSel)
            2'b00: instLed = inst[15:0];                            
            2'b01: instLed = inst[31:16];
            2'b10: instLed = {2'b00,Branch,MemRead  ,MemtoReg, MemWrite,ALUSrc,RegWrite,muxPc,zero, ALUOp,ALUCtrl};
            default: instLed = 0;
        endcase
        
  case (ssdSel)
        4'b0000: ssd = pc_out [12:0];
        4'b0001: ssd = pc_out[12:0]+4;
        4'b0010: ssd = pcBranch[12:0];
        4'b0011: ssd = pc_in[12:0];
        4'b0100: ssd = regread1[12:0];
        4'b0101: ssd = regread2[12:0];
        4'b0110: ssd = writeData[12:0];
        4'b0111: ssd = imm[12:0];
        4'b1000: ssd = offset[12:0];
        4'b1001: ssd = inAluB[12:0];
        4'b1010: ssd = aluOut[12:0];
        4'b1011: ssd = dataRead[12:0];
  endcase
end 
endmodule
