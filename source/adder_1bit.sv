// $Id: $
// File name:   adder_1bit.sv
// Created:     1/31/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: first postlab
module adder_1bit
(
	input wire a,
	input wire b,
	input wire carry_in,
	output sum,
	output carry_out
);
	assign sum = carry_in ^ (a ^ b);
	assign carry_out = ((~carry_in) & b & a) | (carry_in & (b|a));
endmodule