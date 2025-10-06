//wrapper module

module wrapper(input signed [23:0] angle_in,
input input_valid, clk, rst,
output reg [23:0] angle_out,
output reg angle_valid,
output [1:0]quad_data);

    localparam signed [23:0] PI = 24'b0_11_001001000011111101101;
  	localparam signed [23:0] MINUS_PI = 24'b1_00_110110111100000010010;
    localparam signed [23:0] PI_BY_2 = 24'b0_01_100100100001111110110;
    localparam signed [23:0] MINUS_PI_BY_2 = 24'b1_10_011011011110000001001;
  
    reg[1:0] quadrant_data;

    always@(posedge(clk)) begin
        if(rst) begin
            quadrant_data <= 2'bx;
            angle_out <= 24'bx;
            angle_valid <= 1'b0;
        end
        else begin
            if((angle_in >= 0) && (angle_in <= PI_BY_2)) begin
                 quadrant_data <= 2'b00;
                 angle_out <= angle_in;
            end
          else if (((angle_in > PI_BY_2) && (angle_in <= PI)) || (angle_in < MINUS_PI)) begin
            if(!(angle_in < MINUS_PI))
                angle_out <= PI - angle_in;
            else angle_out <= -(PI + angle_in);
                quadrant_data <= 2'b01;
            end
          else if((angle_in < 0) && (angle_in >= MINUS_PI_BY_2)) begin
                angle_out <= -angle_in;
                quadrant_data <= 2'b10;
                end
          else begin
            if(angle_in > PI) angle_out <= angle_in - PI;
            else angle_out <= (PI + angle_in);
                quadrant_data <= 2'b11;
            end
            angle_valid <= input_valid;
        end
    end

    assign quad_data = quadrant_data;
endmodule
