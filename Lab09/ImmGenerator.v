module SignExtender(BusImm, Imm26, Ctrl);
	output reg [63:0] BusImm;
	input [25:0] Imm26;
  	input [2:0] Ctrl;
	
	//wire extBit;
  	//assign #1 extBit = (Ctrl ? 1'b0 : Imm26[25]); //if Ctrl is 1, extend 0's. else extend 25th bit
  	//assign BusImm [63:0] = {{38{extBit}}, Imm26[25:0]};
  	
  
  	always@(Ctrl or Imm26)
    	case(Ctrl)
          3'b000 : BusImm [63:0] = {{52{Imm26[21]}},Imm26[21:10]}; //i type
          3'b001 : BusImm [63:0] = {{55{Imm26[20]}},Imm26[20:12]}; //d type
          3'b010 : BusImm [63:0] = {{38{Imm26[25]}},Imm26[25:0]}; //b type
          3'b011 : BusImm [63:0] = {{45{Imm26[23]}},Imm26[23:5]}; //cb type
          3'b100 : BusImm [63:0] = {{48{1'b0}},{Imm26[20:5]}};
          3'b101 : BusImm [63:0] = {{32{1'b0}},{Imm26[20:5]},{16{1'b0}}};
          3'b110 : BusImm [63:0] = {{16{1'b0}},{Imm26[20:5]},{32{1'b0}}};
          3'b111 :	BusImm [63:0] = {{Imm26[20:5]},{48{1'b0}}};
        endcase
endmodule
