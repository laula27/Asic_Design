// $Id: $
// File name:   flex_counter.sv
// Created:     2/10/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: counter
module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input reg [NUM_CNT_BITS-1:0] rollover_val,
	output reg [NUM_CNT_BITS-1:0] count_out,
	output reg rollover_flag
);
reg flag;
reg [NUM_CNT_BITS-1:0] count;
always_ff @ (negedge n_rst, posedge clk)
begin: REG_LOGIC
	if(1'b0 == n_rst) begin
		count_out <= 0;
		rollover_flag <= 0;
	end
	else begin
	count_out <= count;
	rollover_flag <= flag;
	end
end	

always_comb 
begin: NXT_LOGIC
	flag = 0;
	count = 0;
	if (1'b1 == clear) begin
		count = 0;
		flag = 0;
	end
	else if (1'b1 == count_enable) begin
		if (rollover_val-1 == count_out) begin
			flag = 1;
		end
		count = count_out + 1;
		if (rollover_val == count_out) begin
			count = 1;
			flag = 0;
		end
	end
	else begin
		count = count_out;
	end
end	


endmodule