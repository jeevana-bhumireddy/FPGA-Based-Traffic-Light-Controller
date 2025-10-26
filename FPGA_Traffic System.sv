
module tc(
    input CLOCK_50, reset_n,
    input sN, sE,
    output reg GN, YN, RN,
    output reg GE, YE, RE,
    output wire [6:0] HEX,
    output reg EN1, EN2
);

    // Internal wires and registers
    reg [1:0] tens_counter; // Tens counter (0 to 3)
    reg [3:0] ones_counter; // Ones counter (0 to 9)
    reg [1:0] state_reg, state_next;
    wire clk_1hz, clk_100hz;

    // Synchronize sensor inputs
    reg se_sync, sn_sync;
    always @(posedge clk_1hz or negedge reset_n) begin
        if (~reset_n) begin
            se_sync <= 1'b0;
            sn_sync <= 1'b0;
        end else begin
            se_sync <= sE;
            sn_sync <= sN;
        end
    end

    // State encoding
    localparam s0 = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11;

    // Clock dividers
    counter_divider_1hz clk_div_1hz (
        .c_clr(reset_n),
        .c_clk(CLOCK_50),
        .clk_d(clk_1hz)
    );

    counter_divider_100hz clk_div_100hz (
        .c_clr(reset_n),
        .c_clk(CLOCK_50),
        .clk_d(clk_100hz)
    );

    // State machine
    always @(posedge clk_1hz or negedge reset_n) begin
        if (~reset_n)
            state_reg <= s0;
        else
            state_reg <= state_next;
    end

    always @(*) begin
        state_next = state_reg;

        case (state_reg)
            s0: begin
                if ((tens_counter == 3) && (ones_counter == 0))
                    if (se_sync)
                        state_next = s1;
                    else
                        state_next = s0;
                else
                    state_next = s0;
            end
            s1: begin
                if ((tens_counter == 0) && (ones_counter == 5))
                    state_next = s2;
                else
                    state_next = s1;
            end
            s2: begin
                if ((tens_counter == 3) && (ones_counter == 0))
                    if (sn_sync)
                        state_next = s3;
                    else
                        state_next = s2;
                else
                    state_next = s2;
            end
            s3: begin
                if ((tens_counter == 0) && (ones_counter == 5))
                    state_next = s0;
                else
                    state_next = s3;
            end
        endcase
    end

    // BCD counters
    always @(posedge clk_1hz or negedge reset_n) begin
        if (~reset_n) begin
            tens_counter <= 0;
            ones_counter <= 0;
        end else begin
            if ((tens_counter == 3) && (ones_counter == 0)) begin
                tens_counter <= 0;
                ones_counter <= 0;
            end else if (ones_counter == 9) begin
                ones_counter <= 0;
                tens_counter <= tens_counter + 1;
            end else
                ones_counter <= ones_counter + 1;
        end
    end

    // Output logic
    always @(*) begin
        GN = 1'b1;
        YN = 1'b1;
        RN = 1'b1;
        GE = 1'b1;
        YE = 1'b1;
        RE = 1'b1;

        case (state_reg)
            s0: begin
                GN = 1'b0;
                RE = 1'b0;
            end
            s1: begin
                YN = 1'b0;
                RE = 1'b0;
            end
            s2: begin
                GE = 1'b0;
                RN = 1'b0;
            end
            s3: begin
                YE = 1'b0;
                RN = 1'b0;
            end
        endcase
    end

    // Display multiplexing
    reg display_sel;
    wire [3:0] bcd_input;
    assign bcd_input = display_sel ? {2'b00, tens_counter} : ones_counter;

    always @(posedge clk_100hz or negedge reset_n) begin
        if (~reset_n)
            display_sel <= 1'b0;
        else
            display_sel <= ~display_sel;
    end

    // BCD to 7-segment decoder
    b2d_ssd H (
        .X(bcd_input),
        .SSD(HEX)
    );

    always @* begin
        if (display_sel) begin
            EN1 = 1'b1; // Enable tens display
            EN2 = 1'b0;
        end else begin
            EN1 = 1'b0; // Enable ones display
            EN2 = 1'b1;
        end
    end

endmodule

// 1 Hz clock divider
module counter_divider_1hz (
    input c_clr,
    input c_clk,
    output reg clk_d
);

    reg [24:0] counter;

    always @(posedge c_clk or negedge c_clr) begin
        if (~c_clr)
            counter <= 0;
        else begin
            if (counter == 25'd24999999) begin
                clk_d <= ~clk_d;
                counter <= 0;
            end else
                counter <= counter + 1;
        end
    end

endmodule

// 100 Hz clock divider
module counter_divider_100hz (
    input c_clr,
    input c_clk,
    output reg clk_d
);

    reg [19:0] counter;

    always @(posedge c_clk or negedge c_clr) begin
        if (~c_clr)
            counter <= 0;
        else begin
            if (counter == 20'd249999) begin
                clk_d <= ~clk_d;
                counter <= 0;
            end else
                counter <= counter + 1;
        end
    end

endmodule

// BCD to 7-segment decoder
module b2d_ssd (
    input [3:0] X,
    output reg [6:0] SSD
);

  always @(*) begin
        case (X)
            4'd0: SSD = 7'b1000000; // gfedcba
            4'd1: SSD = 7'b1111001;
            4'd2: SSD = 7'b0100100;
            4'd3: SSD = 7'b0110000;
            4'd4: SSD = 7'b0011001;
            4'd5: SSD = 7'b0010010;
            4'd6: SSD = 7'b0000010;
            4'd7: SSD = 7'b1111000;
            4'd8: SSD = 7'b0000000;
            4'd9: SSD = 7'b0010000;
            default: SSD = 7'b1111111;

        endcase
    end

endmodule