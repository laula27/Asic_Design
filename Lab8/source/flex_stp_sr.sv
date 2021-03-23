// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/17/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: Flexibl shift register design
module flex_stp_sr
#(
	parameter NUM_BITS = 4,
    parameter SHIFT_MSB = 1

)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output reg [NUM_BITS-1:0] parallel_out
);
    reg [NUM_BITS-1:0] parallel;
    always_ff @ (negedge n_rst, posedge clk)
    begin: REG_LOGIC
	    if(n_rst == 0) begin
		    parallel_out <=  '1;
	    end
	    else begin
	        parallel_out <= parallel;
	    end
    end
    always_comb 
    begin: NXT_LOGIC
	    if (shift_enable == 1) begin
            if (SHIFT_MSB ==1) begin
                parallel = {parallel_out[NUM_BITS-2:0],serial_in};
            end
            else begin
                parallel = {serial_in,parallel_out[NUM_BITS-1:1]};
            end 
        end 
        else begin
            parallel = parallel_out;
        end  
    end	
endmodule