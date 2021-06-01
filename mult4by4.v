

`timescale 1ns/1ns

module mul4datapath(input[3:0]a, input[3:0]b, input rst, clk, ld, s0, s1, s2, output [7:0]c);
  
  wire [3:0] a1, b1, m_out;
  wire [1:0] m_in1, m_in2;
  wire [7:0] sign_out, shift_out, mux_out, add_out;
  
  reg4bit reg4_1(a, clk, rst, ld, a1);
  mux2bit2to1 mux1(a1[3:2], a1[1:0], s0, m_in1);

  reg4bit reg4_2(b, clk, rst, ld, b1);
  mux2bit2to1 mux2(b1[3:2], b1[1:0], s1, m_in2);

  mult2bit mult(m_in1, m_in2, m_out);
  zeroExtend ext(sign_out,m_out);
  left2Shift8b shl(shift_out, c);

  mux8bit2to1 mux3(c, shift_out, s2, mux_out);
  adder8bit add(sign_out, mux_out, add_out);
  reg8bit reg8(add_out, clk, rst, ld, c);
  
endmodule
module mul4controller(input start, clk, enable, output rst, ld, s0, s1, s2);

    wire A, B, C;
    wire _A, _B, _C;
    wire and_A_1, and_A_2, and_B_1, and_B_2, and_C_1, and_C_2, and_C_3;
    wire and_s0_1, and_s0_2, and_s1_1, and_s1_2, and_s2_1, and_s2_2;
    wire and_ld_1, and_ld_2, and_ld_3, or_ld;
    wire t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17;

    // _A to A 
    NOT not1(t2, B);
    NOT not2(t1, A);
    AND GA1(and_A_1, A, t2);
    AND GA21(t3, B, C);
    AND GA22(and_A_2, t1, t3);
    OR GA3(_A, and_A_1, and_A_2);
    D_flip_flop D_A(_A, clk, enable, A);

    // _B to B
    NOT not3(t4, C);
    AND GB1(and_B_1, t2, C);
    AND GB21(t5, B, t4);
    AND GB22(and_B_2, t1, t5);
    OR GB(_B, and_B_1, and_B_2);
    D_flip_flop D_B(_B, clk, enable, B);

    // _C to C
    AND GC11(t6, t4, start);
    AND GC12(and_C_1, t1, t6);
    AND GC21(t7, B, t4);
    AND GC22(and_C_2, t1, t7);
    AND GC31(t8, t2, t4);
    AND GC32(and_C_3, A, t8);
    OR GC41(t9, and_C_2, and_C_3);
    OR GC42(_C, and_C_1, t9);
    D_flip_flop D_C(_C, clk, enable, C);

    // ld
    AND G_ld_1(and_ld_1, t1, B);
    AND G_ld_2(and_ld_2, B, t4);
    AND G_ld_3(and_ld_3, A, t2);
    OR G_ld_41(t10, and_ld_2, and_ld_3);
    OR G_ld_42(ld, and_ld_1, t10);

    // rst
    AND G_rst1(t11, t2, C);
    AND G_rst2(rst, t1, t11);

    // s0
    AND G_s0_11(t12, B, C);
    AND G_s0_12(and_s0_1, t1, t12);
    AND G_s0_21(t13, t2, C);
    AND G_s0_22(and_s0_2, A, t13);
    OR G_s0_3(s0, and_s0_1, and_s0_2);

    // s1
    AND G_s1_11(t14, t2, t4);
    AND G_s1_12(and_s1_1, A, t14);
    AND G_s1_21(t15, B, C);
    AND G_s1_22(and_s1_2, t1,t15);
    OR G_s1_3(s1, and_s1_1, and_s1_2);

    // s2
    AND G_s2_11(t16, B, C);
    AND G_s2_12(and_s2_1, t1, t16);
    AND G_s2_21(t17, t2, C);
    AND G_s2_22(and_s2_2, A, t17);
    OR G_s2_3(s2, and_s2_1, and_s2_2);

endmodule 

module multiplier_4(input[3:0]a, input[3:0]b, input clk, enable, start, output [7:0]result);

    wire rst, ld, s0, s1, s2;

    mul4datapath data_path(a, b, rst, clk, ld, s0, s1, s2, result);
    mul4controller control(start, clk, enable, rst, ld, s0, s1, s2);

endmodule

module mul4TestBench();

  reg [3:0] a, b;
  reg start, clk, enable;
  wire [7:0] out;

  multiplier_4 mul(a, b, clk, enable, start, out);
   integer i;
   integer j;
   integer true = 0;
  initial begin

    a = 4'b0000;
    b = 4'b0000;

    clk = 0; 
    start = 0; 
    enable = 0;
    
    #100 clk = 1; #100 clk = 0;
    enable = 1;
    #100 clk = 1; #100 clk = 0;
    enable = 0;
    
    #100 clk = 1; #100 clk = 0;
    for (i = 0; i < 16; i = i + 1) begin
         for ( j = 0; j < 16; j = j + 1) begin
            start = 1; clk = 0;
            #100 clk = 1; #100 clk = 0;
            #10 start = 1;
            #100 clk = 1; #100 clk = 0;
            #10 start = 0;
            repeat(15) #100 clk = ~clk;
            $display(" my answer = %d  golden result = %d",out,j*i);
            if (out == j*i) true = true + 1;
            a = a + 1;
         end
         b = b + 1;
    end
    $display("right results = %d",true);
    #100 $stop;
  end

endmodule



