`timescale 1ns/1ns
module adder_1(input a, b, ci, output s, co);
  wire i, j, k;
  XOR xor1(i, a, b);
  XOR xor2(s, i, ci);
  AND and1(j, a, b);
  AND and2(k, i, ci);
  OR or1(co, j, k);

endmodule


module adder8bit(input [7:0]a, input [7:0]b, output [7:0]s);
  
  supply0 Gnd;
  wire [7:0]co;
  adder_1 add1(a[0], b[0], Gnd, s[0], co[0]);
  genvar i;
  generate 
        for (i = 1; i < 8; i = i + 1) begin: add
            adder_1 add2(a[i], b[i], co[i-1], s[i], co[i]);
        end
  endgenerate
  
endmodule

// --------------------- adders --------------------- 
module FA(output w, co, input a, b, ci);
    wire tmp_xor;
    wire [1:0] tmp_and;

    xor(tmp_xor, a, b);
    xor(w, tmp_xor, ci);
    and(tmp_and[0], tmp_xor, ci);
    and(tmp_and[1], a, b);
    or(co, tmp_and[0], tmp_and[1]);
endmodule


module adder8bit1(input[7:0] a, b, output[7:0] w, output co);
    wire [6:0] c;
    supply0 zero;

    FA fa0(w[0], c[0], a[0], b[0], zero);
    genvar i;
    generate 
        for (i = 1; i < 7; i = i + 1) begin: adderw
            FA fa(w[i], c[i], a[i], b[i], c[i-1]);
        end
    endgenerate

    FA fa7(w[7], co, a[7], b[7], c[6]);
endmodule


module adder10bit(input[9:0] a, b, output[9:0] w, output co);
	wire [8:0] c;
    	supply0 zero;

    	FA fa0(w[0], c[0], a[0], b[0], zero);
    	genvar i;
    	generate for (i = 1; i < 9; i = i + 1) begin: adderw
            FA fa(w[i], c[i], a[i], b[i], c[i-1]);
        end
    endgenerate

    FA fa9(w[9], co, a[9], b[9], c[8]);

endmodule

