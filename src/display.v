module score_render #(
    parameter [9:0] X0 = 0,
    parameter [9:0] Y0 = 0,
    parameter        SCALE = 1
)(
      input   wire            clk,
          input  wire             reset_n,
    input wire [9:0]  x_count,
    input wire [9:0]  y_count,
    input wire [3:0] score,
    output wire is_score
);


function [7:0] digit_row8;
  input [3:0] digit;
  input [2:0] row;
  begin
    digit_row8 = 8'b00000000;

    case (digit)
      4'd0: case (row)
        3'd0: digit_row8 = 8'b00111100;
        3'd1: digit_row8 = 8'b01100110;
        3'd2: digit_row8 = 8'b01101110;
        3'd3: digit_row8 = 8'b01110110;
        3'd4: digit_row8 = 8'b01100110;
        3'd5: digit_row8 = 8'b01100110;
        3'd6: digit_row8 = 8'b00111100;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd1: case (row)
        3'd0: digit_row8 = 8'b00011000;
        3'd1: digit_row8 = 8'b00111000;
        3'd2: digit_row8 = 8'b00011000;
        3'd3: digit_row8 = 8'b00011000;
        3'd4: digit_row8 = 8'b00011000;
        3'd5: digit_row8 = 8'b00011000;
        3'd6: digit_row8 = 8'b01111110;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd2: case (row)
        3'd0: digit_row8 = 8'b00111100;
        3'd1: digit_row8 = 8'b01100110;
        3'd2: digit_row8 = 8'b00000110;
        3'd3: digit_row8 = 8'b00001100;
        3'd4: digit_row8 = 8'b00110000;
        3'd5: digit_row8 = 8'b01100000;
        3'd6: digit_row8 = 8'b01111110;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd3: case (row)
        3'd0: digit_row8 = 8'b00111100;
        3'd1: digit_row8 = 8'b01100110;
        3'd2: digit_row8 = 8'b00000110;
        3'd3: digit_row8 = 8'b00011100;
        3'd4: digit_row8 = 8'b00000110;
        3'd5: digit_row8 = 8'b01100110;
        3'd6: digit_row8 = 8'b00111100;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd4: case (row)
        3'd0: digit_row8 = 8'b00001100;
        3'd1: digit_row8 = 8'b00011100;
        3'd2: digit_row8 = 8'b00101100;
        3'd3: digit_row8 = 8'b01001100;
        3'd4: digit_row8 = 8'b01111110;
        3'd5: digit_row8 = 8'b00001100;
        3'd6: digit_row8 = 8'b00001100;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd5: case (row)
        3'd0: digit_row8 = 8'b01111110;
        3'd1: digit_row8 = 8'b01100000;
        3'd2: digit_row8 = 8'b01111100;
        3'd3: digit_row8 = 8'b00000110;
        3'd4: digit_row8 = 8'b00000110;
        3'd5: digit_row8 = 8'b01100110;
        3'd6: digit_row8 = 8'b00111100;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd6: case (row)
        3'd0: digit_row8 = 8'b00111100;
        3'd1: digit_row8 = 8'b01100110;
        3'd2: digit_row8 = 8'b01100000;
        3'd3: digit_row8 = 8'b01111100;
        3'd4: digit_row8 = 8'b01100110;
        3'd5: digit_row8 = 8'b01100110;
        3'd6: digit_row8 = 8'b00111100;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd7: case (row)
        3'd0: digit_row8 = 8'b01111110;
        3'd1: digit_row8 = 8'b00000110;
        3'd2: digit_row8 = 8'b00001100;
        3'd3: digit_row8 = 8'b00011000;
        3'd4: digit_row8 = 8'b00110000;
        3'd5: digit_row8 = 8'b00110000;
        3'd6: digit_row8 = 8'b00110000;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd8: case (row)
        3'd0: digit_row8 = 8'b00111100;
        3'd1: digit_row8 = 8'b01100110;
        3'd2: digit_row8 = 8'b01100110;
        3'd3: digit_row8 = 8'b00111100;
        3'd4: digit_row8 = 8'b01100110;
        3'd5: digit_row8 = 8'b01100110;
        3'd6: digit_row8 = 8'b00111100;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      4'd9: case (row)
        3'd0: digit_row8 = 8'b00111100;
        3'd1: digit_row8 = 8'b01100110;
        3'd2: digit_row8 = 8'b01100110;
        3'd3: digit_row8 = 8'b00111110;
        3'd4: digit_row8 = 8'b00000110;
        3'd5: digit_row8 = 8'b01100110;
        3'd6: digit_row8 = 8'b00111100;
        3'd7: digit_row8 = 8'b00000000;
      endcase

      default: digit_row8 = 8'b00000000;
    endcase
  end
