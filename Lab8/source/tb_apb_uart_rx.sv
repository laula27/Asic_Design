// $Id: $
// File name:   tb_apb_uart_rx.sv
// Created:     3/19/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: test bench for apb and uart
// $Id: $
// File name:   tb_apb_slave.sv
// Created:     10/1/2018
// Author:      Tim Pritchett
// Lab Section: 9999
// Version:     1.0  Initial Design Entry
// Description: Starter bus model based test bench for the apb-slave module

`timescale 1ns / 10ps

module tb_apb_uart_rx();

// Timing related constants
localparam CLK_PERIOD = 10;
localparam BUS_DELAY  = 800ps; // Based on FF propagation delay
parameter NORM_DATA_PERIOD  = (10 * CLK_PERIOD);

// Sizing related constants
localparam DATA_WIDTH      = 1;
localparam ADDR_WIDTH      = 3;
localparam DATA_WIDTH_BITS = DATA_WIDTH * 8;
localparam DATA_MAX_BIT    = DATA_WIDTH_BITS - 1;
localparam ADDR_MAX_BIT    = ADDR_WIDTH - 1;

// Define our address mapping scheme via constants
localparam ADDR_DATA_SR  = 3'd0;
localparam ADDR_ERROR_SR = 3'd1;
localparam ADDR_BIT_CR0  = 3'd2;
localparam ADDR_BIT_CR1  = ADDR_BIT_CR0 + 1;
localparam ADDR_DATA_CR  = 3'd4;
localparam ADDR_RX_DATA  = 3'd6;

// APB-Slave reset value constants
// Student TODO: Update these based on the reset values for your config registers
localparam RESET_BIT_PERIOD = '0;
localparam RESET_DATA_SIZE  = '0;

//*****************************************************************************
// Declare TB Signals (Bus Model Controls)
//*****************************************************************************
// Testing setup signals
logic                          tb_enqueue_transaction;
logic                          tb_transaction_write;
logic                          tb_transaction_fake;
logic [(ADDR_WIDTH - 1):0]     tb_transaction_addr;
logic [((DATA_WIDTH*8) - 1):0] tb_transaction_data;
logic                          tb_transaction_error;
// Testing control signal(s)
logic    tb_enable_transactions;
integer  tb_current_transaction_num;
logic    tb_model_reset;
string   tb_test_case;
integer  tb_test_case_num;
logic [DATA_MAX_BIT:0] tb_test_data;
string                 tb_check_tag;
logic [13:0]           tb_test_bit_period;
logic                  tb_mismatch;
logic                  tb_check;

//*****************************************************************************
// General System signals
//*****************************************************************************
logic tb_clk;
logic tb_n_rst;


//*****************************************************************************
// APB-Slave side signals
//*****************************************************************************
logic                          tb_psel;
logic [(ADDR_WIDTH - 1):0]     tb_paddr;
logic                          tb_penable;
logic                          tb_pwrite;
logic [((DATA_WIDTH*8) - 1):0] tb_pwdata;
logic [((DATA_WIDTH*8) - 1):0] tb_prdata;
logic                          tb_pslverr;

//*****************************************************************************
// UART-side Signals
//*****************************************************************************
// From UART(TB)
logic [7:0]  tb_rx_data;
logic        tb_data_ready;
logic        tb_serial_in;
logic        tb_overrun_error;
logic        tb_framing_error;
// To UART (From DUT)
logic        tb_data_read;
logic [3:0]  tb_data_size;
logic [13:0] tb_bit_period;
logic        tb_expected_data_read;
logic [3:0]  tb_expected_data_size;
logic [13:0] tb_expected_bit_period;
// To UART (From DUT)
//logic tb_serial_in;
logic [7:0] bit_stream;



//*****************************************************************************
// Clock Generation Block
//*****************************************************************************
// Clock generation block
always begin
  // Start with clock low to avoid false rising edge events at t=0
  tb_clk = 1'b0;
  // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
  #(CLK_PERIOD/2.0);
  tb_clk = 1'b1;
  // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
  #(CLK_PERIOD/2.0);
end

//*****************************************************************************
// Bus Model Instance
//*****************************************************************************
apb_bus BFM ( .clk(tb_clk),
          // Testing setup signals
          .enqueue_transaction(tb_enqueue_transaction),
          .transaction_write(tb_transaction_write),
          .transaction_fake(tb_transaction_fake),
          .transaction_addr(tb_transaction_addr),
          .transaction_data(tb_transaction_data),
          .transaction_error(tb_transaction_error),
          // Testing controls
          .model_reset(tb_model_reset),
          .enable_transactions(tb_enable_transactions),
          .current_transaction_num(tb_current_transaction_num),
          // APB-Slave Side
          .psel(tb_psel),
          .paddr(tb_paddr),
          .penable(tb_penable),
          .pwrite(tb_pwrite),
          .pwdata(tb_pwdata),
          .prdata(tb_prdata),
          .pslverr(tb_pslverr));


//*****************************************************************************
// DUT Instance
//*****************************************************************************
apb_uart_rx DUT ( .clk(tb_clk), .n_rst(tb_n_rst),
            // UART Operation signals
            .serial_in(tb_serial_in),
            .psel(tb_psel),
            .paddr(tb_paddr),
            .penable(tb_penable),
            .pwrite(tb_pwrite),
            .pwdata(tb_pwdata),
            .prdata(tb_prdata),
            .pslverr(tb_pslverr));
//*****************************************************************************
// DUT Related TB Tasks
//*****************************************************************************
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
task send_packet;
    input  [7:0] data;
    input  int data_size;
    input  time data_period;
    
    integer i;
  begin
    // First synchronize to away from clock's rising edge
    @(negedge tb_clk)
    
    // Send start bit
    tb_serial_in = 1'b0;
    #data_period;
    
    // Send data bits
    for(i = 0; i < data_size; i = i + 1)
    begin
      tb_serial_in = data[i];
      #data_period;
    end
    
    // Send stop bit
    tb_serial_in = 1;
    #data_period;
  end
  endtask

  task configure;
    input  [13:0] test_period;
    input  [7:0] data_size;
  begin
    enqueue_transaction(1'b1, 1'b1, ADDR_BIT_CR0, test_period[7:0], 1'b0);
    enqueue_transaction(1'b1, 1'b1, ADDR_BIT_CR1, {2'b00, test_period[13:8]}, 1'b0);
    enqueue_transaction(1'b1, 1'b1, ADDR_DATA_CR, data_size[7:0], 1'b0);
    execute_transactions(3);
    #0.1;
  end
  endtask

task check_outputs;
  input string check_tag;
  input logic [7:0] expected_prdata;
begin
  tb_mismatch = 1'b0;
  tb_check    = 1'b1;
  if(expected_prdata == tb_prdata) begin // Check passed
    $info("Correct 'prdata' output %s during %s test case%d", check_tag, tb_test_case,tb_test_case_num);
  end
  else begin // Check failed
    tb_mismatch = 1'b1;
    $error("Incorrect 'prdata' output %s during %s test case%d", check_tag, tb_test_case,tb_test_case_num);
  end
  // Wait some small amount of time so check pulse timing is visible on waves
  #(0.1);
  tb_check =1'b0;
end
endtask

//*****************************************************************************
// Bus Model Usage Related TB Tasks
//*****************************************************************************
// Task to pulse the reset for the bus model
task reset_model;
begin
  tb_model_reset = 1'b1;
  #(0.1);
  tb_model_reset = 1'b0;
end
endtask

// Task to enqueue a new transaction
task enqueue_transaction;
  input logic for_dut;
  input logic write_mode;
  input logic [ADDR_MAX_BIT:0] address;
  input logic [DATA_MAX_BIT:0] data;
  input logic expected_error;
begin
  // Make sure enqueue flag is low (will need a 0->1 pulse later)
  tb_enqueue_transaction = 1'b0;
  #0.1ns;

  // Setup info about transaction
  tb_transaction_fake  = ~for_dut;
  tb_transaction_write = write_mode;
  tb_transaction_addr  = address;
  tb_transaction_data  = data;
  tb_transaction_error = expected_error;

  // Pulse the enqueue flag
  tb_enqueue_transaction = 1'b1;
  #0.1ns;
  tb_enqueue_transaction = 1'b0;
end
endtask

// Task to wait for multiple transactions to happen
task execute_transactions;
  input integer num_transactions;
  integer wait_var;
begin
  // Activate the bus model
  tb_enable_transactions = 1'b1;
  @(posedge tb_clk);

  // Process the transactions
  for(wait_var = 0; wait_var < num_transactions; wait_var++) begin
    @(posedge tb_clk);
    @(posedge tb_clk);
  end

  // Turn off the bus model
  @(negedge tb_clk);
  tb_enable_transactions = 1'b0;
end
endtask

// Tasks for regulating the timing of input stimulus to the design
  
//*****************************************************************************
//*****************************************************************************
// Main TB Process
//*****************************************************************************
//*****************************************************************************
initial begin
  // Initialize Test Case Navigation Signals
  tb_test_case       = "Initilization";
  tb_test_case_num   = -1;
  tb_test_data       = '0;
  tb_check_tag       = "N/A";
  tb_test_bit_period = '0;
  tb_check           = 1'b0;
  tb_mismatch        = 1'b0;
  // Initialize all of the directly controled DUT inputs
  tb_n_rst          = 1'b1;
  tb_rx_data        = '0;
  tb_data_ready     = 1'b0;
  tb_overrun_error  = 1'b0;
  tb_framing_error  = 1'b0;
  // Initialize all of the bus model control inputs
  tb_model_reset          = 1'b0;
  tb_enable_transactions  = 1'b0;
  tb_enqueue_transaction  = 1'b0;
  tb_transaction_write    = 1'b0;
  tb_transaction_fake     = 1'b0;
  tb_transaction_addr     = '0;
  tb_transaction_data     = '0;
  tb_transaction_error    = 1'b0;
  tb_serial_in= 1;


  // Wait some time before starting first test case
  #(0.1);

  // Clear the bus model
  reset_model();

  //*****************************************************************************
  // Power-on-Reset Test Case
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Power-on-Reset";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Setup UART provided signals with 'active' values for reset check
  tb_rx_data        = '1;
  tb_data_ready     = 1'b1;
  tb_overrun_error  = 1'b1;
  tb_framing_error  = 1'b1;

  // Reset the DUT
  reset_dut();

  // Check outputs for reset state
  tb_expected_data_read  = 1'b0;
  tb_expected_bit_period = RESET_BIT_PERIOD;
  tb_expected_data_size  = RESET_DATA_SIZE;
  //check_outputs("after DUT reset");

  // Set all UART inputs back to inactive values
  tb_rx_data        = '0;
  tb_data_ready     = 1'b0;
  tb_overrun_error  = 1'b0;
  tb_framing_error  = 1'b0;

  //*****************************************************************************

  //*****************************************************************************
  // Test Case 1: Configure the Bit Period Settings
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Read from Bit Period Config Register after setting it";
  tb_test_case_num = tb_test_case_num + 1;

  // Reset the DUT to isolate from prior to isolate from prior test case
  reset_dut();
  
  // Enque the needed transactions (Overall period of 1000 clocks)
  tb_test_bit_period = 14'd10;
  // Enqueue the CR Writes
  enqueue_transaction(1'b1, 1'b1, ADDR_BIT_CR0, tb_test_bit_period[7:0], 1'b0);
  enqueue_transaction(1'b1, 1'b1, ADDR_BIT_CR1, {2'b00, tb_test_bit_period[13:8]}, 1'b0);
  
  // Run the write transactions via the model
  execute_transactions(2);

  // Check the DUT outputs
  tb_expected_data_read  = 1'b0;
  //tb_expected_bit_period = tb_test_bit_period;
  tb_expected_data_size  = RESET_DATA_SIZE;

  // Enqueue the CR Reads
  enqueue_transaction(1'b1, 1'b0, ADDR_BIT_CR0, tb_test_bit_period[7:0], 1'b0);
  execute_transactions(1);
  check_outputs("after attempting to configure a first period",tb_test_bit_period[7:0]);

  enqueue_transaction(1'b1, 1'b0, ADDR_BIT_CR1, {2'b00, tb_test_bit_period[13:8]}, 1'b0);
  execute_transactions(1);
  check_outputs("after attempting to configure a second bit period",{2'b00, tb_test_bit_period[13:8]});


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Student TODO: Add more test cases here
  // Update Navigation Info
  //TEST CASE 2
  tb_test_case     = "data size test";
  tb_test_case_num = tb_test_case_num + 1;
  // Reset the DUT to isolate from prior to isolate from prior test case
  //reset_dut();
  
  // Enque the needed transactions (Overall period of 1000 clocks)
  tb_data_size = 4'd8;
  //tb_test_bit_period = 14'd1111;
  // Enqueue the CR Writes
  enqueue_transaction(1'b1, 1'b1,ADDR_DATA_CR, tb_data_size, 1'b0);
  //enqueue_transaction(1'b1, 1'b1, 3'd6, {2'b00, tb_test_bit_period[13:8]}, 1'b1);
  // Run the write transactions via the model
  execute_transactions(1);

  enqueue_transaction(1'b1, 1'b0,ADDR_DATA_CR, tb_data_size, 1'b0);
  //enqueue_transaction(1'b1, 1'b1, 3'd6, {2'b00, tb_test_bit_period[13:8]}, 1'b1);
  // Run the write transactions via the model
  execute_transactions(1);
  check_outputs("after attempting to data size",tb_data_size);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //TEST CASE 3
  /*tb_test_case     = "data read test";
  tb_test_case_num = tb_test_case_num + 1;
  // Reset the DUT to isolate from prior to isolate from prior test case
  reset_dut();
  
  // Enque the needed transactions (Overall period of 1000 clocks)
  //tb_test_bit_period = 14'd10;
  bit_stream = 5'b10101;
  // Enqueue the CR Writes
  send_packet(bit_stream,5,tb_test_bit_period*CLK_PERIOD);
  enqueue_transaction(1'b1, 1'b0,ADDR_DATA_SR,8'b1, 1'b0);
  execute_transactions(1);
  //check for data ready
  check_outputs("check for data ready",8'b00000001);
  //test rx data 
  enqueue_transaction(1'b1, 1'b0, 3'd6, bit_stream, 1'b0);
  // Run the write transactions via the model
  execute_transactions(1);
  check_outputs("check rx_data",{3'b000,bit_stream});

  //check data ready after read
  enqueue_transaction(1'b1, 1'b0,ADDR_DATA_SR,8'b0, 1'b0);
  execute_transactions(1);
  check_outputs("check for data ready after data read",8'b00000000);*/
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//TEST CASE 4
  @(negedge tb_clk);  
  tb_test_case     = "normal package for rx_data test";
  tb_test_case_num = tb_test_case_num + 1;
  tb_data_ready     = 1'b1;
  //reset_dut();
   // Setup packet info for debugging/verificaton signals
   bit_stream       = 8'b01101101;
   tb_test_bit_period = NORM_DATA_PERIOD;
   // Send packet
   send_packet(bit_stream, 8, tb_test_bit_period);
  
   // Wait for 2 data periods to allow DUT to finish processing the packet
   #(tb_test_bit_period * 2);
  enqueue_transaction(1'b1, 1'b0, 3'd6, bit_stream, 1'b0);
  execute_transactions(1);
   // Check outputs
   check_outputs("SECOND check for data ready after data read",bit_stream);




  // test 4 slave error test
  tb_test_case     = "slave error test";
  tb_test_case_num = tb_test_case_num + 1;
  // Reset the DUT to isolate from prior to isolate from prior test case
  //reset_dut();
  
  // Enque the needed transactions (Overall period of 1000 clocks)
  $info("write to wrong address");
  enqueue_transaction(1'b1, 1'b1,3'd0, tb_rx_data, 1'b1);
  execute_transactions(1);
  $info("read to wrong address");
  enqueue_transaction(1'b1, 1'b0,3'd0, tb_rx_data, 1'b1);
  execute_transactions(1);

  // Enqueue the CR Writes
  //enqueue_transaction(1'b1, 1'b0,3'd7, tb_rx_data, 1'b1);
  //enqueue_transaction(1'b1, 1'b1, 3'd3, {2'b00, tb_test_bit_period[13:8]}, 1'b0);
  // Run the write transactions via the model
  //execute_transactions(1);

 //TEST CASE 2
  tb_test_case     = "data size2 test";
  tb_test_case_num = tb_test_case_num + 1;
  // Reset the DUT to isolate from prior to isolate from prior test case
  //reset_dut();
  
  // Enque the needed transactions (Overall period of 1000 clocks)
  tb_data_size = 4'd7;
  //tb_test_bit_period = 14'd1111;
  // Enqueue the CR Writes
  enqueue_transaction(1'b1, 1'b1,ADDR_DATA_CR, tb_data_size, 1'b0);
  //enqueue_transaction(1'b1, 1'b1, 3'd6, {2'b00, tb_test_bit_period[13:8]}, 1'b1);
  // Run the write transactions via the model
  execute_transactions(1);

  enqueue_transaction(1'b1, 1'b0,ADDR_DATA_CR, tb_data_size, 1'b0);
  //enqueue_transaction(1'b1, 1'b1, 3'd6, {2'b00, tb_test_bit_period[13:8]}, 1'b1);
  // Run the write transactions via the model
  execute_transactions(1);
  check_outputs("after attempting to data size",tb_data_size);

  //TEST CASE 5
  @(negedge tb_clk);  
  tb_test_case     = "normal package for rx_data test";
  tb_test_case_num = tb_test_case_num + 1;
  tb_data_ready     = 1'b1;
  //reset_dut();
   // Setup packet info for debugging/verificaton signals
   bit_stream       = 7'b1000110;
   tb_test_bit_period = NORM_DATA_PERIOD;
   // Send packet
   send_packet(bit_stream, 7, tb_test_bit_period);
  
   // Wait for 2 data periods to allow DUT to finish processing the packet
   #(tb_test_bit_period * 2);
  enqueue_transaction(1'b1, 1'b0, 3'd6, bit_stream, 1'b0);
  execute_transactions(1);
   // Check outputs
   check_outputs("third check for data ready after data read",bit_stream);
end

endmodule
 
