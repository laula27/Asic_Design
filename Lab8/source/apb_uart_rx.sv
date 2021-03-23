// $Id: $
// File name:   apb_uart_rx.sv
// Created:     3/16/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: apb_uart_rx
module apb_uart_rx (
    input wire clk,
    input wire n_rst, 
    input wire serial_in,
    input wire psel,
    input wire [2:0]paddr,
    input wire penable,
    input wire pwrite,
    input wire [7:0]pwdata,
    output reg [7:0]prdata,
    output reg pslverr
);
wire data_read;
wire data_ready;
wire overrun_error;
wire framing_error;
wire [3:0] data_size;
wire [13:0] bit_period;
wire [7:0] rx_data;

rcv_block
  uart(
    .clk(clk),
    .n_rst(n_rst),
    .serial_in(serial_in),
    .data_read(data_read),
    .data_size(data_size[3:0]),
    .bit_period(bit_period),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .overrun_error(overrun_error),
    .framing_error(framing_error)

  );

  apb_slave 
  apb(
    .clk(clk),
    .n_rst(n_rst),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .overrun_error(overrun_error),
    .framing_error(framing_error),
    .psel(psel),
    .paddr(paddr),
    .penable(penable),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .pslverr(pslverr),
    .data_size(data_size),
    .bit_period(bit_period),
    .data_read(data_read)
  );
  endmodule
