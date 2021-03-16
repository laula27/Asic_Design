// $Id: $
// File name:   sync_low.sv
// Created:     2/9/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: Logic Low Synchronizer
module sync_low
(
	input wire clk,
	input wire n_rst,
	input reg async_in,
	output reg sync_out
);
	reg i;
	always_ff @ (negedge n_rst, posedge clk)
	begin
		if(1'b0==n_rst) 
		begin
			sync_out <= 1'b0;
			i <= 1'b0;
		end
		else begin
		i <= async_in;
		sync_out <= i;
		end
	end	
endmodule