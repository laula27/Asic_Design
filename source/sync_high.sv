// $Id: $
// File name:   sync_high.sv
// Created:     2/9/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: High Synchronizer
module sync_high
(
	input wire clk,
	input wire n_rst,
	input reg async_in,
	output reg sync_out
);
reg i;
always_ff @ (negedge n_rst, posedge clk)
begin: REG_LOGIC
	if(1'b0 == n_rst) begin
		sync_out <= 1'b1;
		i <= 1'b1;
	end
	else begin
	i <= async_in;
	sync_out <= i;
	end
end	
endmodule