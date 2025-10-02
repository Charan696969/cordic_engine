`timescale 1ns/1ps

module tb_cordic_top;

    reg clk;
    reg rst;
    reg [31:0] angle_in;
    reg input_valid;

    wire [31:0] sine;
    wire [31:0] cosine;

    cordic_engine uut (
        .clk(clk),
        .rst(rst),
        .angle_in(angle_in),
        .input_valid(input_valid),
        .sine(sine),
        .cosine(cosine)
    );

    always #5 clk = ~clk;

    // Q2.29 scale factor
    real scale = 2.0**29;

    // Test vectors (angles in radians)
    real test_angles [0:15];
    integer num_tests;
    initial begin
        test_angles[0]  = 0.0;
        test_angles[1]  = 0.01;
        test_angles[2]  = -0.01;
        test_angles[3]  = 3.141592653589793/4;
        test_angles[4]  = -(3.141592653589793/4);
        test_angles[5]  = 3.141592653589793/2;
        test_angles[6]  = -(3.141592653589793/2);
        test_angles[7]  = 3.141592653589793*3/4;
        test_angles[8]  = -(3.141592653589793*3/4);
        test_angles[9]  = 3.141592653589793;
        test_angles[10] = -3.141592653589793;
        test_angles[11] = 3.999;      
        test_angles[12] = -3.999;     
        test_angles[13] = -0.001;
        test_angles[14] = 3.1415;
        test_angles[15] = 2.71828;    
        num_tests = 16;
    end

    integer i;
    reg [31:0] fixed_angle;
    initial begin
        $dumpfile("cordic_tb.vcd");
        $dumpvars(0, tb_cordic_top);

        clk = 0;
        rst = 1;
        input_valid = 0;
        angle_in = 32'b0;

        #20;
        rst = 0;

        for (i = 0; i < num_tests; i = i + 1) begin
            fixed_angle = $rtoi(test_angles[i] * scale);
            @(posedge clk);
            angle_in = fixed_angle;
            input_valid = 1;
            @(posedge clk);
            input_valid = 0;

            // Wait for 34 cycles (CORDIC latency N=32)
            repeat (34) @(posedge clk);

            $display("Angle_in=%f | Sine(CORDIC)=%f | Cos(CORDIC)=%f | Sine(expected)=%f | Cos(expected)=%f",
                test_angles[i],
                $itor($signed(sine)) / scale,
                $itor($signed(cosine)) / scale,
                $sin(test_angles[i]),
                $cos(test_angles[i])
            );
        end

        $finish;
    end

endmodule
