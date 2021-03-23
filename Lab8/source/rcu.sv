// $Id: $
// File name:   rcu.sv
// Created:     3/1/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: reciver control unit
module rcu(
    input wire clk,
    input wire n_rst,
    input wire start_bit_detected,
    input wire packet_done,
    input wire framing_error,
    output reg sbc_clear,
    output reg sbc_enable,
    output reg load_buffer,
    output reg enable_timer

);
typedef enum bit [2:0] 
{
    STATE_0,STATE_1,STATE_2,STATE_3, WAIT, IDLE
}stateType;
stateType state;
stateType nxt_state;

always_ff @ (negedge n_rst, posedge clk)
begin : REG_LOGIC
    if(1'b0 ==n_rst)
        state <= IDLE;
    else
        state <= nxt_state;
end


always_comb
begin : NXT_LOGIC
    nxt_state = state;
    case(state)
        IDLE:
        begin
        if (start_bit_detected==1)
            nxt_state = STATE_0;
        else
            nxt_state = IDLE;
        end
        STATE_0:
        begin
            nxt_state = STATE_1;
        end   
        STATE_1:
        begin
        if (packet_done==1)
            nxt_state = WAIT;
        else
            nxt_state = STATE_1;
        end
        WAIT:
            nxt_state = STATE_2;
        STATE_2:
        begin
        if (framing_error==1)
            nxt_state = IDLE;
        else
            nxt_state = STATE_3;
        end
        STATE_3:
        begin
            nxt_state = IDLE;
        end
    endcase
end

always_comb
begin : OUT_LOGIC
    sbc_clear = 0;
    sbc_enable = 0;
    load_buffer = 0;
    enable_timer = 0;
    if (state==STATE_3)
        load_buffer = 1;
    if(state==STATE_1)
    begin 
        sbc_clear = 0;
        enable_timer = 1;
    end
    if(state== STATE_0)
    begin 
        sbc_clear = 1;
        enable_timer = 1;
    end
    if(state==WAIT)
    begin
        sbc_clear = 0;
        sbc_enable = 1;
        load_buffer = 0;
        enable_timer = 0;
    end
    if(state==IDLE)
    begin
        sbc_clear = 0;
        sbc_enable = 0;
        load_buffer = 0;
        enable_timer = 0;
    end
end
endmodule