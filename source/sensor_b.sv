// $Id: $
// File name:   sensor_b.sv
// Created:     1/31/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: third
module sensor_b
(
	input wire [3:0] sensors,
	output reg error
);
	always_comb
	begin
		error = 1'b0;
		error = (sensors[1] & sensors[2])|(sensors[1] &sensors[3])| sensors[0];
	end 
endmodule