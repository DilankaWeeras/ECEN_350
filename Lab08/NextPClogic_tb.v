module NextPClogic_tb();
  reg [63:0] CurrentPC, SignExtImm64;
  reg Branch, ALUZero, Uncondbranch;
  wire [63:0] NextPC;
  
  NextPClogic dut(.NextPC(NextPC), .CurrentPC(CurrentPC), .SignExtImm64(SignExtImm64), .Branch(Branch), .ALUZero(ALUZero), .Uncondbranch(Uncondbranch));	
  //initialize the test module.
  initial begin
  
  $dumpfile("dump.vcd");
  	$dumpvars(1);
    //test 1
	CurrentPC = 10; SignExtImm64 = 20; Branch = 0; ALUZero = 0; Uncondbranch = 1; #10
    if(NextPC != 90)
      $display("test 1 failed");
    else
      $display("test 1 passed:\nCurrentPC: %h\nSignExtImm64: %h\nBranch: %d\tALUZero: %d\tUncondbranch: %d\nNextPC: %h\n\n", CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch, NextPC);
    //test2
    CurrentPC = 10; SignExtImm64 = 20; Branch = 1; ALUZero = 1; Uncondbranch = 0; #10
    if(NextPC != 90)
      $display("test 2 failed");
    else
      $display("test 2 passed:\nCurrentPC: %h\nSignExtImm64: %h\nBranch: %d\tALUZero: %d\tUncondbranch: %d\nNextPC: %h\n\n", CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch, NextPC);
    //test3
    CurrentPC = 10; SignExtImm64 = 20; Branch = 1; ALUZero = 0; Uncondbranch = 1; #10
    if(NextPC != 90)
      $display("test 3 failed");
    else
      $display("test 3 passed:\nCurrentPC: %h\nSignExtImm64: %h\nBranch: %d\tALUZero: %d\tUncondbranch: %d\nNextPC: %h\n\n", CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch, NextPC);
    //test4
    CurrentPC = 10; SignExtImm64 = 20; Branch = 1; ALUZero = 0; Uncondbranch = 0; #10
    if(NextPC != 14)
      $display("test 4 failed");
    else
      $display("test 4 passed:\nCurrentPC: %h\nSignExtImm64: %h\nBranch: %d\tALUZero: %d\tUncondbranch: %d\nNextPC: %h\n\n", CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch, NextPC);
    //test5
    CurrentPC = 10; SignExtImm64 = 20; Branch = 0; ALUZero = 0; Uncondbranch = 0; #10
    if(NextPC != 14)
      $display("test 5 failed");
    else
      $display("test 5 passed:\nCurrentPC: %h\nSignExtImm64: %h\nBranch: %d\tALUZero: %d\tUncondbranch: %d\nNextPC: %h\n\n", CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch, NextPC);
    
  end
endmodule