// $Id: $
// File name:   tb_flex_counter.sv
// Created:     2/10/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: test bench
`timescale 1ns / 10ps

module tb_flex_counter();

  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 1;
  localparam  FF_SETUP_TIME = 0.190;
  localparam  FF_HOLD_TIME  = 0.100;
  localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  
  localparam  INACTIVE_VALUE     = 1'b0;
  localparam  RESET_OUTPUT_VALUE = INACTIVE_VALUE;
  
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg tb_clear;
  reg tb_count_enable;
  reg [3:0] tb_rollover_val;
  wire [3:0] tb_count_out;
  wire tb_rollover_flag;

  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;
  integer tb_stream_test_num;
  string tb_stream_check_tag;
  
  // Task for standard DUT reset procedure
  task reset_dut;
  begin
    // Activate the reset
    tb_n_rst = 1'b0;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
    tb_n_rst = 1'b1;

    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges, 
    // since inputs to DUT should normally be applied away from rising clock edges
    @(negedge tb_clk);
    @(negedge tb_clk);
  end
  endtask

  // Task to cleanly and consistently check DUT output values
  task check_output;
    input logic  [3:0] expected_value;
    input logic  expected_flag;
    input string check_tag;
  begin
    if(expected_value == tb_count_out && expected_flag == tb_rollover_flag) begin // Check passed
      $info("Correct synchronizer output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect synchronizer output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  

  // Clock generation block
  always
  begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end
  
  // DUT Port map
  flex_counter DUT(.clk(tb_clk), .n_rst(tb_n_rst),.clear(tb_clear),.count_enable(tb_count_enable), .rollover_val(tb_rollover_val), .rollover_flag(tb_rollover_flag), .count_out(tb_count_out));
  
  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_clear  = 0; // Initialize input to inactive  value
    tb_test_num = 0;               // Initialize test case counter
    tb_count_enable = 0;
    tb_rollover_val = 4'b0000;
    tb_test_case = "Test bench initializaton";
    tb_stream_test_num = 0;
    tb_stream_check_tag = "N/A";
    // Wait some time before starting first test case
    #(0.1);
    
    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    tb_n_rst  = 1'b0;    // Activate reset
    
    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    check_output( RESET_OUTPUT_VALUE, RESET_OUTPUT_VALUE,
                  "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_output( RESET_OUTPUT_VALUE,RESET_OUTPUT_VALUE, 
                  "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(2 * FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    #0.1;
    // Check that internal state was correctly keep after reset release
    check_output( RESET_OUTPUT_VALUE, RESET_OUTPUT_VALUE,
                  "after reset was released");



    // ************************************************************************
    // Test Case 2: Rollover for a rollover value that is not power of two
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = " Rollover for a rollover value that is not power of two";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_rollover_val = 4'b0000;
    tb_count_enable = 0;
    tb_clear  = 0;
    reset_dut();

    // Assign test case stimulus
    tb_rollover_val = 4'd3;
    tb_count_enable = 1;
    tb_clear  = 0;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd1,1'b0,
                  "after processing delay");


    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd2,1'b0,
                  "after processing delay");
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd3,1'b1,
                  "after processing delay");


   // Test Case 3: Continuous counting
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Continuous counting";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_rollover_val = 4'b0000;
    tb_count_enable = 0;
    tb_clear  = 0;
    reset_dut();

    // Assign test case stimulus
    tb_rollover_val = 4'd15;
    tb_count_enable = 1;
    tb_clear  = 0;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd1,1'b0,
                  "after processing delay");
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd2,1'b0,
                  "after processing delay");
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd3,1'b0,
                  "after processing delay");
                
     @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd4,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd5,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd6,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd7,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd8,1'b0,
                  "after processing delay");

     @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd9,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd10,1'b0,
                  "after processing delay");


    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd11,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd12,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd13,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd14,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd15,1'b1,
                  "after processing delay");
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd1,1'b0,
                  "after processing delay");


      

  // Test Case 4: Disontinuous counting
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Discontinuous counting";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_rollover_val = 4'b0000;
    tb_count_enable = 0;
    tb_clear  = 0;
    reset_dut();

    // Assign test case stimulus
    tb_rollover_val = 4'd5;
    tb_count_enable = 1;
    tb_clear  = 0;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd1,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd2,1'b0,
                  "after processing delay");

    tb_count_enable = 0;
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd2,1'b0,
                  "after processing delay");


    tb_count_enable = 1;
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd3,1'b0,
                  "after processing delay");


    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd4,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd5,1'b1,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd1,1'b0,
                  "after processing delay");

    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd2,1'b0,
                  "after processing delay");
    








    // Test Case 4: Clearing while counting to check clear vs count enable priority
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Clearing while counting to check clear vs count enable priority";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_rollover_val = 4'b0000;
    tb_count_enable = 0;
    tb_clear  = 0;
    reset_dut();

    // Assign test case stimulus
    tb_rollover_val = 4'd5;
    tb_count_enable = 1;
    tb_clear  = 0;

    // Wait for DUT to process stimulus before checking results
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd1,0,
                  "after processing delay");


    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd2,0,
                  "after processing delay");

    tb_clear = 1;
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd0,0,
                  "after processing delay");


    tb_clear = 1;
    tb_count_enable = 1;
    @(posedge tb_clk);
    // Move away from risign edge and allow for propagation delays before checking
    #(CHECK_DELAY);
    // Check results
    check_output( 4'd0,0,
                  "after processing delay");





    
    
  end
endmodule