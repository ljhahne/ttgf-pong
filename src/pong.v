// clk_f = vidout_vs

module pong #(
    parameter [9:0] H_DISPLAY,
    parameter [9:0] V_DISPLAY,
    parameter [9:0] H_BPORCH,
    parameter [9:0] V_BPORCH,
    parameter SCALE,
    parameter [9:0] DIGIT_Y_OFFSET,
    parameter [9:0] DASH_LENGTH,
    parameter [9:0] GAP_LENGTH,
    parameter [9:0] LINE_LENGTH,
    parameter [9:0] PADDLE_OFFSET,
    parameter [9:0] PADDLE_W,
    parameter [9:0] PADDLE_H,
    parameter [9:0] PADDLE_V,
    parameter [9:0] SQUARE_W,
    parameter [9:0] SQUARE_H,
    parameter signed [10:0] V_X_INIT,
    parameter signed [10:0] V_Y_INIT
) (
    input  wire               clk,
    input  wire               reset_n,
    output wire               is_display,
    output wire               is_paddle_1,
    output wire               is_paddle_2,
    output wire        [23:0] rgb_paddle_1,
    output wire        [23:0] rgb_paddle_2,
    output wire        [23:0] rgb_square,
    output wire               is_square,
    output wire        [23:0] rgb_display_pong,
    input  wire        [ 9:0] x_count,
    input  wire        [ 9:0] y_count,
    input  wire               vidout_vs,
    input  wire               up1,
    input  wire               down1,
    input  wire               up2,
    input  wire               down2,
    output wire signed [10:0] square_x,
    output wire signed [10:0] square_y
);

  wire [3:0] score_left_ones;
  wire [3:0] score_left_tens;
  wire [3:0] score_right_ones;
  wire [3:0] score_right_tens;



  wire signed [10:0] paddle_x_1;
  wire signed [10:0] paddle_y_1;

  wire signed [10:0] paddle_x_2;
  wire signed [10:0] paddle_y_2;

  wire signed [10:0] paddle_1_next_y;
  wire signed [10:0] paddle_2_next_y;

  display #(
      .VID_H_ACTIVE(H_DISPLAY),
      .VID_V_ACTIVE(V_DISPLAY),
      .VID_H_BPORCH(H_BPORCH),
      .VID_V_BPORCH(V_BPORCH),
      .SCALE(SCALE),
      .DIGIT_Y_OFFSET(DIGIT_Y_OFFSET),
      .DASH_LENGTH(DASH_LENGTH),
      .GAP_LENGTH(GAP_LENGTH),
      .LENGTH(LINE_LENGTH)
  ) display_1 (
      .clk(clk),
      .reset_n(reset_n),
      .is_display(is_display),
      .rgb_display(rgb_display_pong),
      .x_count(x_count),
      .y_count(y_count),
      .score_left_ones(score_left_ones),
      .score_left_tens(score_left_tens),
      .score_right_ones(score_right_ones),
      .score_right_tens(score_right_tens)
  );

  // TODO hight calculation is wrong: paddle is not in the center
  paddle #(
      .IS_LEFT(1),
      .VID_H_ACTIVE(H_DISPLAY),
      .VID_V_ACTIVE(V_DISPLAY),
      .VID_H_BPORCH(H_BPORCH),
      .VID_V_BPORCH(V_BPORCH),
      .PADDLE_OFFSET(PADDLE_OFFSET),
      .PADDLE_W(PADDLE_W),
      .PADDLE_H(PADDLE_H),
      .PADDLE_V(PADDLE_V)
  ) paddle_1 (
      .clk(clk),
      .reset_n(reset_n),
      .vidout_vs(vidout_vs),
      .up(up1),
      .down(down1),
      .x_count(x_count),
      .y_count(y_count),
      .rgb_paddle(rgb_paddle_1),
      .paddle_x(paddle_x_1),
      .paddle_y(paddle_y_1),
      .is_paddle(is_paddle_1),
      .next_y(paddle_1_next_y)
  );


  paddle #(
      .IS_LEFT(0),
      .VID_H_ACTIVE(H_DISPLAY),
      .VID_V_ACTIVE(V_DISPLAY),
      .VID_H_BPORCH(H_BPORCH),
      .VID_V_BPORCH(V_BPORCH),
      .PADDLE_OFFSET(PADDLE_OFFSET),
      .PADDLE_W(PADDLE_W),
      .PADDLE_H(PADDLE_H),
      .PADDLE_V(PADDLE_V)
  ) paddle_2 (
      .clk(clk),
      .reset_n(reset_n),
      .vidout_vs(vidout_vs),
      .up(up2),
      .down(down2),
      .x_count(x_count),
      .y_count(y_count),
      .rgb_paddle(rgb_paddle_2),
      .paddle_x(paddle_x_2),
      .paddle_y(paddle_y_2),
      .is_paddle(is_paddle_2),
      .next_y(paddle_2_next_y)
  );

  square #(
      .VID_H_ACTIVE(H_DISPLAY),
      .VID_V_ACTIVE(V_DISPLAY),
      .VID_H_BPORCH(H_BPORCH),
      .VID_V_BPORCH(V_BPORCH),
      .SQUARE_W(SQUARE_W),
      .SQUARE_H(SQUARE_H),
      .PADDLE_H(PADDLE_H),
      .PADDLE_W(PADDLE_W),
      .V_X_INIT(V_X_INIT),
      .V_Y_INIT(V_Y_INIT)
  ) square_1 (
      .clk(clk),
      .reset_n(reset_n),
      .vidout_vs(vidout_vs),
      .x_count(x_count),
      .y_count(y_count),
      .rgb_square(rgb_square),
      .square_x_right(square_x),
      .square_y_bottom(square_y),
      .is_square(is_square),
      .paddle_left_x_right(paddle_x_1),
      .paddle_left_y_bottom_next(paddle_1_next_y),
      .paddle_right_x_right(paddle_x_2),
      .paddle_right_y_bottom_next(paddle_2_next_y),
      .score_left_ones(score_left_ones),
      .score_left_tens(score_left_tens),
      .score_right_ones(score_right_ones),
      .score_right_tens(score_right_tens)
  );


  wire _unused_ok = &{paddle_y_1, paddle_y_2};

endmodule
