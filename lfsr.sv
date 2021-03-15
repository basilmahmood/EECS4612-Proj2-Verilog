// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps

//test bench for d flip flop
//1. Declare module and ports

module testbench #(parameter N = 20);
    logic s, r, clk, load;
    logic [N-1:0] q, qbar;

    //2. Instantiate the module we want to test. We have instantiated the srff_behavior

    lfsr #(N) dut(.*); // instantiate all ports

    localparam clk_period = 10;
    localparam cycle_period = (clk_period*N);

    initial begin
        s = 0;
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
        s = 1;

        // Finish loading seed
        #clk_period
        load = 0;
        s = 0;

        #(cycle_period) $finish;
    end


endmodule

module lfsr #(parameter N = 26)
                (input clk,
                 input r,
                 input s,
                 input load,
                 output logic [N-1:0] q,
                 output logic [N-1:0] qbar);

    logic [N-1:0] tap_out;
    logic zero = 0;

    mux load_mux(mux_out, load, s, q[N-1]);
    d_flip_flop_with_sr first_ff(mux_out, zero, r, clk, q[0], qbar[0]);

    genvar i;
    generate
        for (i = 1; i < N; i++) begin

            if ((i == 2) || (i == 19)) begin
                xor tap(tap_out[i], q[N-1], q[i-1]);
                d_flip_flop_with_sr gen_with_tap(tap_out[i], zero, r, clk, q[i], qbar[i]);
            end
            else begin
                d_flip_flop_with_sr gen_no_tap(q[i-1], zero, r, clk, q[i], qbar[i]);
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
