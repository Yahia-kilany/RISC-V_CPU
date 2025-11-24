module clk_divider_2 (
    input  wire clk_i,      // Input clock (1 MHz)
    input  wire rst_i,      // Active high reset
    output reg  clk_o       // Output clock (500 kHz)
);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            clk_o <= 1'b0;
        end else begin
            clk_o <= ~clk_o;  // Toggle output clock every input clock cycle
        end
    end

endmodule