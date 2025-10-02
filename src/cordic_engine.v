// Top module that connects wrapper (preprocessor) and cordic_engine

module cordic_engine(
    input  clk,
    input  rst,
  input  [31:0] angle_in,
    input         input_valid,
  output [31:0] sine,
  output [31:0] cosine
);

  wire [31:0] angle_processed;
    wire angle_valid;
    wire [1:0] quadrant_bits;

    // Wrapper (angle preprocessor)
    wrapper u_wrapper (
        .angle_in(angle_in),
        .input_valid(input_valid),
        .clk(clk),
        .rst(rst),
        .angle_out(angle_processed),
        .angle_valid(angle_valid),
        .quad_data(quadrant_bits)
    );

    // CORDIC Engine
    engine u_cordic (
        .angle(angle_processed),
        .sign(quadrant_bits),
        .angle_valid(angle_valid),
        .clk(clk),
        .rst(rst),
        .sine(sine),
        .cosine(cosine)
    );

endmodule
