module clk_frame(input wire clk, input reg [9:0] pix_y, output wire clk_f);
    reg [9:0] prev_y;

    always @(posedge clk) begin
    prev_y <= pix_y;
    end

    assign clk_f = (pix_y == 0) && (prev_y != 0);
endmodule