// $Id: $
// File name:   adder_nbit.sv
// Created:     2/3/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: postlab third
module adder_nbit
#(
	parameter BIT_WIDTH=4
)
(
	input wire [BIT_WIDTH-1:0] a,
	input wire [BIT_WIDTH-1:0] b,
	input wire carry_in,
	output [BIT_WIDTH-1:0] sum,
	output overflow
);
	//wire temp1;
	//wire temp2;
	//assign sum[0] = carry_in ^ (a[0] ^ b[0]);
	//assign temp1 = ((~carry_in) & b[0] & a[0]) | (carry_in & (b[0] | a[0]));
	//assign sum[1] = temp1^ (a[0] ^ b[0]);
	//assign temp2 = ((~temp1) & b[0] & a[0]) | (temp1 & (b[0] | a[0]));
	//assign sum[2] = temp2 ^ (a[0] ^ b[0]);
	//assign overflow = ((~temp2) & b[0] & a[0]) | (temp2 & (b[0] | a[0]));
	wire [BIT_WIDTH:0] carry;
	genvar i;
	
	assign carry[0] = carry_in;
	generate
	for(i=0;i<BIT_WIDTH;i=i+1)
	begin
		always @ (a, b, carry_in)
		begin 
			assert((a[i] == 1'b1) || (a[i] == 1'b0))
			else $error("Input 'a[i]' is not a digital logic value");
			
			assert((b[i] == 1'b1) || (b[i] == 1'b0))
			else $error("Input 'b[i]'is not a digital logic value");

			assert((carry_in == 1'b1) || (carry_in == 1'b0))
			else $error("Input 'carry_in' is not a digital logic value");
		end
		adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carry[i]), .sum(sum[i]), .carry_out(carry[i+1]));
	end 
	endgenerate	
	assign overflow = carry[BIT_WIDTH];
endmodule