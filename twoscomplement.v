// --------------------- 2's complement --------------------- 
module twosComplement(input [7:0] in, output[7:0] out);
	wire[7:0] first_complement;
	wire cout;
	
	genvar i;
	generate for (i = 1; i < 7; i = i + 1) begin: inverter
		not(first_complement[i], in[i]);
	end
	endgenerate
	
	adder8bit adder(first_complement, 8'b 00000001,out, cout);
endmodule
