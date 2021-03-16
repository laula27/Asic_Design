// $Id: $
// File name:   timer.sv
// Created:     3/1/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: timing controller
module timer
(
    input wire clk,
    input wire n_rst,
    input wire enable_timer,
    output wire shift_enable,
    output reg packet_done
);
flex_counter #(.NUM_CNT_BITS(4)) 
count10 (
            .clk(clk), 
            .n_rst(n_rst), 
            .clear(!enable_timer), 
            .count_enable(enable_timer), 
            .rollover_val(4'b1010), 
            .rollover_flag(shift_enable),
            .count_out()
        );
flex_counter #(.NUM_CNT_BITS(4)) 
count9bit (
            .clk(clk), 
            .n_rst(n_rst), 
            .clear(!enable_timer), 
            .count_enable(shift_enable), 
            .rollover_val(4'b1001), 
            .rollover_flag(packet_done),
            .count_out()
        );
endmodule