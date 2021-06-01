
// --------------------- multiplexers --------------------- 

module mux1bit2to1(input a, b, input sel, output out);
	wire sel_not;
	wire w[1:0];
	not(sel_not, sel);
	and(w[0], a, sel);
	and(w[1], b, sel_not);
	or(out, w[0], w[1]);
endmodule

module mux2bit2to1(input [1:0] a, b, input s, output [1:0] w);
    wire [1:0] tmp0, tmp1;
    wire n_s;

    not(n_s, s);

    and(tmp0[0], a[0], n_s);
    and(tmp0[1], b[0], s);
    and(tmp1[0], a[1], n_s);
    and(tmp1[1], b[1], s);

    or(w[0], tmp0[0], tmp0[1]);
    or(w[1], tmp1[0], tmp1[1]);

endmodule

module mux8bit2to1( input [7:0] a, b, input s, output [7:0] w);
    mux2bit2to1 mux0( a[1:0], b[1:0], s, w[1:0]);
    mux2bit2to1 mux1( a[3:2], b[3:2], s,w[3:2]);
    mux2bit2to1 mux2( a[5:4], b[5:4], s, w[5:4]);
    mux2bit2to1 mux3( a[7:6], b[7:6], s, w[7:6]);
endmodule
module mux2bit2to111(input [1:0] a, b, input sel, output [1:0] out);
	genvar i;
	generate for(i=0; i<2; i=i+1) begin
		mux1bit2to1 mux(a[i], b[i], sel, out[i]);
		end
	endgenerate
endmodule

module mux4bit2to1(input [3:0] a, b, input sel, output [3:0] c);
	mux2bit2to1 LSB({a[1], a[0]}, {b[1], b[0]},sel, {c[1], c[0]});
	mux2bit2to1 MSB({a[3], a[2]}, {b[3], b[2]},sel, {c[3], c[2]});
	
endmodule

module mux1b4to1(input [1:0]sel, input a, b, c, d, output out);
	wire [1:0]nsel;

	not(nsel[0], sel[0]);
	not(nsel[1], sel[1]);	
	and(tempa, a, nsel[1], nsel[0]);
	and(tempb, b, nsel[1], sel[0]);
	and(tempc, c, sel[1], nsel[0]);
	and(tempd, d, sel[1], sel[0]);

	or(out, tempa, tempb, tempc, tempd);
endmodule

module mux8bit4to1(input [1:0]sel, input[7:0] a, b, c, d, output [7:0]out);
	genvar i;
	generate for(i=0; i<8; i=i+1) begin: mux
			mux1b4to1 mu(sel, a[i], b[i], c[i], d[i], out[i]);
		end
	endgenerate
endmodule


