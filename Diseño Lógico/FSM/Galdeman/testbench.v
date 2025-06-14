module tb_detector_casa();

reg clk;
reg reset;
reg [4:0] simbolo;
wire [31:0] contador;

detector_casa dut (
    .clk(clk),
    .reset(reset),
    .simbolo(simbolo),
    .contador(contador)
);

// Clock
initial clk = 0;
always #5 clk = ~clk;

// Parámetros
parameter A = 5'd1;
parameter C = 5'd3;
parameter S = 5'd20;
parameter X = 5'd25;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_detector_casa);

    $display("Inicio de simulación");
    reset = 1;
    simbolo = 0;
    #10;
    reset = 0;

    // Envio secuencia: casa casa xx casa 
    send(C); send(A); send(S); send(A);
    send(C); send(A); send(S); send(A);
    send(X); send(X);
    send(C); send(A); send(S); send(A);

    #20;
    $display("Contador final: %d", contador);
    $finish;
end

task send(input [4:0] sym);
    begin
        simbolo = sym;
        #10;
    end
endtask

endmodule
