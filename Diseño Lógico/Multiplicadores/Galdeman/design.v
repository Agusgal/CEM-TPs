module serial_parallel_multiplier #(parameter N = 4)(
    input clk,
    input rst,
    input start,
    input signed [N-1:0] a,
    input signed [N-1:0] b,
    output reg signed [2*N-1:0] result,
    output reg done
);

    reg [N-1:0] a_abs, b_abs;
    reg signed [2*N-1:0] acc;
    reg [N-1:0] b_shift;
    reg [$clog2(N+1)-1:0] count;
    reg negative_result;
    reg busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc <= 0;
            result <= 0;
            done <= 0;
            busy <= 0;
            count <= 0;
        end else if (start && !busy) begin
            // start operation
            busy <= 1;
            done <= 0;
            acc <= 0;
            count <= 0;
            a_abs <= a[N-1] ? -a : a;
            b_abs <= b[N-1] ? -b : b;
            b_shift <= b[N-1] ? -b : b;
            negative_result <= a[N-1] ^ b[N-1]; // XOR = true if signs differ
        end else if (busy) begin
            if (b_shift[0])
                acc <= acc + (a_abs << count);
            b_shift <= b_shift >> 1;
            count <= count + 1;

            if (count == N) begin
                result <= negative_result ? -acc : acc;
                done <= 1;
                busy <= 0;
            end
        end
    end
endmodule