endfunction


// instantiating module sets X0 and Y0
/* verilator lint_off UNSIGNED */
wire in_score_box;
assign in_score_box =
    (x_count >= X0) && (x_count < X0 + 8*SCALE) &&
    (y_count >= Y0) && (y_count < Y0 + 8*SCALE);
/* verilator lint_on UNSIGNED */

wire [9:0] score_row_full = (y_count - Y0) / SCALE;
wire [9:0] score_col_full = (x_count - X0) / SCALE;
wire [2:0] score_row = score_row_full[2:0];
wire [2:0] score_col = score_col_full[2:0];
wire _unused_score = &{score_row_full[9:3], score_col_full[9:3]};

reg [3:0] prev_score;
reg [7:0] score_bits [0:7];

always @(posedge clk) begin
  if(~reset_n) begin

    score_bits[0] <= digit_row8(4'd0, 3'd0);
    score_bits[1] <= digit_row8(4'd0, 3'd1);
    score_bits[2] <= digit_row8(4'd0, 3'd2);
    score_bits[3] <= digit_row8(4'd0, 3'd3);
    score_bits[4] <= digit_row8(4'd0, 3'd4);
    score_bits[5] <= digit_row8(4'd0, 3'd5);
    score_bits[6] <= digit_row8(4'd0, 3'd6);
    score_bits[7] <= digit_row8(4'd0, 3'd7);

  end else if(score != prev_score) begin
    prev_score <= score;
    score_bits[0] <= digit_row8(score, 3'd0);
    score_bits[1] <= digit_row8(score, 3'd1);
    score_bits[2] <= digit_row8(score, 3'd2);
    score_bits[3] <= digit_row8(score, 3'd3);
    score_bits[4] <= digit_row8(score, 3'd4);
    score_bits[5] <= digit_row8(score, 3'd5);
    score_bits[6] <= digit_row8(score, 3'd6);
    score_bits[7] <= digit_row8(score, 3'd7);
  end
end

assign is_score = in_score_box && score_bits[score_row][7 - score_col];

endmodule

module dash_line #(
    parameter [9:0] LENGTH = 1,
    parameter [9:0] GAP_LENGTH = 3,
    parameter [9:0] DASH_LENGTH = 4,
    parameter [9:0] VID_V_ACTIVE = 0,
    parameter [9:0] VID_H_ACTIVE = 0,
    parameter [9:0] VID_H_BPORCH = 0,
    parameter [9:0] VID_V_BPORCH = 0
)(
        input   wire            clk,
          input  wire             reset_n,
    input wire [9:0]  x_count,
    input wire [9:0]  y_count,
    output wire is_dashline
);

wire is_line;
wire is_dash;



reg [9:0] y_dash;
reg [9:0] y_count_prev;

always @(posedge clk or negedge reset_n) begin
  if(~reset_n) begin
    y_dash <= 0;
    y_count_prev <= 0;
  end else begin
    y_count_prev <= y_count;
    if(y_count == 0) begin
      y_dash <= 0;
    end
    if(y_count != y_count_prev) begin
      // count from 0 to GAP_LENGTH + DASH_LENGTH - 1 repeatedly (modulo equivalent)
      y_dash <= (y_dash >= GAP_LENGTH + DASH_LENGTH - 1 ) ? 0 : y_dash + 1;
    end
  end
end

assign is_line = (x_count >= (VID_H_BPORCH + VID_H_ACTIVE/2 - LENGTH)) && (x_count <= (VID_H_BPORCH + VID_H_ACTIVE/2 + LENGTH));
// parameters instaniated by instantiating module
/* verilator lint_off UNSIGNED */
assign is_dash = y_count >= VID_V_BPORCH && y_count < VID_V_ACTIVE+VID_V_BPORCH && y_dash < DASH_LENGTH;
/* verilator lint_on UNSIGNED */
assign is_dashline = (is_dash && is_line);

endmodule


module display #(
    parameter [9:0] LENGTH = 1,
    parameter [9:0] GAP_LENGTH = 3,
    parameter [9:0] DASH_LENGTH = 4,
    parameter [9:0] VID_V_ACTIVE = 0,
    parameter [9:0] VID_H_ACTIVE = 0,
    parameter [9:0] VID_H_BPORCH = 0,
    parameter [9:0] VID_V_BPORCH = 0,
    parameter        SCALE = 1,
    parameter [9:0] DIGIT_Y_OFFSET = 10,
    parameter COLOUR_DEFAULT = 24'hFFFFFF
)(
    input   wire            clk,
    input  wire             reset_n,
    input wire [9:0]  x_count,
    input wire [9:0]  y_count,
    output wire is_display,
    output reg [23:0]  rgb_display,
    input wire [3:0] score_left_ones,
    input wire [3:0] score_left_tens,
    input wire [3:0] score_right_ones,
    input wire [3:0] score_right_tens
);

    wire is_score_left_tens;
    wire is_score_left_ones;

    wire is_score_right_ones;
    wire is_score_right_tens;

    wire is_rim;
    wire is_dashline;

    localparam [9:0] SCORE_Y0        = VID_V_BPORCH + DIGIT_Y_OFFSET;
    localparam [9:0] SCORE_L_TENS_X0 = VID_H_BPORCH;
    localparam [9:0] SCORE_L_ONES_X0 = VID_H_BPORCH + 10'd8 * SCALE;
    localparam [9:0] SCORE_R_ONES_X0 = VID_H_BPORCH + VID_H_ACTIVE - 10'd1 - 10'd8  * SCALE;
    localparam [9:0] SCORE_R_TENS_X0 = VID_H_BPORCH + VID_H_ACTIVE - 10'd1 - 10'd16 * SCALE;

    dash_line #(
        .VID_H_ACTIVE(VID_H_ACTIVE),
        .VID_V_ACTIVE(VID_V_ACTIVE),
        .VID_H_BPORCH(VID_H_BPORCH),
        .VID_V_BPORCH(VID_V_BPORCH),
        .LENGTH(LENGTH),
        .GAP_LENGTH(GAP_LENGTH),
        .DASH_LENGTH(DASH_LENGTH)
        ) dash_line_1 (
        .clk(clk),
        .reset_n(reset_n),
        .is_dashline(is_dashline),
        .x_count(x_count),
        .y_count(y_count)
        );


    score_render #(
        .X0(SCORE_L_TENS_X0),
        .Y0(SCORE_Y0),
        .SCALE(SCALE)
    ) score_render_left_tens(
        .clk(clk),
        .reset_n(reset_n),
        .x_count(x_count),
        .y_count(y_count),
        .score(score_left_tens),
        .is_score(is_score_left_tens)
    );

    score_render #(
        .X0(SCORE_L_ONES_X0),
        .Y0(SCORE_Y0),
        .SCALE(SCALE)
    ) score_render_left_ones(
        .clk(clk),
        .reset_n(reset_n),
        .x_count(x_count),
        .y_count(y_count),
        .score(score_left_ones),
        .is_score(is_score_left_ones)
    );

    score_render #(
        .X0(SCORE_R_ONES_X0),
        .Y0(SCORE_Y0),
        .SCALE(SCALE)
    ) score_render_right_ones(
        .clk(clk),
        .reset_n(reset_n),
        .x_count(x_count),
        .y_count(y_count),
        .score(score_right_ones),
        .is_score(is_score_right_ones)
    );

    score_render #(
        .X0(SCORE_R_TENS_X0),
        .Y0(SCORE_Y0),
        .SCALE(SCALE)
    ) score_render_right_tens(
        .clk(clk),
        .reset_n(reset_n),
        .x_count(x_count),
        .y_count(y_count),
        .score(score_right_tens),
        .is_score(is_score_right_tens)
    );

    // params all set by instantiating module
    /* verilator lint_off UNSIGNED */
    assign is_rim = (y_count >= VID_V_BPORCH && y_count < VID_V_BPORCH + SCALE) ||
                    (y_count >= VID_V_ACTIVE + VID_V_BPORCH - SCALE && y_count < VID_V_ACTIVE + VID_V_BPORCH);
    /* verilator lint_on UNSIGNED */
    assign is_display = is_dashline || is_rim || is_score_left_tens || is_score_left_ones || is_score_right_ones || is_score_right_tens;
    always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        // default colour
        rgb_display <= COLOUR_DEFAULT;
    end
end
endmodule
