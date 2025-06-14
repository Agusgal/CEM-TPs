`timescale 1ns/1ps
// ------------------------------------------------------------
//  Etapa combinacional CORDIC (rotación / vectorización)
// ------------------------------------------------------------
module cordic_stage (
    //  Entradas
    input  wire signed [18:0] x_i ,
    input  wire signed [18:0] y_i ,
    input  wire signed [17:0] z_i ,
    input  wire signed [17:0] phi_i ,
    input  wire        [ 3:0] i ,
    input  wire               rot0_vec1 , // 0 = rot, 1 = vec
    //  Salidas
    output wire signed [18:0] x_ip1 ,
    output wire signed [18:0] y_ip1 ,
    output wire signed [17:0] z_ip1
);
    // Signos
    wire sign_z = z_i[17];
    wire sign_y = y_i[18];

    // Desplazamientos aritméticos (>>>) para preservar signo
    wire signed [18:0] x_shifted = x_i >>> i;
    wire signed [18:0] y_shifted = y_i >>> i;

    // Dirección de giro
    wire di = rot0_vec1 ? sign_y : sign_z;

    // Próximos valores
    assign x_ip1 = di ? x_i + y_shifted : x_i - y_shifted;
    assign y_ip1 = di ? y_i - x_shifted : y_i + x_shifted;
    assign z_ip1 = di ? z_i + phi_i    : z_i - phi_i;
endmodule