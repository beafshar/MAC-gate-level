


// --------------------- Complex multiplier --------------------- 

module complexmult4to4DP(input[7:0] a, b, input init_rst, sela, selb, sel2,rst, clk, ld, ldout, ldu, ldd, mult_start,
		output[15:0] out, output mult_ready);
	wire [7:0] a_out, b_out, mult_out, twos_out, mux_out, add_out, temp_out;
	
	wire [3:0] mux_aout, mux_bout;
	wire cout;
	reg8bit areg(clk, rst, ld, a, a_out);
	reg8bit breg(clk, rst, ld, b, b_out);

	mux4bit2to1 amux(a_out[3:0], a_out[7:4], sela, mux_aout);
	mux4bit2to1 bmux(b_out[3:0], b_out[7:4], selb, mux_bout);
	
	
	multiplier4b mu(.out(mult_out), .ready(mult_ready) , .a(mux_aout), .b(mux_bout), .start(mult_start)
		, .clk(clk), .init_rst(init_rst));
	

	twosComplement twosc(mult_out, twos_out);

	mux8bit2to1 mux8bit(twos_out, mult_out, sel2, mux_out);
	
	adder8bit adder(mux_out, temp_out, add_out, cout);

	reg8bit reg_out(clk, rst, ld_out, add_out, temp_out);

	reg16bit reg_out16(clk, rst, ldu, ldd, temp_out,  out);



endmodule

module complexmult4to4CU(input start, clk, mult_ready, output reg sela, selb, sel2,rst, ld, ldout, ldu, ldd,init_rst, ready, mult_start);
	reg[3:0] ns, ps;
	
	always @(ps, start)begin
		ns = 3'b 000;
		{sela, selb, sel2,rst, ld, ldout, ldu, ldd, ready, mult_start,init_rst} = 11'b 00000000000;
		case(ps)
			4'b 0000: begin ns = start? 4'b 0001: 3'b 0000; ready = 1'b 1; end
			4'b 0001: begin ns = 4'b 0010; rst = 1'b 1; end
			4'b 0010: begin ns = 4'b 0011; ld = 1'b 1; init_rst = 1'b 1; end
			4'b 0011: begin ns = 4'b 0100; {sela, selb, sel2, ldout, mult_start} = 5'b 11011; end
			4'b 0100: begin ns = mult_ready? 4'b 0101: 4'b 0100; end
			4'b 0101: begin ns = 4'b 0110; {sela, selb, sel2, ldout, mult_start} = 5'b 00111; end
			4'b 0110: begin ns = mult_ready? 4'b 0111: 4'b 0110; end
			4'b 0111: begin ns = 4'b 1000; {sela, selb, sel2, ldu, ldout, mult_start} = 6'b 100111; end
			4'b 1000: begin ns = mult_ready? 4'b 1001: 4'b 1000; end
			4'b 1001: begin ns = 4'b 1010; {sela, selb, sel2, ldout, mult_start} = 5'b 01011; end
			4'b 1010:begin ns = mult_ready? 4'b 1011: 4'b 1010; end
			4'b 1011: begin ns = 4'b 0000; ldd = 1'b 1; end
		endcase
	end
	always @(posedge clk) begin
		ps <= ns;
	end

endmodule

module complexmult4to4(input clk, start, input[7:0] a, b, output ready, output[15:0] out);
	wire sela, selb, sel2,rst, ld, ldout, ldu, ldd, mult_start, mult_ready, init_rst;
	complexmult4to4DP dp(a, b,init_rst,sela, selb, sel2,rst, clk, ld, ldout, ldu, ldd, mult_start, out, mult_ready);
	complexmult4to4CU cu(start, clk,mult_ready,sela, selb, sel2,rst, ld, ldout, ldu, ldd,init_rst, ready, mult_start);

endmodule


module complexmultiplierTB();
	reg [7:0] a, b;
	reg clk;
	reg start;
	wire [15:0] out;
	wire finish;

	complexmult4to4 mult8b(clk, start,a, b,  finish, out);

	always @(*) begin
		repeat(5000)
			#5 clk = ~clk;
	end

	initial begin
		clk = 0;
		start = 0;
		a = 8'b0110_0111;
		b = 8'b0101_0011;
		#20 start = 1;
		#20 start = 0;
	end
endmodule
