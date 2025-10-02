//CORDIC Engine Design


module engine (
    input [31:0] angle,
    input [1:0] sign,
    input angle_valid, clk, rst,
    output reg [31:0] sine, cosine
);

    localparam[1:0] IDLE = 2'b00, COMPUTE = 2'b01, DONE = 2'b10;
    localparam[5:0] N = 6'd32;

    reg[31:0] arctan_table[0:N-1];

    initial begin
        $readmemh("arctan_lut.hex",arctan_table);
    end

    reg[1:0] current, next;
    reg[4:0] counter;
    reg signed[31:0] x_reg, y_reg, z_reg;
  wire signed[31:0] x,y,z,arctan_value;
    reg di;

    always@(posedge(clk)) begin
        if(rst) begin
            current <= IDLE;
            counter <= 5'b0;
            
        end
        else begin
            current <= next;
          if(current != IDLE) counter <= counter + 1;
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
                x_reg <= 32'b0;
            y_reg <= 32'b0;
            z_reg <= 32'b0;
            sine <= 32'bx;
            cosine <= 32'bx;
            end
            COMPUTE: begin
                if(counter == 0) begin
                    x_reg <= 32'b00010011011011101001110110110101;
                    y_reg <= 32'b0;
                    z_reg <= angle;
                  	di <= angle[31];
                end
                else begin
                  x_reg <= di ? (x_reg + (y_reg >>> (counter-1))) : (x_reg - (y_reg >>> (counter-1)));
                  y_reg <= di ? (y_reg - (x_reg >>> (counter-1))) : (y_reg + (x_reg >>> (counter-1)));
                  z_reg = di ? (z_reg + arctan_value) : (z_reg - arctan_value);
                  di = z_reg[31];
                  
                end
            end
            DONE: begin
              cosine <= sign[0] ? -x_reg : x_reg;
              sine <= sign[1] ? -y_reg : y_reg;
            end 
            default: begin
                sine <= 32'bx;
                cosine <= 32'bx;
            end
        endcase
    end

  assign arctan_value = counter ? arctan_table[counter-1] : 32'b0;

endmodule
