module detector_casa (
    input wire clk,
    input wire reset,
    input wire [4:0] simbolo,
    output reg [31:0] contador
);

parameter A = 5'd1, C = 5'd3, S = 5'd20;

parameter IDLE = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;

reg [2:0] estado, proximo_estado;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        estado <= IDLE;
        contador <= 0;
    end else begin
        estado <= proximo_estado;
        if (proximo_estado == S4 && estado != S4)
            contador <= contador + 1;
    end
end

always @(*) begin
    case (estado)
        IDLE:      proximo_estado = (simbolo == C) ? S1 : IDLE;
        S1:        proximo_estado = (simbolo == A) ? S2 : (simbolo == C) ? S1 : IDLE;
        S2:        proximo_estado = (simbolo == S) ? S3 : (simbolo == C) ? S1 : IDLE;
        S3:        proximo_estado = (simbolo == A) ? S4 : (simbolo == C) ? S1 : IDLE;
        S4:        proximo_estado = (simbolo == C) ? S1 : IDLE;
        default:   proximo_estado = IDLE;
    endcase
end

endmodule
