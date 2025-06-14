`timescale 1ns/1ps
// ------------------------------------------------------------
//  Test‑bench simple para el DUT CORDIC
// ------------------------------------------------------------
module tb_cordic;
    reg         rst, clk, start;
    reg  [17:0] x0,  y0,  z0;
    reg         rot0_vec1;
    reg  [ 3:0] n_iter;

    wire        done, busy;
    wire [18:0] xn, yn;
    wire [17:0] zn;

    // ---- DUT -------------------------------------------
    cordic_top dut (
        .rst(rst), .clk(clk), .start(start),
        .x0(x0), .y0(y0), .z0(z0),
        .rot0_vec1(rot0_vec1), .n_iter(n_iter),
        .done(done), .busy(busy),
        .xn(xn), .yn(yn), .zn(zn)
    );
    
        // --- probe para debug ---
    always @(posedge clk) begin
        if (dut.busy)
            $display("[%0t] busy=1  i=%0d  n_iter=%0d", $time, dut.i, dut.n_iter);
        if (dut.done)
            $display("[%0t] >>> DONE pulse!", $time);
    end

    // ---- Clock 10 ns -----------------------------------
    always #5 clk = ~clk;

    // ---- Dump VCD --------------------------------------
    initial begin
        $dumpfile("cordic.vcd");
        $dumpvars(0, tb_cordic);
    end

    // ---- Estímulos -------------------------------------
    initial begin
        // Reset
        rst   <= 1'b1; clk <= 1'b0; start <= 1'b0;
        #25   rst   <= 1'b0;

        // ---------- PRUEBA 1: rotación (x0>0) -------------
        @(negedge clk);
        rot0_vec1 <= 1'b0;            // modo rotación
        n_iter    <= 4'd15;
        x0 <= 18'sd32768;             // 1.0 en Q2.16
        y0 <= 18'sd0;
        z0 <= 18'sd8192;              // 45°/4   = 11.25°
        start <= 1'b1;
        @(negedge clk) start <= 1'b0;
        wait(done);

        // ---------- PRUEBA 2: vectorización x<0 ----------
        @(negedge clk);
        rot0_vec1 <= 1'b1;            // modo vectorización
        n_iter    <= 4'd15;
        x0 <= -18'sd39322;            // ≈‑0.6
        y0 <= -18'sd52429;            // ≈‑0.8
        z0 <= 18'sd0;
        start <= 1'b1;
        @(negedge clk) start <= 1'b0;
        wait(done);

        // Fin de simulación
        #20 $finish;
    end
endmodule