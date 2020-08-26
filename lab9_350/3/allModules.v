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



//signExtender
module SignExtender(BusImm, Imm26, Ctrl);
	output reg [63:0] BusImm;
	input [25:0] Imm26;
  	input [2:0] Ctrl;
	
	//wire extBit;
  	//assign #1 extBit = (Ctrl ? 1'b0 : Imm26[25]); //if Ctrl is 1, extend 0's. else extend 25th bit
  	//assign BusImm [63:0] = {{38{extBit}}, Imm26[25:0]};
  	
  
  	always@(Ctrl or Imm26)
    	case(Ctrl)
          3'b000 : BusImm [63:0] = {{52{Imm26[21]}},Imm26[21:10]}; //i type
          3'b001 : BusImm [63:0] = {{55{Imm26[20]}},Imm26[20:12]}; //d type
          3'b010 : BusImm [63:0] = {{38{Imm26[25]}},Imm26[25:0]}; //b type
          3'b011 : BusImm [63:0] = {{45{Imm26[23]}},Imm26[23:5]}; //cb type
          3'b100 : BusImm [63:0] = {{48{1'b0}},{Imm26[20:5]}};
          3'b101 : BusImm [63:0] = {{32{1'b0}},{Imm26[20:5]},{16{1'b0}}};
          3'b110 : BusImm [63:0] = {{16{1'b0}},{Imm26[20:5]},{32{1'b0}}};
          3'b111 :	BusImm [63:0] = {{Imm26[20:5]},{48{1'b0}}};
        endcase
endmodule



//ALU
// Code your design here
`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111


module ALU(BusW, BusA, BusB, ALUCtrl, Zero);
    
    parameter n = 64;

    output  [n-1:0] BusW;
    input   [n-1:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    output  Zero;
    
    reg     [n-1:0] BusW;
    
    always @(ALUCtrl or BusA or BusB) begin
        case(ALUCtrl)
            `AND: BusW <= #20 BusA & BusB;
            `OR: BusW <= #20 BusA | BusB;
            `ADD: BusW <= #20 BusA + BusB;
            `SUB: BusW <= #20 BusA - BusB;
            `PassB: BusW <= #20 BusB;
        endcase
    end
	
  assign #1 Zero = (BusW ? 1'b0 : 1'b1);
endmodule


//dataMem

`define SIZE 1024

module DataMemory(ReadData , Address , WriteData , MemoryRead , MemoryWrite , Clock);
    input [63:0]      WriteData;
    input [63:0]      Address;
    input             Clock, MemoryRead, MemoryWrite;
    output reg [63:0] ReadData;

    reg [7:0]         memBank [`SIZE-1:0];


    // This task is used to write arbitrary data to the Data Memory by
    // the intialization block.
    task initset;
      input [63:0] addr;
      input [63:0] data;
      begin
     memBank[addr] =  data[63:56] ; // Big-endian for the win...
     memBank[addr+1] =  data[55:48];
     memBank[addr+2] =  data[47:40];
     memBank[addr+3] =  data[39:32];
     memBank[addr+4] =  data[31:24];
     memBank[addr+5] =  data[23:16];
     memBank[addr+6] =  data[15:8];
     memBank[addr+7] =  data[7:0];
      end
    endtask


    initial
    begin
        // preseting some data in the data memory used by test #1

        // Address 0x0 gets 0x1
        initset( 64'h0,  64'h1);  //Counter variable
        initset( 64'h8,  64'ha);  //Part of mask
        initset( 64'h10, 64'h5);  //Other part of mask
        initset( 64'h18, 64'h0ffbea7deadbeeff); //big constant
        initset( 64'h20, 64'h0); //clearing space

        // Add any data you need for your tests here.

    end

    // This always block reads the data memory and places a double word
    // on the ReadData bus.
    always @(posedge Clock)
    begin
        if(MemoryRead)
        begin
            ReadData[63:56] <= #20 memBank[Address];
            ReadData[55:48] <= #20 memBank[Address+1];
            ReadData[47:40] <= #20 memBank[Address+2];
            ReadData[39:32] <= #20 memBank[Address+3];
            ReadData[31:24] <= #20 memBank[Address+4];
            ReadData[23:16] <= #20 memBank[Address+5];
            ReadData[15:8] <= #20 memBank[Address+6];
            ReadData[7:0] <= #20 memBank[Address+7];
        end
    end

    // This always block takes data from the WriteData bus and writes
    // it into the DataMemory.
    always @(posedge Clock)
    begin
        if(MemoryWrite)
        begin
            memBank[Address] <= #20 WriteData[63:56] ;
            memBank[Address+1] <= #20 WriteData[55:48];
            memBank[Address+2] <= #20 WriteData[47:40];
            memBank[Address+3] <= #20 WriteData[39:32];
            memBank[Address+4] <= #20 WriteData[31:24];
            memBank[Address+5] <= #20 WriteData[23:16];
            memBank[Address+6] <= #20 WriteData[15:8];
            memBank[Address+7] <= #20 WriteData[7:0];
            // Could be useful for debugging:
            // $display("Writing Address:%h Data:%h",Address, WriteData);
        end
    end
