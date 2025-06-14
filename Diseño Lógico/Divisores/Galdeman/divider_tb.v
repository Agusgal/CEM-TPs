`timescale 1ns/1ps
module tb_div_binsearch;

    //------------------------------------------------------------------
    // Parametrización
    //------------------------------------------------------------------
    parameter N      = 16;
    localparam CLK_P = 10;              // 100 MHz

    //------------------------------------------------------------------
    // Conexiones de DUT 
    //------------------------------------------------------------------
    reg                 clk = 1'b0;
    reg                 rst = 1'b1;
    reg                 start = 1'b0;
    reg  signed [N-1:0] dividend;
    reg  signed [N-1:0] divisor;
    wire                busy;
    wire                done;
    wire signed [N-1:0] quotient;

    // Se instancia la división
    div_binsearch #(.N(N)) dut (
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .dividend (dividend),
        .divisor  (divisor),
        .busy     (busy),
        .done     (done),
        .quotient (quotient)
    );

    //------------------------------------------------------------------
    // Generación de clock
    //------------------------------------------------------------------
    always #(CLK_P/2) clk = ~clk;

    //------------------------------------------------------------------
    // Helper task
    //------------------------------------------------------------------
    task automatic do_divide;
        input signed [N-1:0] a, b;
        reg   signed [N-1:0] expected;
    begin
        @(negedge clk);
        dividend = a;
        divisor  = b;
        start    = 1'b1;
        @(negedge clk);
        start    = 1'b0;

        wait (done);

        if (b !== 0) begin
            expected = a / b;                   // Referencia behavioural 
            if (quotient !== expected)
                $display("FAIL: %0d / %0d  => got %0d, expected %0d",
                         a, b, quotient, expected);
            else
                $display("PASS: %0d / %0d  => %0d",
                         a, b, quotient);
        end
        else begin
            if (quotient !== 0)
                $display("FAIL: divide‑by‑zero produced %0d (should be 0)",
                         quotient);
            else
                $display("PASS: divide‑by‑zero handled (quotient=0)");
        end
        @(negedge clk);
    end
    endtask

    //------------------------------------------------------------------
    // Estimulos
    //------------------------------------------------------------------
    initial begin
        // Reset
        #(3*CLK_P) rst = 1'b0;

        // Set de pruebas
        do_divide(  42,   8);
        do_divide( -42,   8);
        do_divide(  42,  -8);
        do_divide( -42,  -8);

        do_divide(    100,     3);
        do_divide(   -100,     3);
        do_divide(    100,    -3);
        do_divide(   -100,    -3);

        do_divide(    257,    16);   // potencias de dos
        do_divide(   -257,    16);
        do_divide(    257,   -16);
        do_divide(   -257,   -16);

        do_divide(   7,   3);
        do_divide(   0,   5);
        do_divide(  10,   0);   // divison por cero
        do_divide( 32767, 123); // casi overflow
        do_divide(-32768,-321);

        #(10*CLK_P);
        $display("All tests finished.");
        $finish;
    end

endmodule