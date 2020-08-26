`timescale 1ns / 1ps
`define STRLEN 32
module ALUTest_v;

    task passTest;
        input [64:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;
        inout [7:0] passed;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
        else $display ("%s failed: %x should be %x", testType, actualOut, expectedOut);
    endtask

    task allPassed;
        input [7:0] passed;
        input [7:0] numTests;

        if(passed == numTests) $display ("All tests passed");
        else $display("Some tests failed");
    endtask

    // Inputs
    reg [63:0] BusA;
    reg [63:0] BusB;
    reg [3:0] ALUCtrl;
    reg [7:0] passed;

    // Outputs
    wire [63:0] BusW;
    wire Zero;

    // Instantiate the Unit Under Test (UUT)
    alu uut (
        .busW(BusW),
        .zero(Zero),
        .busA(BusA),
        .busB(BusB),
        .ctrl(ALUCtrl)
    );

    initial begin
        // Initialize Inputs
        BusA = 0;
        BusB = 0;
        ALUCtrl = 0;
        passed = 0;

        // ADD tests
        {BusA, BusB, ALUCtrl} = {64'h82C639269A, 64'h152672E37E, 4'h2}; #40;
        passTest({Zero, BusW}, 65'h097ECAC0A18, "ADD1", passed);

        {BusA, BusB, ALUCtrl} = {64'hFA49D367EB2, 64'hCBCD7A09B01, 4'h2}; #40;
        passTest({Zero, BusW}, 65'h01C6174D719B3, "ADD2", passed);

        // AND tests
        {BusA, BusB, ALUCtrl} = {64'h9C212C90E109EF50, 64'hAF93053C8CA68455, 4'h0}; #40;
        passTest({Zero, BusW}, 65'h08C01041080008450, "AND1", passed);

        {BusA, BusB, ALUCtrl} = {64'h7F0C4B3F, 64'h5A0E7A39, 4'h0}; #40;
        passTest({Zero, BusW}, 65'h05A0C4A39, "AND2", passed);

        // ORR tests
        {BusA, BusB, ALUCtrl} = {64'h9C212C90E109EF50, 64'hAF93053C8CA68455, 4'h1}; #40;
        passTest({Zero, BusW}, 65'h0BFB32DBCEDAFEF55, "ORR1", passed);

        {BusA, BusB, ALUCtrl} = {64'h7F0C4B3F, 64'h5A0E7A39, 4'h1}; #40;
        passTest({Zero, BusW}, 65'h07F0E7B3F, "ORR2", passed);

        // SUB tests
        {BusA, BusB, ALUCtrl} = {64'h7F0C4B3F, 64'h5A0E7A39, 4'b0110}; #40;
        passTest({Zero, BusW}, 65'h024FDD106, "SUB1", passed);

        {BusA, BusB, ALUCtrl} = {64'h82C639269A, 64'h152672E37E, 4'b0110}; #40;
        passTest({Zero, BusW}, 65'h06D9FC6431C, "SUB2", passed);

        // PASS tests
        {BusA, BusB, ALUCtrl} = {64'h7F0C4B3F, 64'h5A0E7A39, 4'h7}; #40;
        passTest({Zero, BusW}, {1'b0,64'h5A0E7A39}, "PASS1", passed);

        {BusA, BusB, ALUCtrl} = {64'h82C639269A, 64'h0, 4'h7}; #40;
        passTest({Zero, BusW}, {1'b1,64'h0}, "PASS2", passed);

        allPassed(passed, 10);
    end

endmodule

