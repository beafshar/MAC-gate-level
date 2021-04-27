
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

module reg16bit(input clk, rst, ldu, ldd, input[7:0] in, output reg [15:0] out);
	initial begin
		out <= 0;
	end

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else if(ldu)
			out[15:8] <= in;
		else if (ldd)
			out[7:0] <= in;
		
	end
endmodule

module reg20bit(input clk, rst, input[19:0] in, output reg [19:0] out);
	initial begin
		out <= 0;
	end

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else
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

module SE16bit(input [15:0] in,output[19:0] out);

  assign out = {2'b 00,in, 2'b 00};
  
endmodule

// --------------------- shifter --------------------- 
  
module shiftL2 (input[7:0] in ,output[7:0] out);
  assign out = {in[5:0],2'b00};
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

module adder20bit(input[19:0] a, b, output[19:0] out, output cout);
	wire [18:0] cin;
	supply0 zero;

	FA fa0(a[0], b[0], zero,cin[0], out[0]);
	genvar i;
	generate for (i = 1; i < 19; i = i + 1) begin: adder
		FA fa(a[i], b[i], cin[i-1], cin[i], out[i]);
	end
	endgenerate
	FA fa7(a[19], b[19], cin[18],cout, out[19]);

endmodule

// --------------------- 4*4 multiplier --------------------- 

module mult4bitDP (input [3:0] a, b, input sela, selb, rst, clk, ld, selo, output[7:0] out);
	wire [3:0] a_out, b_out, mult_out;
	wire [1:0] a_mux_out, b_mux_out;
	wire [7:0] se_out, mux2_out, add_out, shift_out;
	wire cout;
	
	reg4bit areg(clk, rst, ld, a, a_out);
	reg4bit breg(clk, rst, ld, a, a_out);

	mux2bit2to1 amux(a_out[3:2], a_out[1:0], sela, a_mux_out);
	mux2bit2to1 bmux(b_out[3:2], b_out[1:0], selb, b_mux_out);

	mult2bit mult(a_mux_out, b_mux_out, mult_out);

	SE4to8bit se(mult_out , se_out);
		
	adder8bit adder(se_out, mux2_out, add_out, cout);


	reg8bit outreg(clk, rst, ld, add_out, out);
	//shift left ya right?
	shiftL2 shifter(out ,shift_out);
	mux8bit2to1 mux2(out, shift_out, sel_o, mux2_out);


endmodule

module mult4bitCU (input clk, start, output reg ready, rst, ld, sela, selb, selo);
	reg[2:0] ns, ps;
	
	always @(ps, start)begin
		ns = 3'b 000;
		{rst, ld, sela, selb, selo, ready} = 6'b 000000;
		case(ps)
			3'b 000: begin ns = start? 3'b 001: 3'b 000; ready = 1'b 1; end
			3'b 001: begin ns = 3'b 010; rst = 1'b 1; end
			3'b 010: begin ns = 3'b 011; ld = 1'b 1; end
			3'b 011: begin ns = 3'b 100; {sela, selb, selo} = 3'b 111; end
			3'b 100: begin ns = 3'b 101; {sela, selb, selo} = 3'b 100; end
			3'b 101: begin ns = 3'b 110; {sela, selb, selo} = 3'b 011; end
			3'b 110: begin ns = 3'b 000; {sela, selb, selo} = 3'b 000; end
		endcase
	end
	always @(posedge clk) begin
		ps <= ns;
	end
endmodule

module mult4bit(input clk, start, input [3:0] a, b, output ready, output [7:0] out);
	wire sela, selb, rst, ld, selo;
	mult4bitDP dp(a, b, sela, selb, rst, clk, ld, selo, out);
	mult4bitCU cu(clk, start, ready, rst, ld, sela, selb, selo);

endmodule

module Mult4bitTB();
	reg [3:0]a, b;
	reg clk, start;
	wire finish;
	wire [7:0]out;
	
	mult4bit mult(clk, start, a, b, finish,out);
		
	always@ (*)
		repeat(20000)
			#5 clk = ~clk;
	
	initial begin
		clk = 0;
		start = 0;
		a = 0;
		b = 0;
		#20;
		for(a = 1; a < 16; a = a + 1) begin
			for(b = 1; b < 16; b = b + 1) begin
				start = 1;
				#20 start = 0;
				#100;
				if(finish == 1 && out == a*b)
					$display("wrong answer for a: %d, b: %d, c: %d", a, b, out);

			end
		end
	end

endmodule

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

// --------------------- Complex multiplier --------------------- 

module complexmult4to4DP(input[7:0] a, b, input sela, selb, sel2,rst, clk, ld, ldout, ldu, ldd, mult_start,
		output[16:0] out, output mult_ready);
	wire [7:0] a_out, b_out, mult_out, twos_out, mux_out, add_out;
	wire [3:0] mux_aout, mux_bout;
	wire cout;
	reg8bit areg(clk, rst, ld, a, a_out);
	reg8bit breg(clk, rst, ld, b, b_out);

	mux4bit2to1 amux(a_out[3:0], a_out[7:4], sela, mux_aout);
	mux4bit2to1 bmux(b_out[3:0], b_out[7:4], selb, mux_bout);
	
	
	mult4bit mult(clk, mult_start, mux_aout, mux_bout, mult_ready, mult_out);
	

	twosComplement twosc(mult_out, twos_out);

	mux8bit2to1 mux8bit(twos_out, mult_out, sel2, mux_out);
	
	adder8bit adder(mux_out, temp_out, add_out, cout);

	reg8bit reg_out(clk, rst, ld_out, add_out, temp_out);

	reg16bit reg_out16(clk, rst, ldu, ldd, temp_out,  out);



endmodule

module complexmult4to4CU(input start, clk, mult_ready, output reg sela, selb, sel2,rst, ld, ldout, ldu, ldd, ready, mult_start);
	reg[2:0] ns, ps;
	
	always @(ps, start)begin
		ns = 3'b 000;
		{sela, selb, sel2,rst, ld, ldout, ldu, ldd, ready} = 9'b 000000000;
		case(ps)
			3'b 000: begin ns = start? 3'b 001: 3'b 000; ready = 1'b 1; end
			3'b 001: begin ns = 3'b 010; rst = 1'b 1; end
			3'b 010: begin ns = 3'b 011; ld = 1'b 1; end
			3'b 011: begin ns = 3'b 100; {sela, selb, sel2, ldout} = 4'b 1101; end
			3'b 100: begin ns = 3'b 101; {sela, selb, sel2, ldout} = 4'b 0011; end
			3'b 101: begin ns = 3'b 110; {sela, selb, sel2, ldu, ldout} = 5'b 10011; end
			3'b 110: begin ns = 3'b 111; {sela, selb, sel2, ldout} = 4'b 0101; end
			3'b 111: begin ns = 3'b 000; ldd = 1'b 1; end
		endcase
	end
	always @(posedge clk) begin
		ps <= ns;
	end

endmodule

module complexmult4to4(input clk, start, input[7:0] a, b, output reg ready, output[16:0] out);
	wire sela, selb, sel2,rst, ld, ldout, ldu, ldd, mult_start, mult_ready;
	complexmult4to4DP dp(a, b,sela, selb, sel2,rst, clk, ld, ldout, ldu, ldd, mult_start, out, mult_ready);
	complexmult4to4CU cu(start, clk,sela, selb, sel2,rst, ld, ldout, ldu, ldd, ready);

endmodule


// --------------------- MAC --------------------- 

module MACdp(input[31:0] X, Y, input clk, rst, ld_in, start, input[1:0] sel, output reg ready, output reg [19:0] out);
  reg[7:0] X1, X2, X3, X4, Y1, Y2, Y3, Y4, a, b,
            temp1, temp2, temp3, temp4;
  reg[15:0] multout;
  reg[19:0] se_out, adr_out;
  reg cout;
  
  reg8bit Xreg1(clk, rst, ld_in, X[7:0], X1);
  reg8bit Xreg2(clk, rst, ld_in, X[15:8], X2);
  reg8bit Xreg3(clk, rst, ld_in, X[23:16], X3);
  reg8bit Xreg4(clk, rst, ld_in, X[31:24], X4);
  
  reg8bit Yreg1(clk, rst, ld_in, Y[7:0], Y1);
  reg8bit Yreg2(clk, rst, ld_in, Y[15:8], Y2);
  reg8bit Yreg3(clk, rst, ld_in, Y[23:16], Y3);
  reg8bit Yreg4(clk, rst, ld_in, Y[31:24], Y4);
  
  mux8bit2to1 mux1(X1, X2, sel[1], temp1);
  mux8bit2to1 mux2(X3, X4, sel[1], temp2);
  mux8bit2to1 mux3(temp1, temp2, sel[0], a);
  
  mux8bit2to1 mux4(Y1, Y2, sel[1], temp3);
  mux8bit2to1 mux5(Y3, Y4, sel[1], temp4);
  mux8bit2to1 mux6(temp3, temp4, sel[0], b);
  
  complexmult4to4 mult(clk, start, a, b, ready, multout);
  
  SE16bit se(multout, se_out);
  
  reg20bit outreg(clk, rst, adr_out, out);
  
  adder20bit adr(out, se_out, adrout, cout);
endmodule


module MACcu(input clk, start, mult_ready, output reg [1:0] sel, output reg ready, reg_rst, ld_in, mult_start);
	reg[3:0] ns, ps;
	
	always @(ps, start)begin
		ns = 4'b 0000;
		{ready, mult_start, sel} = 4'b 0000;
		case(ps)
			4'b 0000: begin ns = start? 4'b 0001: 4'b 0000; ready = 1'b 1;  end
			4'b 0001: begin ns = 4'b 0010; {reg_rst, ld_in} = 2'b 11; end // rst ki?
			4'b 0010: begin ns = 4'b 0011; {mult_start, sel} = 3'b 100; end
			4'b 0011: begin ns = mult_ready? 4'b 0100: 4'b 0011; end
			4'b 0100: begin ns = 4'b 0101; {mult_start, sel} = 3'b 101; end
			4'b 0101: begin ns = mult_ready? 4'b 0110: 4'b 0101; end
			4'b 0110: begin ns = 4'b 0111; {mult_start, sel} = 3'b 110; end
			4'b 0111: begin ns = mult_ready? 4'b 1000: 4'b 0111; end
			4'b 1000: begin ns = 4'b 1001; {mult_start, sel} = 3'b 111; end
			4'b 1001: begin ns = mult_ready? 4'b 0000: 4'b 1001; end
		endcase
	end
	always @(posedge clk) begin
		ps <= ns;
	end

endmodule

module MAC(input[31:0] X, Y, input clk, output reg ready, output reg [19:0] out);
	wire[1:0] sel;
	wire reg_rst, ld_in, mult_start, mult_ready;
	// ld in nabudan tu controller
	MACdp dp(X, Y, clk, reg_rst, ld_in, mult_start, sel, mult_ready, out);
	MACcu cu(clk, start, mult_ready, sel, ready, reg_rst, mult_start);

endmodule