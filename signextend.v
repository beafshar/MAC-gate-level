

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


module zeroExtend(output [7:0] w, input [3:0] a);
    supply0 zero;
    
    genvar i;
    generate 
        for (i = 4; i < 8; i = i + 1) begin
            and(w[i], zero, a[0]);
            or(w[i-4], zero, a[i-4]);
        end
    endgenerate

endmodule