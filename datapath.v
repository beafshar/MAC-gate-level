
// --------------------- 2*2 multiplier --------------------- 
module mult2bit(input [1:0]a, b, output [3:0]c);
	wire [1:0] b_not, a_not;
	wire w[5:0];
	not(b_not[1], b[1]);
	not(b_not[0], b[0]);
	not(a_not[1], a[1]);
	not(a_not[0], a[0]);


	and(c[0],a[0],b[0]);
	
	and(w[0],a[1],b_not[1],b[0]);
	and(w[1],a_not[1],b[1],a[0]);
	and(w[2],a[0],b_not[0],b[1]);
	and(w[3],a[1],a_not[0],b[0]);

	or(c[1],w[0],w[1],w[2],w[3]);

	and(w[4], a[1], a_not[0], b[1]);
	and(w[5], a[1], b_not[0], b[1]);
	
	or(c[2], w[4], w[5]);
	
	and(c[3], a[1], a[0], b[1], b[0]);


endmodule

// --------------------- registers --------------------- 

module reg4bit(input clk, rst, en, input[3:0] in, output reg [3:0] out);
	initial begin
		out <= 0;
	end

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else if(en)
			out <= in;
	end
endmodule

module reg8bit(input clk, rst, en, input[7:0] in, output reg [7:0] out);
	initial begin
		out <= 0;
	end

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else if(en)
			out <= in;
	end
endmodule

// --------------------- multiplexers --------------------- 

module mux1bit2to1(input a, b, input sel, output out);
	wire sel_not;
	wire w[1:0];
	not(sel_not, sel);
	and(w[0], a, sel);
	and(w[1], b, sel_not);
	or(out, w[0], w[1]);
endmodule

module mux2bit2to1(input [1:0] a, b, input sel, output [1:0] out);
	genvar i;
	generate for(i=0; i<2; i=i+1) begin
		mux1bit2to1 mux(a[i], b[i], sel, out[i]);
		end
	endgenerate
endmodule

module mux4bit2to1(input [3:0] a, b, input sel, output [3:0] out);
	genvar i;
	generate for(i=0; i<4; i=i+1) begin
		mux1bit2to1 mux(a[i], b[i], sel, out[i]);
		end
	endgenerate
endmodule

module mux8bit2to1(input [7:0] a, b, input sel, output [7:0] out);
	genvar i;
	generate for(i=0; i<8; i=i+1) begin
		mux1bit2to1 mux(a[i], b[i], sel, out[i]);
		end
	endgenerate
endmodule
// --------------------- sign extend --------------------- 
module SE4to8bit(input[3:0]in , output[7:0] out);
	supply1 one;
	genvar i;
	generate for(i=0; i<4; i=i+1) begin
		and(out[i], in[i], one);
		end
	endgenerate
	genvar j;
	generate for(j=4; j<8; j=j+1) begin
		and(out[j], in[3], one);
		end
	endgenerate
endmodule


// --------------------- adders --------------------- 

module FA(input a, b, cin, output cout, s);
	wire a1, a2, a3;    
	xor(a1,a,b);
 	and(a2,a,b);
	and(a3,a1,cin);
	or(cout,a2,a3);
	xor(s,a1,cin); 

endmodule

module adder8bit(input[7:0] a, b, output[7:0] out, output cout);
	wire [6:0] cin;
	supply0 zero;

	FA fa0(a[0], b[0], zero,cin[0], out[0]);
	genvar i;
	generate for (i = 1; i < 7; i = i + 1) begin: adder
		FA fa(a[i], b[i], cin[i-1], cin[i], out[i]);
	end
	endgenerate
	FA fa7(a[7], b[7], cin[6],cout, out[7]);

endmodule

// --------------------- 4*4 multiplier --------------------- 

module mult4bit (input [3:0] a, b, sela, selb, rst, clk, ld, selo, output [7:0] out);
	reg [3:0] a_out, b_out, a_mux_out, b_mux_out, mult_out;
	reg [7:0] se_out, mux2_out, add_out;
	reg cout;
	// ld a bahaman?
	reg4bit areg(clk, rst, ld, a, a_out);
	reg4bit breg(clk, rst, ld, a, a_out);

	mux2bit2to1 amux(a_out[3:2], a_out[1:0], sela, a_mux_out);
	mux2bit2to1 bmux(b_out[3:2], b_out[1:0], selb, b_mux_out);

	mult2bit mult(a_mux_out, b_mux_out, mult_out);

	SE4to8bit se(mult_out , se_out);
		
	adder8bit adder(se_out, mux2_out, add_out, cout);


	reg8bit outreg(clk, rst, ld, add_out, out);
	// in shifteresho nazadam
	mux8bit2to1 mux2(out, {2'b0, out[7:1]}, sel_o, mux2_out);


endmodule