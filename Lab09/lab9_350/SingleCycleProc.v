`timescale 1ns / 1ps
// Code your design here
module singlecycle(
    input resetl,
    input [63:0] startpc,
    output reg [63:0] currentpc,
    output [63:0] dmemout,
    input CLK
);

    // Next PC connections
  wire [63:0] nextpc;     // The next PC, to be updated on clock cycle

    // Instruction Memory connections
  wire [31:0] instruction;  // The current instruction

    // Parts of instruction
    wire [4:0] rd;            // The destination register
    wire [4:0] rm;            // Operand 1
    wire [4:0] rn;            // Operand 2
    wire [10:0] opcode;

    // Control wires
    wire reg2loc;
    wire alusrc;
    wire mem2reg;
    wire regwrite;
    wire memread;
    wire memwrite;
    wire branch;
    wire uncond_branch;
    wire [3:0] aluctrl;
  	wire [2:0] signop;

    // Register file connections
    wire [63:0] regoutA;     // Output A
    wire [63:0] regoutB;     // Output B

    // ALU connections
    wire [63:0] aluout;
  	wire [63:0] inputB; //= alusrc ? extimm : regoutB;
  	assign inputB = alusrc ? extimm : regoutB;
    wire zero;

    // Sign Extender connections
    wire [63:0] extimm;
	
	//Data memory 
	//wire [63:0] readData;
	
	//registerFile
  	wire [63:0] busW;
  	assign busW = mem2reg ? dmemout : aluout;

    // PC update logic
    always @(negedge CLK)
    begin
        if (resetl)
            currentpc <= nextpc;
        else
            currentpc <= startpc;
    end

    // Parts of instruction
    assign rd = instruction[4:0];
    assign rm = instruction[9:5];
    assign rn = reg2loc ? instruction[4:0] : instruction[20:16];
    assign opcode = instruction[31:21];

  
    InstructionMemory imem(
        .Data(instruction),
        .Address(currentpc)
    );
  
  
  	//nextPC logic
	
	NextPClogic npcl(.NextPC(nextpc), .CurrentPC(currentpc), .SignExtImm64(extimm), .Branch(branch), .ALUZero(zero), .Uncondbranch(uncond_branch));

  
    control control(
        .reg2loc(reg2loc),
        .alusrc(alusrc),
        .mem2reg(mem2reg),
        .regwrite(regwrite),
        .memread(memread),
        .memwrite(memwrite),
        .branch(branch),
        .uncond_branch(uncond_branch),
        .aluop(aluctrl),
        .signop(signop),
        .opcode(opcode)
    );
  
  
  	//regFile
	
  RegisterFile rf2(.BusA(regoutA), .BusB(regoutB), .BusW(busW), .RA(rm), .RB(rn), .RW(instruction[4:0]), .RegWr(regwrite), .Clk(CLK));
	
  
	//signExt
	
	SignExtender se2(.BusImm(extimm), .Imm26(instruction[25:0]), .Ctrl(signop));
	
	
	//ALU
	
  	ALU alu2(.BusW(aluout), .BusA(regoutA), .BusB(inputB), .ALUCtrl(aluctrl), .Zero(zero));
  
  
  	//dataMemory
	
  	DataMemory dmem(.ReadData(dmemout), .Address(aluout), .WriteData(regoutB), .MemoryRead(memread), .MemoryWrite(memwrite), .Clock(CLK));
	
endmodule




