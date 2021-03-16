// $Id: $
// File name:   adder_4bit.sv
// Created:     1/31/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: Postlab second
module adder_4bit
(
	input wire [3:0] a,
	input wire [3:0] b,
	input wire carry_in,
	output [3:0] sum,
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
	wire [4:0] carry;
	genvar i;

	assign carry[0] = carry_in;
	generate
	for(i=0;i<=3;i=i+1)
		begin
		adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carry[i]), .sum(sum[i]), .carry_out(carry[i+1]));
		end 
	endgenerate	
	assign overflow = carry[4];
endmodule
