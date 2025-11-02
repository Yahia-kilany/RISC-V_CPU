`timescale 1ns / 1ps

/*******************************************************************
*
* Module: four_digit_seven_segment_driver.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description:
*   Drives a 4-digit 7-segment display. Accepts a 13-bit binary input (0–8191),
*   converts it to BCD, and multiplexes the four digits using a refresh counter.
*
* Dependencies:
*   bcd.v
*
* Change history:
*   09/9/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module four_digit_seven_segment_driver (
    input  wire        clk,        // Input clock
    input  wire [12:0] num_i,        // 13-bit binary input (0–8191)
    output reg  [3:0]  anode_o,      // Active-low anode control
    output reg  [6:0]  seg_o         // 7-segment cathode output
);

    // Internal BCD digit wires
    wire [3:0] thousands_w;
    wire [3:0] hundreds_w;
    wire [3:0] tens_w;
    wire [3:0] ones_w;

    // Refresh counter for multiplexing (20-bit)
    reg [19:0] refresh_counter_r = 20'd0;
    wire [1:0] digit_sel_w;

    // Instantiate binary-to-BCD converter
    bcd bcd_inst (
        .num_i       (num_i),
        .thousands_o (thousands_w),
        .hundreds_o  (hundreds_w),
        .tens_o      (tens_w),
        .ones_o      (ones_w)
    );

    // Increment refresh counter
    always @(posedge clk) begin
        refresh_counter_r <= refresh_counter_r + 1'b1;
    end

    // Use top bits for digit selection
    assign digit_sel_w = refresh_counter_r[19:18];

    // Current BCD digit to display
    reg [3:0] bcd_digit_r;

    // Digit selection and anode control
    always @* begin
        case (digit_sel_w)
            2'b00: begin
                anode_o    = 4'b0111;     // Enable leftmost digit
                bcd_digit_r = thousands_w;
            end
            2'b01: begin
                anode_o    = 4'b1011;
                bcd_digit_r = hundreds_w;
            end
            2'b10: begin
                anode_o    = 4'b1101;
                bcd_digit_r = tens_w;
            end
            2'b11: begin
                anode_o    = 4'b1110;     // Enable rightmost digit
                bcd_digit_r = ones_w;
            end
            default: begin
                anode_o    = 4'b1111;
                bcd_digit_r = 4'd0;
            end
        endcase
    end

    // BCD to seven-segment decoding
    always @* begin
        case (bcd_digit_r)
            4'd0: seg_o = 7'b0000001;
            4'd1: seg_o = 7'b1001111;
            4'd2: seg_o = 7'b0010010;
            4'd3: seg_o = 7'b0000110;
            4'd4: seg_o = 7'b1001100;
            4'd5: seg_o = 7'b0100100;
            4'd6: seg_o = 7'b0100000;
            4'd7: seg_o = 7'b0001111;
            4'd8: seg_o = 7'b0000000;
            4'd9: seg_o = 7'b0000100;
            default: seg_o = 7'b1111111; // Blank display
        endcase
    end

endmodule