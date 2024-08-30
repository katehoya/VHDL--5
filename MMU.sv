module MMU #(
    parameter int depth = 3,
    parameter int bit_width = 8,
    parameter int acc_width = 24,
    parameter int size = 3
)(
  /* verilator lint_off UNUSED */
    input logic				      clk,
    input logic				      control,
    input logic				      reset,
    input logic [(bit_width * depth) - 1 : 0] data_arr,
    input logic [(bit_width * depth) - 1 : 0] wt_arr,
    output logic [(acc_width * size) - 1 : 0] acc_out
);

    logic [bit_width - 1:0] data_out00, data_out01, data_out02;
    logic [bit_width - 1:0] data_out10, data_out11, data_out12;
    logic [bit_width - 1:0] data_out20, data_out21, data_out22;
    logic [bit_width - 1:0] wt_out00, wt_out01, wt_out02;
    logic [bit_width - 1:0] wt_out10, wt_out11, wt_out12;
    logic [bit_width - 1:0] wt_out20, wt_out21, wt_out22;
    logic [acc_width - 1:0] acc_out00, acc_out01, acc_out02;
    logic [acc_width - 1:0] acc_out10, acc_out11, acc_out12;
    logic [acc_width - 1:0] acc_out20, acc_out21, acc_out22;
   /* verilator lint_on UNUSED */

    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m00 (
        .clk(clk), .control(control), .reset(reset), .acc_in(24'b0), .acc_out(acc_out00), 
        .data_in(data_arr[7:0]), .wt_path_in(wt_arr[7:0]), .data_out(data_out00), .wt_path_out(wt_out00)
    );
    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m10 (
        .clk(clk), .control(control), .reset(reset), .acc_in(24'b0), .acc_out(acc_out10), 
        .data_in(data_out00), .wt_path_in(wt_arr[15:8]), .data_out(data_out10), .wt_path_out(wt_out10)
    );
    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m20 (
        .clk(clk), .control(control), .reset(reset), .acc_in(24'b0), .acc_out(acc_out20), 
        .data_in(data_out10), .wt_path_in(wt_arr[23:16]), .data_out(data_out20), .wt_path_out(wt_out20)
    );


    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m01 (
        .clk(clk), .control(control), .reset(reset), .acc_in(acc_out00), .acc_out(acc_out01), 
        .data_in(data_arr[15:8]), .wt_path_in(wt_out00), .data_out(data_out01), .wt_path_out(wt_out01)
    );
    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m11 (
        .clk(clk), .control(control), .reset(reset), .acc_in(acc_out10), .acc_out(acc_out11), 
        .data_in(data_out01), .wt_path_in(wt_out10), .data_out(data_out11), .wt_path_out(wt_out11)
    );
    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m21 (
        .clk(clk), .control(control), .reset(reset), .acc_in(acc_out20), .acc_out(acc_out21), 
        .data_in(data_out11), .wt_path_in(wt_out20), .data_out(data_out21), .wt_path_out(wt_out21)
    );


    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m02 (
        .clk(clk), .control(control), .reset(reset), .acc_in(acc_out01), .acc_out(acc_out02), 
        .data_in(data_arr[23:16]), .wt_path_in(wt_out01), .data_out(data_out02), .wt_path_out(wt_out02)
    );
    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m12 (
        .clk(clk), .control(control), .reset(reset), .acc_in(acc_out11), .acc_out(acc_out12), 
        .data_in(data_out02), .wt_path_in(wt_out11), .data_out(data_out12), .wt_path_out(wt_out12)
    );
    MAC #(.bit_width(bit_width), .acc_width(acc_width)) m22 (
        .clk(clk), .control(control), .reset(reset), .acc_in(acc_out21), .acc_out(acc_out22), 
        .data_in(data_out12), .wt_path_in(wt_out21), .data_out(data_out22), .wt_path_out(wt_out22)
    );



    always_ff @(posedge clk) begin
        acc_out <= {acc_out22, acc_out12, acc_out02};
    end

endmodule
