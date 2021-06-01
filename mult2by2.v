
`timescale 1ns/1ns
module mult2bit(input [1:0]a, b, output [3:0]c);
	
  wire a0, a1, b0, b1, i, j, k, l, m, n;
  wire t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;

  AND and1(c[0], a[0], b[0]);
  
  NOT inv1(a0, a[0]);
  NOT inv2(a1, a[1]);
  NOT inv3(b0, b[0]);
  NOT inv4(b1, b[1]);
  
  AND and21(t1, b1, b[0]);
  AND and22(i, a[1], t1);
  AND and31(t2, a[0], b[1]);
  AND and32(j, a1, t2);
  AND and41(t3, b[1], b0);
  AND and42(k, a[0], t3);
  AND and51(t4, a0, b[0]);
  AND and52(l, a[1], t4);
  OR or11(t5, k, l);
  OR or12(t6, i, j);
  OR or13(c[1], t5, t6);
  
  AND and61(t7, a0, b[1]);
  AND and62(m, a[1], t7);
  AND and71(t8, b[1], b0);
  AND and72(n, a[1], t8);
  OR or2(c[2], m, n);
  
  AND and81(t9, b[0], b[1]);
  AND and82(t10, a[0], a[1]);
  AND and83(c[3], t9, t10);

endmodule


module mult2TB();
	reg [1:0] a, b;
	wire [3:0] c;
	mult2bit mul(a, b, c);

	integer i = 0;
	integer j = 0;
	integer true = 0;
  	initial begin
	#10
    	a = 2'b00;
    	b = 2'b00;
    	for (i = 0; i < 4; i = i + 1) begin
         for ( j = 0; j < 4; j = j + 1) begin
	    #10
            $display(" my answer = %d  golden result = %d",c,j*i);
            if (c == j*i) true = true + 1;
            a = a + 1;
         end
         b = b + 1;
    	end
    	$display("right results = %d",true);
    #400
    $stop;
  end

endmodule