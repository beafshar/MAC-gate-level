


// --------------------- shifter --------------------- 
  
module left2Shift8b(output [7:0] w, input [7:0] a);
    supply0 zero;
    and(w[0], a[6], zero);
    and(w[1], a[7], zero);
    
    genvar i;
    generate 
        for (i = 2; i < 8; i = i + 1) begin: lf
            or(w[i], a[i-2], zero);
        end
    endgenerate

endmodule

