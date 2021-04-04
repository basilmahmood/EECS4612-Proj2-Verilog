// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

module testbench #(parameter N = 26);
    logic reset, clk, load, gen;
    logic [3:0] seed;
    logic [N-1:0] q, qbar;
    logic [N-1:0] vectors[1000:0], currentvec;
    logic [10:0] vectornum, errors;
    logic always_flag;

    control #(N) control(.*); // instantiate all ports

    localparam clk_period = 10;
    localparam cycle_period = (clk_period*N);

    initial begin
        seed[3:0] = 4'b0;
        reset = 1;
        clk = 0;
        load = 0;
        gen = 0;
        $readmemb("lfsr.tv", vectors);
        vectornum = 0;
        errors = 0;
    end

    always
        #(clk_period/2) clk = ~clk;

    initial begin
        // Loading seed
        #clk_period
        reset = 0;
        load = 1;
        seed[3:0] = 4'b0001;

        // Finish loading seed and start generation
        #clk_period
        load = 0;
        seed[3:0] = 4'b0;
        gen = 1;
    end

    always begin
        #(cycle_period) // Delay by the cycle period every time
        if (vectornum == 0) #(clk_period*2); // Delay by an additional 2 clk_periods if first run

        currentvec = vectors[vectornum];
        if (currentvec[0] === 1'bx) begin
            $display("Completed %d tests with %d errors.", vectornum, errors);
            $stop;
        end else begin
            if (q[N-1:0] !== currentvec[N-1:0]) begin
                $display("output = %b (%b expected)", q[N-1:0], currentvec[N-1:0]);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end

    end

endmodule

module control #(parameter N = 26)
                (input clk,
                 input reset,
                 input [3:0] seed,
                 input load,
                 input gen,
                 output logic [N-1:0] q,
                 output logic [N-1:0] qbar);

    logic zero = 0;
    logic [N-1:0] s;

    mux load_mux_0(s[0], load, seed[0], zero);
    mux load_mux_1(s[1], load, seed[1], zero);
    mux load_mux_2(s[2], load, seed[2], zero);
    mux load_mux_3(s[3], load, seed[3], zero);

    assign s[25:4] = 21'b0;

    or clk_or(clk_on, reset, load, gen);
    mux clk_mux(clk_mux_out, clk_on, clk, zero);

    lfsr #(N) lfsr(.*, .clk (clk_mux_out), .r (reset));
endmodule

module lfsr #(parameter N = 26)
                (input clk,
                 input r, // Reset for flip flops
                 input [N-1:0] s, // Set for flip flops
                 output logic [N-1:0] q,
                 output logic [N-1:0] qbar);

    logic [N-1:0] tap_out;

    xor tap_0(tap_out[0], q[N-1], q[N-1]);
    d_flip_flop_with_sr ff_0(tap_out[0], s[0], r, clk, q[0], qbar[0]);

    xor tap_1(tap_out[1], q[0], q[N-1]);
    d_flip_flop_with_sr ff_1(tap_out[1], s[1], r, clk, q[1], qbar[1]);

    xor tap_2(tap_out[2], q[1], q[N-1]);
    d_flip_flop_with_sr ff_2(tap_out[2], s[2], r, clk, q[2], qbar[2]);

    d_flip_flop_with_sr ff_3(q[2], s[3], r, clk, q[3], qbar[3]);
    d_flip_flop_with_sr ff_4(q[3], s[4], r, clk, q[4], qbar[4]);
    d_flip_flop_with_sr ff_5(q[4], s[5], r, clk, q[5], qbar[5]);

    xor tap_6(tap_out[6], q[5], q[N-1]);
    d_flip_flop_with_sr ff_6(tap_out[6], s[6], r, clk, q[6], qbar[6]);

    d_flip_flop_with_sr ff_7(q[6], s[7], r, clk, q[7], qbar[7]);
    d_flip_flop_with_sr ff_8(q[7], s[8], r, clk, q[8], qbar[8]);
    d_flip_flop_with_sr ff_9(q[8], s[9], r, clk, q[9], qbar[9]);
    d_flip_flop_with_sr ff_10(q[9], s[10], r, clk, q[10], qbar[10]);
    d_flip_flop_with_sr ff_11(q[10], s[11], r, clk, q[11], qbar[11]);
    d_flip_flop_with_sr ff_12(q[11], s[12], r, clk, q[12], qbar[12]);
    d_flip_flop_with_sr ff_13(q[12], s[13], r, clk, q[13], qbar[13]);
    d_flip_flop_with_sr ff_14(q[13], s[14], r, clk, q[14], qbar[14]);
    d_flip_flop_with_sr ff_15(q[14], s[15], r, clk, q[15], qbar[15]);
    d_flip_flop_with_sr ff_16(q[15], s[16], r, clk, q[16], qbar[16]);
    d_flip_flop_with_sr ff_17(q[16], s[17], r, clk, q[17], qbar[17]);
    d_flip_flop_with_sr ff_18(q[17], s[18], r, clk, q[18], qbar[18]);
    d_flip_flop_with_sr ff_19(q[18], s[19], r, clk, q[19], qbar[19]);
    d_flip_flop_with_sr ff_20(q[19], s[20], r, clk, q[20], qbar[20]);
    d_flip_flop_with_sr ff_21(q[20], s[21], r, clk, q[21], qbar[21]);
    d_flip_flop_with_sr ff_22(q[21], s[22], r, clk, q[22], qbar[22]);
    d_flip_flop_with_sr ff_23(q[22], s[23], r, clk, q[23], qbar[23]);
    d_flip_flop_with_sr ff_24(q[23], s[24], r, clk, q[24], qbar[24]);
    d_flip_flop_with_sr ff_25(q[24], s[25], r, clk, q[25], qbar[25]);
    
endmodule

// See https://en.wikipedia.org/wiki/Flip-flop_(electronics)#/media/File:Edge_triggered_D_flip_flop_with_set_and_reset.svg for diagram
module d_flip_flop_with_sr(d, s, r, clk, q, qbar);

    input d,s,r,clk;
    output reg q, qbar;

    always @(posedge clk)
    begin
        if (s == 0 && r == 0)
            begin
                q = d;
                qbar = ~d;
            end
        else
            begin
               q = s;
               qbar = r;
            end
    end
endmodule

module mux(f, sel, a, b);
    output f;
    input a, b, sel;
    reg f;

    always @(a or b or sel)
        if (sel) f = a;
        else f = b;
endmodule
