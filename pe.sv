module pe (
    input		clk,
    input		rst,
    input [7:0]		input_data,
    input [7:0]		weight,
    input [15:0]	accum_in,
    output logic [15:0]	accum_out
);
    logic [15:0] mul_result;
    logic [15:0] add_result;


    multiplier mult (
        .a(input_data),
        .b(weight),
        .result(mul_result)
    );

    adder add (
        .a(mul_result),
        .b(accum_in),
        .result(add_result)
    );

    always @(posedge clk) begin
        if (rst) begin
            accum_out <= 0;
        end else if (!rst) begin
            accum_out <= add_result;
        end
    end
endmodule
