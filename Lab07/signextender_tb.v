`timescale 1ns / 1ps
`define STRLEN 20

module ImmGeneratorTest;

    task passTest;
        input [63:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;
        inout [7:0] passed;

    if(actualOut == expectedOut)
    begin
        $display ("%s passed", testType); passed = passed + 1;
    end
    else
        $display ("%s failed: %x should be %x", testType, actualOut, expectedOut);
    endtask

    task allPassed;
        input [7:0] passed;
        input [7:0] numTests;

        if(passed == numTests) $display ("All tests passed");
        else $display("Some tests failed");
    endtask

    // Inputs
    reg [25:0] Imm;
    reg [7:0] passed;
    reg [1:0] SignOp;

    // Outputs
    wire [63:0] BusImm;

    // Instantiate the Device Under Test (DUT)
    ImmGenerator dut (
        .Imm64(BusImm),
        .Imm26(Imm),
        .Ctrl(SignOp)
    );

    initial begin
        // Initialize Inputs
        Imm = 0;
        passed = 0;

        // ADDI (opcode: 1001000100)
        #10; {SignOp, Imm} = {2'b00, 26'b0100_000000001100_0001000000}; #10; 
            passTest(BusImm, 64'b0000000000000000000000000000000000000000000000000000000000001100, "IMM Test 1", passed);
        // SUBI (opcode: 1101000100)
        #10; {SignOp, Imm} = {2'b00, 26'b0100_111111111111_0000100001}; #10; 
            passTest(BusImm, 64'b0000000000000000000000000000000000000000000000000000111111111111, "IMM Test 2", passed);

        // STUR (opcode: 11111000000)
        #10; {SignOp, Imm} = {2'b01, 26'b00000_100001111_000010000001}; #10; 
            passTest(BusImm, 64'b1111111111111111111111111111111111111111111111111111111100001111, "MEM Test 1", passed);
        // LDUR (opcode: 11111000010)
        #10; {SignOp, Imm} = {2'b01, 26'b00010_000101000_000000110011}; #10; 
            passTest(BusImm, 64'b0000000000000000000000000000000000000000000000000000000000101000, "MEM Test 2", passed);

        // B (opcode: 000101)
        #10; {SignOp, Imm} = {2'b10, 26'b00000000000000000000000010}; #10; 
            passTest(BusImm, 64'b0000000000000000000000000000000000000000000000000000000000000010, "Branch Test 1", passed);
        #10; {SignOp, Imm} = {3'b10, 26'b11111111111111111111111100}; #10; 
            passTest(BusImm, 64'b1111111111111111111111111111111111111111111111111111111111111100, "Branch Test 2", passed);

        // CBZ  (opcode: 10110100)
        #10; {SignOp, Imm} = {2'b11, 26'b00_0000000000000000010_00001}; #10; 
            passTest(BusImm, 64'b0000000000000000000000000000000000000000000000000000000000000010, "CBZ Test 1", passed);
        #10; {SignOp, Imm} = {2'b11, 26'b00_1111111111111111110_00010}; #10; 
            passTest(BusImm, 64'b1111111111111111111111111111111111111111111111111111111111111110, "CBZ Test 2", passed);
        #10;

        allPassed(passed, 8);
    end

endmodule

