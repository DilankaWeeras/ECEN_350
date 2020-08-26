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
