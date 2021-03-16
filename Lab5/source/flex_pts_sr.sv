// $Id: $
// File name:   flex_pts_sr.sv
// Created:     2/17/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: parallel to serial
module flex_pts_sr
#(
	parameter NUM_BITS = 4,
    parameter SHIFT_MSB = 1

)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
    input wire load_enable,
	output reg serial_out,
	input wire [NUM_BITS-1:0] parallel_in
);
    reg [NUM_BITS-1:0] shiftregister;
    reg [NUM_BITS-1:0] nextshiftregister;
    
    always_ff @ (negedge n_rst, posedge clk)
    begin: REG_LOGIC
	    if(1'b0 == n_rst) begin
            shiftregister <= '1;
	    end
	    else begin
	    shiftregister <= nextshiftregister;
	    end
    end
    //assign serial_out = shiftregister[NUM_BITS-1];
    always_comb 
    begin: NXT_LOGIC
	    if (1'b1 == load_enable) begin
            nextshiftregister = parallel_in;
        end
        else if (1'b1 == shift_enable && 1'b0 == load_enable) begin
            if (SHIFT_MSB ==1) begin
                nextshiftregister = {shiftregister[NUM_BITS-2:0],1'b1};

            end
            else begin
                nextshiftregister = {1'b1,shiftregister[NUM_BITS-1:1]};
            end 
        end 
        else begin
            nextshiftregister = shiftregister;
        end  
    end	
    if (SHIFT_MSB ==1) begin
        assign serial_out = shiftregister[NUM_BITS-1];
    end
    else begin
        assign serial_out = shiftregister[0];
    end 
    endmodule