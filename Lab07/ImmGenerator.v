`timescale 1ns / 1ps
module ImmGenerator(Imm64, Imm26, Ctrl);
	output reg [63:0] Imm64;
	input [25:0] Imm26;
	input [1:0]Ctrl;

	wire extBit;


always @(*)begin
	if(Ctrl == 2'b00)begin //ADDI SUBI
		Imm64 = {{52{1'b0}},Imm26[21:10]};
	end
	else if(Ctrl == 2'b01)begin // LDUR STUR
		Imm64 = {{55{Imm26[20]}}, Imm26[20:12]};
	end
	else if(Ctrl == 2'b10)begin // B
		Imm64 = {{38{Imm26[25]}}, Imm26};
	end
	else begin// CBZ 2'b11
		Imm64 = {{45{Imm26[23]}}, Imm26[23:5]};
	end
end
endmodule
