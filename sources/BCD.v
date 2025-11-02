`timescale 1ns / 1ps

/*******************************************************************
*
* Module: four_digit_seven_segment_driver.v
* Project: RISC-V_CPU
* Author: Yahia Kilany
* Author: Ouail Slama 
*
* Description:
*   Converts an 13-bit binary input (num_i) to four BCD digits:
*   thousands_o, hundreds_o, tens_o, ones_o.
*   Implements the double-dabble (shift-add-3) algorithm.
*
* Dependencies:
*   bcd.v
*
* Change history:
*   09/9/2025 – Initial lab version created
*   11/02/2025 – Adapted and cleaned for project use (Yahia)
*
*******************************************************************/

module bcd (
    input [12:0] num_i,
    output reg [3:0] thousands_o,
    output reg [3:0] hundreds_o,
    output reg [3:0] tens_o,
    output reg [3:0] ones_o
);
    always @* begin
        integer i;
        //initialization
        thousands_o = 4'd0;
        hundreds_o = 4'd0;
        tens_o = 4'd0;
        ones_o = 4'd0;
        
        for (i = 7; i >= 0 ; i = i-1 ) begin

            if(thousands_o >= 5)
                thousands_o = thousands_o + 3;
            if(hundreds_o >= 5 )
                hundreds_o = hundreds_o + 3;
            if (tens_o >= 5 )
                tens_o = tens_o + 3;
            if (ones_o >= 5)
                ones_o = ones_o +3;

            //shift left one
            thousands_o  = thousands_o<<1;
            thousands_o [0] = hundreds_o[3]; 
            hundreds_o = hundreds_o << 1;
            hundreds_o [0] = tens_o [3];
            tens_o = tens_o << 1;
            tens_o [0] = ones_o[3];
            ones_o = ones_o << 1;
            ones_o[0] = num_i[i];
            
        end
    end
endmodule

