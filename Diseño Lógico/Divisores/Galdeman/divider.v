`timescale 1ns/1ps
module div_binsearch
#(
    parameter N = 16  // Tamaño de inputs y outputs.
)
(
    input                  clk,
    input                  rst,         // Reset sincronico activo alto. 
    input                  start,       
    input  signed [N-1:0]  dividend,
    input  signed [N-1:0]  divisor,
    output reg             busy,        // Alto mientras la divison este en proceso.
    output reg             done,        
    output reg signed [N-1:0] quotient  
);

    //----------------------------------------------------------------
    // Señales y parametros internos
    //----------------------------------------------------------------
    localparam S_IDLE   = 2'b00,
               S_INIT   = 2'b01,
               S_SEARCH = 2'b10,
               S_FINISH = 2'b11;

    reg [1:0] state;
    reg signed [N-1:0] abs_dividend;
    reg signed [N-1:0] abs_divisor;
    reg signed [N:0] L, H;
    reg q_sign;

    reg signed [N:0] mid_next;
    reg signed [2*N-1:0] prod_next;

    //----------------------------------------------------------------
    // Logica secuencial
    //----------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state    <= S_IDLE;
            busy     <= 1'b0;
            done     <= 1'b0;
            quotient <= 0;
            mid_next <= 0;
            prod_next <= 0;
        end else begin
            done <= 1'b0;

            case (state)
                //--------------------------------------------------
                S_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        if (divisor == 0) begin
                            quotient <= 0;
                            done     <= 1'b1;
                        end else begin
                            abs_dividend <= (dividend[N-1]) ? -dividend : dividend;
                            abs_divisor  <= (divisor[N-1])  ? -divisor  : divisor;
                            q_sign       <= dividend[N-1] ^ divisor[N-1];
                            state        <= S_INIT;
                            busy         <= 1'b1;
                        end
                    end
                end

                //--------------------------------------------------
                S_INIT: begin
                    L         <= 0;
                    H         <= {1'b0, abs_dividend};
                    state     <= S_SEARCH;
                end

                //--------------------------------------------------
                S_SEARCH: begin
                    mid_next  = (L + H + 1) >>> 1;
                    prod_next = mid_next * abs_divisor;

                    if (prod_next > {{(2*N - N){1'b0}}, abs_dividend})
                        H <= mid_next;
                    else
                        L <= mid_next;

                    if (H <= (L + 1))
                        state <= S_FINISH;
                end

                //--------------------------------------------------
                S_FINISH: begin
                    quotient <= q_sign ? -L[N-1:0] : L[N-1:0];
                    busy     <= 1'b0;
                    done     <= 1'b1;
                    state    <= S_IDLE;
                end

                //--------------------------------------------------
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule