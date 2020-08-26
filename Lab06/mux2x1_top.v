module mux2x1_top(OUT, A, B, switch);

    output OUT;
    input A, B, switch;

    mux2x1 mux1(OUT, A, B, switch);
endmodule