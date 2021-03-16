// $Id: $
// File name:   rcv_block.sv
// Created:     3/1/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: receiver block
module rcv_block
(
	input wire clk,
	input wire n_rst,
	input wire serial_in,
	input wire data_read,
	output reg [7:0] rx_data,
	output reg overrun_error,
  output reg data_ready,
	output reg framing_error
);
  wire load_buffer;
  wire sbc_clear;
  wire sbc_enable;
  wire stop_bit;
  wire enable_timer;
  wire shift_enable;
  reg [7:0] packet_data;
  wire start_bit_detected;
  wire shift_strobe;
  wire new_package_detected;
  wire packet_done;


  rx_data_buff 
  data(
    .clk(clk),
    .n_rst(n_rst),
    .load_buffer(load_buffer),
    .packet_data(packet_data),
    .data_read(data_read),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .overrun_error(overrun_error)

  );


  stop_bit_chk 
  stop(
    .clk(clk),
    .n_rst(n_rst),
    .sbc_clear(sbc_clear),
    .sbc_enable(sbc_enable),
    .stop_bit(stop_bit),
    .framing_error(framing_error)

  );
  start_bit_det 
  start(
    .clk(clk),
    .n_rst(n_rst),
    .serial_in(serial_in),
    .start_bit_detected(start_bit_detected),
    .new_package_detected(new_package_detected)

  );
  timer
  timecontro(
    .clk(clk),
    .n_rst(n_rst),
    .enable_timer(enable_timer),
    .shift_enable(shift_strobe),
    .packet_done(packet_done)
      
  );
  sr_9bit
  shift(
    .clk(clk),
    .n_rst(n_rst),
    .shift_strobe(shift_strobe),
    .serial_in(serial_in),
    .packet_data(packet_data),
    .stop_bit(stop_bit)

  );

  rcu
  recieve(
    .clk(clk),
    .n_rst(n_rst),
    .start_bit_detected(start_bit_detected),
    .packet_done(packet_done),
    .framing_error(framing_error),
    .sbc_enable(sbc_enable),
    .sbc_clear(sbc_clear),
    .load_buffer(load_buffer),
    .enable_timer(enable_timer)

  );
  endmodule