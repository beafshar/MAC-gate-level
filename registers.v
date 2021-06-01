
// --------------------- registers --------------------- 

module reg4bit(input clk, rst, en, input[3:0] in, output reg [3:0] out);

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else if(en)
			out <= in;
	end
endmodule



module reg8bit(input clk, rst, en, input[7:0] in, output reg [7:0] out);

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else if(en)
			out <= in;
	end
endmodule

module reg16bit(input clk, rst, ldu, ldd, input[7:0] in, output reg [15:0] out);

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else if(ldu)
			out[15:8] <= in;
		else if (ldd)
			out[7:0] <= in;
		
	end
endmodule

module reg10bit(input clk, rst, input[9:0] in, output reg [9:0] out);

	always@ (posedge clk, posedge rst) begin
		if(rst)
			out <= 0;
		else
			out <= in;
	end
endmodule

module jk_ff(input j, input k, input clk, init_rst, output reg q);
   always @ (posedge clk, init_rst) begin
      if (init_rst == 1'b1) begin
         q <= 0;
      end
      case ({j,k})
         2'b00 :  q <= q;  
         2'b01 :  q <= 0;  
         2'b10 :  q <= 1; 
         2'b11 :  q <= ~q;
      endcase
   end
endmodule

