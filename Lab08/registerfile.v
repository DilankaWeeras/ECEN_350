module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
  output [63:0] BusA, BusB;				//output
  input [63:0] BusW;					//inputs
  input [4:0] RA, RB, RW;
  input RegWr, Clk;
  
  reg [63:0] registers [31:0];			//create 32 registers of 64 bits wide
  initial registers[31] = 0;			//make reg[31] = 0
  
  assign #2 BusA = registers[RA];		//dataflow for output A
  assign #2 BusB = registers[RB];		//dataflow for output B
  
  always @ (negedge Clk) begin			//on the neg clock edge, if you need to write and its not reg[31], do it.
    if(RegWr)
      if(RW != 31)
      		registers[RW] <= #3 BusW;
      registers[31] <= #3 0;	
    end
endmodule
