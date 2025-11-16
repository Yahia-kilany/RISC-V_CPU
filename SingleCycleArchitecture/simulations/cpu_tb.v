`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 09:28:57 PM
// Design Name: 
// Module Name: cpu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu_tb;

    reg clk, rst;
    reg [1:0] led_sel_i;
    reg [3:0] ssd_sel_i;
    wire [15:0] inst_led_o;
    wire [12:0] ssd_o;

    // Instantiate CPU
    cpu uut (
        .clk       (clk),
        .rst       (rst),
        .led_sel_i (led_sel_i),
        .ssd_sel_i (ssd_sel_i),
        .inst_led_o(inst_led_o),
        .ssd_o     (ssd_o)
    );

    // Clock generation: 10ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;


    initial begin
        rst = 1;
        led_sel_i = 2'b00;
        ssd_sel_i = 4'b0000;

        // Keep reset asserted for some cycles
        #20;
        rst = 0;

        // Run simulation for a fixed time or number of clock cycles
        #1000;  // Simulate 1000ns (~100 clock cycles)

        $stop;  // Stop simulation
    end
endmodule