endmodule



//instructionMEm
/*
 * Module: InstructionMemory
 *
 * Implements read-only instruction memory
 * 
 */
module InstructionMemory(Data, Address);
   parameter T_rd = 20;
   parameter MemSize = 40;
   
   output [31:0] Data;
   input [63:0]  Address;
   reg [31:0] 	 Data;
   
   /*
    * ECEN 350 Processor Test Functions
    * Texas A&M University
    */
   
   always @ (Address) begin
      case(Address)

	/* Test Program 1:
	 * Program loads constants from the data memory. Uses these constants to test
	 * the following instructions: LDUR, ORR, AND, CBZ, ADD, SUB, STUR and B.
	 * 
	 * Assembly code for test:
	 * 
	 * 0: LDUR X9, [XZR, 0x0]    //Load 1 into x9
	 * 4: LDUR X10, [XZR, 0x8]   //Load a into x10
	 * 8: LDUR X11, [XZR, 0x10]  //Load 5 into x11
	 * C: LDUR X12, [XZR, 0x18]  //Load big constant into x12
	 * 10: LDUR X13, [XZR, 0x20]  //load a 0 into X13
	 * 
	 * 14: ORR X10, X10, X11  //Create mask of 0xf
	 * 18: AND X12, X12, X10  //Mask off low order bits of big constant
	 * 
	 * loop:
	 * 1C: CBZ X12, end  //while X12 is not 0
	 * 20: ADD X13, X13, X9  //Increment counter in X13
	 * 24: SUB X12, X12, X9  //Decrement remainder of big constant in X12
	 * 28: B loop  //Repeat till X12 is 0
	 * 2C: STUR X13, [XZR, 0x20]  //store back the counter value into the memory location 0x20
	 */
	

	63'h000: Data = 32'hF84003E9;
	63'h004: Data = 32'hF84083EA;
	63'h008: Data = 32'hF84103EB;
	63'h00c: Data = 32'hF84183EC;
	63'h010: Data = 32'hF84203ED;
	63'h014: Data = 32'hAA0B014A;
	63'h018: Data = 32'h8A0A018C;
	63'h01c: Data = 32'hB400008C;
	63'h020: Data = 32'h8B0901AD;
	63'h024: Data = 32'hCB09018C;
	63'h028: Data = 32'h17FFFFFD;
	63'h02c: Data = 32'hF80203ED;
	63'h030: Data = 32'hF84203ED;  //One last load to place stored value on memdbus for test checking.

	/* Add code for your tests here */
	
        63'h034: Data = {11'b11010010111,16'h1234,5'h9};//movz x9 1234
        63'h038: Data = {11'b11010010110,16'h5678,5'hA};//movz x10 5678
        63'h03C: Data = {11'bx0x01011xxx,5'hA,6'h0,5'h9,5'h9};//add x9 x9 x10
        63'h040: Data = {11'b11010010101,16'h9abc,5'hA};//movz x10 9abc
        63'h044: Data = {11'bx0x01011xxx,5'hA,6'h0,5'h9,5'h9};//add x9 x9 x10
        63'h048: Data = {11'b11010010100,16'hdef0,5'hA};//movz x10 5678
        63'h04C: Data = {11'bx0x01011xxx,5'hA,6'h0,5'h9,5'h9};//add x9 x9 x10
        63'h050: Data = {11'bxx111000000,9'h28,2'h0,5'd31,5'h9};//stur x9 [xzr,0x28]
        63'h054: Data = {11'bxx111000010,9'h28,2'h0,5'd31,5'h10};//ldur x10, [xzr, 0x28]		
        63'h058: Data = {11'bxx111000010,9'h28,2'h0,5'd31,5'h10};//ldur x10, [xzr, 0x28]
        
			
	default: Data = 32'hXXXXXXXX;
      endcase
   end
endmodule



//nextPC
module NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
      	input [63:0] CurrentPC, SignExtImm64; 
      	input Branch, ALUZero, Uncondbranch; 
      	output reg [63:0] NextPC; 
      	/* write your code here */

  		always@ (Uncondbranch or Branch or ALUZero or SignExtImm64 or CurrentPC)	//when these values change, execute block
        begin
          if(Uncondbranch | (Branch & ALUZero))										//logic for the need to branch in dataflow
           	NextPC = #3 (SignExtImm64 << 2) + CurrentPC;							//nextPC value when branch is taken
          else
           	NextPC = #2 CurrentPC + 4;												//nextPC value when branch is not taken.
        end
endmodule



