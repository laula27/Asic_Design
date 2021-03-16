// $Id: $
// File name:   sensor_s.sv
// Created:     1/27/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: lab2.
module sensor_s
(
	input [3:0] sensors,
	output error
);
	wire temp1;
	wire temp2;
	wire temp3;
	AND2X1 A1 (.Y(temp1), .A(sensors[1]), .B(sensors[2]));	
	AND2X1 A2 (.Y(temp2), .A(sensors[1]), .B(sensors[3]));
	OR2X1 A3 (.Y(temp3), .A(temp2), .B(temp1));
	OR2X1 A4 (.Y(error), .A(temp3), .B(sensors[0]));
endmodule
 