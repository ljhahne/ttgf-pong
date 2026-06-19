module square #(
    parameter [9:0] VID_H_ACTIVE = 0,
    parameter [9:0] VID_V_ACTIVE = 0,
    parameter [9:0] VID_H_BPORCH = 0,
    parameter [9:0] VID_V_BPORCH = 0,
    parameter [9:0] SQUARE_W = 50,
    parameter [9:0] SQUARE_H = 50,
    parameter COLOUR_DEFAULT = 24'hFFFFFF,
    parameter [9:0] PADDLE_H = 0,
    parameter [9:0] PADDLE_W = 0,
    parameter signed [10:0] V_X_INIT = -4,
    parameter signed [10:0] V_Y_INIT = 4
) (

    input  wire               clk,
    input  wire               reset_n,
    input  wire               vidout_vs,
    input  wire        [ 9:0] x_count,
    input  wire        [ 9:0] y_count,
    output reg         [23:0] rgb_square,
    output reg signed  [10:0] square_x_right,
    output reg signed  [10:0] square_y_bottom,
    output wire               is_square,
    input  wire signed [10:0] paddle_left_x_right,
    input  wire signed [10:0] paddle_left_y_bottom_next,
    input  wire signed [10:0] paddle_right_x_right,
    input  wire signed [10:0] paddle_right_y_bottom_next,
    output reg         [ 3:0] score_left_ones,
    output reg         [ 3:0] score_right_ones,
    output reg         [ 3:0] score_left_tens,
    output reg         [ 3:0] score_right_tens
);

  function [7:0] score;
    input [3:0] score_tens_in;
    input [3:0] score_ones_in;
    begin
      if (score_ones_in == 4'd9) begin
        if (score_tens_in == 4'd9)
          // overflow
          score = {
            4'd0, 4'd0
          };
        else score = {score_tens_in + 1'b1, 4'd0};
      end else begin
        score = {score_tens_in, score_ones_in + 1'b1};
      end
    end
  endfunction

  localparam signed [10:0] V_X_ABS = V_X_INIT[10] ? -V_X_INIT : V_X_INIT;

  // init square bottom right
  localparam INIT_X = VID_H_ACTIVE / 2 + (SQUARE_W) / 2;
  localparam INIT_Y = VID_V_ACTIVE / 2 - (SQUARE_H) / 2;

  wire signed [10:0] x_count_s = $signed({1'b0, x_count});
  wire signed [10:0] y_count_s = $signed({1'b0, y_count});

  wire signed [10:0] visible_x_s = x_count_s - $signed({1'b0, VID_H_BPORCH});
  wire signed [10:0] visible_y_s = y_count_s - $signed({1'b0, VID_V_BPORCH});

  wire signed [10:0] SQUARE_W_S = $signed({1'b0, SQUARE_W});
  wire signed [10:0] SQUARE_H_S = $signed({1'b0, SQUARE_H});

  wire signed [10:0] PADDLE_H_S = $signed({1'b0, PADDLE_H});
  wire signed [10:0] PADDLE_W_S = $signed({1'b0, PADDLE_W});

  wire signed [10:0] VID_H_ACTIVE_S = $signed({1'b0, VID_H_ACTIVE});
  wire signed [10:0] VID_V_ACTIVE_S = $signed({1'b0, VID_V_ACTIVE});

  reg signed  [10:0] next_x_right;
  reg signed  [10:0] next_y;

  reg signed  [10:0] v_x;
  reg signed  [10:0] v_y;

  reg signed  [10:0] next_v_x;
  reg signed  [10:0] next_v_y;

  wire signed [10:0] square_x_left = square_x_right - (SQUARE_W_S - 1);
  wire signed [10:0] square_y_top = square_y_bottom - (SQUARE_H_S - 1);

  assign is_square =
    (visible_x_s >= square_x_left) && (visible_x_s <= square_x_right) &&
    (visible_y_s >= square_y_top ) && (visible_y_s <= square_y_bottom);

  // paddle interval
  wire signed [10:0] paddle_left_y_top    = paddle_left_y_bottom_next - (PADDLE_H_S - 1);
  wire signed [10:0] paddle_right_y_top_next    = paddle_right_y_bottom_next - (PADDLE_H_S - 1);

  // paddle 2 right
  wire signed [10:0] paddle_right_x_left = paddle_right_x_right - PADDLE_W_S;


  reg signed [10:0] ball_y_bottom;
  reg signed [10:0] ball_y_top;

  reg [3:0] score_left_ones_next;
  reg [3:0] score_right_ones_next;
  reg [3:0] score_left_tens_next;
  reg [3:0] score_right_tens_next;

  always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
      v_x <= V_X_INIT;
      v_y <= V_Y_INIT;

      square_x_right <= INIT_X;
      square_y_bottom <= INIT_Y;

      // default colour
      rgb_square <= COLOUR_DEFAULT;

      score_left_ones <= 0;
      score_right_ones <= 0;

      score_left_tens <= 0;
      score_right_tens <= 0;

    end else begin
      if (vidout_vs) begin
        square_x_right <= next_x_right;
        square_y_bottom <= next_y;

        v_x <= next_v_x;
        v_y <= next_v_y;
        score_left_ones <= score_left_ones_next;
        score_right_ones <= score_right_ones_next;

        score_left_tens <= score_left_tens_next;
        score_right_tens <= score_right_tens_next;
      end
    end
  end

  always @(*) begin
    // default
    ball_y_bottom = square_y_bottom;
    ball_y_top = ball_y_bottom - (SQUARE_H_S - 1);

    next_x_right = square_x_right + v_x;
    next_y = square_y_bottom + v_y;

    next_v_x = v_x;
    next_v_y = v_y;

    score_left_tens_next = score_left_tens;
    score_left_ones_next = score_left_ones;

    score_right_tens_next = score_right_tens;
    score_right_ones_next = score_right_ones;


    // reset when ball goes offscreen
    if ((next_x_right > (VID_H_ACTIVE_S - 1 + SQUARE_W_S)) | (next_x_right < 0)) begin
      if (next_x_right < 0) begin
        next_v_x = -V_X_ABS;
        {score_right_tens_next, score_right_ones_next} =
            score(score_right_tens_next, score_right_ones_next);

      end else begin
        {score_left_tens_next, score_left_ones_next} =
            score(score_left_tens_next, score_left_ones_next);
        next_v_x = V_X_ABS;
      end

      next_x_right = INIT_X;
      next_y = INIT_Y;

      next_v_y = V_Y_INIT;


      // left paddle
    end else if ((v_x < 0) && next_x_right <= (paddle_left_x_right + (SQUARE_W_S - 1))) begin
      ball_y_bottom = square_y_bottom + (paddle_left_x_right - square_x_left);
      // ball_y_top = ball_y_bottom - (SQUARE_H_S - 1);

      // collision check y-axis
      if ((ball_y_bottom >= paddle_left_y_top) && (ball_y_top <= paddle_left_y_bottom_next)) begin

        // next_x_right = square right edge
        next_x_right = paddle_left_x_right + (SQUARE_W_S - 1);
        next_v_x = -v_x;
      end

      // right paddle
    end else if ((v_x > 0) && next_x_right >= (paddle_right_x_right - PADDLE_W_S)) begin
      // ball_y_bottom = square_y_paddle_2;

      // we have to check if we would hit the paddle in the y domain if x_ball = x_paddle
      // we have
      // vec_ball + t * vec_speed = vec_paddle

      // to get the position of the ball in y we do
      // I vec_ball_x + t * vec_speed_x = vec_padlle_x
      // II vec_ball_y + t * vec_speed_y = vec_paddle_y
      // III use I: t = (vec_paddle_x - vec_ball_x)/vec_speed_x

      // vec_paddle_y = vec_ball_y + (vec_paddle_x - vec_ball_x)/vec_speed_x * vec_speed_y

      // square_y_bottom = right side of square
      ball_y_bottom = square_y_bottom + (paddle_right_x_left - square_x_right);
      // ball_y_top = ball_y_bottom - (SQUARE_H_S - 1);

      // we are not on the paddle if
      // ball_y_bottom > paddle_y_top OR ball_y_top < paddle_bottom
      // now use the inverse
      // ball_y_bottom <= paddle_y_top AND ball_y_top >= paddle_bottom

      // note that the coordinate system has an inverted y axis (low screen y value > high screen value) so we have to adjust our expression
      // ball_y_bottom >= paddle_y_top AND ball_y_top <= paddle_bottom

      // collision check y-axis
      if ((ball_y_bottom >= paddle_right_y_top_next) &&
          (ball_y_top <= paddle_right_y_bottom_next)) begin
        next_x_right = paddle_right_x_right - PADDLE_W_S;
        next_v_x = -v_x;
      end
    end
    // clamp Y
    if (next_y < (SQUARE_H_S - 1)) begin
      next_y   = (SQUARE_H_S - 1);
      next_v_y = -v_y;

    end else if (next_y > (VID_V_ACTIVE_S - 1)) begin
      next_y   = VID_V_ACTIVE_S - 1;
      next_v_y = -v_y;
    end
  end

endmodule
