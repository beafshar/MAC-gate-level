
// --------------------- MAC --------------------- 

module MACdp(input[31:0] X, Y, input clk, rst, ld_in, start, input[1:0] sel, output ready, output [19:0] out);
  wire[7:0] X1, X2, X3, X4, Y1, Y2, Y3, Y4, a, b,
            temp1, temp2, temp3, temp4;
  wire[15:0] multout;
  
  wire cout, cout1;
  wire[9:0] realout, imagout, real_adr_out, imag_adr_out, realtemp, imagtemp;
  
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

  assign realtemp = {2'b 00, multout[7:0]};
  assign imagtemp = {2'b 00, multout[15:8]};

  
  

  adder10bit adr(realtemp, realout, real_adr_out, cout);
  adder10bit adr1(imagtemp, imagout, imag_adr_out, cout1);

  reg10bit outreg(clk, rst, real_adr_out, realout);
  reg10bit outreg1(clk, rst, imag_adr_out, imagout);

  assign out = {realout, imagout};
endmodule


module MACcu(input clk, start, mult_ready, output reg [1:0] sel, output reg ready, reg_rst, ld_in, mult_start);
	reg[3:0] ns, ps;
	
	always @(ps, start)begin
		ns = 4'b 0000;
		{ready, mult_start, sel} = 4'b 0000;
		case(ps)
			4'b 0000: begin ns = start? 4'b 0001: 4'b 0000; ready = 1'b 1;  end
			4'b 0001: begin ns = 4'b 0010; {reg_rst, ld_in} = 2'b 11; end 
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

module MAC(input[31:0] X, Y, input clk, start, output ready, output [19:0] out);
	wire[1:0] sel;
	wire reg_rst, ld_in, mult_start, mult_ready;

	MACdp dp(X, Y, clk, reg_rst, ld_in, mult_start, sel, mult_ready, out);
	MACcu cu(clk, start, mult_ready, sel, ready, reg_rst,ld_in, mult_start);

endmodule


module MACTB();
    reg[31:0] X, Y;
    reg clk;
    reg start;
    wire finish;
    wire [19:0]out; 

    MAC mac(X,Y, clk, start, finish, out);

    always @(*) begin
        repeat(5000)
            #5 clk = ~clk;
    end

    initial begin
	X = 32'b 0001_0011_0101_0011_0010_0101_0111_0000;
	Y = 32'b 0011_0101_0001_0100_0010_0101_0111_0000;
        

        start = 0;
        clk = 0;
        #20 start = 1;
		#20 start = 0;
    end

endmodule