//regFile
module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
  output [63:0] BusA, BusB;				//output
  input [63:0] BusW;					//inputs
  input [4:0] RA, RB, RW;
  input RegWr, Clk;
  
  reg [63:0] registers [31:0];			//create 32 registers of 64 bits wide
  //initial registers[31] = 0;			//make reg[31] = 0
  
  assign #2 BusA = (RA==31)?0: registers[RA];		//dataflow for output A
  assign #2 BusB = (RB==31)?0: registers[RB];		//dataflow for output B
  
  always @ (negedge Clk) begin			//on the neg clock edge, if you need to write and its not reg[31], do it.
    if(RegWr)begin 
      if(RW != 5'd31)
        registers[RW] <= #3 BusW; end
    end
endmodule




//control
`define OPCODE_ANDREG 11'b?0001010???
`define OPCODE_ORRREG 11'b?0101010???
`define OPCODE_ADDREG 11'b?0?01011???
`define OPCODE_SUBREG 11'b?1?01011???

`define OPCODE_ADDIMM 11'b?0?10001??? 
`define OPCODE_SUBIMM 11'b?1?10001???

`define OPCODE_MOVZ   11'b110100101??

`define OPCODE_B      11'b?00101?????
`define OPCODE_CBZ    11'b?011010????

`define OPCODE_LDUR   11'b??111000010
`define OPCODE_STUR   11'b??111000000

module control(
    output reg reg2loc,
    output reg alusrc,
    output reg mem2reg,
    output reg regwrite,
    output reg memread,
    output reg memwrite,
    output reg branch,
    output reg uncond_branch,
    output reg [3:0] aluop,
  output reg [2:0] signop,
    input [10:0] opcode
);

always @(*)
begin
    casez (opcode)

        /* Add cases here for each instruction your processor supports */
		
		`OPCODE_ANDREG : begin
			reg2loc       <= 1'b0;
            alusrc        <= 1'b0;
            mem2reg       <= 1'b0;
            regwrite      <= 1'b1;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= `AND;
            signop        <= 3'bxx;
		end
		
		`OPCODE_ORRREG: 
		begin
			reg2loc       <= 1'b0;
            alusrc        <= 1'b0;
            mem2reg       <= 1'b0;
            regwrite      <= 1'b1;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= `OR;
            signop        <= 3'bxx;
		end
		
		11'b?0?01011??? : 
		begin
			reg2loc       <= 1'b0;
            alusrc        <= 1'b0;
            mem2reg       <= 1'b0;
            regwrite      <= 1'b1;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0010;
            signop        <= 3'bxx;
		end
		
		11'b?1?01011??? : 
		begin
			reg2loc       <= 1'b0;
            alusrc        <= 1'b0;
            mem2reg       <= 1'b0;
            regwrite      <= 1'b1;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0110;
            signop        <= 3'bxx;
		end
		
		11'b?0?10001??? : 			
		begin
			reg2loc       <= 1'bx;
            alusrc        <= 1'b1;
            mem2reg       <= 1'b0;
            regwrite      <= 1'b1;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0010;
            signop        <= 3'b00;
		end
		
		11'b?1?10001??? : 				
		begin
			reg2loc       <= 1'bx;
            alusrc        <= 1'b1;
            mem2reg       <= 1'b0;
            regwrite      <= 1'b1;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0110;
            signop        <= 3'b00;
		end
		
		11'b110100101?? : 
		begin
			reg2loc       <= 1'bx;
            alusrc        <= 1'b1;
            mem2reg       <= 1'b0;
            regwrite      <= 1'b1;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0111;//passb
          signop        <= {1'b1, opcode[1:0]};
		end
		
		11'b?00101????? :
		begin
			reg2loc       <= 1'bx;
            alusrc        <= 1'b0;
            mem2reg       <= 1'bx;
            regwrite      <= 1'b0;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b1;
            aluop         <= 4'b0111;
            signop        <= 3'b10;
		end
		
		11'b?011010???? :
		begin
			reg2loc       <= 1'b1;
            alusrc        <= 1'b0;
            mem2reg       <= 1'bx;
            regwrite      <= 1'b0;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b1;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0111;
            signop        <= 3'b11;
		end
		
		11'b??111000010 : 
		begin
			reg2loc       <= 1'bx;
            alusrc        <= 1'b1;
            mem2reg       <= 1'b1;
            regwrite      <= 1'b1;
            memread       <= 1'b1;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0010;
            signop        <= 3'b01;
		end
		
		11'b??111000000 : 
		begin
			reg2loc       <= 1'b1;
            alusrc        <= 1'b1;
            mem2reg       <= 1'bx;
            regwrite      <= 1'b0;
            memread       <= 1'b0;
            memwrite      <= 1'b1;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'b0010;
            signop        <= 3'b01;
		end
		
        default :
        begin
            reg2loc       <= 1'bx;
            alusrc        <= 1'bx;
            mem2reg       <= 1'bx;
            regwrite      <= 1'b0;
            memread       <= 1'b0;
            memwrite      <= 1'b0;
            branch        <= 1'b0;
            uncond_branch <= 1'b0;
            aluop         <= 4'bxxxx;
            signop        <= 3'bxx;
        end
    endcase
end

endmodule