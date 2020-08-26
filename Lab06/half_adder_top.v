module half_adder_top(SUM, CARRY, A, B);

    output SUM, CARRY;
    input A, B;

    half_adder add1(SUM, CARRY, A, B);
endmodule