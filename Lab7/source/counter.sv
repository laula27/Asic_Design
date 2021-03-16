// $Id: $
// File name:   counter.sv
// Created:     3/7/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: counter
module counter
(
    input wire clk,
    input wire n_rst,
    input wire cnt_up,
    output wire clear,
    output reg one_k_samples
);
flex_counter #(.NUM_CNT_BITS(10)) 
count1000 
(
            .clk(clk), 
            .n_rst(n_rst), 
            .clear(clear), 
            .count_enable(cnt_up), 
            .rollover_val(10'd1000), 
            .rollover_flag(one_k_samples)
        );
endmodule