`timescale 1ns/1ps

module tb;

    parameter N = 2;

    reg clk = 0;
    always #5 clk = ~clk;

    reg rst, start;
    reg signed [N-1:0] a, b;
    wire signed [2*N-1:0] result;
    wire done;

    serial_parallel_multiplier #(N) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(done)
    );

    integer i, j;

    initial begin
        $display("a\tb\tresult");
        rst = 1; start = 0;
        #10 rst = 0;

        for (i = -2; i < 2; i = i + 1) begin
            for (j = -2; j < 2; j = j + 1) begin
                a = i;
                b = j;
                start = 1;
                #10 start = 0;

                wait (done == 1);
                #5;
                $display("%0d\t%0d\t%0d", a, b, result);
                #10;
            end
        end

        $finish;
    end

endmodule