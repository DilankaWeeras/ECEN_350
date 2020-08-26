module Mux21(out, in, sel);

    output out;
    input [1:0]in, sel;

    wire W, X, Y;

    and and1(X, in[0], switch);
    not not1(W, switch);
    and and2(Y, W, in[1]);
    or or1(out, X, Y);

endmodule