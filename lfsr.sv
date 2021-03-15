// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

//test bench for d flip flop
//1. Declare module and ports

module testbench #(parameter N = 26);
    logic r, clk, load;
    logic [3:0] s;
    logic [N-1:0] q, qbar;

    control #(N) control(.*); // instantiate all ports

    localparam clk_period = 10;
    localparam cycle_period = (clk_period*N);

    initial begin
        s[3:0] = 4'b0;
        r = 1;
        clk = 0;
        load = 0;
    end

    always
        #(clk_period/2) clk = ~clk;

    initial begin
        // Loading seed
        #clk_period 
        r = 0;
        load = 1;
        s[3:0] = 4'b0001;

        // Finish loading seed
        #clk_period
        load = 0;
        s[3:0] = 4'b0;

        #(cycle_period*2) $finish;
    end


endmodule

module control #(parameter N = 26)
                (input clk,
                 input r,
                 input [3:0] s,
                 input load,
                 output logic [N-1:0] q,
                 output logic [N-1:0] qbar);
    
    lfsr #(N) lfsr(.*);
endmodule   

module lfsr #(parameter N = 26)
                (input clk,
                 input r,
                 input [3:0] s,
                 input load,
                 output logic [N-1:0] q,
                 output logic [N-1:0] qbar);

    logic [N-1:0] tap_out;
    logic [N-1:0] load_mux_out;
    logic zero = 0;

    genvar i_load_mux;
    generate 
        for (i_load_mux = 0; i_load_mux < 4; i_load_mux++) begin
            mux load_mux(load_mux_out[i_load_mux], load, s[i_load_mux], zero);
        end
    endgenerate

    // First flip_flop + tap has special logic (since the tap is comming from the last index)
    xor tap_first(tap_out[0], q[N-1], q[N-1]);
    d_flip_flop_with_sr ff_first(tap_out[0], load_mux_out[0], r, clk, q[0], qbar[0]);

    // Generate the rest of the taps and flip flops
    genvar i;
    generate
        for (i = 1; i < N; i++) begin
            // Create a flip-flop with a tap (tap location is 1 behind index location, i.e for tap 0 its created on index 1)
            if ((i == 0 + 1) || (i == 1 + 1) || (i == 5 + 1)) begin
                xor tap(tap_out[i], q[N-1], q[i-1]);
                d_flip_flop_with_sr gen_with_tap(tap_out[i], (i < 4) ? load_mux_out[i] : zero, r, clk, q[i], qbar[i]);
            end

            // Create a flip-flop with no tap
            else begin
                d_flip_flop_with_sr gen_no_tap(q[i-1], (i < 4) ? load_mux_out[i] : zero, r, clk, q[i], qbar[i]);
            end

        end
    endgenerate
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
