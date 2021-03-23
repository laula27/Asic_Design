// $Id: $
// File name:   apb_slave.sv
// Created:     3/16/2021
// Author:      Laula Student
// Lab Section: 337-015
// Version:     1.0  Initial Design Entry
// Description: slave
module apb_slave (
    input wire clk,
    input wire n_rst, 
    input wire [7:0]rx_data,
    input wire data_ready,
    input wire overrun_error,
    input wire framing_error,
    input wire psel,
    input wire [2:0]paddr,
    input wire penable,
    input wire pwrite,
    input wire [7:0]pwdata,
    output reg [7:0]prdata,
    output reg pslverr,
    output reg [3:0]data_size,
    output reg [13:0]bit_period,
    output reg data_read
);
reg [7:0] nxt_prdata;
reg [13:0] nxt_bitperiod;
reg [3:0] nxt_datasize;

//reg nxt_dataread;
//reg nxt_pslverr;
//reg [7:0] nxt_rxdata;
always_ff @ (negedge n_rst, posedge clk)
begin : R_LOGIC
    if(1'b0 ==n_rst)
    begin
        prdata <= '0;
        bit_period <= '0;
        data_size <= '0;
        //data_read <= '0;
        //pslverr <= '0;
        //nxt_rxdata <= '0;
    end
    else
    begin
        prdata <= nxt_prdata;
        bit_period <= nxt_bitperiod;
        data_size <= nxt_datasize;
        //data_read <= nxt_dataread;
        //pslverr <= nxt_pslverr;
        //nxt_rxdata <= rx_data;
    end
end

always_comb 
begin
    pslverr=0;
    if(psel && penable)
    begin
        if(pwrite && !(paddr==3'd2 || paddr==3'd3 || paddr==3'd4))  
            pslverr=1;
        if(!pwrite && !(paddr==3'd0 || paddr==3'd1 || paddr==3'd2 || paddr==3'd3 || paddr==3'd4 || paddr==3'd6))
            pslverr=1;
    end
    
end

always_comb 
begin
    //read
    nxt_prdata = '0;
    data_read = '0;
    nxt_bitperiod = bit_period;
    nxt_datasize = data_size;
    //pslverr = '0;
    //write
    if(psel && pwrite)
    begin
        case(paddr)
            //3'b000: nxt_pslverr=1;
            //3'b001: nxt_pslverr=1;
            3'b010: nxt_bitperiod={bit_period[13:8],pwdata};
            3'b011: nxt_bitperiod={pwdata, bit_period[7:0]};
            3'b100: nxt_datasize={4'b0000,pwdata[3:0]};//extend upper four bit with zero
            //3'b110: nxt_pslverr=1;
        endcase 
    end
    if(psel && !pwrite)
    begin
        //nxt_prdata = prdata;
        case(paddr)
            3'b000: nxt_prdata={7'd0,data_ready};
            3'b001: 
            begin
                    nxt_prdata[0]=framing_error;
                    nxt_prdata[1]=overrun_error;
            end
            3'b010: nxt_prdata=bit_period[7:0];
            3'b011: nxt_prdata={2'b00,bit_period[13:8]};
            3'b100: nxt_prdata[3:0]= data_size;
            3'b110: 
            begin
                data_read=1;//clear data buffer
                nxt_prdata=rx_data;
            end
        endcase 
    end

end
endmodule







