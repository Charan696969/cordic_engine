  //CORDIC Engine Design


  module engine (
      input [23:0] angle,
      input [1:0] sign,
      input angle_valid, clk, rst,
      output reg [23:0] sine, cosine
  );

      localparam[1:0] IDLE = 2'b00, COMPUTE = 2'b01, DONE = 2'b10;
      localparam[5:0] N = 5'd23;

      reg[23:0] arctan_table[0:N-1];

      initial begin
        $readmemh("arctan_lut.hex",arctan_table);
      end

      reg[1:0] current, next;
      reg[4:0] counter;
      reg signed[23:0] x_reg, y_reg, z_reg;
      wire signed[23:0] z_next, arctan_value;
      reg di;

      always@(posedge(clk)) begin
          if(rst) begin
              current <= IDLE;
              counter <= 5'b0;
          end
          else begin current <= next;
            if(current == COMPUTE) counter <= counter + 5'd1;
            else counter <= 5'b0;
          end
      end

      always@(*) begin
          case (current)
              IDLE: next = angle_valid ? COMPUTE : IDLE;
              COMPUTE: next = (counter == N-1) ? DONE : COMPUTE;
              DONE: next = (counter == 0) ? IDLE : DONE;
              default: next = IDLE;
          endcase
      end

      always@(posedge(clk)) begin
          case (current)
              IDLE: begin
                  x_reg <= 24'b000100110110111010011101;
                  y_reg <= 24'b0;
                  z_reg <= angle;
                  di <= angle[23];
              end
              COMPUTE: begin
                    x_reg <= di ? (x_reg + (y_reg >>> (counter))) : (x_reg - (y_reg >>> (counter)));
                    y_reg <= di ? (y_reg - (x_reg >>> (counter))) : (y_reg + (x_reg >>> (counter)));
                    z_reg <= z_next;
                    di <= z_next[23];
              end
              DONE: begin
                cosine <= sign[0] ? -x_reg : x_reg;
                sine <= sign[1] ? -y_reg : y_reg;
              end 
              default: begin
                  sine <= 24'bx;
                  cosine <= 24'bx;
              end
          endcase
      end

    assign arctan_value = arctan_table[counter];
    assign z_next = di ? (z_reg + arctan_value) : (z_reg - arctan_value);

  endmodule
