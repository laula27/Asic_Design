// $Id: $
// File name:   mealy.sv
// Created:     2/23/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: mealy machine
module mealy
(
    input wire clk,
    input wire n_rst,
    input wire i,
    output reg o
);
typedef enum bit [2:0] 
{
    STATE_1,STATE_2, STATE_3,IDLE
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
        if (i==1)
            nxt_state = STATE_1;
        else
            nxt_state = IDLE;
        end

        STATE_1:
        begin
        if (i==1)
            nxt_state = STATE_2;
        else
            nxt_state = IDLE;
        end
        STATE_2:
        begin
        if (i==0)
            nxt_state = STATE_3;
        else
            nxt_state = STATE_2;
        end
        STATE_3:
        begin
        if (i==1)
            nxt_state = STATE_1;
        else
            nxt_state = IDLE;
        end
    endcase
end

always_comb
begin : OUT_LOGIC
    if (state==STATE_3 && i ==1)
        o = 1;
    else
        o = 0;
end
endmodule
