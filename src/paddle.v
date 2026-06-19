module paddle #(
    parameter IS_LEFT = 1,
    parameter [9:0] VID_H_ACTIVE = 0,
    parameter [9:0] VID_V_ACTIVE = 0,
    parameter [9:0] VID_H_BPORCH = 0,
    parameter [9:0] VID_V_BPORCH = 0,
    parameter [9:0] PADDLE_OFFSET = 0,
    parameter [9:0] PADDLE_W = 5,
    parameter [9:0] PADDLE_H = 20,
    parameter [9:0] PADDLE_V = 5,
    parameter COLOUR_DEFAULT = 24'hFFFFFF
) (

    input  wire              clk,
    input  wire              reset_n,
    input  wire              vidout_vs,
    input  wire              up,
    input  wire              down,
    input  wire       [ 9:0] x_count,
    input  wire       [ 9:0] y_count,
    output reg        [23:0] rgb_paddle,
    output reg signed [10:0] paddle_x,
    output reg signed [10:0] paddle_y,
    output wire              is_paddle,
    output reg signed [10:0] next_y
);

  localparam INIT_X = IS_LEFT ? (PADDLE_OFFSET + PADDLE_W - 1) : (VID_H_ACTIVE - PADDLE_OFFSET - 1);
  localparam INIT_Y = (VID_V_ACTIVE / 2 + PADDLE_H / 2 - 1);

  wire signed [10:0] x_count_s = $signed({1'b0, x_count});
  wire signed [10:0] y_count_s = $signed({1'b0, y_count});

  wire signed [10:0] visible_x_s = x_count_s - $signed({1'b0, VID_H_BPORCH});
  wire signed [10:0] visible_y_s = y_count_s - $signed({1'b0, VID_V_BPORCH});

  wire signed [10:0] PADDLE_W_S = $signed({1'b0, PADDLE_W});
  wire signed [10:0] PADDLE_H_S = $signed({1'b0, PADDLE_H});

  wire signed [10:0] VID_V_ACTIVE_S = $signed({1'b0, VID_V_ACTIVE});

  wire signed [10:0] left = paddle_x - (PADDLE_W_S - 1);
  wire signed [10:0] top = paddle_y - (PADDLE_H_S - 1);

  assign is_paddle =
    (visible_x_s >= left) && (visible_x_s <= paddle_x) &&
    (visible_y_s >= top ) && (visible_y_s <= paddle_y);


  always @(*) begin
    next_y = paddle_y;

    if (up) next_y = next_y - PADDLE_V;
    if (down) next_y = next_y + PADDLE_V;

    if (next_y < (PADDLE_H_S - 1)) next_y = (PADDLE_H_S - 1);
    else if (next_y > (VID_V_ACTIVE_S - 1)) next_y = (VID_V_ACTIVE_S - 1);
  end

  always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin

      paddle_x   <= INIT_X;
      paddle_y   <= INIT_Y;

      // default colour
      rgb_paddle <= COLOUR_DEFAULT;

    end else begin

      if (vidout_vs) begin
        paddle_y <= next_y;

      end


    end
  end

endmodule
