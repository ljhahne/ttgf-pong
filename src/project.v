/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ljhahne_pong(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // === Scaling (1 = FPGA 320x240 native, 2 = 640x480) ===
  localparam SCALE = 2;

  // === Display resolution ===
  localparam H_DISPLAY = 640;
  localparam V_DISPLAY = 480;
  localparam H_BPORCH  = 0;
  localparam V_BPORCH  = 0;

  // === Ball ===
  localparam [9:0] SQUARE_W = 10 * SCALE;
  localparam [9:0] SQUARE_H = 10 * SCALE;
  localparam signed [10:0] V_X_INIT = -4 * SCALE;
  localparam signed [10:0] V_Y_INIT =  4 * SCALE;

  // === Paddle ===
  localparam [9:0] PADDLE_W      = 5  * SCALE;
  localparam [9:0] PADDLE_H      = 20 * SCALE;
  localparam [9:0] PADDLE_OFFSET = 30 * SCALE;
  localparam [9:0] PADDLE_V      = 5  * SCALE;

  // === Display elements ===
  localparam [9:0] DIGIT_Y_OFFSET = 10 * SCALE;
  localparam [9:0] DASH_LENGTH    = 4  * SCALE;
  localparam [9:0] GAP_LENGTH     = 3  * SCALE;
  localparam [9:0] LINE_LENGTH    = 1  * SCALE;

  // VGA signals
  wire hsync;
  wire vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // Gamepad Pmod
  wire inp_b, inp_y, inp_select, inp_start, inp_up, inp_down, inp_left, inp_right, inp_a, inp_x, inp_l, inp_r;

  // is_present is deliberately not used 
  /* verilator lint_off PINCONNECTEMPTY */
  gamepad_pmod_single driver (
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(ui_in[6]),
      .pmod_clk(ui_in[5]),
      .pmod_latch(ui_in[4]),
      .b(inp_b),
      .y(inp_y),
      .select(inp_select),
      .start(inp_start),
      .up(inp_up),
      .down(inp_down),
      .left(inp_left),
      .right(inp_right),
      .a(inp_a),
      .x(inp_x),
      .l(inp_l),
      .r(inp_r),
      .is_present()
  );
  /* verilator lint_on PINCONNECTEMPTY */

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  wire clk_f;
  clk_frame clk_i(.clk(clk), .pix_y(pix_y), .clk_f(clk_f));

  wire is_display;
  wire is_paddle_1;
  wire is_paddle_2;
  wire is_square;
  wire [23:0] rgb_paddle_1;
  wire [23:0] rgb_paddle_2;
  wire [23:0] rgb_square;
  wire [23:0] rgb_display_pong;
  wire signed [10:0] square_x;
  wire signed [10:0] square_y;

  pong #(
      .H_DISPLAY(H_DISPLAY),
      .V_DISPLAY(V_DISPLAY),
      .H_BPORCH(H_BPORCH),
      .V_BPORCH(V_BPORCH),
      .SCALE(SCALE),
      .DIGIT_Y_OFFSET(DIGIT_Y_OFFSET),
      .DASH_LENGTH(DASH_LENGTH),
      .GAP_LENGTH(GAP_LENGTH),
      .LINE_LENGTH(LINE_LENGTH),
      .PADDLE_OFFSET(PADDLE_OFFSET),
      .PADDLE_W(PADDLE_W),
      .PADDLE_H(PADDLE_H),
      .PADDLE_V(PADDLE_V),
      .SQUARE_W(SQUARE_W),
      .SQUARE_H(SQUARE_H),
      .V_X_INIT(V_X_INIT),
      .V_Y_INIT(V_Y_INIT)
  ) pong_1 (
      .clk(clk),
      .reset_n(rst_n),
      .vidout_vs(clk_f),
      .up1(inp_up),
      .down1(inp_down),
      .up2(inp_a),
      .down2(inp_b),
      .x_count(pix_x),
      .y_count(pix_y),
      .is_display(is_display),
      .is_paddle_1(is_paddle_1),
      .is_paddle_2(is_paddle_2),
      .rgb_paddle_1(rgb_paddle_1),
      .rgb_paddle_2(rgb_paddle_2),
      .is_square(is_square),
      .rgb_square(rgb_square),
      .rgb_display_pong(rgb_display_pong),
      .square_x(square_x),
      .square_y(square_y)
  );

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin
      R <= 0;
      G <= 0;
      B <= 0;

      if (video_active) begin
        R <= (is_display || is_paddle_1 || is_paddle_2 || is_square) ? 2'b11 : 2'b00;
        G <= (is_display || is_paddle_1 || is_paddle_2 || is_square) ? 2'b11 : 2'b00;
        B <= (is_display || is_paddle_1 || is_paddle_2 || is_square) ? 2'b11 : 2'b00;
      end
    end
  end


  // Suppress unused signals warning
  wire _unused_ok_ = &{rgb_display_pong, rgb_paddle_1, rgb_paddle_2, rgb_square, square_x, square_y,
                        inp_y, inp_select, inp_start, inp_left, inp_right, inp_x, inp_l, inp_r};

endmodule
