module NextPCLogic(
    output reg [63:0] NextPC,
    input      [63:0] CurrentPC,
    input      [63:0] SignExtImm64,
    input             Branch,
    input             ALUZero,
    input             Uncondbranch
);

	always@ (Uncondbranch or Branch or ALUZero or SignExtImm64 or CurrentPC)	//when these values change, execute block
	begin
		if(Uncondbranch | (Branch & ALUZero))										//logic for the need to branch in dataflow
		   	NextPC = #3 (SignExtImm64 << 2) + CurrentPC;							//nextPC value when branch is taken
		else
		   	NextPC = #2 CurrentPC + 4;												//nextPC value when branch is not taken.
	end

endmodule
