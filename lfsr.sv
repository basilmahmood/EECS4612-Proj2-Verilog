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
    localparam start_load = clk_period*2;
    localparam finish_load = clk_period*3;
    localparam init_cycle = finish_load + cycle_period;

    initial begin
        s = 0;
        r = 1;
        clk = 0;
        load = 0;
    end

    always
        #(clk_period/2) clk = ~clk;

    initial begin
        #clk_period r = 0;

        #(start_load) load = 1;
        #(start_load) s = 1;

        #(finish_load) load = 0;
        #(finish_load) s = 0;

        #(init_cycle*3) $finish;
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

    mux load_mux(mux_out, load, s, q[N-1]);
    sr_flip_flop first_ff(mux_out, r, clk, q[0], qbar[0]);

    genvar i;
    generate
        for (i = 1; i < N; i++) begin

            if ((i == 2) || (i == 19)) begin
                xor tap(tap_out[i], q[N-1], q[i-1]);
                sr_flip_flop gen_with_tap(tap_out[i], r, clk, q[i], qbar[i]);
            end
            else begin
                sr_flip_flop gen_no_tap(q[i-1], r, clk, q[i], qbar[i]);
            end

        end
    endgenerate
endmodule

module sr_flip_flop(s, r, clk, q, qbar);

    input s,r,clk;
    output reg q, qbar;

    always @(posedge clk)
    begin

    if(s == 1)
        begin
            q = 1;
            qbar = 0;
        end
    else if(r == 1)
        begin
            q = 0;
            qbar = 1;
        end
    else if(s == 0 & r == 0)
        begin
            q = 0;
            qbar <= 1;
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
