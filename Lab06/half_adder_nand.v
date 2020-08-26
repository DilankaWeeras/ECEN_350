module HalfAdd(Cout,Sum,A,B);

    input wire A,B; //inputs a,b,c,d
    output wire Sum, Cout; // outputs E,F

    wire X,Y,Z; // internal nets XYZ

    nand NAND1(X, A, B); //create x
    nand NAND2(Y, A, X); //create y
    nand NAND3(Z, B, X); //create z

    nand NAND4(Sum, Y, Z); // create sum
    nand NAND5(Cout, X, X); // create carry

endmodule