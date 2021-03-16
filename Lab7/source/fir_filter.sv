// $Id: $
// File name:   fir_filter.sv
// Created:     3/8/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: finite impulse responsefilter
module fir_filter
(
    input wire clk,
    input wire n_reset,
    input wire [15:0] sample_data,
    input wire [15:0] fir_coefficient,
    input wire load_coeff,
    input wire data_ready,
    output reg one_k_samples,
    output reg modwait,
    output reg [15:0] fir_out,
    output reg err
);
wire data_ready_sync;
wire load_coeff_sync;
wire clear;
wire cnt_up;
wire [2:0] op;
wire [3:0] src1;
wire [3:0] src2;
wire [3:0] dest;
wire overflow;
wire [16:0] outreg_data;


sync_low
sync(
    .clk(clk),
    .n_rst(n_reset),
    .async_in(data_ready),
    .sync_out(data_ready_sync)
);
sync_low
syncnc(
    .clk(clk),
    .n_rst(n_reset),
    .async_in(load_coeff),
    .sync_out(load_coeff_sync)
);
counter
count1000(
    .clk(clk),
    .n_rst(n_reset),
    .cnt_up(cnt_up),
    .clear(clear),
    .one_k_samples(one_k_samples)

);

controller
controlunit(
    .clk(clk),
    .n_rst(n_reset),
    .dr(data_ready_sync),
    .lc(load_coeff_sync),
    .overflow(overflow),
    .cnt_up(cnt_up),
    .clear(clear),
    .modwait(modwait),
    .op(op),
    .src1(src1),
    .src2(src2),
    .dest(dest),
    .err(err)
);
magnitude
mag(
    .in(outreg_data),
    .out(fir_out)
);
datapath
data(
    .clk(clk),
    .n_reset(n_reset),
    .op(op),
    .src1(src1),
    .src2(src2),
    .dest(dest),
    .ext_data1(sample_data),
    .ext_data2(fir_coefficient),
    .outreg_data(outreg_data),
    .overflow(overflow)
);
endmodule


