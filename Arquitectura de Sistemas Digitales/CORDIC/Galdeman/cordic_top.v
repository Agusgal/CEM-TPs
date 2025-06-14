`timescale 1ns/1ps
// ------------------------------------------------------------
//  Top‑level CORDIC – parametrizable y con pre‑acondicionamiento
// ------------------------------------------------------------
module cordic_top (
    // ---------------- Entradas ----------------
    input  wire         rst   ,
    input  wire         clk   ,
    input  wire         start ,
    input  wire  [17:0] x0    ,
    input  wire  [17:0] y0    ,
    input  wire  [17:0] z0    ,
    input  wire         rot0_vec1 ,   // 0‑rot, 1‑vec
    input  wire  [ 3:0] n_iter    ,   // nº iteraciones (1‑16)
    // ---------------- Salidas -----------------
    output reg          done  ,
    output reg          busy  ,
    output reg  [18:0]  xn    ,
    output reg  [18:0]  yn    ,
    output reg  [17:0]  zn
);
    // ---------------- Constantes --------------
    // π codificado como –131 072 (18‑bit signado: 0x2_0000)
    localparam signed [17:0] PI = 18'sh20000;

    // ---------------- Pre‑acondicionamiento ------------
    // Sólo en modo vectorización y cuando x0 < 0
    wire signed [17:0] x0_adj, y0_adj, z0_adj;

    assign {x0_adj, y0_adj, z0_adj} =
           (rot0_vec1 && x0[17]) ?             // ¿vec + x0 negativo?
             ( y0[17] ?                        // y0 < 0  →  +π
               { -x0 , -y0 , z0 - PI } :
               { -x0 , -y0 , z0 + PI } ) :     // y0 > 0  →  –π
             {  x0 ,  y0 ,  z0 };              // caso normal

    // ---------------- Señales internas ----------------
    reg  [18:0] x_q, y_q;
    reg  [17:0] z_q;
    wire [18:0] x_next, y_next;
    wire [17:0] z_next;
    reg  [ 3:0] i;
    reg         en_outs;

    // LUT de ángulos (18‑bit Q2.16, 16 valores)
    reg signed [17:0] phi_i;
    always @(*) begin
        case (i)
            4'd0  : phi_i = 18'd32768;   // 45°
            4'd1  : phi_i = 18'd19344;
            4'd2  : phi_i = 18'd10221;
            4'd3  : phi_i = 18'd5188;
            4'd4  : phi_i = 18'd2604;
            4'd5  : phi_i = 18'd1302;
            4'd6  : phi_i = 18'd652;
            4'd7  : phi_i = 18'd326;
            4'd8  : phi_i = 18'd163;
            4'd9  : phi_i = 18'd82;
            4'd10 : phi_i = 18'd41;
            4'd11 : phi_i = 18'd20;
            4'd12 : phi_i = 18'd10;
            4'd13 : phi_i = 18'd5;
            4'd14 : phi_i = 18'd3;
            4'd15 : phi_i = 18'd1;
        endcase
    end

    // ---------------- Instancia de etapa ----------------
    cordic_stage u_stage (
        .x_i (x_q),  .y_i (y_q),  .z_i (z_q),
        .phi_i (phi_i), .i (i),
        .rot0_vec1 (rot0_vec1),
        .x_ip1 (x_next), .y_ip1 (y_next), .z_ip1 (z_next)
    );

    // ---------------- Registros datapath ---------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x_q <= 19'sd0; y_q <= 19'sd0; z_q <= 18'sd0;
        end else if (start) begin
            x_q <= { x0_adj[17], x0_adj }; // extens. de signo a 19 bits
            y_q <= { y0_adj[17], y0_adj };
            z_q <=  z0_adj;
        end else if (busy) begin
            x_q <= x_next;
            y_q <= y_next;
            z_q <= z_next;
        end
    end

    // ---------------- Salidas registradas --------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            xn <= 19'sd0; yn <= 19'sd0; zn <= 18'sd0;
        end else if (en_outs) begin
            xn <= x_q; yn <= y_q; zn <= z_q;
        end
    end

    // ---------------- FSM de control -------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 4'd0; busy <= 1'b0; done <= 1'b0; en_outs <= 1'b0;
        end else begin
            done <= 1'b0;      // pulso de un ciclo
            en_outs <= 1'b0;

            if (start) begin
                busy <= 1'b1;
                i    <= 4'd0;
            end else if (busy) begin
                if (i == (n_iter - 1)) begin
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    en_outs <= 1'b1;
                end else begin
                    i <= i + 4'd1;
                end
            end
        end
    end

    
endmodule