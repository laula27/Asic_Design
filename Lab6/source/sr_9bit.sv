// $Id: $
// File name:   sr_9bit.sv
// Created:     3/1/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: 9 bit shift register
module sr_9bit
(
    input wire clk,
    input wire n_rst,
    input wire shift_strobe,
    input wire serial_in,
    output wire [7:0] packet_data,
    output wire stop_bit
);
    reg [8:0] data;
    assign packet_data = data[7:0];
    assign stop_bit = data[8];
    flex_stp_sr #(.NUM_BITS(9), .SHIFT_MSB(0)) shiftbit (.clk(clk), .n_rst(n_rst), .serial_in(serial_in), .shift_enable(shift_strobe), .parallel_out(data));

endmodule