// $Id: $
// File name:   controller.sv
// Created:     3/7/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: controller

module controller(
    input wire clk,
    input wire n_rst,
    input wire dr,
    input wire lc,
    input wire overflow,
    output reg cnt_up,
    output reg clear,
    output reg modwait,
    output reg [2:0] op,
    output reg [3:0] src1,
    output reg [3:0] src2,
    output reg [3:0] dest,
    output reg err
);
localparam nop = 3'b000;
localparam copy = 3'b001;
localparam load1 = 3'b010;
localparam load2 = 3'b011;
localparam add = 3'b100;
localparam sub = 3'b101;
localparam mul = 3'b110;
localparam r0 = 4'b0000;//sum
localparam r1 = 4'b0001;//sample1
localparam r2 = 4'b0010;//sample2
localparam r3 = 4'b0011;//sample3
localparam r4 = 4'b0100;//sample4
localparam r5 = 4'b0101;//f0
localparam r6 = 4'b0110;//f1
localparam r7 = 4'b0111;//f2
localparam r8 = 4'b1000;//f3
localparam r9 = 4'b1001;//temp

typedef enum bit [4:0] 
{
    STORE, WAITLOAD0, LOAD0, WAITLOAD1, LOAD1,WAITLOAD2, LOAD2,LOAD3,ZERO,SORT1, SORT2, SORT3, SORT4,
    MUL0, SUB0, MUL1, ADD1, MUL2,SUB2, MUL3, ADD3, EIDLE,IDLE
}stateType;
stateType state;
stateType nxt_state;
reg nxt_modwait;

always_ff @ (negedge n_rst, posedge clk)
begin : REG_LOGIC
    if(1'b0 ==n_rst)
    begin
        state <= IDLE;
        modwait <= 0;
    end 
    else
    begin
        state <= nxt_state;
        modwait <= nxt_modwait;
    end
        
end


always_comb
begin : NXT_LOGIC
    nxt_state = state;
    case(state)
        IDLE:
        begin
        if (lc==1)
            nxt_state = LOAD0;
        if (dr==1)
            nxt_state = STORE;
        end
        LOAD0:
        begin
            nxt_state = WAITLOAD0;
        end   
        WAITLOAD0:
        begin
            if(lc == 0)
                nxt_state = WAITLOAD0;
            else
                nxt_state = LOAD1;
        end
        LOAD1:
        begin
            nxt_state = WAITLOAD1;
        end   
        WAITLOAD1:
        begin
            if(lc == 0)
                nxt_state = WAITLOAD1;
            else
                nxt_state = LOAD2;
        end
        LOAD2:
        begin
            nxt_state = WAITLOAD2;
        end   
        WAITLOAD2:
        begin
            if(lc == 0)
                nxt_state = WAITLOAD2;
            else
                nxt_state = LOAD3;
        end
        LOAD3:
        begin
            nxt_state = IDLE;
        end
        STORE:
        begin
        if (dr == 0)
            nxt_state = EIDLE;
        else
            nxt_state = ZERO;
        end   
        ZERO:
        begin
            nxt_state = SORT1;
        end
        SORT1:
        begin
            nxt_state = SORT2;
        end
        SORT2:
        begin
            nxt_state = SORT3;
        end
        SORT3:
        begin
            nxt_state = SORT4;
        end
        SORT4:
        begin
            nxt_state = MUL3;
        end
        MUL3:
        begin
            nxt_state = ADD3;
        end
        ADD3:
        begin
            if(overflow == 0)
                nxt_state = MUL2;
            else
                nxt_state = EIDLE;
        end
        MUL2:
        begin
            nxt_state = SUB2;
        end
        SUB2:
        begin
            if(overflow == 0)
                nxt_state = MUL1;
            else
                nxt_state = EIDLE;
        end
        MUL1:
        begin
            nxt_state = ADD1;
        end
        ADD1:
        begin
            if(overflow == 0)
                nxt_state = MUL0;
            else
                nxt_state = EIDLE;
        end
        MUL0:
        begin
            nxt_state = SUB0;
        end
        SUB0:
        begin
            if(overflow == 0)
                nxt_state = IDLE;
            else
                nxt_state = EIDLE;
        end
        
        
        
        EIDLE:
        begin
            if(dr)
                nxt_state = STORE;
            else
                nxt_state = EIDLE;

        end
    endcase
end


always_comb
begin : OUT_LOGIC

    cnt_up = 0;
    clear = 0;
    nxt_modwait = 0;
    op = '0;
    src1 = '0;
    src2 = '0;
    dest = '0;
    err = 0;
    case(state)
        IDLE: 
        begin
            op = nop;
        end
        STORE: 
        begin
            clear = 1;
            nxt_modwait = 1;
            op = load1;
            dest = r9;
        end
        ZERO: 
        begin
            nxt_modwait = 1;
            cnt_up = 1;
            op = sub;
            src1 = r1;
            src2 = r1;
            dest = r0;
        end
        SORT1: 
        begin
            nxt_modwait = 1;
            op = copy;
            src1 = r3;
            dest = r4;
        end
        SORT2: 
        begin
            nxt_modwait = 1;
            op = copy;
            src1 = r2;
            dest = r3;
        end
        SORT3: 
        begin
            nxt_modwait = 1;
            op = copy;
            src1 = r1;
            dest = r2;
        end
        SORT4: 
        begin
            nxt_modwait = 1;
            op = copy;
            src1 = r9;
            dest = r1;
        end
        MUL0:
        begin
            nxt_modwait = 1;
            op = mul;
            src1 = r1;
            src2 = r5;
            dest = r9;
        end
        SUB0:
        begin
            nxt_modwait = 1;
            op = sub;
            src1 = r0;
            src2 = r9;
            dest = r0;
        end
        MUL1:
        begin
            nxt_modwait = 1;
            op = mul;
            src1 = r2;
            src2 = r6;
            dest = r9;
        end
        ADD1:
        begin
            nxt_modwait = 1;
            op = add;
            src1 = r0;
            src2 = r9;
            dest = r0;
        end
        MUL2:
        begin
            nxt_modwait = 1;
            op = mul;
            src1 = r3;
            src2 = r7;
            dest = r9;
        end
        SUB2:
        begin
            nxt_modwait = 1;
            op = sub;
            src1 = r0;
            src2 = r9;
            dest = r0;
        end
        MUL3:
        begin
            nxt_modwait = 1;
            op = mul;
            src1 = r4;
            src2 = r8;
            dest = r9;
        end
        ADD3:
        begin
            nxt_modwait = 1;
            op = add;
            src1 = r0;
            src2 = r9;
            dest = r0;
        end
        EIDLE:
        begin
            err = 1;
            op = nop;
        end
        LOAD0:
        begin
            nxt_modwait = 1;
            op = load2;
            dest = r5;
        end
        WAITLOAD0:
        begin
            nxt_modwait = 0;
            op = nop;
        end
        LOAD1:
        begin
            nxt_modwait = 1;
            op = load2;
            dest = r6;
        end
        WAITLOAD1:
        begin
            nxt_modwait = 0;
            op = nop;
        end
        LOAD2:
        begin
            nxt_modwait = 1;
            op = load2;
            dest = r7;
        end
        WAITLOAD2:
        begin
            nxt_modwait = 0;
            op = nop;
        end
        LOAD3:
        begin
            nxt_modwait = 1;
            op = load2;
            dest = r8;
        end
    endcase
end
endmodule
